//
//  XMLManualParser.m
//  ImageUploader
//
//  Copyright Time at Task Aps 2012. All rights reserved.
//

#import "XMLManualParser.h"

int tagCount;

NSRange endRangeGlobal;

@implementation XMLManualParser

+(NSString *)getTagValue:(NSString *)tagName XMLContent:(NSString *)xmlContent {
	
	NSString *tagValue = @"";
	NSString *tagStartName = [NSString stringWithFormat:@"<%@>",tagName];
	NSString *tagEndName = [NSString stringWithFormat:@"</%@>",tagName];
	
	if(tagName && xmlContent && [xmlContent length] > [tagName length]) {
		
		NSRange tagStartRange = [xmlContent rangeOfString:tagStartName];
		NSRange tagEndRange = [xmlContent rangeOfString:tagEndName];
		
		if(tagStartRange.location != NSNotFound && tagEndRange.location != NSNotFound) {
			
			NSRange subStringRange;
			subStringRange.location = tagStartRange.location + tagStartRange.length;
			subStringRange.length = tagEndRange.location - subStringRange.location;
			
			tagValue = [xmlContent substringWithRange:subStringRange];
		}
	}
	return tagValue;
	
}

@end
