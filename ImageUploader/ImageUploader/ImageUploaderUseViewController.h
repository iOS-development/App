//
//  ImageUploaderUseViewController.h
//  ImageUploader
//
//  Copyright Time at Task Aps 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestResponseManager.h"

@interface ImageUploaderUseViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate,RequestManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate> {

    IBOutlet UIImageView *imgToUse;
    IBOutlet UIView *uploadContainer;
    IBOutlet UIView *uploadInnerContainer;
    IBOutlet UIView *overlayView;
    IBOutlet UILabel *lblTotal;
    IBOutlet UILabel *lblUploaded;
    IBOutlet UIActivityIndicatorView *activityView;
    IBOutlet UIButton *btnSelectedCategory;
    IBOutlet UIButton *btnCancel;
    IBOutlet UIButton *cutomCancelButton;
    IBOutlet UIButton *customCameraButton;

	UIImagePickerController *imagePicker;

    UIBarButtonItem *btnSave;
    UIBarButtonItem *btnRetake;
    
    //For reference image from previous view controller.
    UIImage *image;
    
    //Show the image category list.
    NSArray *imgCategoryList;
    
    //To check whether image added on server or not.
    BOOL isAdded;
    
    //To specify the selected category for the image.
    int selectedCategoryIndex;
    
    //To store the URL of current request.
    NSString *cancleURL;
}

@property(nonatomic, assign)UIImage *image;

//To select the category of the image.
- (IBAction)selectCategoryButtonPressed:(id)sender;

//To cancle the upload image request. 
- (IBAction)cancelButtonPressed:(id)sender;

//To retake the image.
- (IBAction)retakeButtonPressed;

//Close the camera view.
- (IBAction)cancleCameraViewButtonPressed:(id)sender;

//Capture the image from the camera view.
- (IBAction)caputreCameraButtonPressed:(id)sender;

//Show actionsheet with the picker.
- (void)showActionSheetWithPicker;

//To send the image upload request.
- (void)saveButtonPressed;

//To show the alert view.
- (void)showAlert:(NSString *)title Content:(NSString *)bodyText;

//To save the image locally.
- (void)saveImageLocally;

//Picker source either camera or gallery.
- (void)openImagePickerWithSource:(UIImagePickerControllerSourceType)sourceType;

//delete the last saved image after it uploaded successfully.
- (void)deleteLastSavedImage;

@end
