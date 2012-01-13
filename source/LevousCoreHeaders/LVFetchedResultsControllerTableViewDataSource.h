//
//  LVFetchedResultsControllerTableViewDataSource.h
//  LevousCore
//
//  Created by Rusty Zarse on 2/26/11.
//  Copyright 2011 LeVous, LLC. All rights reserved.
//


@interface LVFetchedResultsControllerTableViewDataSource : NSObject<NSFetchedResultsControllerDelegate, UITableViewDataSource> {
	NSFetchedResultsController *fetchedResultsController;
	NSArray *sortDescriptors;
}


@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSArray *sortDescriptors;
@property (nonatomic, retain) NSPredicate *fetchedResultsPredicate;
@property (nonatomic, retain) LVCoreDataManager *coreDataManager;
@property (nonatomic, copy) NSString *tableViewCellClassXibName;
@property (nonatomic, copy) NSString *tableViewCellReuseIdentifier;
@property (nonatomic, copy) NSString *fetchedEntityName;

- (void)sortByFieldKeyPath:(NSString *)sortFieldKeyPath ascending:(BOOL)ascending;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

@end
