//
//  LVStyleSheet.m
//  LevousCore
//
//  Created by Rusty Zarse on 1/2/11.
//  Copyright 2011 LeVous, LLC. All rights reserved.
//

#import "LVStyleSheet.h"


@implementation LVStyleSheet

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

- (UIColor *)subHeaderFontColor{
  return [UIColor darkGrayColor];
}
- (UIColor *)subHeaderFontShadowColor{
  return [UIColor whiteColor];
}

@end
