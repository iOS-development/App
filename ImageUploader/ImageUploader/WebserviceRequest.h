//
//  WebserviceRequest.h
//  ImageUploader
//
//  Copyright Time at Task Aps 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestResponseManager.h"

@class HttpManager;

@interface WebserviceRequest : NSObject {
    HttpManager *httpHandler;
    HTTPRequest requestType;
    id<RequestManagerDelegate> requestDelegate;
    NSObject *extraInfo;
    HTTPRequestCachingType cachingMode;
}

@property(nonatomic, retain)HttpManager *httpHandler;
@property HTTPRequest requestType;
@property(nonatomic, assign)id<RequestManagerDelegate> requestDelegate;
@property(nonatomic, assign)NSObject *extraInfo;
@property HTTPRequestCachingType cachingMode;

@end
