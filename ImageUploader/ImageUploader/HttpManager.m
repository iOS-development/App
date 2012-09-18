//
//  HttpManager.m
//  ImageUploader
//
//  Copyright Time at Task Aps 2012. All rights reserved.
//

#import "HttpManager.h"
#import "ApplicationData.h"
#import "WebserviceRequest.h"

@implementation HttpManager

@synthesize delegate;
@synthesize theResponseData;
@synthesize httpConnection;
@synthesize requestURL;
@synthesize userRequest;

- (void)cancelRequest {
    if(theResponseData) {
        [theResponseData release];
        theResponseData = nil;
    }
    [httpConnection cancel];
    [httpConnection release];
    httpConnection = nil;
    delegate = nil;
}

- (void)asynchronousRequestServerWithXMLPost:(NSString *)urlAddress PostData:(NSData *)postContent {
    
    self.requestURL = urlAddress;
    self.theResponseData = nil;
//    if(userRequest.cachingMode == kLoadLocallyFirst) {
//        self.theResponseData = (NSMutableData *)[[ApplicationData sharedInstance].userFileManager getContentForPath:requestURL];
//        if(self.theResponseData) {
//            [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(loadContentWithLocalData) userInfo:nil repeats:NO];
//            return;
//        }
//    }
    NSLog(@"URL : %@", urlAddress);
	self.theResponseData = [NSMutableData data];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self encodeStringForURL:urlAddress]]
		cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:120.0f];
    
    if(postContent) {
        [request setHTTPMethod:@"POST"];
        [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postContent];
    } else {
        [request setHTTPMethod:@"GET"];
    }
	
	NSURLConnection *conn;

	// alloc+init and start an NSURLConnection; release on completion/failure
	conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];	
	
	self.httpConnection = conn;
	[self.httpConnection start];
}

- (void)asynchronousRequestServerWithMultipartPost:(NSString *)urlAddress PostData:(NSData *)postContent Boundry:(NSString *)contentBoundry {
    
    self.requestURL = urlAddress;
	self.theResponseData = [NSMutableData data];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self encodeStringForURL:urlAddress]]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:180.0f];
    
    if(postContent) {
        [request setHTTPMethod:@"POST"];
        [request setValue:contentBoundry forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postContent];
    } else {
        [request setHTTPMethod:@"GET"];
    }
	
	NSURLConnection *conn;
    
	// alloc+init and start an NSURLConnection; release on completion/failure
	conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];	
	
	self.httpConnection = conn;
	[self.httpConnection start];
}

- (NSString *)encodeStringForURL:(NSString *)originalURL {
	NSMutableString *escaped = [[NSMutableString alloc] init];
	[escaped appendString:[originalURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];       
	return escaped;	
}

- (void)loadContentWithLocalData {
    if(self.delegate) {
		// call our delegate and tell it that our icon is ready for display
		[delegate connectionDidFinish:self];
	}
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	//DLog(@"Connection Started Loading");
    [self.theResponseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	self.theResponseData = nil;
    
    if(userRequest.cachingMode != kNoCaching) {
//        self.theResponseData = (NSMutableData *)[[ApplicationData sharedInstance].userFileManager getContentForPath:requestURL];
    }
    
    if(self.theResponseData) {
        if(self.delegate) {
            // call our delegate and tell it that our icon is ready for display
            [delegate connectionDidFinish:self];
        }
    } else {
        // Release the connection now that it's finished
        //self.httpConnection = nil;
        [delegate connectionDidFail:self];
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    CGFloat percent = ((CGFloat)totalBytesWritten)/totalBytesExpectedToWrite;
    [delegate percentageUploadingCompleted:percent Connection:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSString* response = [[NSString alloc] initWithData:self.theResponseData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Server Response : %@", response);
    // Release the connection now that it's finished
    //self.httpConnection = nil;
    if(userRequest.cachingMode != kNoCaching) {
//        [[ApplicationData sharedInstance].userFileManager setContentForPath:requestURL FileContent:self.theResponseData];
    }
    
	if(self.delegate) {
		// call our delegate and tell it that our icon is ready for display
		[delegate connectionDidFinish:self];
	}
}


- (void)dealloc {
	[self cancelRequest];
    [super dealloc];
}

@end
