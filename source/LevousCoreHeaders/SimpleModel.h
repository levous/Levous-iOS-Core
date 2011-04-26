//
//  SimpleModel.h
//  SimpleData
//
//  Created by Brian Collins on 09-10-03.
//  Copyright 2009 Brian Collins. All rights reserved.
//
#import <CoreData/CoreData.h>

@interface SimpleModel : NSManagedObject {

}


@property (nonatomic, readonly) NSURL *objectURI;
@property (nonatomic, readonly) NSString *objectURIString;

+ (id)findByObjectURI:(NSURL *)objectURI;
+ (id)findByObjectURIString:(NSString *)objectURI;

+ (id)createWithAttributes:(NSDictionary *)attributes;

+ (id)findAll;
+ (id)find:(id)obj inColumn:(NSString *)col;
+ (id)findWithPredicate:(NSPredicate *)predicate limit:(NSUInteger)limit;
+ (id)findWithPredicate:(NSPredicate *)predicate limit:(NSUInteger)limit sortBy:(NSMutableArray *)sortCol;

+ (void)forwardInvocation:(NSInvocation *)invocation;

- (BOOL)save;
- (BOOL)deleteObject;
+ (BOOL)deleteAllObjects;
- (void)deleteObjectAndSave:(BOOL)save;

- (void)setAttributes:(NSDictionary *)attributes;

@end
