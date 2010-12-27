//
//  InstrumentationController.h
//  LevousCore
//
//  Created by Rusty Zarse on 8/18/10.
//  Copyright 2010 LeVous, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LVInstrumentationController : NSObject {

}
+ (void)logWithFormat:(NSString *)formatString, ...;
+ (void)logInfo:(NSString *)message;
@end
