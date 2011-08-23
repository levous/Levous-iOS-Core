//
//  NSManagedObject+Levous.h
//  LevousCore
//
//  Created by Rusty Zarse on 2/28/11.
//  Copyright 2011 LeVous, LLC. All rights reserved.
//


@interface NSManagedObject (Levous)
/***************************************************************************************************/
/**  Used for simple defaulted display text
 Default behavior will return the output of [NSObject description] truncated to 60 character       */
/***************************************************************************************************/
- (NSString *)lvDisplayText;
@end
