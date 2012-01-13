//
//  UIImage+LVAdditions.m
//  LevousCore
//
//  Created by Rusty Zarse on 5/1/11.
//  Copyright 2011 LeVous, LLC. All rights reserved.
//

#import "UIImage+LVAdditions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage (LVAdditions)

+ (void)lvBeginImageContextWithSize:(CGSize)size
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(size, YES, 2.0);
        } else {
            UIGraphicsBeginImageContext(size);
        }
    } else {
        UIGraphicsBeginImageContext(size);
    }
}

+ (void)lvEndImageContext
{
    UIGraphicsEndImageContext();
}

+ (UIImage*)lvImageFromView:(UIView*)view
{
    [self lvBeginImageContextWithSize:[view bounds].size];
    BOOL hidden = [view isHidden];
    [view setHidden:NO];
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [self lvEndImageContext];
    [view setHidden:hidden];
    return image;
}

+ (UIImage*)lvImageFromView:(UIView*)view scaledToSize:(CGSize)newSize
{
    UIImage *image = [self lvImageFromView:view];
    if ([view bounds].size.width != newSize.width ||
        [view bounds].size.height != newSize.height) {
        image = [self lvImageWithImage:image scaledToSize:newSize];
    }
    return image;
}

+ (UIImage*)lvImageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    [self lvBeginImageContextWithSize:newSize];
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    [self lvEndImageContext];
    return newImage;
}

@end
