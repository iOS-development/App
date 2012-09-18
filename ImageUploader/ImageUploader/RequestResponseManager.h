//
//  RequestResponseManager.h
//  ImageUploader
//
//  Copyright Time at Task Aps 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpManager.h"

@protocol RequestManagerDelegate

-(void)requestCompleted:(HTTPRequest)requestType;
-(void)percentageUploaded:(CGFloat)percentage;

@end

@interface RequestResponseManager : NSObject<HTTPManagerDelegate> {
	NSMutableDictionary *requestQueque;
    NSMutableDictionary *urlQueque;
}

+(RequestResponseManager*)sharedInstance;

-(void)initialize;
-(NSString *)sendGetHttpRequest:(NSString *)requestURL RequestType:(HTTPRequest)request Delegate:(id<RequestManagerDelegate>)delegate ExtraInfoDetail:(NSObject *)extraInfo CacheOption:(HTTPRequestCachingType)cacheType;
-(NSString *)sendPostHttpRequest:(NSString *)requestURL RequestType:(HTTPRequest)request PostContent:(NSString *)xmlContent Delegate:(id<RequestManagerDelegate>)delegate ExtraInfoDetail:(NSObject *)extraInfo CacheOption:(HTTPRequestCachingType)cacheType;
-(NSString *)sendPostHttpMultipartRequest:(NSString *)requestURL RequestType:(HTTPRequest)request PostContent:(NSData *)content Boundry:(NSString *)contentBoundry Delegate:(id<RequestManagerDelegate>)delegate ExtraInfoDetail:(NSObject *)extraInfo CacheOption:(HTTPRequestCachingType)cacheType;
-(void)cancleRequestForURL:(NSString *)requestURL;

@end
