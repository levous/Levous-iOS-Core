//
//  SimpleModel.m
//  SimpleData
//
//  Created by Brian Collins on 09-10-03.
//  Copyright 2009 Brian Collins. All rights reserved.
//

#import "SimpleModel.h"
#import "SimpleStore.h"
#import "NSString.h"
#import "NSMutableArray.h"

#define LOTS_OF_ARGS "@^v@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

@implementation SimpleModel


+ (id)findByObjectURI:(NSURL *)objectURI {    
    // Look up the user
    NSManagedObjectID *objectID = [SIMPLE_STORE.persistentStoreCoordinator managedObjectIDForURIRepresentation:objectURI];
    if (!objectID) {
        return nil;
    }
    
    id object = [SIMPLE_STORE.managedObjectContext objectWithID:objectID];
    if (![object isFault]) {
        return object;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@", objectID];
    NSArray *result = [self findWithPredicate:predicate limit:1];
    
    if (result && [result count] == 1) {
		return [result objectAtIndex:0];
	} 
    else {
        return nil;
    }
}


+ (id)findByObjectURIString:(NSString *)objectURI {
    return [self findByObjectURI:[NSURL URLWithString:objectURI]];
}


- (NSURL *)objectURI {
    return self.objectID.URIRepresentation;
}


- (NSString *)objectURIString {
    return [self.objectURI absoluteString];
}


+ (NSArray *)findAll {
	return [self findWithPredicate: [NSPredicate predicateWithFormat:@"1 = 1"]
							 limit: 0];
}


- (BOOL)save {
    return [SIMPLE_STORE save];
}


- (void)deleteObjectAndSave:(BOOL)save {
    [SIMPLE_STORE.managedObjectContext deleteObject:self];
    if (save) [self save];
}


- (BOOL)deleteObject {
    [SIMPLE_STORE.managedObjectContext deleteObject:self];
    return YES;
}


+ (BOOL)deleteAllObjects {
    NSArray *objects = [self findAll];
    NSManagedObjectContext *moc = SIMPLE_STORE.managedObjectContext;
    for (NSManagedObject *object in objects) {
        [moc deleteObject:object];
    }
    return [SIMPLE_STORE save];
}


+ (id)createWithAttributes:(NSDictionary *)attributes {
    NSManagedObjectContext *moc = SIMPLE_STORE.managedObjectContext;

    NSEntityDescription *entity = [NSEntityDescription entityForName:[self description] inManagedObjectContext:moc]; 
    id obj = [[self alloc] initWithEntity:entity insertIntoManagedObjectContext:moc];
    
    for (NSString *attr in attributes) {
        [obj setValue:[attributes objectForKey:attr] forKey:attr];
    }
    
    return [obj autorelease];
}


- (void)setAttributes:(NSDictionary *)attributes {
   [self setValuesForKeysWithDictionary:attributes];
}


+ (id)find:(id)obj inColumn:(NSString *)col {    
	NSArray *result = [self findWithPredicate: [NSPredicate predicateWithFormat:
												[NSString stringWithFormat:@"%@ = %%@", col], obj]
										limit: 1];
	if (result && [result count] > 0) {
		return [result objectAtIndex:0];
	} else {
		return nil;
	}
	
}


+ (id)findWithPredicate:(NSPredicate *)predicate limit:(NSUInteger)limit {
	return [self findWithPredicate:predicate limit:limit sortBy:nil];
}



+ (id)findWithPredicate:(NSPredicate *)predicate limit:(NSUInteger)limit sortBy:(NSMutableArray *)sortDescriptors {
    NSManagedObjectContext *moc = SIMPLE_STORE.managedObjectContext;

    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:[self description] inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
    request.sortDescriptors = sortDescriptors;
    
    [request setEntity:entityDescription];
    
    if (limit)
        request.fetchLimit = limit;
    
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    
	return array;
}


+ (NSArray *)forwardedMethods {
	return [NSArray arrayWithObjects:@"findBy", @"findAllBy", @"createWith",
			@"findOrCreateWith", nil];
}


+ (NSString *)willForward:(SEL)selector {
	NSString *sel = NSStringFromSelector(selector);
	for (NSString *key in [self forwardedMethods]) {
		if ([sel hasPrefix:key])
			return key;
	}
	return nil;
}


+ (NSMutableArray *)attributesForInvocation:(NSInvocation *)invocation withSelectorString:(NSString *)sel {
	NSArray *chunks = [[[NSStringFromSelector(invocation.selector) after:sel] uncapitalizedString] 
					   componentsSeparatedByString: @":"];
	NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:5];
	int i = 2;
	for (NSString *chunk in chunks) {
		if (![chunk isEqualToString:@""]) {
			id arg;
			[invocation getArgument:&arg atIndex:i++];
			[attributes addObject:chunk];
			[attributes addObject:arg];
		}
	}
	return attributes;
}


+ (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
	if ([self respondsToSelector:selector]) 
		return [super methodSignatureForSelector:selector];
	else if ([self willForward:selector]) 
		return [NSMethodSignature signatureWithObjCTypes:LOTS_OF_ARGS];
	else
		return nil;
}


+ (void)forwardInvocation:(NSInvocation *)invocation {
	NSString *sel;
	if ((sel = [self willForward:invocation.selector])) {
		NSArray *attrs = [self attributesForInvocation:invocation withSelectorString:sel];
		[invocation setArgument:&attrs atIndex:2];
		[invocation setSelector:NSSelectorFromString([NSString stringWithFormat:@"_%@:", sel])];
		[invocation invokeWithTarget:self];
	}
}


+ (id)_createWith:(NSMutableArray *)attributes {
    NSManagedObjectContext *moc = SIMPLE_STORE.managedObjectContext;

    NSEntityDescription *entity = [NSEntityDescription entityForName:[self description] inManagedObjectContext:moc];
    id obj = [[self alloc] initWithEntity:entity insertIntoManagedObjectContext:moc];
    while ([attributes count] > 0) {
        NSString *key = [attributes shift];
        [obj setValue:[attributes shift] forKey:key];
    }
	return [obj autorelease];	
}


+ (id)_findBy:(NSMutableArray *)attributes {
	return [self find:[attributes objectAtIndex:1] inColumn:[attributes objectAtIndex:0]];
}


+ (NSMutableArray *)sortDescriptorsFromAttributes:(NSMutableArray *)attributes {
	NSMutableArray *sortDescriptors = [NSMutableArray arrayWithCapacity:2];
	
	while ([attributes count] > 0) {
		NSString *sortBy = [attributes shift];
		
		if ([sortBy isEqualToString:@"sortByDescending"]) {
			[sortDescriptors addObject:[[[NSSortDescriptor alloc] initWithKey:[attributes shift] ascending:NO] autorelease]];
		} else if ([sortBy isEqualToString:@"sortBy"]) {
			[sortDescriptors addObject:[[[NSSortDescriptor alloc] initWithKey:[attributes shift] ascending:YES] autorelease]];
		} else { 
			@throw([NSException exceptionWithName:@"Unexpected Argument" reason:@"Bad sort descriptor" userInfo:nil]);
		}
	}
	
	return [sortDescriptors count] == 0 ? nil : sortDescriptors;
}


+ (id)_findAllBy:(NSMutableArray *)attributes {
	NSString *col = [attributes shift];
	id val = [attributes shift];
	
	return [self findWithPredicate:[NSPredicate predicateWithFormat:
									[NSString stringWithFormat:@"%@ = %%@", col], val]
							 limit:0
							sortBy:[self sortDescriptorsFromAttributes:attributes]];
}

+ (id)_findOrCreateWith:(NSMutableArray *)attributes {
	id obj;
	if ((obj = [self find:[attributes objectAtIndex:1] inColumn:[attributes objectAtIndex:0]])) 
		return obj;
	else 
		return [self _createWith:attributes];
}

@end
