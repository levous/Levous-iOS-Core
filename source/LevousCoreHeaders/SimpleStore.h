//
//  SimpleStore.h
//  SimpleData
//
//  Created by Brian Collins on 09-10-03.
//  Copyright 2009 Brian Collins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define SIMPLE_STORE_KEY @"SimpleStore"
#define SIMPLE_STORE ((SimpleStore *)[SimpleStore currentStore])

@interface SimpleStore : NSObject {
	NSString *path;
	NSManagedObjectModel *managedObjectModel;    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSMutableArray *observers;
    NSMutableArray *threadInfos;
}

+ (SimpleStore *)currentStore;
+ (id)storeWithPath:(NSString *)p;
+ (void)deleteStoreAtPath:(NSString *)p;

- (unsigned long long)sizeOfStore;

- (id)initWithPath:(NSString *)p;

- (BOOL)save;
- (BOOL)close;
- (BOOL)saveAndClose;

- (void)cleanup;

@property (copy) NSString *path;

@property (readonly) NSManagedObjectModel *managedObjectModel;
@property (readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// MOCs are per-thread
@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (readonly) NSMutableArray *observers;
@property (readonly) NSMutableArray *threadInfos;

@end
