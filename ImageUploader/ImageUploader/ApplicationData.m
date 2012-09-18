//
//  ApplicationData.m
//  ImageUploader
//
//  Copyright Time at Task Aps 2012. All rights reserved.
//

#import "ApplicationData.h"
#import <QuartzCore/QuartzCore.h>

static ApplicationData *applicationData = nil;

@implementation ApplicationData

@synthesize shouldLoadContentLocally;
@synthesize pathForImageAlreadyInLocal;
@synthesize isUploaded;
@synthesize fileManager;
@synthesize photoList;
@synthesize isViewLoadedFirstTime;
@synthesize lastScreen;
@synthesize galleryView;
@synthesize currentNetworkStatus;
@synthesize responseCode;

- (id)init {
    self = [super init];
	if(self) {
        fileManager = [[UserFileManager alloc] init];
        isUploaded = NO;
        isViewLoadedFirstTime = YES;
        NSFileManager *fileMngr = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Image.plist"];
        BOOL success = [fileMngr fileExistsAtPath:filePath];
        if(success) {
            photoList = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
        }
        else
        {
            photoList = [[NSMutableArray alloc] init];
        }
        // to check network status
        wifiReach = [[Reachability reachabilityWithHostName:@"www.google.com"] retain];
        [wifiReach startNotifer];
        galleryView = NO;
    }
	return self;
}

- (void)initialize {
    
}


+ (ApplicationData*)sharedInstance {
	
    if (applicationData == nil) {
		
        applicationData = [[super allocWithZone:NULL] init];
		[applicationData initialize];
		
    }
	
    return applicationData;
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

+ (void)setDefaultSettings {
	NSUserDefaults *userSettings = [NSUserDefaults standardUserDefaults];
	if([userSettings integerForKey:kUserSettingsStatus] != kDefaultUserSetting) {
		[userSettings setInteger:kDefaultUserSetting forKey:kUserSettingsStatus];
	}
}

- (void)dealloc {
	[super dealloc];
}

+ (void)setBorder:(UIView *)view Color:(UIColor *)color CornerRadius:(float)radius Thickness:(float)thickness {
	CALayer *viewLayer = [view layer];
	[viewLayer setMasksToBounds:YES];
	[viewLayer setCornerRadius:radius];
	[viewLayer setBorderWidth:thickness];
	[viewLayer setBorderColor:[color CGColor]];
}

- (BOOL)reachable {
    NetworkStatus internetStatus = [wifiReach currentReachabilityStatus];
    if(internetStatus == NotReachable) {
        return NO;
    }
    return YES;
}

@end