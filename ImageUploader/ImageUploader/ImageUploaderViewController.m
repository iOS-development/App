//
//  ImageUploaderViewController.m
//  ImageUploader
//
//  Copyright Time at Task Aps 2012. All rights reserved.
//


#import "ImageUploaderViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HttpManager.h"
#import "ImageUploaderAppDelegate.h"
#import "ImageUploaderUseViewController.h"
#import "ImageUploaderAppDelegate.h"
#import "ApplicationData.h"
#import "RequestResponseManager.h"

@implementation ImageUploaderViewController

- (void)dealloc {
    [btnBarUpload release];
    [imageScrollContainer release];
    [photoView release];
    [uploaderContainer release];
    [uploaderInnerContainer release];
    [uploaderTotalView release];
    [uploderCompletedView release];
    [lblUploadingState release];
    [btnCancel release];
    [fullScreenImageView release];
    [lblNoImages release];
    [navigationBar release];
    [btnUse release];
    [btnRetake release];
    [imgContainer release];
    [btnClose release];
    [overlayView release];
    [customCancelButton release];
    [customCaptureButton release];
    [lblTitle release];
    [btnBackCamera release];
    [activityView release];
    [super dealloc];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    photoList = [ApplicationData sharedInstance].photoList;
    
    [ApplicationData setBorder:uploaderInnerContainer Color:[UIColor blackColor] CornerRadius:15.0 Thickness:1.0];
    [ApplicationData setBorder:uploaderTotalView Color:[UIColor darkGrayColor] CornerRadius:7.0 Thickness:1.0];
    [ApplicationData setBorder:uploderCompletedView Color:[UIColor darkGrayColor] CornerRadius:7.0 Thickness:1.0];
    [ApplicationData setBorder:customCancelButton Color:[UIColor clearColor] CornerRadius:5.0 Thickness:1.0];
    [ApplicationData setBorder:customCaptureButton Color:[UIColor clearColor] CornerRadius:5.0 Thickness:1.0];
    uploadingList = [[NSMutableArray alloc] init];
    removePath = [[NSMutableArray alloc] init];    
    uploadImageIndex = 0;
    UIImage *newImage = [[UIImage imageNamed:@"whiteButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
    [btnCancel setBackgroundImage:newImage forState:UIControlStateNormal];
    [btnUse setBackgroundImage:newImage forState:UIControlStateNormal];
    [btnRetake setBackgroundImage:newImage forState:UIControlStateNormal];

    UIImage *newPressedImage = [[UIImage imageNamed:@"blueButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
    [btnCancel setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
    [btnUse setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
    [btnRetake setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
    
    [lblTitle setText:NSLocalizedString(@"lbl_Image_Uploader", @"lable title")];
    [btnBarUpload setTitle:NSLocalizedString(@"button_upload", @"button title")];
    [customCancelButton setTitle:NSLocalizedString(@"button_cancel", @"button title") forState:UIControlStateNormal];
//    [customCaptureButton setTitle:NSLocalizedString(@"button_camera", @"button title") forState:UIControlStateNormal];
    [btnCancel setTitle:NSLocalizedString(@"button_cancel", @"button title") forState:UIControlStateNormal];    
    [ApplicationData setBorder:customCaptureButton Color:[UIColor grayColor] CornerRadius:15.0 Thickness:1.0];
    isShowUploadAlert = NO;
    selectedImage = [[UIImage alloc] init];
    isNewPic = NO;
    isFullScreenMode = NO;
    isFullScreenModeUpload = NO;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"button_retake", @"button title") style:UIBarButtonItemStyleBordered target:nil action:nil];
	[self.navigationItem setBackBarButtonItem:backButton];
	[backButton release];
}

- (void)viewDidUnload {
    [btnBarUpload release];
    btnBarUpload = nil;
    [imageScrollContainer release];
    imageScrollContainer = nil;
    [photoView release];
    photoView = nil;
    [uploaderContainer release];
    uploaderContainer = nil;
    [uploaderInnerContainer release];
    uploaderInnerContainer = nil;
    [uploaderTotalView release];
    uploaderTotalView = nil;
    [uploderCompletedView release];
    uploderCompletedView = nil;
    [lblUploadingState release];
    lblUploadingState = nil;
    [btnCancel release];
    btnCancel = nil;
    [fullScreenImageView release];
    fullScreenImageView = nil;
    [lblNoImages release];
    lblNoImages = nil;
    [navigationBar release];
    navigationBar = nil;
    [btnUse release];
    btnUse = nil;
    [btnRetake release];
    btnRetake = nil;
    [imgContainer release];
    imgContainer = nil;
    [btnClose release];
    btnClose = nil;
    [overlayView release];
    overlayView = nil;
    [customCancelButton release];
    customCancelButton = nil;
    [customCaptureButton release];
    customCaptureButton = nil;
    [lblTitle release];
    lblTitle = nil;
    [btnBackCamera release];
    btnBackCamera = nil;
    [activityView release];
    activityView = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    ApplicationData *appdata = [ApplicationData sharedInstance];
    [UIApplication sharedApplication].applicationIconBadgeNumber = [appdata.photoList count];
    if([photoList count] > 0 && ((!isNewPic) || appdata.isUploaded)) {
        if(appdata.isUploaded) {
            [fullScreenImageView removeFromSuperview];
        }
        [fullScreenImageView removeFromSuperview];
        appdata.isUploaded = NO;
        [lblNoImages setHidden:YES];
        isNewPic = YES;
        [self showPhotoList];
    }
    
    if([photoList count] == 0 && appdata.isUploaded) {
        appdata.isUploaded = NO;
        [fullScreenImageView removeFromSuperview];
        [lblNoImages setHidden:NO];
    }
    
    
    //[self showEmailInputAlert];
    
    if(appdata.lastScreen == CameraScreen) {
        [self captureButtonPressed:nil];
        appdata.lastScreen = NoneScreen;
    }
    else if(appdata.lastScreen == GalleryScreen) {
        [self galleryButtonPressed:nil];
        appdata.lastScreen = NoneScreen;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    
    ApplicationData *appdata = [ApplicationData sharedInstance];
    if([photoList count] == 0 && appdata.isViewLoadedFirstTime) {
        // show camera at the starup of app
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
            [self openImagePickerWithSource:UIImagePickerControllerSourceTypeCamera];
        }
    }
    appdata.isViewLoadedFirstTime = FALSE;
    if(appdata.lastScreen == EmailRegisterScreen) {
        for (UIWindow* window in [UIApplication sharedApplication].windows) {
            NSArray* subviews = window.subviews;
            if ([subviews count] > 0) {
                if ([[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]]) {
                    [(UIAlertView *)[subviews objectAtIndex:0] setDelegate:self];
                    [(UIAlertView *)[subviews objectAtIndex:0] setTag:-299];
                }
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if([uploaderContainer superview] == self.view) {
        [self cancelButtonPressed];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (UIInterfaceOrientationIsPortrait(interfaceOrientation));
}

- (void)showPhotoList {
    [self.view addSubview:imageScrollContainer];
    float height = imageScrollContainer.frame.size.height;
    float width = imageScrollContainer.frame.size.width;
    int GRID_INNER_MARGIN = 8;
    int GRID_TOP_MARGIN = 8;
    int GRID_COLOMNS = 3;
	int cellWidth = 96;
	int cellHeight = 120;
	int x = GRID_TOP_MARGIN, y = GRID_TOP_MARGIN;
	
	int totalRows = [photoList count]/GRID_COLOMNS;
    if([photoList count]%GRID_COLOMNS != 0) {
        ++totalRows;
    }
    
    for(UIView *previewView in [imageScrollContainer subviews]) {
        [previewView setHidden:YES];
    }
    
    float totalHeight = totalRows*(cellHeight+GRID_INNER_MARGIN) + 3*GRID_TOP_MARGIN - GRID_INNER_MARGIN;
    if(totalHeight < height) {
        totalHeight = height;
    }
    
	imageScrollContainer.contentSize = CGSizeMake(width, totalHeight);
    for(int i=0;i<[photoList count]; ++i)
	{
        UIImage *photo = [[ApplicationData sharedInstance].fileManager getImageForPath:[photoList objectAtIndex:i]];
        UIView *previewContainer = (UIButton *)[imageScrollContainer viewWithTag:-(i+1)];
        if(!(previewContainer && [previewContainer isKindOfClass:[UIView class]])) {
            if ([[NSBundle mainBundle] loadNibNamed:@"PhotoView" owner:self options:nil] != nil) {
                previewContainer = photoView;
            }
            
            previewContainer.frame = CGRectMake(x, y, cellWidth, cellHeight);
            [imageScrollContainer addSubview:previewContainer];
        } 
        
        UIButton *selectButton = (UIButton *)[previewContainer viewWithTag:2];
        if([uploadingList indexOfObject:photo] != NSNotFound) {
            [selectButton setSelected:YES];
            [ApplicationData setBorder:previewContainer Color:[UIColor blackColor] CornerRadius:10.0 Thickness:2.0];
        } else {
            [selectButton setSelected:NO];
            [ApplicationData setBorder:previewContainer Color:[UIColor grayColor] CornerRadius:10.0 Thickness:1.0];
        }
        
        [previewContainer setHidden:NO];
        UIImageView *imgPhoto = (UIImageView *)[previewContainer viewWithTag:1];
		[imgPhoto setImage:photo];
		previewContainer.tag = -(i+1);
		
		x += (cellWidth + GRID_INNER_MARGIN);
		if((i+1) % GRID_COLOMNS == 0)
		{
			x = GRID_INNER_MARGIN;
			y += (cellHeight + GRID_INNER_MARGIN);
		}
	}
}

- (void)showImageSelectionOptions {
    UIActionSheet *actionSheet = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:NULL_STRING
                       delegate:self
                       cancelButtonTitle:nil
                       destructiveButtonTitle:NSLocalizedString(@"button_cancel",@"")
                       otherButtonTitles:NSLocalizedString(@"button_gallery",@""),NSLocalizedString(@"button_camera",@""),nil];
    } else {
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:NULL_STRING
                       delegate:self
                       cancelButtonTitle:nil
                       destructiveButtonTitle:NSLocalizedString(@"button_cancel",@"")
                       otherButtonTitles:NSLocalizedString(@"button_gallery",@""),nil];
    }
    actionSheet.tag = 1;
    actionSheet.alpha = 0.8;
	[actionSheet showInView:self.view]; // show from our tabbar view (pops up in the middle of the tabbar)
	[actionSheet release];
}

- (void)openImagePickerWithSource:(UIImagePickerControllerSourceType)sourceType {
    if(!isOverLayView) {
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType =  sourceType;
        if(sourceType == UIImagePickerControllerSourceTypeCamera) {
            imagePicker.showsCameraControls = NO;
            imagePicker.cameraOverlayView = overlayView;
        }
        imagePicker.delegate = self;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:imagePicker animated:YES];
        [imagePicker release];
    }
    else
    {
        UIImagePickerController *overlayImagePicker = [[UIImagePickerController alloc] init];
        overlayImagePicker.sourceType =  sourceType;
        overlayImagePicker.delegate = self;
        [imagePicker presentModalViewController:overlayImagePicker animated:YES];
        [UIApplication sharedApplication].statusBarHidden = NO;
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [overlayImagePicker release];
    }
}

- (void)showConfirmationAlert:(NSString *)title Content:(NSString *)bodyText {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:bodyText delegate:self cancelButtonTitle:NSLocalizedString(@"button_cancel", @"button") otherButtonTitles:NSLocalizedString(@"button_ok", @"button"), nil];
    [alert setContentMode:UIViewContentModeScaleAspectFit];	
	[alert show];	
	[alert release];
}

- (void)showAlert:(NSString *)title Content:(NSString *)bodyText {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:bodyText delegate:self cancelButtonTitle:NSLocalizedString(@"button_ok", @"button") otherButtonTitles:nil];
    [alert setContentMode:UIViewContentModeScaleAspectFit];	
    if([ApplicationData sharedInstance].lastScreen == EmailRegisterScreen) {
        alert.tag = -299;
    }
	[alert show];	
	[alert release];
}

- (void)sendImageUploadRequest {
    
    RequestResponseManager *requestManager = [RequestResponseManager sharedInstance];
    if(([uploadingList count] >= 1 /*&& [uploadingList count] > uploadImageIndex*/)) {
        NSString *imagePath = [removePath objectAtIndex:0];
        imagePath = [[imagePath componentsSeparatedByString:@"_"] objectAtIndex:0];
        NSString *requestURL = [NSString stringWithFormat:SERVER_URL, [ImageUploaderAppDelegate getUUID], imagePath];
       
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        CGRect viewFrame = uploaderTotalView.frame;
        viewFrame.size.width = 0;
        [uploderCompletedView setFrame:viewFrame];
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        NSMutableData *postbody = [NSMutableData data];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photo\"; filename=\"image.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        if(isFullScreenModeUpload) {
            [postbody appendData:[NSData dataWithData:UIImageJPEGRepresentation([uploadingList lastObject], 1.0)]];
            [lblUploadingState setHidden:YES];
        }
        else
        {
            [lblUploadingState setHidden:NO];
            [postbody appendData:[NSData dataWithData:UIImageJPEGRepresentation([uploadingList objectAtIndex:0], 1.0)]];
            [lblUploadingState setText:[NSString stringWithFormat:NSLocalizedString(@"lbl_upload", @"upload message"), uploadImageIndex+1, totalUploadingCount]];
        }
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        cancelURL = [requestManager sendPostHttpMultipartRequest:requestURL RequestType:HTTPPicUploadRequest PostContent:postbody Boundry:contentType Delegate:self ExtraInfoDetail:nil CacheOption:kNoCaching];
    } else {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [uploaderContainer removeFromSuperview];
    }
}

- (void)removeCompletedImages {
    if(isFullScreenModeUpload) {
        isFullScreenModeUpload = NO;
        [uploadingList removeLastObject];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Image.plist"];
        [[ApplicationData sharedInstance].fileManager setImageForPath:[removePath lastObject] FileContent:nil];
        [removePath removeLastObject];
        [photoList removeObjectAtIndex:selectedImageIndex];
        [photoList writeToFile:filePath atomically:YES];
        [UIApplication sharedApplication].applicationIconBadgeNumber = [photoList count];
        [fullScreenImageView removeFromSuperview];
    }
    else
    {
        if(uploadImageIndex > [uploadingList count]) {
            uploadImageIndex = [uploadingList count];
        }
        
        for(int i=uploadImageIndex-1;i>=0;--i) {
            UIImage *uploadImage = [uploadingList objectAtIndex:i];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Image.plist"];
            [[ApplicationData sharedInstance].fileManager setImageForPath:[removePath objectAtIndex:i] FileContent:nil];
            [photoList removeObject:[removePath objectAtIndex:i]];
            [removePath removeObjectAtIndex:i];
            [uploadingList removeObject:uploadImage];
            [photoList writeToFile:filePath atomically:YES];
            [UIApplication sharedApplication].applicationIconBadgeNumber = [photoList count];
        }
    }
    uploadImageIndex = 0;
    [self showPhotoList];
    if([uploadingList count] == 0) {
        [btnBarUpload setEnabled:NO];
    } else {
        [btnBarUpload setEnabled:YES];
    }
    if([photoList count] > 0) {
        [lblNoImages setHidden:YES];
    } else {
        [lblNoImages setHidden:NO];
    }
}

- (void)removeInterMediateCompletedImage {
    UIImage *uploadImage = [uploadingList objectAtIndex:0];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Image.plist"];
    [[ApplicationData sharedInstance].fileManager setImageForPath:[removePath objectAtIndex:0] FileContent:nil];
    [photoList removeObject:[removePath objectAtIndex:0]];
    [removePath removeObjectAtIndex:0];
    [uploadingList removeObject:uploadImage];
    [photoList writeToFile:filePath atomically:YES];
    [UIApplication sharedApplication].applicationIconBadgeNumber = [photoList count];
}

- (void)sendEmailSaveRequest:(NSString *)emailAddress {
    [activityView startAnimating];
    RequestResponseManager *requestManager = [RequestResponseManager sharedInstance];
    NSString *requestURL = [NSString stringWithFormat:EMAIL_SAVE_URL, [ImageUploaderAppDelegate getUUID], emailAddress];
    cancelURL = [requestManager sendGetHttpRequest:requestURL RequestType:HTTPRegisterMailRequest Delegate:self ExtraInfoDetail:nil CacheOption:kNoCaching];
}

- (void)showEmailInputAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"lbl_email", @"title") message:@"\n\n"
                                                   delegate:self cancelButtonTitle:NSLocalizedString(@"button_back", @"title") otherButtonTitles:NSLocalizedString(@"button_store", @"title"), nil];
    CGRect frame = CGRectZero;
    alert.tag = -199;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(14, 45, 255, 40);
    } else {
        frame = CGRectMake(15, 55, 55, 31);
    }
    UILabel *lblEmail = [[UILabel alloc] initWithFrame:frame];
    [lblEmail setTextColor:[UIColor whiteColor]];
    [lblEmail setText:@"Email:"];
    [lblEmail setOpaque:NO];
    [lblEmail setBackgroundColor:[UIColor clearColor]];
    [alert addSubview:lblEmail];
    
    frame = CGRectMake(70, 55, 185, 31);
    UITextField* txtEmail = [[UITextField alloc] initWithFrame:frame];
    
    txtEmail.borderStyle = UITextBorderStyleRoundedRect;
    txtEmail.textColor = [UIColor blackColor];
    txtEmail.textAlignment = UITextAlignmentCenter;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        txtEmail.font = [UIFont systemFontOfSize:18.0];
    } 
    
    [txtEmail setFont:[UIFont systemFontOfSize:14.0]];
    txtEmail.placeholder = @"example@domain.com";
    txtEmail.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
    
    txtEmail.keyboardType = UIKeyboardTypeEmailAddress;	// use the default type input method (entire keyboard)
    txtEmail.returnKeyType = UIReturnKeyDone;
    txtEmail.delegate = self;
    txtEmail.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
    [txtEmail setText:@""];
    txtEmail.tag = -99;
    
    alert.delegate = self;
    [alert addSubview:txtEmail];
    [txtEmail becomeFirstResponder];
    [alert show];
    [alert release];
}

#pragma mark -
#pragma mark UIButton Event Methods

- (IBAction)captureButtonPressed:(id)sender {
//    [self showImageSelectionOptions];
    [ApplicationData sharedInstance].galleryView = NO;
    isOverLayView = NO;
    if([activityView isAnimating]) {
        return;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        [self openImagePickerWithSource:UIImagePickerControllerSourceTypeCamera];
        isCameraView = YES;
    }
}

- (IBAction)uploadButtonPressed:(id)sender {
    if([activityView isAnimating]) {
        return;
    }
    
    if([uploadingList count] > 0) {
        uploadImageIndex = 0;
        totalUploadingCount = [removePath count];
        [self.view addSubview:uploaderContainer];
        [self sendImageUploadRequest];
    }
}

- (IBAction)selectButtonPressed:(id)sender {
    if([activityView isAnimating]) {
        return;
    }
    
    int photoIndex = -([sender superview].tag + 1);
    UIImage *imgSelect = [[ApplicationData sharedInstance].fileManager getImageForPath:[photoList objectAtIndex:photoIndex]];
    if([sender isSelected]) {
        [ApplicationData setBorder:[sender superview] Color:[UIColor grayColor] CornerRadius:10.0 Thickness:1.0];
        [sender setSelected:NO];
        [uploadingList removeObject:imgSelect];
        [removePath removeObject:[photoList objectAtIndex:photoIndex]];
    } else {
        [ApplicationData setBorder:[sender superview] Color:[UIColor blackColor] CornerRadius:10.0 Thickness:2.0];
        [sender setSelected:YES];
        [uploadingList addObject:imgSelect];
        [removePath addObject:[photoList objectAtIndex:photoIndex]];
    }
    if([removePath count] > 0) {
        [btnBarUpload setEnabled:YES];
    } else {
        [btnBarUpload setEnabled:NO];
    }
}

- (IBAction)deleteButtonPressed:(id)sender {
    if([activityView isAnimating]) {
        return;
    }
    
    deleteIndex = -([sender superview].tag + 1);
    [self showConfirmationAlert:NSLocalizedString(@"alert_title_confirm", @"title") Content:NSLocalizedString(@"alert_body_confirm", @"title")];
}

- (IBAction)cancelButtonPressed {
    if(isFullScreenMode) {
        [fullScreenImageView removeFromSuperview];
    }
    [[RequestResponseManager sharedInstance] cancleRequestForURL:cancelURL];
    [activityView stopAnimating];
    [uploaderContainer removeFromSuperview];
    [uploadingList removeAllObjects];
    [removePath removeAllObjects];
    [btnBarUpload setEnabled:NO];
    uploadImageIndex = 0;
    [self showPhotoList];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (IBAction)fullScreenImageButtonPressed:(id)sender {
    if([activityView isAnimating]) {
        return;
    }
    
    selectedImageIndex = -([sender superview].tag + 1);
    isFullScreenModeUpload = YES;
    isFullScreenMode = YES;
    [imgContainer setZoomScale:1.0 animated:NO];
    [btnUse setHidden:NO];
    [btnRetake setHidden:NO];
    UIImageView *img = (UIImageView *) [imgContainer viewWithTag:-1];
    [img setImage:[[ApplicationData sharedInstance].fileManager getImageForPath:[photoList objectAtIndex:-([sender superview].tag+1)]]];
    selectedImage = [img image];
    [ApplicationData sharedInstance].pathForImageAlreadyInLocal = [photoList objectAtIndex:-([sender superview].tag+1)];
    [btnClose setHidden:NO];
    [selectedImage retain];
    [imageScrollContainer removeFromSuperview];
    [fullScreenImageView setAlpha:1.0];
    [fullScreenImageView setFrame:CGRectMake(0, 44, 320, 416)];
    [self.view addSubview:fullScreenImageView];
    [uploadingList addObject:[[ApplicationData sharedInstance].fileManager getImageForPath:[photoList objectAtIndex:-([sender superview].tag+1)]]];
    [removePath addObject:[photoList objectAtIndex:-([sender superview].tag+1)]];
    [btnBarUpload setEnabled:YES];
}

- (IBAction)retakeButtonPressed:(id)sender {
    if([activityView isAnimating]) {
        return;
    }
    
    [self showImageSelectionOptions];
}

- (IBAction)useButtonPressed:(id)sender {
    if([activityView isAnimating]) {
        return;
    }
    
    ImageUploaderUseViewController *controller = [[ImageUploaderUseViewController alloc] init];
    controller.image = selectedImage;
    [self.navigationController pushViewController:controller animated:NO];
    [controller release];
}

- (IBAction)closeButtonPressed:(id)sender {
    if([activityView isAnimating]) {
        return;
    }
    
    isFullScreenModeUpload = NO;
    [fullScreenImageView setAlpha:0.0];
    [btnClose setHidden:YES];
    isFullScreenMode = NO;
    [imgContainer setZoomScale:1.0 animated:NO];
//    [self.view addSubview:navigationBar];
    [self.view addSubview:imageScrollContainer];
    [removePath removeLastObject];
    [uploadingList removeLastObject];
    [btnBarUpload setEnabled:NO];
}

- (IBAction)galleryButtonPressed:(id)sender {
    [ApplicationData sharedInstance].galleryView = YES;
    isOverLayView = NO;
    if([activityView isAnimating]) {
        return;
    }
    
    isCameraView = NO;
    [self openImagePickerWithSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)closeCameraButtonPressed:(id)sender {
    [ApplicationData sharedInstance].lastScreen = NoneScreen;
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)caputreCameraImageButtonPressed:(id)sender {
    if([activityView isAnimating]) {
        return;
    }
    
    [imagePicker takePicture];
}

- (IBAction)openGalleryViewButtonPressed:(id)sender {
    isOverLayView = YES;
    [self openImagePickerWithSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

#pragma mark -
#pragma mark UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1) {
        [self openImagePickerWithSource:UIImagePickerControllerSourceTypePhotoLibrary];
    } else if(buttonIndex == 2) {
        [self openImagePickerWithSource:UIImagePickerControllerSourceTypeCamera];
    }
}

#pragma mark -
#pragma UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    selectedImage = [selectedImage fixOrientation];
    CGSize size = selectedImage.size;
	CGFloat ratio = 0;
    
    if((selectedImage.size.height > MAX_IMAGE_HEIGHT) || (selectedImage.size.width > MAX_IMAGE_WIDTH)){
		if (size.width > size.height) {
			ratio = MAX_IMAGE_WIDTH / size.width;
		}
		else {
			ratio = MAX_IMAGE_HEIGHT / size.height;
		}
		CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
		
		UIGraphicsBeginImageContext(rect.size);
		[selectedImage drawInRect:rect];
		selectedImage = UIGraphicsGetImageFromCurrentImageContext();
	}
    
    [self useButtonPressed:nil];
    if(isCameraView) {
        [ApplicationData sharedInstance].lastScreen = CameraScreen;
    } else {
        [ApplicationData sharedInstance].lastScreen = GalleryScreen;
    }
    if(!isOverLayView) {
        [picker dismissModalViewControllerAnimated:YES];	
    }
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma UIAlertViewDelegate 

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == -299) {
        [self showEmailInputAlert];
        NSLog(@"Alert Found");
        return;
    }
    
    if(alertView.tag == -199) {
        if(buttonIndex == 1) {
            UITextField *txtEmail = (UITextField *)[alertView viewWithTag:-99];
            if(txtEmail && [txtEmail isKindOfClass:[UITextField class]]) {
                if([txtEmail.text length] > 0) {
                    [self sendEmailSaveRequest:txtEmail.text];
                }
                else
                {
                    [self showAlert:NSLocalizedString(@"alert_title_error", @"title") Content:NSLocalizedString(@"alert_body_emailerror", @"alert message")];
                }
            }
        }
        else
        {
            if([ApplicationData sharedInstance].galleryView) {
                [self galleryButtonPressed:nil];
            }
            else
            {
                [self captureButtonPressed:nil];
            }
        }
        return;
    }
    
    if([alertView.title isEqualToString:NSLocalizedString(@"alert_title_upload", @"alert title")]) {
        
        if(buttonIndex == 1) {
            [self.view addSubview:uploaderContainer];
            [self sendImageUploadRequest];
        }
    }
    else
    {
        if(buttonIndex == 1 && deleteIndex >= 0) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Image.plist"];
            [[ApplicationData sharedInstance].fileManager setImageForPath:[photoList objectAtIndex:deleteIndex] FileContent:nil];
            [photoList removeObjectAtIndex:deleteIndex];
            [photoList writeToFile:filePath atomically:YES];
            [UIApplication sharedApplication].applicationIconBadgeNumber = [photoList count];
            [self showPhotoList];
            if([photoList count] > 0) {
                [lblNoImages setHidden:YES];
            } else {
                
                [lblNoImages setHidden:NO];
            }
            
            if([uploadingList count] == 0) {
                [btnBarUpload setEnabled:NO];
            }
        }
        deleteIndex = -1;
    }
}

#pragma mark- 
#pragma mark ScrollViewDelegate Methods

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    [scrollView setScrollEnabled:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    return [imgContainer viewWithTag:-1];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)aScrollView withView:(UIView *)view atScale:(float)scale {
}

#pragma mark ReuqestManager Delegate Methods

- (void)requestCompleted:(HTTPRequest)requestType {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [activityView stopAnimating];
    [ApplicationData sharedInstance].lastScreen = NoneScreen;
    [uploaderContainer removeFromSuperview];
    
    switch ([ApplicationData sharedInstance].responseCode) {
        case VM_SUCCESS:
            if(requestType == HTTPRegisterMailRequest) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kEmailRegistered];
            }
            else
            {
                if(isFullScreenModeUpload) {
                    [self removeCompletedImages];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    
                    if(![[NSUserDefaults standardUserDefaults] boolForKey:kEmailRegistered]) {
                        [ApplicationData sharedInstance].lastScreen = EmailRegisterScreen;
                    }
                    
                    [self showAlert:NSLocalizedString(@"alert_title_success", @"title") Content:NSLocalizedString(@"alert_body_uploadsuccess", @"success message")];
                    return;
                }
                ++uploadImageIndex;
                if(totalUploadingCount > uploadImageIndex) {
                    [self removeInterMediateCompletedImage];
                    [self sendImageUploadRequest];
                } else {
                    [self removeCompletedImages];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    if(![[NSUserDefaults standardUserDefaults] boolForKey:kEmailRegistered]) {
                        [ApplicationData sharedInstance].lastScreen = EmailRegisterScreen;
                    }
                    [self showAlert:NSLocalizedString(@"alert_title_success", @"title") Content:NSLocalizedString(@"alert_body_uploadsuccess", @"success message")];
                }
            }
            break;
            
        case VM_SERVER_ERROR:
            [self showAlert:NSLocalizedString(@"alert_title_error", @"title") Content:NSLocalizedString(@"alert_body_uploaderror", @"success message")];
            break;

        case VM_NOTVALID_EMAIL_ERROR:
            [self showAlert:NSLocalizedString(@"alert_title_error", @"title") Content:NSLocalizedString(@"alert_body_emailreg_fail", @"alert msg")];
            break;
    }
}

- (void)percentageUploaded:(CGFloat)percentage {
    CGRect viewFrame = uploaderTotalView.frame;
    viewFrame.size.width = viewFrame.size.width*percentage;
    [uploderCompletedView setFrame:viewFrame];
}

@end
