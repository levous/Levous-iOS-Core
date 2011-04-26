//
//  LVStyleSheet.h
//  LevousCore
//
//  Created by Rusty Zarse on 1/2/11.
//  Copyright 2011 LeVous, LLC. All rights reserved.
//

#import "LVTextStyle.h"

@interface LVStyleSheet : NSObject {
}
/** The configured text style.  Needs to be retained by the consumer and is a pointer, not a copy. **/
@property(retain,nonatomic) LVTextStyle *subHeaderTextStyle;
+ (LVStyleSheet *)instance;
+ (LVStyleSheet *)newDefaultStyleSheet;


@end
