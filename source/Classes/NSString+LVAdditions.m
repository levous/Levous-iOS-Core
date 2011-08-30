//
//  NSString+LVAdditions.m
//  LevousCore
//
//  Created by Rusty Zarse on 4/25/11.
//  Copyright 2011 LeVous, LLC. All rights reserved.
//

#import "NSString+LVAdditions.h"


@implementation NSString (LVAdditions)

/////////////////////////////////////////////////////
// format the given string as an ssn with dashes
- (NSString *)lvFormatAsSsn {
	NSUInteger len = [self length];
	NSUInteger charIdx;
	// declare and pad char array
	unichar    numericChars[9];
    
	for (charIdx = 0; charIdx < 9; charIdx++)
		numericChars[charIdx] = ' ';
    
	NSUInteger formattedStringIdx = 0;
	for (charIdx = 0; charIdx < len; charIdx++)
	{
		unichar c = [self characterAtIndex:charIdx];
		if (c >= '0' && c <= '9')
		{
			numericChars[formattedStringIdx++] = c;
		}
		// ensure itws not past the index
		if (formattedStringIdx == 9)
			break;
	}
    
	NSString *formattedString = [NSString stringWithFormat:@"%C%C%C-%C%C-%C%C%C%C",
	                             numericChars[0],
	                             numericChars[1],
	                             numericChars[2],
	                             numericChars[3],
	                             numericChars[4],
	                             numericChars[5],
	                             numericChars[6],
	                             numericChars[7],
	                             numericChars[8]
                                 ];
	NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@" -"];
	return [formattedString stringByTrimmingCharactersInSet:charSet];
}

//
- (NSString *)lvStringByCapitalizingFirstLetter {
	return [self stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[self substringToIndex:1] uppercaseString]];
}

// NSURL's stringByAddingPercentEscapesUsingEncoding: does not escape
// some characters that should be escaped in URL parameters, like ? and some others.
// We'll use CFURL to force the encoding of those
// NOTE: Amazon S3 handles the / char fine in the 'path' portion of a url, so it is left alone
//
// Reference: http://www.ietf.org/rfc/rfc3986.txt
const CFStringRef kCharsToForceEscape = CFSTR("!*'();:@&=+$,/?%#[]");
- (NSString *)lvStringByUrlEncoding {
	NSString    *resultStr = self;
    
	CFStringRef originalString = (CFStringRef)self;
	CFStringRef leaveUnescaped = NULL;
    
	CFStringRef escapedStr;
    
	escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
	                                                     originalString,
	                                                     leaveUnescaped,
	                                                     kCharsToForceEscape,
	                                                     kCFStringEncodingUTF8);
	if (escapedStr)
	{
		resultStr = [(id)CFMakeCollectable(escapedStr) autorelease];
	}
	return resultStr;
}

- (NSString *)lvStringByUrlDecoding {
	return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)lvStringByEncodingForInternalPath {
	// replace "/" with "\_" because NSURL incorrectly unencodes the path
	//   before breaking into path components and this breaks three20 navigation
	// then encode the result using url encoding
	return [[self stringByReplacingOccurrencesOfString:@"/" withString:@"\\_"] lvStringByUrlEncoding];
}

- (NSString *)lvStringByDecodingFromInternalPath {
	// unencode using url encoding, then replace "\_" with "/" (reverse stringByEncodingForInternalPath)
	return [[self lvStringByUrlDecoding] stringByReplacingOccurrencesOfString:@"\\_" withString:@"/"];
}

+ (NSString*)lvStringWithGeneratedUUID {
	CFUUIDRef uuidObj = CFUUIDCreate(nil); //create a new UUID
	//get the string representation of the UUID
	NSString  *uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
    
	CFRelease(uuidObj);
	return [uuidString autorelease];
}

+ (NSString*)lvStringIfHasValue:(NSString *)valueString orAlternateString:(NSString *)altString {
	if (valueString == nil || [valueString length] < 1)
	{
		return altString;
	}
	else
	{
		return valueString;
	}
}

/* //////////////
 * // trying to calculate a hash that will provide a reliable sorting numeric.  This is experimental and likely, nope, IS WRONG
 * - (NSUInteger)sortableHash{
 * int charCount = 50;
 * NSString *paddedValue = [self stringByPaddingToLength:charCount withString:@"0" startingAtIndex:0];
 * NSUInteger hash;
 * for (int idx = 0; idx < charCount; idx++) {
 *  unichar c = [paddedValue characterAtIndex:idx];
 *  // calculate the char raised to the power of the reverse index
 *  hash += ( (int)c * ( 10 * ( charCount - idx ) ) );
 * }
 * return hash;
 * }
 * ///////////////// */

- (CGFloat)lvFontSizeSingleWordSafeWithFont:(UIFont *)font constrainedToSize:(CGSize)size butNotSmallerThan:(CGFloat)minimumFontSize {
	CGFloat fontSize = [self lvFontSizeWithFont:font constrainedToSize:size butNotSmallerThan:minimumFontSize];
	UIFont  *newFont = [UIFont fontWithName:font.fontName size:fontSize];
    
	// Loop through words in string and resize to fit
	for (NSString *word in [self componentsSeparatedByString : @" "])
	{
		CGFloat width = [word sizeWithFont:newFont].width;
		while (width > size.width && width != 0)
		{
			fontSize--;
			newFont = [UIFont fontWithName:font.fontName size:fontSize];
			width   = [word sizeWithFont:newFont].width;
		}
	}
	return fontSize;
}

- (CGFloat)lvFontSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size minimumFontSize:(CGFloat)minFontSize maximumFontSize:(CGFloat)maxFontSize {
	CGFloat fontSize = minFontSize;
    
	font = [UIFont fontWithName:[font fontName] size:fontSize];
	CGFloat height = [self sizeWithFont:font constrainedToSize:CGSizeMake(size.width, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;
	while (height < size.height && fontSize < maxFontSize)
	{
		fontSize += 5;
		font      = [UIFont fontWithName:[font fontName] size:fontSize];
		height    = [self sizeWithFont:font constrainedToSize:CGSizeMake(size.width, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;
	}
    
	while (height > size.height && fontSize > minFontSize)
	{
		--fontSize;
		font   = [UIFont fontWithName:[font fontName] size:fontSize];
		height = [self sizeWithFont:font constrainedToSize:CGSizeMake(size.width, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;
	}
	return MIN(maxFontSize, MAX(minFontSize, fontSize));
}

- (CGFloat)lvFontSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size butNotSmallerThan:(CGFloat)minimumFontSize {
	// note: be sure to t	rim first, if appropriate.
	//   I would do it here but that might cause performance
	//   degradation and, heck, the space might be intentional
	CGFloat fontSize = [font pointSize];
	CGFloat height   = [self sizeWithFont:font constrainedToSize:CGSizeMake(size.width, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;
	UIFont  *newFont = font;
    
	//Increase font size while still room to go.  Jump by 5s.  break if insane
	while (height < size.height && height < 100)
	{
		fontSize += 2;
		newFont   = [UIFont fontWithName:font.fontName size:fontSize];
		height    = [self sizeWithFont:newFont constrainedToSize:CGSizeMake(size.width, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;
	}
	;
    
	//Reduce font size while too large, break if no height (empty string)
	while (height > size.height && fontSize >= minimumFontSize && height != 0)
	{
		fontSize--;
		newFont = [UIFont fontWithName:font.fontName size:fontSize];
		height  = [self sizeWithFont:newFont constrainedToSize:CGSizeMake(size.width, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;
	}
	;
    
	return fontSize;
}


@end
