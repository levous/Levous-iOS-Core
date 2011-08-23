//
//  CoreDataManager.h
//  LevousCore
//
//  Created by Rusty Zarse on 12/23/2010.
//  Copyright 2010 Levous, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FilterSortInfo, SimpleStore;

@interface LVCoreDataManager : NSObject <NSFetchedResultsControllerDelegate>
{
	NSManagedObjectModel			*managedObjectModel;
	NSManagedObjectContext			*managedObjectContext;	    
	NSPersistentStoreCoordinator	*persistentStoreCoordinator;
	NSString						*dbFilePath;
	NSFetchedResultsController		*textResultsController;
	NSFetchedResultsController		*keywordResultsController;
	NSSet							*keywords;
	SimpleStore *simpleStore;
}

@property (nonatomic, retain, readonly) NSString *dbFilePath;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;


////////////////////////////////////////
// SINGLETONS
//
// The default instance that manages a shared context for most uses
//   When making edits that are volitile like a new bill, use an explicit
//   context.  Ensure that this class knows how to manage, merge and 
//   generally deal with these outstanding edits.  ie: if an edit is 
//   pending when the app shuts down, persist the in memory edit to file
//   and then check for these files upon init.  Encrypt these files, of
//   course.

+ (LVCoreDataManager *)instance;

////////////////////////////////////////

// init                 ////////////////////////////////////////
- (id)initWithDbName:(NSString *)dbName;

// wipe database
- (BOOL)wipeDatabaseFromDevice;

// context lifecycle    ////////////////////////////////////////
- (BOOL)commitPendingChanges:(NSError **)errorOrNil;
- (void)shutDownCoreData;

// generic helpers   //////////////////////////////////////////
- (NSFetchRequest *)fetchForEntityNamed:(NSString *)entityName;
- (NSArray *)executeFetch:(NSFetchRequest *)fetchRequest;
- (NSUInteger)getCountForEntity:(NSString *)entityName withPredicate:(NSPredicate *)predicate;
- (NSManagedObject *)getEntityNamed:(NSString *)entityName withTitle:(NSString *)title;
- (void)intializeModelWithTestData;

@end
