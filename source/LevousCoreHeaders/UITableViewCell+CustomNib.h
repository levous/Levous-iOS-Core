//
//  UITableViewCell+CustomNib.h
//  LevousCore
//
//  Created by Rusty Zarse on 12/23/2010.
//  Copyright 2010 Levous, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UITableViewCell (CustomNib)
+ (id)loadInstanceOfClass:(Class)class fromNibNamed:(NSString*)nibName withReuseIdentifier:(NSString *)reuseIdentifier;
+ (id)loadInstanceOfClass:(Class)class fromNibNamed:(NSString*)nibName withStyle:(UITableViewStyle)style andReuseIdentifier:(NSString *)reuseIdentifier;

@end


