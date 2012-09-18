//
//  ImageUploaderUseViewController.m
//  ImageUploader
//
//  Copyright Time at Task Aps 2012. All rights reserved.
//

#import "ImageUploaderUseViewController.h"
#import "ImageUploaderAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageUploaderAppDelegate.h"
#import "ApplicationData.h"
#import "RequestResponseManager.h"

@implementation ImageUploaderUseViewController

@synthesize image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [imgToUse release];
    [uploadContainer release];
    [uploadInnerContainer release];
    [lblTotal release];
    [lblUploaded release];
    [activityView release];
    [btnCancel release];
    [btnSelectedCategory release];
    [overlayView release];
    [cutomCancelButton release];
    [customCameraButton release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:NSLocalizedString(@"title_save_image", @"title")];
    [imgToUse setImage:image];
    btnSave = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"button_save", @"button title") style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed)];
    [self.navigationItem setRightBarButtonItem:btnSave];
    [btnSave setEnabled:NO];
    
    btnRetake = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"button_retake", @"button title") style:UIBarButtonItemStyleDone target:self action:@selector(retakeButtonPressed)];
//    [self.navigationItem setLeftBarButtonItem:btnRetake];
    
    imgCategoryList = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ImageCategory" ofType:@"plist"]];
    [ApplicationData setBorder:uploadInnerContainer Color:[UIColor blackColor] CornerRadius:15.0 Thickness:1.0];
    [ApplicationData setBorder:lblTotal Color:[UIColor darkGrayColor] CornerRadius:7.0 Thickness:1.0];
    [ApplicationData setBorder:lblUploaded Color:[UIColor darkGrayColor] CornerRadius:7.0 Thickness:1.0];
    [ApplicationData setBorder:customCameraButton Color:[UIColor clearColor] CornerRadius:5.0 Thickness:1.0];
    [ApplicationData setBorder:cutomCancelButton Color:[UIColor clearColor] CornerRadius:5.0 Thickness:1.0];
    UIImage *newImage = [[UIImage imageNamed:@"whiteButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
    [btnCancel setBackgroundImage:newImage forState:UIControlStateNormal];
    [btnSelectedCategory setBackgroundImage:newImage forState:UIControlStateNormal];
    
    UIImage *newPressedImage = [[UIImage imageNamed:@"blueButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
    [btnCancel setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
    [btnSelectedCategory setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
    
    [cutomCancelButton setTitle:NSLocalizedString(@"button_cancel", @"button title") forState:UIControlStateNormal];
    [customCameraButton setTitle:NSLocalizedString(@"button_camera", @"button title") forState:UIControlStateNormal];
    [btnCancel setTitle:NSLocalizedString(@"button_cancel", @"button title") forState:UIControlStateNormal];    
    
    isAdded = NO;
    selectedCategoryIndex = -1;
}

- (void)viewDidUnload {
    [imgToUse release];
    imgToUse = nil;
    [uploadContainer release];
    uploadContainer = nil;
    [uploadInnerContainer release];
    uploadInnerContainer = nil;
    [lblTotal release];
    lblTotal = nil;
    [lblUploaded release];
    lblUploaded = nil;
    [activityView release];
    activityView = nil;
    [btnCancel release];
    btnCancel = nil;
    [btnSelectedCategory release];
    btnSelectedCategory = nil;
    [overlayView release];
    overlayView = nil;
    [cutomCancelButton release];
    cutomCancelButton = nil;
    [customCameraButton release];
    customCameraButton = nil;
    image = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
}

- (IBAction)selectCategoryButtonPressed:(id)sender {
//    [self showActionSheetWithPicker];
    if(selectedCategoryIndex >= 0) {
        [ApplicationData setBorder:[self.view viewWithTag:-(selectedCategoryIndex+1)] Color:[UIColor clearColor] CornerRadius:0 Thickness:0.0];
    }
    selectedCategoryIndex = -[sender tag] - 1;
    [ApplicationData setBorder:sender Color:[UIColor whiteColor] CornerRadius:0 Thickness:2.0];
    [btnSave setEnabled:YES];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [[RequestResponseManager sharedInstance] cancleRequestForURL:cancleURL];
    [activityView stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [uploadContainer removeFromSuperview];
    [ApplicationData sharedInstance].lastScreen = NoneScreen;
    [ApplicationData sharedInstance].isUploaded = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)retakeButtonPressed {
    [self openImagePickerWithSource:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)cancleCameraViewButtonPressed:(id)sender {
    [imagePicker dismissModalViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)caputreCameraButtonPressed:(id)sender {
    [imagePicker takePicture];
}

- (void)saveButtonPressed {
    if([activityView isAnimating]) {
        return;
    }
    self.navigationItem.hidesBackButton = YES;
    [btnRetake setEnabled:NO];
    [self.view addSubview:uploadContainer];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self saveImageLocally];
    RequestResponseManager *requestManager = [RequestResponseManager sharedInstance];
    NSString *imagePath = [[ApplicationData sharedInstance].photoList lastObject];
    imagePath = [[imagePath componentsSeparatedByString:@"_"] objectAtIndex:0];
    NSString *requestURL = [NSString stringWithFormat:SERVER_URL, [ImageUploaderAppDelegate getUUID], imagePath];
    CGRect viewFrame = lblTotal.frame;
    viewFrame.size.width = 0;
    [lblUploaded setFrame:viewFrame];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photo\"; filename=\"image.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    cancleURL = [requestManager sendPostHttpMultipartRequest:requestURL RequestType:HTTPPicUploadRequest PostContent:postbody Boundry:contentType Delegate:self ExtraInfoDetail:nil CacheOption:kNoCaching];
    [activityView startAnimating];
}

- (void)openImagePickerWithSource:(UIImagePickerControllerSourceType)sourceType {
    imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.sourceType =  sourceType;
    imagePicker.showsCameraControls = NO;
    imagePicker.cameraOverlayView = overlayView;
	imagePicker.delegate = self;
	imagePicker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:imagePicker animated:YES];
    [imagePicker release];
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

- (void)showActionSheetWithPicker {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n"
                                                             delegate:self cancelButtonTitle:nil  destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"button_ok",@""),NSLocalizedString(@"button_cancel",@""),nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = 1;
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 280, 216)];
    actionSheet.alpha = 0.8;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    
    // add this picker to our view controller, initially hidden
    [actionSheet insertSubview:pickerView atIndex:0];
    
    actionSheet.destructiveButtonIndex = 1;	// make the second button red (destructive)
	[actionSheet showInView:self.view];
	//[actionSheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES]; // show from our tabbar view (pops up in the middle of the tabbar)
    [actionSheet release];
}

- (void)showAlert:(NSString *)title Content:(NSString *)bodyText {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:bodyText delegate:self cancelButtonTitle:NSLocalizedString(@"button_ok", @"button") otherButtonTitles:nil];
    [alert setContentMode:UIViewContentModeScaleAspectFit];	
    alert.tag = -299;
	[alert show];	
	[alert release];
}

- (void)saveImageLocally {
    if(!isAdded) {
        [ApplicationData sharedInstance].isUploaded = YES;
        isAdded = YES;
        UIButton *selectedButton = (UIButton *)[self.view viewWithTag:-(selectedCategoryIndex+1)];
        NSString *currentPath = [NSString stringWithFormat:@"%@_%.0lf.png", [selectedButton titleForState:UIControlStateNormal] ,[[NSDate date] timeIntervalSince1970]];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Image.plist"];
        [[ApplicationData sharedInstance].photoList addObject:currentPath];
        [[[ApplicationData sharedInstance] fileManager] setImageForPath:currentPath FileContent:UIImagePNGRepresentation(image)];
        
        [[ApplicationData sharedInstance].photoList writeToFile:filePath atomically:YES];
        [UIApplication sharedApplication].applicationIconBadgeNumber = [[ApplicationData sharedInstance].photoList count];
    }
}

- (void)deleteLastSavedImage {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"Image.plist"];
    [[ApplicationData sharedInstance].fileManager setImageForPath:[[ApplicationData sharedInstance].photoList lastObject] FileContent:nil];
    [[ApplicationData sharedInstance].photoList removeLastObject];
    
    [[ApplicationData sharedInstance].photoList writeToFile:filePath atomically:YES];
    [UIApplication sharedApplication].applicationIconBadgeNumber = [[ApplicationData sharedInstance].photoList count];
}

- (void)sendEmailSaveRequest:(NSString *)emailAddress {
    [activityView startAnimating];
    RequestResponseManager *requestManager = [RequestResponseManager sharedInstance];
    NSString *requestURL = [NSString stringWithFormat:EMAIL_SAVE_URL, [ImageUploaderAppDelegate getUUID], emailAddress];
    cancleURL = [requestManager sendGetHttpRequest:requestURL RequestType:HTTPRegisterMailRequest Delegate:self ExtraInfoDetail:nil CacheOption:kNoCaching];
}

#pragma mark-
#pragma mark PickerViewDelegate & DataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [imgCategoryList count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [imgCategoryList objectAtIndex:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 280;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    CGRect itemRect = CGRectMake(0.0, 0.0, 280.0, 44.0);
    UIView* customView = [[[UIView alloc] initWithFrame:itemRect] autorelease];
	
	// create the button object
	UILabel * headerLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	headerLabel.backgroundColor = [UIColor clearColor];
    [headerLabel setNumberOfLines:0];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        headerLabel.font = [UIFont systemFontOfSize:16.0];
    }
    else
    {
        headerLabel.font = [UIFont systemFontOfSize:13.0];
    }
    itemRect.origin.x = 10;
    itemRect.size.width -= 15.0;
	headerLabel.frame = itemRect;
	headerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
	[customView addSubview:headerLabel];
	return customView;
}

#pragma mark-
#pragma mark UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        UIPickerView *pickerView = [actionSheet.subviews objectAtIndex:0];
        [btnSelectedCategory setTitle:[imgCategoryList objectAtIndex:[pickerView selectedRowInComponent:0]] forState:UIControlStateNormal];
        [btnSave setEnabled:YES];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    return imgToUse;
}

#pragma mark -
#pragma UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [image fixOrientation];
    CGSize size = image.size;
	CGFloat ratio = 0;
    
    if((image.size.height > MAX_IMAGE_HEIGHT) || (image.size.width > MAX_IMAGE_WIDTH)){
		if (size.width > size.height) {
			ratio = MAX_IMAGE_WIDTH / size.width;
		}
		else {
			ratio = MAX_IMAGE_HEIGHT / size.height;
		}
		CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
		
		UIGraphicsBeginImageContext(rect.size);
		[image drawInRect:rect];
		image = UIGraphicsGetImageFromCurrentImageContext();
	}
    
    [imgToUse setImage:image];
	[picker dismissModalViewControllerAnimated:YES];	
    if(isAdded) {
        [self deleteLastSavedImage];
        isAdded = FALSE;
    }
}

#pragma  mark - 
#pragma UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma  mark - 
#pragma UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    
}

#pragma mark ReuqestManager Delegate Methods

- (void)requestCompleted:(HTTPRequest)requestType {
    [activityView stopAnimating];
    [uploadContainer removeFromSuperview];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    switch ([ApplicationData sharedInstance].responseCode) {
        case VM_SUCCESS:
            if(requestType == HTTPRegisterMailRequest) {
                NSLog(@"Registering");
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kEmailRegistered];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                if(![[NSUserDefaults standardUserDefaults] boolForKey:kEmailRegistered]) {
                    NSLog(@"Not Registered");
//                    [ApplicationData sharedInstance].lastScreen = EmailRegisterScreen;
                } else {
                    NSLog(@"Registered");
                }
                
                [btnRetake setEnabled:YES];
                [self deleteLastSavedImage];
                [ApplicationData sharedInstance].isUploaded = YES;
                [self showAlert:NSLocalizedString(@"alert_title_success", @"title") Content:NSLocalizedString(@"alert_body_uploadsuccess", @"success message")];
            }
            break;
            
        case VM_SERVER_ERROR:
            [self showAlert:NSLocalizedString(@"alert_title_error", @"title") Content:NSLocalizedString(@"alert_body_uploaderror", @"success message")];
            break;
            
        case VM_NOTVALID_EMAIL_ERROR:
            [self showAlert:NSLocalizedString(@"alert_title_error", @"title") Content:NSLocalizedString(@"alert_body_emailreg_fail", @"alert msg")];
            break;
            
        default:
            break;
    }
}

- (void)percentageUploaded:(CGFloat)percentage {
    CGRect viewFrame = lblTotal.frame;
    viewFrame.size.width = viewFrame.size.width*percentage;
    [lblUploaded setFrame:viewFrame];
}


#pragma mark-
#pragma mark AlertViewDelegate Methods.

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if([alertView tag] == -299) {
        if([[NSUserDefaults standardUserDefaults] boolForKey:kEmailRegistered]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [self showEmailInputAlert];
        }
    }
    if([alertView tag] == -199) {
        if(buttonIndex == 1) {
            UITextField *txtEmail = (UITextField *)[alertView viewWithTag:-99];
            if(txtEmail && [txtEmail isKindOfClass:[UITextField class]]) {
                if([txtEmail.text length] > 0) {
                    [self sendEmailSaveRequest:txtEmail.text];
                }
            }
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
