//
//  LVStyleSheet.h
//  LevousCore
//
//  Created by Rusty Zarse on 1/2/11.
//  Copyright 2011 LeVous, LLC. All rights reserved.
//


@interface LVStyleSheet : NSObject {

}
+ (LVStyleSheet *)instance;
+ (LVStyleSheet *)newDefaultStyleSheet;
- (UIColor *)subHeaderFontColor;
- (UIColor *)subHeaderFontShadowColor;

@end
