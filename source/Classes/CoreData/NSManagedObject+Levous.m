//
//  NSManagedObject+Levous.m
//  LevousCore
//
//  Created by Rusty Zarse on 2/28/11.
//  Copyright 2011 LeVous, LLC. All rights reserved.
//

#import "NSManagedObject+Levous.h"


@implementation NSManagedObject (Levous)

- (NSString *)lvDisplayText{
  // default behavior, use [NSObject description]
  NSString *displayText = [self description];
  // limit to max length
  if ([[self description] length] > 60) {
    return [displayText substringToIndex:60];
  }
  return displayText;
}
@end
