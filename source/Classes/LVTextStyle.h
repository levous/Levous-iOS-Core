//
//  LVTextStyle.h
//  LevousCore
//
//  Created by Rusty Zarse on 1/3/11.
//  Copyright 2011 LeVous, LLC. All rights reserved.
//



/** Simple Configuration for Defining Styled Text
 provides a simple data structure for defining details used to style text
 */
@interface LVTextStyle : NSObject {

}

@property(retain, nonatomic) UIColor  *backgroundColor;
@property(retain, nonatomic) UIFont   *font;
@property(retain, nonatomic) UIColor  *textColor;
@property(retain, nonatomic) UIColor  *textShadowColor;
@property(nonatomic) CGSize           textShadowOffset;
@property(nonatomic) CGFloat          alpha;

/** Helpful parameter rich init */
- (id) initWithFont:(UIFont *)aFont 
       andTextColor:(UIColor *)aTextColor 
 andBackgroundColor:(UIColor *)aBackgroundColor 
 andTextShadowColor:(UIColor *)aTextShadowColor
andTextShadowOffset:(CGSize)aTextShadowOffset           
           andAlpha:(CGFloat)aAlpha;

/**
 Applies the property values set on the LVTextStyle instance to the passed in UILabel instance
 */
- (void)applyStyleToLabel:(UILabel *)label;

@end
