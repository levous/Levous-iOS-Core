//
//  UIImage+LVAdditions.h
//  LevousCore
//
//  Created by Rusty Zarse on 5/1/11.
//  Copyright 2011 LeVous, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (LVAdditions)

+ (UIImage*)lvImageFromView:(UIView*)view;
+ (UIImage*)lvImageFromView:(UIView*)view scaledToSize:(CGSize)newSize;
+ (UIImage*)lvImageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

@end
