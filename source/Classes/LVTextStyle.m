//
//  LVTextStyle.m
//  LevousCore
//
//  Created by Rusty Zarse on 1/3/11.
//  Copyright 2011 LeVous, LLC. All rights reserved.
//

#import "LVTextStyle.h"


@implementation LVTextStyle
@synthesize backgroundColor, font, textColor, textShadowColor, textShadowOffset, alpha;

#pragma mark -
#pragma mark init

- (id)init{
  if (self == [super init]) {
    [self setAlpha:1.0];
  }
  return self;
}

- (id) initWithFont:(UIFont *)aFont 
              andTextColor:(UIColor *)aTextColor 
        andBackgroundColor:(UIColor *)aBackgroundColor 
        andTextShadowColor:(UIColor *)aTextShadowColor
       andTextShadowOffset:(CGSize)aTextShadowOffset           
                  andAlpha:(CGFloat)aAlpha{
  if (self == [self init]) {
    [self setFont:aFont];
    [self setTextColor:aTextColor];
    [self setBackgroundColor:aBackgroundColor];
    [self setTextShadowColor:aTextShadowColor];
    [self setTextShadowOffset:aTextShadowOffset];
    [self setAlpha:aAlpha];
  }
  return self;
}

#pragma mark -
#pragma mark apply styles methods

- (void)applyStyleToLabel:(UILabel *)label{
  // apply the property values if they were set.  
  if ([self backgroundColor] != nil) [label setBackgroundColor:[self backgroundColor]];
  if ([self textColor] != nil) [label setTextColor:[self textColor]];
  if ([self font] != nil) [label setFont:[self font]];
  if ([self textShadowColor] != nil) [label setShadowColor:[self textShadowColor]];
  // set shadow offset if not CGSizeZero
  if (!CGSizeEqualToSize([self textShadowOffset], CGSizeZero)) [label setShadowOffset:[self textShadowOffset]];
  // always set the alpha.  Defaults in init to 1.0
  [label setAlpha:[self alpha]];
}

#pragma mark -
#pragma mark cleanup

- (void)dealloc{
  [backgroundColor release];
  [font release];
  [textColor release];
  [textShadowColor release];
  
  [super dealloc];
}
   

@end
