//
//  ImageUploaderViewController.h
//  ImageUploader
//
//  Copyright Time at Task Aps 2012. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "RequestResponseManager.h"

@interface ImageUploaderViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, RequestManagerDelegate> {
    
    IBOutlet UIBarButtonItem *btnBarUpload;
    IBOutlet UIScrollView *imageScrollContainer;
    IBOutlet UIView *photoView;
    IBOutlet UIView *uploaderContainer;
    IBOutlet UIView *uploaderInnerContainer;
    IBOutlet UIView *overlayView;
    IBOutlet UILabel *uploaderTotalView;
    IBOutlet UILabel *uploderCompletedView;
    IBOutlet UILabel *lblUploadingState;
    IBOutlet UILabel *lblTitle;
    IBOutlet UIButton *btnCancel;
    IBOutlet UIView *fullScreenImageView;
    IBOutlet UILabel *lblNoImages;
    IBOutlet UINavigationBar *navigationBar;
    IBOutlet UIButton *btnUse;
    IBOutlet UIButton *btnRetake;
    IBOutlet UIScrollView *imgContainer;
    IBOutlet UIButton *btnClose;
    IBOutlet UIButton *customCancelButton;
    IBOutlet UIButton *customCaptureButton;
    IBOutlet UIBarButtonItem *btnBackCamera;
    IBOutlet UIActivityIndicatorView *activityView;
    
    UIImagePickerController *imagePicker;
    
    //To store the selected image.
    UIImage *selectedImage;
    
    //To store the list of images to be uploaded.
    NSMutableArray *uploadingList;
    
    //To store the paths of all the images to be uploaded.
    NSMutableArray *removePath;
    
    //To store the list of photos.
    NSMutableArray *photoList;
    
    //To specify the index of image that is being uploding.
    int uploadImageIndex;
    
    //To specify the index of image for deleting.
    int deleteIndex;
    
    //To specify the total count of images need to be uploaded.
    int totalUploadingCount;
    
    BOOL isShowUploadAlert;

    //To specify whether new pic or not.
    BOOL isNewPic;
    
    //To check full screen mode.
    BOOL isFullScreenMode;
    
    //To specify that upload in the full screen mode.
    BOOL isFullScreenModeUpload;
    
    //Index of the selected image.
    int selectedImageIndex;
    
    //To check camera view or not.
    BOOL isCameraView;
    
    //To check the overlay view.
    BOOL isOverLayView;
    
    //To store the URL of current request.
    NSString *cancelURL;
}

//To open the camera.
- (IBAction)captureButtonPressed:(id)sender;

//To upload the images on the server.
- (IBAction)uploadButtonPressed:(id)sender;

- (IBAction)selectButtonPressed:(id)sender;

- (IBAction)deleteButtonPressed:(id)sender;

//To cancle the upload image request.
- (IBAction)cancelButtonPressed;
- (IBAction)fullScreenImageButtonPressed:(id)sender;

//To open the camera again for the image retake.
- (IBAction)retakeButtonPressed:(id)sender;

- (IBAction)useButtonPressed:(id)sender;

//To close the full screen image view.
- (IBAction)closeButtonPressed:(id)sender;

//To open the gallery view for the image selection.
- (IBAction)galleryButtonPressed:(id)sender;

//To close the camera view.
- (IBAction)closeCameraButtonPressed:(id)sender;

//To capture the image from camera.
- (IBAction)caputreCameraImageButtonPressed:(id)sender;

//To open the gallery view.
- (IBAction)openGalleryViewButtonPressed:(id)sender;

//To show the alert for the email input.
- (void)showEmailInputAlert;

//To send the request for the image upload.
- (void)sendImageUploadRequest;

//To display the list of photos.
- (void)showPhotoList;

//To show the image selection options like gallery or camera.
- (void)showImageSelectionOptions;

//To open the picker source of camera or gallery.
- (void)openImagePickerWithSource:(UIImagePickerControllerSourceType)sourceType;

//For removing the images that has been uploaded to the server.
- (void)removeCompletedImages;

//For removing the images that has been uploaded to the server.
- (void)removeInterMediateCompletedImage;

//For sending the request for the email registration.
- (void)sendEmailSaveRequest:(NSString *)emailAddress;

@end
