//
//  NSString+LVAdditions.h
//  LevousCore
//
//  Created by Rusty Zarse on 4/25/11.
//  Copyright 2011 LeVous, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (LVAdditions)

- (NSString *)lvFormatAsSsn;
- (NSString *)lvStringByCapitalizingFirstLetter;
- (NSString *)lvStringByUrlEncoding;
- (NSString *)lvStringByUrlDecoding;
- (NSString *)lvStringByEncodingForInternalPath;
- (NSString *)lvStringByDecodingFromInternalPath;
//- (NSUInteger)sortableHash;
- (CGFloat)lvFontSizeSingleWordSafeWithFont:(UIFont *)font constrainedToSize:(CGSize)size butNotSmallerThan:(CGFloat)minimumFontSize;
- (CGFloat)lvFontSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size butNotSmallerThan:(CGFloat)minimumFontSize;
- (CGFloat)lvFontSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size minimumFontSize:(CGFloat)minFontSize maximumFontSize:(CGFloat)maxFontSize;

+ (NSString *)lvStringWithGeneratedUUID;
+ (NSString *)lvStringIfHasValue:(NSString *)valueString orAlternateString:(NSString *)altString;


@end
