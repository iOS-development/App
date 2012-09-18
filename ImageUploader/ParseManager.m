//
//  ParseManager.m
//  ImageUploader
//
//  Copyright Time at Task Aps 2012. All rights reserved.
//

#import "ParseManager.h"
#import "ApplicationData.h"
#import "XMLManualParser.h"

//Response Tags.
#define TAG_RESPONSE        @"response"
#define TAG_CODE            @"code"

@implementation ParseManager

+ (bool)parseGeneralResponse:(NSString *)xmlContent {
    ApplicationData *appdata = [ApplicationData sharedInstance];
	appdata.responseCode = [[XMLManualParser getTagValue:TAG_CODE XMLContent:xmlContent] intValue];
	return YES;
}

@end
