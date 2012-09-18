//
//  RequestResponseManager.m
//  ImageUploader
//
//  Copyright Time at Task Aps 2012. All rights reserved.
//

#import "RequestResponseManager.h"
#import "ApplicationData.h"
#import "WebserviceRequest.h"
#import "ParseManager.h"

static RequestResponseManager *requestResponseManager = nil;

@implementation RequestResponseManager

+ (RequestResponseManager*)sharedInstance {
	
    if (requestResponseManager == nil) {
        requestResponseManager = [[super allocWithZone:NULL] init];
		[requestResponseManager initialize];
    }
	
    return requestResponseManager;
}

- (void)initialize {
    requestQueque = [[NSMutableDictionary alloc] init];
    urlQueque = [[NSMutableDictionary alloc] init];
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedInstance] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (void)dealloc {
	[super dealloc];
}

- (NSString *)getKeyForURL:(NSString *)requestURL {
    for(NSString *key in [urlQueque keyEnumerator]) {
        if([requestURL isEqualToString:[urlQueque objectForKey:key]]) {
            return key;
        }
    }
    return NULL_STRING;
}

#pragma mark -
#pragma Send HTTP Get & Post Methods

- (NSString *)sendGetHttpRequest:(NSString *)requestURL RequestType:(HTTPRequest)request Delegate:(id<RequestManagerDelegate>)delegate ExtraInfoDetail:(NSObject *)extraInfo CacheOption:(HTTPRequestCachingType)cacheType {
    if([requestURL length] > 0) {
        NSString *key = NULL_STRING;
        WebserviceRequest *serverRequest = [requestQueque objectForKey:requestURL];
        if(!serverRequest) {
            serverRequest = [[WebserviceRequest alloc] init];
            HttpManager *httpManager = [[HttpManager alloc] init];
            httpManager.delegate = self;
            serverRequest.httpHandler = httpManager;
            serverRequest.requestType = request;
            serverRequest.requestDelegate = delegate;
            serverRequest.extraInfo = extraInfo;
            serverRequest.cachingMode = cacheType;
            httpManager.userRequest = serverRequest;
            key = [NSString stringWithFormat:@"%.2lf", [[NSDate date] timeIntervalSince1970]];
            [urlQueque setObject:requestURL forKey:key];
            [httpManager asynchronousRequestServerWithXMLPost:requestURL PostData:nil];
            [requestQueque setObject:serverRequest forKey:requestURL];
            [serverRequest release];
        } else {
            key = [self getKeyForURL:requestURL];
        }
        return key;
    }
    return NULL_STRING;
}

- (NSString *)sendPostHttpRequest:(NSString *)requestURL RequestType:(HTTPRequest)request PostContent:(NSString *)xmlContent Delegate:(id<RequestManagerDelegate>)delegate ExtraInfoDetail:(NSObject *)extraInfo CacheOption:(HTTPRequestCachingType)cacheType {
    if([requestURL length] > 0) {
        NSString *key = NULL_STRING;
        WebserviceRequest *serverRequest = [requestQueque objectForKey:requestURL];
        if(!serverRequest) {
            serverRequest = [[WebserviceRequest alloc] init];
            HttpManager *httpManager = [[HttpManager alloc] init];
            httpManager.delegate = self;
            serverRequest.httpHandler = httpManager;
            serverRequest.requestType = request;
            serverRequest.requestDelegate = delegate;
            serverRequest.extraInfo = extraInfo;
            serverRequest.cachingMode = cacheType;
            httpManager.userRequest = serverRequest;
            key = [NSString stringWithFormat:@"%.2lf", [[NSDate date] timeIntervalSince1970]];
            [urlQueque setObject:requestURL forKey:key];
            [httpManager asynchronousRequestServerWithXMLPost:requestURL PostData:[xmlContent dataUsingEncoding:NSUTF8StringEncoding]];
            [requestQueque setObject:serverRequest forKey:requestURL];
            [serverRequest release];
        } else {
            key = [self getKeyForURL:requestURL];
        }
        return key; 
    }
    return NULL_STRING;
}

- (NSString *)sendPostHttpMultipartRequest:(NSString *)requestURL RequestType:(HTTPRequest)request PostContent:(NSData *)content Boundry:(NSString *)contentBoundry Delegate:(id<RequestManagerDelegate>)delegate ExtraInfoDetail:(NSObject *)extraInfo CacheOption:(HTTPRequestCachingType)cacheType {
    if([requestURL length] > 0) {
        NSString *key = NULL_STRING;
        WebserviceRequest *serverRequest = [requestQueque objectForKey:requestURL];
        if(!serverRequest) {
            serverRequest = [[WebserviceRequest alloc] init];
            HttpManager *httpManager = [[HttpManager alloc] init];
            httpManager.delegate = self;
            serverRequest.httpHandler = httpManager;
            serverRequest.requestType = request;
            serverRequest.requestDelegate = delegate;
            serverRequest.extraInfo = extraInfo;
            serverRequest.cachingMode = cacheType;
            httpManager.userRequest = serverRequest;
            key = [NSString stringWithFormat:@"%.2lf", [[NSDate date] timeIntervalSince1970]];
            [urlQueque setObject:requestURL forKey:key];
            [httpManager asynchronousRequestServerWithMultipartPost:requestURL PostData:content Boundry:contentBoundry];
            [requestQueque setObject:serverRequest forKey:requestURL];
            [serverRequest release];
        } else {
            key = [self getKeyForURL:requestURL];
        }
        return key; 
    }
    return NULL_STRING;
}

- (void)cancleRequestForURL:(NSString *)requestURL {
    NSString *originalURL = [urlQueque objectForKey:requestURL];
    if(originalURL && [originalURL length] > 0) {
        requestURL = originalURL;
    }
    WebserviceRequest *serverRequest = [requestQueque objectForKey:requestURL];
    if(serverRequest) {
        [serverRequest.httpHandler cancelRequest];
        [requestQueque removeObjectForKey:requestURL];
    }
}

#pragma mark -
#pragma HTTPManagerDelegate protocol methods

- (void)connectionDidFail:(HttpManager *)theConnection {	
    
    [ApplicationData sharedInstance].responseCode = VM_SERVER_ERROR;
    WebserviceRequest *serverRequest = [requestQueque objectForKey:theConnection.requestURL];
    if(serverRequest) {
		[serverRequest.requestDelegate requestCompleted:serverRequest.requestType];
	}
    [requestQueque removeObjectForKey:theConnection.requestURL];
}

- (void)connectionDidFinish:(HttpManager *)theConnection {
    WebserviceRequest *serverRequest = [requestQueque objectForKey:theConnection.requestURL];    
    switch (serverRequest.requestType) {            
        case HTTPPicUploadRequest:
            [ParseManager parseGeneralResponse:[[NSString alloc] initWithData:theConnection.theResponseData encoding:NSUTF8StringEncoding]];
            break;
            
        case HTTPRegisterMailRequest:
            [ParseManager parseGeneralResponse:[[NSString alloc] initWithData:theConnection.theResponseData encoding:NSUTF8StringEncoding]];
            break;
            
        default:
			break;
	}
    
    if(serverRequest && serverRequest.requestDelegate) {
		[serverRequest.requestDelegate requestCompleted:serverRequest.requestType];
	}
    
    if([requestQueque objectForKey:theConnection.requestURL]) {
        [requestQueque removeObjectForKey:theConnection.requestURL];
    }
}

- (void)percentageUploadingCompleted:(CGFloat)percent Connection:(HttpManager *)theConnection {
    WebserviceRequest *serverRequest = [requestQueque objectForKey:theConnection.requestURL];    
    [serverRequest.requestDelegate percentageUploaded:percent];
}

@end