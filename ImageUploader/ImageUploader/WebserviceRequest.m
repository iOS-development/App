//
//  WebserviceRequest.m
//  ImageUploader
//
//  Copyright Time at Task Aps 2012. All rights reserved.
//

#import "WebserviceRequest.h"

@implementation WebserviceRequest

@synthesize httpHandler;
@synthesize requestType;
@synthesize requestDelegate;
@synthesize extraInfo;
@synthesize cachingMode;

- (void)dealloc {
    [httpHandler release];
    [super dealloc];
}

@end
