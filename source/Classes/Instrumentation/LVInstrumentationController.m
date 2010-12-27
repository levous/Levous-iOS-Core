//
//  LVInstrumentationController.m
//  LevousCore 
//
//  Created by Rusty Zarse on 8/18/10.
//  Copyright 2010 LeVous, LLC. All rights reserved.
//

#import "LVInstrumentationController.h"

@implementation LVInstrumentationController
+ (void)logWithFormat:(NSString *)formatString, ...
{	
  va_list args;
  va_start(args, formatString);
	NSLogv(formatString,args);
  va_end(args);
}

+ (void)logInfo:(NSString *)message
{	
	[LVInstrumentationController logWithFormat:message, nil];
}

@end
