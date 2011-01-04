//
//  LVStyleSheet.m
//  LevousCore
//
//  Created by Rusty Zarse on 1/2/11.
//  Copyright 2011 LeVous, LLC. All rights reserved.
//

#import "LVStyleSheet.h"


@implementation LVStyleSheet
@synthesize subHeaderTextStyle;
static LVStyleSheet *_sharedInstance;

+ (LVStyleSheet *)newDefaultStyleSheet{
  return [[LVStyleSheet alloc] init];
}

+ (LVStyleSheet *)instance{
  if( _sharedInstance == nil ){
    _sharedInstance = [LVStyleSheet newDefaultStyleSheet];
  }
  return _sharedInstance;
}

- (id)init{
 if (self == [super init]) {
   LVTextStyle *defaultSubHeaderTextStyle = [[LVTextStyle alloc] initWithFont:nil
                                                                 andTextColor:[UIColor blackColor] 
                                                           andBackgroundColor:nil 
                                                           andTextShadowColor:[UIColor whiteColor] 
                                                          andTextShadowOffset:CGSizeMake(0.5, 0.8) 
                                                                     andAlpha:0.8];
   [self setSubHeaderTextStyle:defaultSubHeaderTextStyle];
   [defaultSubHeaderTextStyle release];
 } 
  return self;
}

- (void)dealloc{
  [self setSubHeaderTextStyle:nil];
  [super dealloc]; 
}

@end
