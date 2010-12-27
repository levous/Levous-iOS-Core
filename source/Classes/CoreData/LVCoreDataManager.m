//
//  CoreDataManager.m
//  LevousCore
//
//  Created by Rusty Zarse on 12/23/2010.
//  Copyright 2010 Levous, LLC. All rights reserved.//

#import "LVCoreDataManager.h"
#import "SimpleStore.h"

@interface LVCoreDataManager (private)
- (NSString *)applicationDocumentsDirectory;
- (void)handleFetchError:(NSError *)error forMethodNamed:(NSString *)methodName withMessage:(NSString *)message;
- (void)initializeDatabaseWithStartupData;
@end

@implementation LVCoreDataManager

@synthesize dbFilePath;
@synthesize fetchedResultsController=fetchedResultsController_;

#pragma mark -
#pragma mark Singleton
static LVCoreDataManager *_sharedInstance;
static BOOL loadingInitialData;

////////////////////////////////////////////////////////
+ (LVCoreDataManager *)instance{
	if( _sharedInstance == nil ){
		_sharedInstance = [[LVCoreDataManager alloc] init];
	}
	return _sharedInstance;
}



#pragma mark -
#pragma mark Initialization

////////////////////////////////////////////////////////
- (id)init{
	return [self initWithDbName:@"CoreDataModel.sqlite"];
}

////////////////////////////////////////////////////////
- (id)initWithDbName:(NSString *)dbName{
  
	BOOL doLoad;
	if( self == [super init] )
	{
		NSString *dbFileName = dbName;
		if( [dbName length] < 8 || [[dbName substringWithRange:NSMakeRange([dbName length] - 7, 7)] compare:@".sqlite"] != NSOrderedSame) dbFileName = [NSString stringWithFormat:@"%@.sqlite", dbName];
		// Check for an existing DB; this must happen BEFORE the MOC is setup, as that creates a DB if one is missing
		dbFilePath = [[[self applicationDocumentsDirectory] stringByAppendingPathComponent:dbFileName] retain]; // having trouble with this variable retaining...

    doLoad = [[NSFileManager defaultManager] fileExistsAtPath:dbFilePath] == NO;
    // initialize the store
    //simpleStore = [[SimpleStore alloc] initWithPath:dbFilePath];
    // share the managed object context
    //managedObjectContext = [simpleStore managedObjectContext];
		if (doLoad && !loadingInitialData) {
      
      LVLog(@"%@ DB not present, will be created upon save", dbName);
      [self initializeDatabaseWithStartupData];
      
		}
    
    //SimpleStore *store = 
    [SimpleStore storeWithPath:dbFilePath];
    
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidChange:) name:NSManagedObjectContextDidSaveNotification object:[self managedObjectContext]];

    
  }
	// although its not expected that init will set a static instance, for IMBills, this is the desired result
	if( _sharedInstance == nil ) LVLog( @"CoreDataManager alloc'd but no shared instance is in use.  \n  This may indicate incorrect use of CoreDataManager.\n  For most operations, we should be using [CoreDataManager instance]" );
	return self;
  
}


#pragma mark -
#pragma mark Wipe Database


////////////////////////////////////////////////////////
- (BOOL)wipeDatabaseFromDevice{
  NSError *error = nil;
  NSURL *dbUrl = [NSURL fileURLWithPath:[self dbFilePath]];
  BOOL success = ( [[NSFileManager defaultManager] removeItemAtURL:dbUrl error:&error]);
  if( error != nil ) {
    LVLog( @"Attempted to wipe database file but received error: %@", [error localizedDescription], nil );
    success = NO;
  }
  
  /*
   NSArray *stores = [persistentStoreCoordinator persistentStores];
   BOOL success = YES;
   
   
   for(NSPersistentStore *store in stores) {
   [persistentStoreCoordinator removePersistentStore:store error:&error];
   if( error != nil ) {
   IMLog( @"Attempted to wipe persistet store but received error: %@", [error localizedDescription], nil );
   success = NO;
   }
   success = ( [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:&error] && success );
   if( error != nil ) {
   IMLog( @"Attempted to wipe database file but received error: %@", [error localizedDescription], nil );
   success = NO;
   }
   }
   
   [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
   */
  return success;
}



#pragma mark -
#pragma mark Save

////////////////////////////////////////////////////////
- (BOOL)commitPendingChanges:(NSError **)errorOrNil {
    NSError *error = nil;
  // if no changes, then successful
	BOOL success = YES;
  if (managedObjectContext != nil && [managedObjectContext hasChanges]) {
    success = [managedObjectContext save:&error];
		if(!success){
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			LVLog(@"Unresolved error %@, %@", error, [error userInfo]);
			//abort();
    } 
  }
	errorOrNil = &error;
	return success;
}


#pragma mark -
#pragma mark Shutdown
////////////////////////////////////////////////////////
//  saves changes in the application's managed object context before the application terminates.
- (void)shutDownCoreData {
	
  NSError *error = nil;
  if (managedObjectContext != nil) {
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			LVLog(@"Unresolved error %@, %@", error, [error userInfo]);
			//abort();
    } 
  }
}


#pragma mark -
#pragma mark Core Data stack

/** ////////////////////////////////////////////////////////
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/** ////////////////////////////////////////////////////////
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/** ////////////////////////////////////////////////////////
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
  if (persistentStoreCoordinator != nil) {
    return persistentStoreCoordinator;
  }
	
  NSURL *storeUrl = [NSURL fileURLWithPath:dbFilePath];
	
	NSError *error = nil;
  persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		
    /*
     Replace this implementation with code to handle the error appropriately.
     
     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
     
     Typical reasons for an error here include:
     * The persistent store is not accessible;
     * The schema for the persistent store is incompatible with current managed object model.
     Check the error message to determine what the actual problem was.
     
     
     If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
     
     If you encounter schema incompatibility errors during development, you can reduce their frequency by:
     * Simply deleting the existing store:
     [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
     
     * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
     [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
     
     Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
     
     
     
		 */
		
#if TARGET_IPHONE_SIMULATOR && !defined(LC_ENCRYPTION_INFO)
		// if this is the simulator and the error is compat problem, blow it away
		if ([error code] == NSPersistentStoreIncompatibleVersionHashError) {
			[self wipeDatabaseFromDevice];
			if( [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error] ){
				return persistentStoreCoordinator;
			}
      
		}
#endif
		
		
		LVLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
  }    
	
  return persistentStoreCoordinator;
}

#pragma mark -
#pragma mark CoreData Helper Methods

///////////////////////////////////////////////////////////////
//   Helper method to create a fetch request in the current context for the entity name given
- (NSFetchRequest *)fetchForEntityNamed:(NSString *)entityName{
	NSFetchRequest *fetch = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entityDesc = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	[fetch setEntity:entityDesc];
	return fetch;
}

////////////////////////////////////////////////////////
- (NSArray *)executeFetch:(NSFetchRequest *)fetchRequest{
  NSError *error = nil;
  NSArray *results = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	if( error ){
    // is there a way to know who called this and pass that to the error handler?
		[self handleFetchError:error forMethodNamed:@"executeFetch" withMessage:@"Failed to fetch"];
	}
  return results;
}

////////////////////////////////////////////////////////
- (NSUInteger)getCountForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate{
  NSFetchRequest *request = [self fetchForEntityNamed:entityName];
  if( predicate != nil ) [request setPredicate:predicate];
  NSUInteger count =  [[self managedObjectContext] countForFetchRequest:request error:nil];
  return count;
}

////////////////////////////////////////////////////////
- (NSManagedObject *)getEntityNamed:(NSString *)entityName withTitle:(NSString *)title{
  NSFetchRequest *fetch = [self fetchForEntityNamed:entityName];
  [fetch setPredicate:[NSPredicate predicateWithFormat:@"title = %@", title]];
  NSArray *results = [[self managedObjectContext] executeFetchRequest:fetch error:nil];
  if( [results count] == 0 ) return nil;
  return (NSManagedObject *)[results objectAtIndex:0];
}


////////////////////////////////////////////////////////
// generic handling for errors when fetching.  logging and such
- (void)handleFetchError:(NSError *)error forMethodNamed:(NSString *)methodName withMessage:(NSString *)message{
  LVLog( @"FAILURE Fetch [CoreDataManager %@]\nmessage: %@\nerror:%@, %@", methodName, message, error, [error userInfo]);
}

#pragma mark -
#pragma mark CoreData CRUD Methods

#pragma mark -
#pragma mark Startup Data Initialization
- (void)initializeDatabaseWithStartupData{

  if( loadingInitialData ) return;
  // indicate that data is loading so it doesn't enter again
  loadingInitialData = YES;
  //#if TARGET_IPHONE_SIMULATOR && !defined(LC_ENCRYPTION_INFO)
  // if this is the simulator and first run, initialize with test data
  [self intializeModelWithTestData];
  //#endif
  loadingInitialData = NO;
  
}

- (void)intializeModelWithTestData{

	// save
	[self commitPendingChanges:nil];
	
}

#pragma mark -
#pragma mark Context Change Notification

-(void)contextDidChange:(NSNotification *)saveNotification {
  
  
  
  NSError *error = nil;
  if (![[self fetchedResultsController] performFetch:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
  }

    
}


#pragma mark -
#pragma mark NSFetchedResultsController Helper Methods



#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[super dealloc];
}


@end

