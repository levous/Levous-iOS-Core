//
//  SimpleStore.m
//  SimpleData
//
//  Created by Brian Collins on 09-10-03.
//  Copyright 2009 Brian Collins. All rights reserved.
//

#import "SimpleStore.h"
#import "NSString.h"
#import "UIApplication.h"

static SimpleStore *current = nil;

@implementation SimpleStore

@synthesize path;

- (void)dealloc {
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    [self cleanup];
    [observers release];
	[super dealloc];
}


- (id)initWithPath:(NSString *)p {
	if (self = [super init]) {
		self.path = p;
	}
	return self;
}


+ (SimpleStore *)currentStore {
    @synchronized(self) {
        return current;
    }
}


+ (NSString *)storePath:(NSString *)p {
	if (![p hasSubstring:@"/"])
		return [[UIApplication documentsDirectory] stringByAppendingPathComponent:p];
	else 
		return p;
}


+ (id)storeWithPath:(NSString *)p {
    @synchronized(self) {
#ifdef DEBUG
    NSAssert([[NSThread currentThread] isEqual:[NSThread mainThread]], @"SimpleData store operations must occur on the main thread");
#endif
        [current release];
        current = nil;
        current = [[SimpleStore alloc] initWithPath:[self storePath:p]];
        current.managedObjectContext;
        return current;
    }
}


+ (void)deleteStoreAtPath:(NSString *)p {	
    @synchronized(self) {
#ifdef DEBUG
    NSAssert([[NSThread currentThread] isEqual:[NSThread mainThread]], @"SimpleData store operations must occur on the main thread");
#endif
        NSError *error;
        if ([[NSFileManager defaultManager] removeItemAtPath:[self storePath:p] error:&error] == NO) {
#ifdef DEBUG
            NSLog(@"Failed to delete store %@: %@", p, error);
#endif
        }
        
        [[[NSThread currentThread] threadDictionary] removeObjectForKey:@"__SIMPLE_DATA_MOC__"];
        [current cleanup];
        [current release];
        current = nil;
    }
}


- (NSMutableArray *)observers {
    @synchronized(self) {
        if (observers) {
            return [[observers retain] autorelease];
        }
        
        observers = [[NSMutableArray alloc] init];
        return [[observers retain] autorelease];
    }
}

- (NSMutableArray *)threadInfos {
    @synchronized(self) {
        if (threadInfos) {
            return [[threadInfos retain] autorelease];
        }
        
        threadInfos = [[NSMutableArray alloc] init];
        return [[threadInfos retain] autorelease];
    }
}

- (void)clearThreadInfos {
    for (NSMutableDictionary *threadInfo in self.threadInfos) {
        [threadInfo removeObjectForKey:@"__SIMPLE_DATA_MOC__"];
    }
    [self.threadInfos removeAllObjects];
}


- (void)unregisterMOCNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    for (id observer in self.observers) {
        [nc removeObserver:observer];
    }
    [self.observers removeAllObjects];
}


- (void)cleanup {
    [self clearThreadInfos];
    [self unregisterMOCNotifications]; 
}

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	@synchronized(self) {
        NSMutableDictionary *threadInfo = [[NSThread currentThread] threadDictionary];
        
        NSManagedObjectContext *managedObjectContext = [threadInfo objectForKey:@"__SIMPLE_DATA_MOC__"];
        if (managedObjectContext != nil) {
            return managedObjectContext;
        }
        
        // Build and store the new context
        managedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
        [threadInfo setObject:managedObjectContext forKey:@"__SIMPLE_DATA_MOC__"];

        // Track it
        [self.threadInfos addObject:threadInfo];
        
        // Set up the context
        [managedObjectContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
        [managedObjectContext setMergePolicy:NSOverwriteMergePolicy];
        
        // If this is not main thread's context, then we need to listen for chanages and merge those into the main thread's context
        if ([[NSThread currentThread] isEqual:[NSThread mainThread]] == NO) {
            // Register for notifications, and do the actual work on the main thread's queue 
            id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:managedObjectContext queue:[NSOperationQueue mainQueue] usingBlock:^ (NSNotification *note) {
            
                 NSManagedObjectContext *mainManagedObjectContext = [[[NSThread mainThread] threadDictionary] objectForKey:@"__SIMPLE_DATA_MOC__"];
#ifdef DEBUG
                NSAssert([[NSThread currentThread] isEqual:[NSThread mainThread]], @"MOC merge notification must occur on main thread");
                NSAssert(mainManagedObjectContext != nil, @"MOC for main thread does not exist for merging");
                NSLog(@"Merging");
//                NSLog(@"Merging %@", note.userInfo);
#endif
                [mainManagedObjectContext mergeChangesFromContextDidSaveNotification:note];
                
            }];
            
            [self.observers addObject:observer];
        }
    
        return managedObjectContext;
    }
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    @synchronized(self) {
        if (managedObjectModel != nil) {
            return managedObjectModel;
        }
        managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
        return managedObjectModel;
    }
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    @synchronized(self) {	
        if (persistentStoreCoordinator != nil) {
            return persistentStoreCoordinator;
        }
        
        NSURL *storeUrl = [NSURL fileURLWithPath: self.path];
        
        NSError *error = nil;
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible
             * The schema for the persistent store is incompatible with current managed object model
             Check the error message to determine what the actual problem was.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }    
        
        return persistentStoreCoordinator;
    }
}


- (BOOL)save {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
	return managedObjectContext && [managedObjectContext hasChanges] && [managedObjectContext save:nil];
}


- (BOOL)saveAndClose {
#ifdef DEBUG
    NSAssert([[NSThread currentThread] isEqual:[NSThread mainThread]], @"SimpleData operations must occur on the main thread");
#endif
	return [self save] && [self close];
}


- (BOOL)close {
#ifdef DEBUG
    NSAssert([[NSThread currentThread] isEqual:[NSThread mainThread]], @"SimpleData operations must occur on the main thread");
#endif
	[[[NSThread currentThread] threadDictionary] removeObjectForKey:SIMPLE_STORE_KEY];
	[self release];
	return YES;
}


- (unsigned long long)sizeOfStore {
    NSError *error = nil;
    NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:self.path error:&error];
    return [attribs fileSize];
}


@end
