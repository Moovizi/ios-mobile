//
//  CreateIssueViewController.m
//  Moovizi
//
//  Created by Tchikovani on 01/02/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>

#import "CreateIssueViewController.h"

#import "WebServices.h"

#import "MBProgressHUD.h"
#import "ColorFactory.h"
#import "UIView+Additions.h"
#import "UIImage+Additions.h"

@interface CreateIssueViewController () <UITextViewDelegate,
                                        UIGestureRecognizerDelegate,
                                        UINavigationControllerDelegate,
                                        UIImagePickerControllerDelegate,
                                        CLLocationManagerDelegate,
                                        WebServicesDelegate>

@property (nonatomic, strong) WebServices *webServices;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) UIBarButtonItem *doneBtn;

@property (nonatomic, strong) UIButton *submitIssue;
@property (nonatomic, strong) UIImageView *pictureView;
@property (nonatomic, strong) UITextView *captionView;

@end

static BOOL isImageFromCamera = NO;

@implementation CreateIssueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webServices = [[WebServices alloc] init];
    self.webServices.delegate = self;
    
    /* We set the location manager for getting coordinates of the issue */
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (UIView *)loadAddPictureView {
    UIView *addPictureView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 10.0f, 200.0f, 200.0f)];
    [addPictureView setBackgroundColor:[ColorFactory redLightColor]];
    
    UIImageView *camera = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    camera.image = [UIImage imageNamed:@"camera.png"];
    camera.center = CGPointMake(addPictureView.width / 2, 70.0f);
    camera.contentMode = UIViewContentModeScaleAspectFit;
    [addPictureView addSubview:camera];
    
    UILabel *addPictureLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 180.0f, 40.0f)];
    [addPictureLabel setBackgroundColor:[UIColor clearColor]];
    addPictureLabel.text = @"Ajoutez une photo";
    addPictureLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:14.0f];
    addPictureLabel.textColor = [UIColor whiteColor];
    addPictureLabel.center = CGPointMake(addPictureView.width / 2, 0.0f);
    addPictureLabel.top = camera.bottom + 10.0f;
    addPictureLabel.textAlignment = NSTextAlignmentCenter;
    [addPictureView addSubview:addPictureLabel];
    return addPictureView;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Annuler"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(cancelIssueCreation:)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
    
    self.doneBtn = [[UIBarButtonItem alloc]
                                  initWithTitle:@"Done"
                                  style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(doneBtnTapped:)];
    
    self.pictureView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 10.0f, 200.0f, 200.0f)];
    self.pictureView.center = CGPointMake(self.view.width / 2, self.pictureView.center.y);
    self.pictureView.layer.borderColor = [ColorFactory grayBorder].CGColor;
    self.pictureView.layer.borderWidth = 1.0f;
    [self.pictureView setBackgroundColor:[ColorFactory redLightColor]];
    self.pictureView.image = [UIImage imageWithView:[self loadAddPictureView]];
    self.pictureView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tappedImage = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(AddPicture:)];
    tappedImage.delegate = self;
    [self.pictureView addGestureRecognizer:tappedImage];
    
    [self.view addSubview:self.pictureView];
    
    self.captionView = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, self.pictureView.bottom + 10.0f, self.view.width - 20.0f, self.view.height - 270.0f)];
    self.captionView.layer.borderColor = [ColorFactory grayBorder].CGColor;
    self.captionView.layer.borderWidth = 1.0f;
    self.captionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.captionView.text = @"Décrivez l'obstacle...";
    self.captionView.font = [UIFont fontWithName:@"Montserrat-Regular" size:14.0f];
    self.captionView.textColor = [UIColor lightGrayColor];
    self.captionView.delegate = self;
    [self.view addSubview:self.captionView];
    
    self.submitIssue = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.submitIssue.frame = CGRectMake(0.0f, 0.0f, self.view.width, 40.0f);
    [self.submitIssue setBackgroundColor:[ColorFactory redBoldColor]];
    [self.submitIssue setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.submitIssue setTitle:@"Valider" forState:UIControlStateNormal];
    self.submitIssue.titleLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:14.0f];
    [self.submitIssue addTarget:self action:@selector(submitIssue:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.submitIssue];
    
    UIView *yellowTopBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.submitIssue.width, 4.0f)];
    [yellowTopBorder setBackgroundColor:[ColorFactory yellowColor]];
    [self.submitIssue addSubview:yellowTopBorder];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.submitIssue.bottom = self.view.height;
}

#pragma mark - WebService delegate

- (void)internetNotAvailable:(kRequestType)requestType {
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet non disponible"
                                                    message:@"Une connection internet est nécessaire pour effectuer cette requête"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)requestFailed:(kRequestType)requestType error:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problème survenu"
                                                    message:@"Notre service rencontre en ce moment des problèmes. Veuillez réessayer plus tard"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)operationDone:(kRequestType)requestType response:(NSDictionary *)response {
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    if (requestType == kPOSTIssue) {
        if ([self.delegate respondsToSelector:@selector(issueCreated:)]) {
            [self.delegate issueCreated:response];
        }
    }
}

#pragma mark - NSNotification observers

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        self.view.bottom = (self.view.height + CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) +
                                                               self.navigationController.navigationBar.height) - keyboardFrameEndRect.size.height + 40.0f;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    
    if (self.captionView.text.length == 0){
        self.captionView.textColor = [UIColor lightGrayColor];
        self.captionView.text = @"Décrivez l'obstacle...";
    }
    
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        self.view.bottom += keyboardFrameEndRect.size.height - 40.0f;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - UITextView delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem = self.doneBtn;
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    if (self.captionView.textColor == [UIColor lightGrayColor]) {
        self.captionView.text = @"";
        self.captionView.textColor = [ColorFactory blackTextColor];
    }
    return YES;
}

#pragma mark - UIImagePicker delegate 

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    isImageFromCamera = YES;
    self.pictureView.image = info[UIImagePickerControllerOriginalImage];
}

#pragma mark - UIButton actions

- (IBAction)AddPicture:(id)sender {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Autorisation"
                                                        message:@"Afin de pouvoir prendre une photo, activez l'autorisation dans Règlages -> Appareil Photo -> Moovizi."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        picker.showsCameraControls = YES;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)doneBtnTapped:(id)sender {
    [self.captionView resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
}

- (IBAction)submitIssue:(id)sender {
    if (self.captionView.textColor == [UIColor lightGrayColor]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Déclaration d'obstacle"
                                                        message:@"Une description de l'obstacle est nécessaire pour l'envoyer"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Localisation"
                                                        message:@"Afin de pouvoir localiser l'obstacle, activez la localisation dans Règlages -> Confidentialité -> Service de localisation."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelFont = [UIFont fontWithName:@"Montserrat-Regular" size:13.0f];
    hud.labelText = @"Obstacle en cours d'envoi";
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.latitude], @"latitude",
                                       [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.longitude], @"longitude",
                                       self.captionView.text, @"description",
                                     nil];

    NSMutableDictionary *request = [NSMutableDictionary
                                    dictionaryWithObjectsAndKeys:parameters, @"parameters",
                                    [NSNumber numberWithInt:kPOSTIssue], @"requestType",
                                    @"http://moovizi-api.herokuapp.com/issues", @"URL",
                                    @"photo", @"mediaNameParameter",
                                    nil];
    if (isImageFromCamera) {
        [request setObject:UIImageJPEGRepresentation(self.pictureView.image, 0.5) forKey:@"media"];
    }
    [self.webServices POSTMediaOperation:request];
}

- (IBAction)cancelIssueCreation:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] == kCLErrorDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Localisation"
                                                        message:@"Afin de pouvoir localiser l'obstacle, activez la localisation dans Règlages -> Confidentialité -> Service de localisation."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

@end
