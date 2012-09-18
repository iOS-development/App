//
//  ImageUploaderAppDelegate.h
//  ImageUploader
//
//  Copyright Time at Task Aps 2012. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <LocalFileStorage/UserFileManager.h>

#define ImageDelegate ((ImageUploaderAppDelegate *)[[UIApplication sharedApplication] delegate])

@class ImageUploaderViewController;

@interface ImageUploaderAppDelegate : NSObject <UIApplicationDelegate> {
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ImageUploaderViewController *viewController;

+ (NSString *)getUUID;

@end
