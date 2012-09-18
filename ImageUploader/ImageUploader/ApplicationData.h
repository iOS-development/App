//
//  ApplicationData.h
//  ImageUploader
//
//  Copyright Time at Task Aps 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LocalFileStorage/UserFileManager.h>
#import "Reachability.h"

@interface ApplicationData : NSObject {
    BOOL shouldLoadContentLocally;
    UserFileManager *fileManager;

    //To specify the response from server for the request.
    HTTPResponseCode responseCode;

    //To specify whether image uploaded or not.
    BOOL isUploaded;

    //Path of the image already available in local.
    NSString *pathForImageAlreadyInLocal;

    //Store the list of photos.
    NSMutableArray *photoList;
    
    // To check newtwork status
    Reachability* wifiReach;
    NetworkStatus currentNetworkStatus;
    BOOL isViewLoadedFirstTime;

    //To specify the last selected screen.
    SelectedScreen lastScreen;
    
    //To check whether gallery view or camera view.
    BOOL galleryView;
}

@property BOOL shouldLoadContentLocally;
@property (nonatomic, retain) UserFileManager *fileManager;
@property BOOL isUploaded;
@property (nonatomic, retain) NSString *pathForImageAlreadyInLocal;
@property (nonatomic, retain) NSMutableArray *photoList;
@property (nonatomic, assign) NetworkStatus currentNetworkStatus;
@property SelectedScreen lastScreen;
@property BOOL isViewLoadedFirstTime;
@property BOOL galleryView;
@property HTTPResponseCode responseCode;

//Create the single instance in the app.
+ (ApplicationData*)sharedInstance;

//For default settings.
+ (void)setDefaultSettings;

//To set the border, corner radius of views.
+ (void)setBorder:(UIView *)view Color:(UIColor *)color CornerRadius:(float)radius Thickness:(float)thickness;

//To check availability of network.
- (BOOL)reachable;

@end