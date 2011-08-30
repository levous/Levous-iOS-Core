//
//  LVFetchedResultsControllerTableViewDataSource.m
//  LevousCore
//
//  Created by Rusty Zarse on 2/26/11.
//  Copyright 2011 LeVous, LLC. All rights reserved.
//

#import "LVFetchedResultsControllerTableViewDataSource.h"
#import "NSManagedObject+Levous.h"
#import "UITableViewCell+CustomNib.h"

@interface LVFetchedResultsControllerTableViewDataSource (Private)

- (NSFetchedResultsController *)createFetchedResultsControllerForEntityNamed:(NSString *)entityName;

@end

@implementation LVFetchedResultsControllerTableViewDataSource

#pragma mark -
#pragma mark Properties

@synthesize tableViewCellClassXibName, tableViewCellReuseIdentifier, coreDataManager, fetchedEntityName, \
fetchedResultsPredicate;

- (id)fetchedResultsController{
	if (fetchedResultsController == nil && [self fetchedEntityName]) {
		[self setFetchedResultsController:[self createFetchedResultsControllerForEntityNamed:[self fetchedEntityName]]];
		
		NSError *error = nil;
		if (![[self fetchedResultsController] performFetch:&error])
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		}
		
	}
	return fetchedResultsController;
}

- (void)setFetchedResultsController:(id)newFetchedResultsController{
	id oldFRC = fetchedResultsController;
	fetchedResultsController = [newFetchedResultsController retain];
	[oldFRC release];
}

- (id)sortDescriptors{
	return sortDescriptors;
}

- (void)setSortDescriptors:(id)newSortDescriptors{
	id oldSortDescriptors = sortDescriptors;
	sortDescriptors = [newSortDescriptors retain];
	[oldSortDescriptors release];
	// nil out the frc because sort descripto change requires a new fetch.
	// this will cause the frc to re-init
	[self setFetchedResultsController:nil];
}


- (void)sortByFieldKeyPath:(id)sortFieldKeyPath ascending:(BOOL)ascending{
	[self setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:sortFieldKeyPath ascending:ascending]]];
}

#pragma mark -
#pragma mark Cleanup
- (void)dealloc{
	[fetchedResultsController release], fetchedResultsController = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Init

- (id)init{
	if (self == [super init]) {
		[self setTableViewCellReuseIdentifier:@"Cell"];
	}
	return self;
}



#pragma mark -
#pragma mark NSFetchedResultsController helper methods

- (NSFetchedResultsController *)createFetchedResultsControllerForEntityNamed:(NSString *)entityName {
	if(![NSThread isMainThread]) {
		LVLogError(@"messaged [LVFetchedResultsControllerTableViewDataSource createFetchedResultsControllerForEntityNamed] while NOT on the UI thread.  This is likely not a safe operation");
	}
	
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[self coreDataManager] fetchForEntityNamed:entityName];
	
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[[self coreDataManager] managedObjectContext]];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// set the filter predicate
	//[fetchRequest setPredicate:[self generateSomeDefaultPredicate]];
	
	// set sort
	[fetchRequest setSortDescriptors:[self sortDescriptors]];
	
	// set sectionNameKeyPath
	NSString *sectionNameKeyPath = nil;
	
	// Edit the section name key path and cache name if appropriate.
	// nil for section name key path means "no sections".
	NSFetchedResultsController *newFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								  managedObjectContext:[[self coreDataManager] managedObjectContext]
																									sectionNameKeyPath:sectionNameKeyPath // this key defines the sections
																											 cacheName:entityName]; 
	return [newFetchedResultsController autorelease];
}

#pragma mark -
#pragma mark UITableViewDataSource delegate methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *managedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	if ([cell respondsToSelector:@selector(configureCellWithEntity:)]) {
		[cell performSelector:@selector(configureCellWithEntity:) withObject:managedObject];
	}else {
		[[cell textLabel] setText:[managedObject lvDisplayText]];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	NSString *reuseIdentifier = [self tableViewCellReuseIdentifier];
	if (reuseIdentifier == nil) reuseIdentifier = @"Cell1";
	//id cellInstance = class_createInstance(NSClassFromString(@"your class name"), 0/*extra bytes*/);
	cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (cell == nil) {
		if( [self tableViewCellClassXibName] != nil ){
			cell = [UITableViewCell loadInstanceOfClass:[UITableViewCell class] 
										   fromNibNamed:[self tableViewCellClassXibName]
									withReuseIdentifier:reuseIdentifier];
		}else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
		}
		
	}
	
	
	// Configure the cell.
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSLog(@"%i sections", [[[self fetchedResultsController] sections] count] );
	return [[[self fetchedResultsController] sections] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	/*
	 NSMutableArray *indexArray = [[[NSMutableArray alloc] initWithArray:[[self fetchedResultsController] sectionIndexTitles]] autorelease];
	 [indexArray insertObject:UITableViewIndexSearch atIndex:0];
	 return indexArray;
	 */
	return [[self fetchedResultsController] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return [[self fetchedResultsController ] sectionForSectionIndexTitle:title atIndex:index];
	/*if (title == UITableViewIndexSearch) {
	 // if magnifying glass
	 [tableView scrollRectToVisible:self.searchDisplayController.searchBar.frame animated:NO];
	 return -1;
	 }
	 return [[self fetchedResultsController ] sectionForSectionIndexTitle:title atIndex:index - 1]; // subtract 1 due to search idx*/
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}


@end
