//
//  HttpManager.h
//  ImageUploader
//
//  Copyright Time at Task Aps 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HTTPManagerDelegate;
@class WebserviceRequest;

@interface HttpManager : NSObject {
	NSMutableURLRequest *theRequest;
	NSURLConnection *httpConnection;
	NSMutableData *theResponseData;
	id<HTTPManagerDelegate> delegate;
    NSString *requestURL;
    WebserviceRequest *userRequest;
    NSData *postData;
}

@property (nonatomic, retain)id<HTTPManagerDelegate> delegate;
@property (nonatomic, retain)NSMutableData *theResponseData;
@property (nonatomic, retain)NSURLConnection *httpConnection;
@property (nonatomic, assign)NSString *requestURL;
@property (nonatomic, assign)WebserviceRequest *userRequest;

-(void)asynchronousRequestServerWithXMLPost:(NSString *)urlAddress PostData:(NSData *)postContent;
-(void)asynchronousRequestServerWithMultipartPost:(NSString *)urlAddress PostData:(NSData *)postContent Boundry:(NSString *)contentBoundry;
-(NSString *)encodeStringForURL:(NSString *)originalURL;
-(void)cancelRequest;
-(void)loadContentWithLocalData;

@end

@protocol HTTPManagerDelegate

- (void) connectionDidFail:(HttpManager *)theConnection;
- (void) connectionDidFinish:(HttpManager *)theConnection;

@optional
- (void) percentageUploadingCompleted:(CGFloat)percent Connection:(HttpManager *)theConnection;

@end

