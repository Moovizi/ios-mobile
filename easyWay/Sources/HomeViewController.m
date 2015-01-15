//
//  ViewController.m
//  easyWay
//
//  Created by Tchikovani on 20/12/2014.
//  Copyright (c) 2014 Tchikovani. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>

#import "HomeViewController.h"

#import "WebServices.h"
#import "AddressTableViewCell.h"
#import "MBProgressHUD.h"
#import "JourneyListResultsViewController.h"
#import "Constants.h"

// UI Tools Imports
#import "UIView+Additions.h"
#import "ColorFactory.h"
#import "UIImage+Additions.h"

@interface HomeViewController () <CLLocationManagerDelegate, UITextFieldDelegate,
                                    UITableViewDataSource, UITableViewDelegate, WebServicesDelegate, GMSMapViewDelegate>

@property (nonatomic, strong) WebServices *webServices;

@property (nonatomic, strong) UITextField *activeField;
@property (nonatomic, strong) UIView *deleteTextView;
@property (nonatomic, strong) UIButton *switchBtn;

@property (nonatomic, strong) UIButton *poiBtn;
@property (nonatomic, strong) UIButton *difficultiesBtn;
@property (nonatomic, strong) UIImageView *poiBtnImage;
@property (nonatomic, strong) UIImageView *difficultiesBtnImage;

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *placesNearMeArray;
@property (nonatomic, strong) NSArray *placesArray;

@property (nonatomic, strong) UITableView *tableView;

@end

static const CGFloat leftPadding = 15.0f;
static BOOL isHeightTableViewSet = NO;
static const BOOL isCurrentLocation = YES;

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.activeField = nil;
    
    self.startGoogleObject = nil;
    self.endGoogleObject = nil;
    self.placesArray = [NSArray array];
    self.placesStartFieldArray = [NSArray array];
    self.placesEndFieldArray = [NSArray array];

    self.placesNearMeArray = [NSArray array];
    
    self.webServices = [[WebServices alloc] init];
    self.webServices.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view setBackgroundColor:[ColorFactory beigeColor]];
    
    /* Start and end location fields container */
    UIView *fieldsContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.width, 150.0f)];
    [fieldsContainer setBackgroundColor:[ColorFactory redLightColor]];
    
    self.startField = [[UITextField alloc] initWithFrame:CGRectMake(leftPadding, 20.0f, self.view.width - (leftPadding * 2) - 30.0f - 10, 30.0f)];
    self.startField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 4.0f, 20.0f)];
    self.startField.leftViewMode = UITextFieldViewModeAlways;
    self.startField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.startField.placeholder = @"Entrez une adresse de départ";
    self.startField.font = [UIFont fontWithName:@"Montserrat-Regular" size:14.0f];
    [self.startField setBackgroundColor:[UIColor whiteColor]];
    self.startField.textColor = [ColorFactory blackTextColor];
    self.startField.layer.borderColor = [ColorFactory grayBorder].CGColor;
    self.startField.layer.borderWidth = 1.0f;
    self.startField.layer.cornerRadius = 4.0f;
    self.startField.delegate = self;
    self.startField.tag = NO;
    self.startField.rightViewMode = UITextFieldViewModeWhileEditing;
    [self.startField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [fieldsContainer addSubview:self.startField];

    self.endField = [[UITextField alloc] initWithFrame:CGRectMake(self.startField.left, self.startField.bottom + 5.0f, self.startField.width , 30.0f)];
    self.endField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4.0f, 20.0f)];
    self.endField.leftViewMode = UITextFieldViewModeAlways;
    self.endField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.endField.placeholder = @"Entrez une adresse d'arrivée";
    self.endField.font = [UIFont fontWithName:@"Montserrat-Regular" size:14.0f];
    [self.endField setBackgroundColor:[UIColor whiteColor]];
    self.endField.textColor = [ColorFactory blackTextColor];
    self.endField.layer.borderColor = [ColorFactory grayBorder].CGColor;
    self.endField.layer.borderWidth = 1.0f;
    self.endField.layer.cornerRadius = 4.0f;
    self.endField.delegate = self;
    self.endField.tag = NO;
    self.endField.rightViewMode = UITextFieldViewModeWhileEditing;
    [self.endField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [fieldsContainer addSubview:self.endField];
    
    self.deleteTextView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30.0f, 30.0f)];
    UIButton *deleteTextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteTextBtn.frame = CGRectMake(0.0f, 5.0f, 20.0f, 20.0f);
    [deleteTextBtn setBackgroundImage:[UIImage imageNamed:@"delete_button.png"] forState:UIControlStateNormal];
    [deleteTextBtn addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteTextView addSubview:deleteTextBtn];
    
    self.switchBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.switchBtn.frame = CGRectMake(self.startField.right + 5.0f, self.startField.bottom + 2.5f - 15.0f, 30.0f, 30.0f);
    [self.switchBtn setBackgroundImage:[UIImage imageNamed:@"switch.png"] forState:UIControlStateNormal];
    [self.switchBtn addTarget:self action:@selector(switchLocations:) forControlEvents:UIControlEventTouchUpInside];
    [fieldsContainer addSubview:self.switchBtn];
    
    UIButton *searchJourneyBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    searchJourneyBtn.frame = CGRectMake(0.0f, 0.0f, 100.0f, 30.0f);
    searchJourneyBtn.center = fieldsContainer.center;
    searchJourneyBtn.top = self.endField.bottom + 20.0f;
    [searchJourneyBtn setTitle:@"Recherchez" forState:UIControlStateNormal];
    [searchJourneyBtn setBackgroundColor:[ColorFactory yellowColor]];
    [searchJourneyBtn.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Bold" size:14.0f]];
    [searchJourneyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    searchJourneyBtn.layer.borderColor = [ColorFactory grayBorder].CGColor;
    searchJourneyBtn.layer.borderWidth = 1.0f;
    searchJourneyBtn.layer.cornerRadius = 4.0f;
    [searchJourneyBtn addTarget:self action:@selector(searchJourneyBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [fieldsContainer addSubview:searchJourneyBtn];
    [self.view addSubview:fieldsContainer];
    
    /* Draw filters */
    UIView *filterContainer = [[UIView alloc] initWithFrame:CGRectMake(0, fieldsContainer.bottom, self.view.width, 60.0f)];
    filterContainer.layer.borderWidth = 1.0f;
    filterContainer.layer.borderColor = [ColorFactory grayBorder].CGColor;
    
    self.poiBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.poiBtn.frame = CGRectMake(0, 0, self.view.width / 2, 60.0f);
    [self.poiBtn setBackgroundColor:[ColorFactory redBoldColor]];
    self.poiBtn.tag = 1;
    [self.poiBtn addTarget:self action:@selector(filterPoiDisplayChanged:) forControlEvents:UIControlEventTouchUpInside];
    self.poiBtnImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    self.poiBtnImage.image = [UIImage imageNamed:@"poi_pin.png"];
    self.poiBtnImage.userInteractionEnabled = NO;
    [self.poiBtnImage setCenter:CGPointMake(self.poiBtn.width / 2, self.poiBtn.height / 2)];
    [self.poiBtn addSubview:self.poiBtnImage];
    [filterContainer addSubview:self.poiBtn];
    
    UIView *separtorFilter = [[UIView alloc] initWithFrame:CGRectMake(self.poiBtn.right, 0.0f, 1.0f, filterContainer.height)];
    [separtorFilter setBackgroundColor:[ColorFactory grayBorder]];
    [filterContainer addSubview:separtorFilter];
    
    UIButton *difficultiesBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    difficultiesBtn.frame = CGRectMake(separtorFilter.right, 0, self.poiBtn.width, 60.0f);
    [difficultiesBtn setBackgroundColor:[ColorFactory redBoldColor]];
    difficultiesBtn.tag = 1;
    [difficultiesBtn addTarget:self action:@selector(filterDifficultiesDisplayChanged:) forControlEvents:UIControlEventTouchUpInside];
    self.difficultiesBtnImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    self.difficultiesBtnImage.image = [UIImage imageNamed:@"difficulty_activated.png"];
    self.difficultiesBtnImage.userInteractionEnabled = NO;
    [self.difficultiesBtnImage setCenter:CGPointMake(difficultiesBtn.width / 2, difficultiesBtn.height / 2)];
    [difficultiesBtn addSubview:self.difficultiesBtnImage];
    [filterContainer addSubview:difficultiesBtn];
    [self.view addSubview:filterContainer];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.locationManager.location.coordinate.latitude
                                                            longitude:self.locationManager.location.coordinate.longitude
                                                                 zoom:16];

    self.mapView = [GMSMapView mapWithFrame:CGRectMake(0, filterContainer.bottom, self.view.width, self.view.height - difficultiesBtn.height - fieldsContainer.height) camera:camera];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 50.0f, self.view.width, self.view.height - 50.0f) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.hidden = YES;
    [self.view addSubview:self.tableView];
}

- (void)viewDidLayoutSubviews {
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Local functions

- (BOOL)isThereCurrentLocationSelected {
    if ([self.activeField.text length] == 0 &&
        !self.startField.tag == isCurrentLocation &&
        !self.endField.tag == isCurrentLocation) {
        return NO;
    }
    return YES;
}

#pragma mark - WebServices Delegate

- (void)internetNotAvailable:(kRequestType)requestType {
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    if (requestType != kGETAddressFromInput) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet non disponible"
                                                        message:@"Une connection internet est nécessaire pour effectuer cette requête"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)requestFailed:(kRequestType)requestType error:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    if (error.code != -999) {
        if (requestType != kGETAddressFromInput) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problème survenu"
                                                            message:@"Notre service rencontre en ce moment des problèmes. Veuillez réessayer plus tard"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)GEToperationDone:(kRequestType)requestType response:(NSDictionary *)response {
    if (requestType == kGETAddressFromInput) {
        if ([response objectForKey:@"predictions"]) {
            if (self.activeField == self.startField) {
                self.placesStartFieldArray = [response objectForKey:@"predictions"];
            }
            else {
                self.placesEndFieldArray = [response objectForKey:@"predictions"];
            }
            self.placesArray = [response objectForKey:@"predictions"];
            [self.tableView reloadData];
        }
    }
    else if (requestType == kGETDetailsStartInput || requestType == kGETDetailsDestinationInput) {
        NSDictionary *result = [response objectForKey:@"result"];
        if (result) {
            if (requestType == kGETDetailsStartInput) {
                self.startGoogleObject = result;
            }
            else {
                self.endGoogleObject = result;
            }
        }
    }
    else if (requestType == kGETJaccedePOINearLocation) {
        [self.mapView clear];
        self.placesNearMeArray = [response objectForKey:@"results"];
        for (NSDictionary *poi in self.placesNearMeArray) {
            GMSMarker *marker = [[GMSMarker alloc] init];
            NSDictionary *location = [[poi valueForKey:@"geometry"] objectForKey:@"location"];
            marker.position = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] doubleValue], [[location objectForKey:@"lng"] doubleValue]);
            marker.icon = [UIImage imageWithImage:[UIImage imageNamed:@"poi_map_yellow.png"] scaledToSize:CGSizeMake(25.0f, 25.0f)];
            marker.map = self.mapView;
        }
    }
    else if (requestType == kGETJourney) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *error = [response objectForKey:@"error"];
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aucun résulat"
                                                            message:@"Aucun itinéraire a été trouvé"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else {
            JourneyListResultsViewController *journeyListVC = [[JourneyListResultsViewController alloc] initWithJourneys:[response objectForKey:@"journeys"]];
            journeyListVC.startField.text = self.startField.text;
            journeyListVC.startField.tag = self.startField.tag;
            journeyListVC.startGoogleObject = self.startGoogleObject;
            journeyListVC.endField.text = self.endField.text;
            journeyListVC.endField.tag = self.endField.tag;
            journeyListVC.endGoogleObject = self.endGoogleObject;
            journeyListVC.placesStartFieldArray = self.placesStartFieldArray;
            journeyListVC.placesEndFieldArray = self.placesEndFieldArray;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:journeyListVC];
            nav.navigationBar.tintColor = [ColorFactory yellowColor];
            UIView *navLineBorder = [[UIView alloc] initWithFrame:CGRectMake(0, nav.navigationBar.bottom - 4.0f, self.view.frame.size.width, 4.0f)];
            [navLineBorder setBackgroundColor:[ColorFactory yellowColor]];
            [nav.navigationBar addSubview:navLineBorder];
            nav.navigationBar.translucent = NO;
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
    }
}

#pragma mark - UITableView datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (![self isThereCurrentLocationSelected] &&
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![self isThereCurrentLocationSelected] &&
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse &&
        section == 0) {
        return 1;
    }
    return [self.placesArray count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddressCell"];

    if (cell == nil) {
        cell = [[AddressTableViewCell alloc] init];
    }
    
    cell.cityLabel.text = @"";
    
    if (![self isThereCurrentLocationSelected] &&
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse &&
        indexPath.section == 0) {
        cell.mainAddressLabel.text = @"Votre position actuelle";
        cell.iconImage.image = [UIImage imageNamed:@"location.png"];
    }
    else {
        if ([[self.placesArray objectAtIndex:indexPath.row] objectForKey:@"terms"]) {
            NSArray *terms = [[self.placesArray objectAtIndex:indexPath.row] objectForKey:@"terms"];
            cell.mainAddressLabel.text = [[terms objectAtIndex:0] objectForKey:@"value"];
            if ([[[self.placesArray objectAtIndex:indexPath.row] objectForKey:@"terms"] count] > 1) {
                cell.cityLabel.text = [[terms objectAtIndex:1] objectForKey:@"value"];
            }
        }
        cell.iconImage.image = [UIImage imageNamed:@"poi_deactivated.png"];
    }
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self isThereCurrentLocationSelected] &&
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse &&
        indexPath.section == 0) {
        self.activeField.tag = isCurrentLocation;
        self.activeField.text = @"Votre position actuelle";
        if (self.activeField == self.startField && self.startGoogleObject) {
            self.startGoogleObject = nil;
        }
        else if (self.activeField == self.endField && self.endGoogleObject) {
            self.endGoogleObject = nil;
        }
    }
    else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           kGOOGLE_PLACES_API_KEY, @"key",
                                           [[self.placesArray objectAtIndex:indexPath.row] objectForKey:@"place_id"], @"placeid",
                                           nil];
        [self.webServices GEToperation:@"https://maps.googleapis.com/maps/api/place/details/json"
                            parameters:parameters
                                header:nil
                           requestType:(self.activeField == self.startField ? kGETDetailsStartInput : kGETDetailsDestinationInput)];
        self.activeField.text = [[self.placesArray objectAtIndex:indexPath.row] objectForKey:@"description"];
    }
    [self.activeField resignFirstResponder];
}

#pragma mark - NSNotification observers

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    if (isHeightTableViewSet == NO) {
        self.tableView.height -= keyboardFrameEndRect.size.height;
        isHeightTableViewSet = YES;
    }
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ((textField.tag != isCurrentLocation &&
        textField == self.startField &&
        self.startGoogleObject == nil)
        ||
        (textField.tag != isCurrentLocation &&
         textField == self.endField &&
         self.endGoogleObject == nil)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sélection d'adresse"
                                                            message:@"Vous devez sélectionner une adresse ou vider le champs"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return NO;
    }

    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.tag == isCurrentLocation) {
        textField.text = @"";
        textField.tag = NO;
        textField.rightView = nil;
        [self.tableView reloadData];
        return;
    }
    [self.webServices cancelAllOperations];
    if (textField == self.startField) {
        self.startGoogleObject = nil;
    }
    else {
        self.endGoogleObject = nil;
    }
    if ([textField.text length] > 0) {
        if (textField.rightView == nil) {
            textField.rightView = self.deleteTextView;
        }
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           kGOOGLE_PLACES_API_KEY, @"key",
                                           textField.text, @"input",
                                           @"48.866667,2.333333", @"location",
                                           @"20000", @"radius",
                                           @"fr", @"language",
                                           @[@"establishment", @"geocode"], @"types",
                                           nil];
        [self.webServices GEToperation:@"https://maps.googleapis.com/maps/api/place/autocomplete/json"
                            parameters:parameters header:nil requestType:kGETAddressFromInput];
    }
    else {
        textField.rightView = nil;
        self.placesArray = [NSArray array];
        if (textField == self.startField) {
            self.placesStartFieldArray = [NSArray array];
        }
        else {
            self.placesEndFieldArray = [NSArray array];
        }
        [self.tableView reloadData];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
    if (textField == self.startField) {
        self.placesArray = self.placesStartFieldArray;
    }
    else {
        self.placesArray = self.placesEndFieldArray;
    }
    [self.tableView reloadData];
    [UIView animateWithDuration:0.3f animations:^{
        self.tableView.hidden = NO;
        self.switchBtn.hidden = YES;
        if (textField == self.endField) {
            self.startField.hidden = YES;
        }
        textField.frame = CGRectMake(leftPadding, 10.0f, self.view.width - (leftPadding * 2), 30.0f);
    } completion:^(BOOL finished) {
        if (textField.text.length > 0) {
            textField.rightView = self.deleteTextView;
        }
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
    CGRect newFrame;
    if (textField == self.startField) {
        newFrame = CGRectMake(self.endField.left, 20.0f, self.endField.width, 30.0f);
    }
    else {
        self.startField.hidden = NO;
        newFrame = CGRectMake(self.startField.left, self.startField.bottom + 5.0f, self.startField.width , 30.0f);
    }
    self.tableView.hidden = YES;
    self.placesArray = [NSArray array];
    [self.tableView reloadData];
    self.switchBtn.hidden = NO;
    textField.rightView = nil;
    [UIView animateWithDuration:0.3f animations:^{
        textField.frame = newFrame;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - Map elements methods 

- (void)loadPoiNearMe {
    GMSVisibleRegion region = self.mapView.projection.visibleRegion;
    CLLocationDistance verticalDistance = GMSGeometryDistance(region.farLeft, region.nearLeft);
    CLLocationDistance  horizontalDistance = GMSGeometryDistance(region.farLeft, region.farRight);
    double radius = fmax(horizontalDistance, verticalDistance) * 0.5;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       kGOOGLE_PLACES_API_KEY, @"key",
                                       [NSString stringWithFormat:@"%f,%f", self.mapView.camera.target.latitude, self.mapView.camera.target.longitude], @"location",
                                       [NSString stringWithFormat:@"%f", radius], @"radius",
                                       nil];
    [self.webServices GEToperation:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json" parameters:parameters header:nil requestType:kGETJaccedePOINearLocation];
}

#pragma mark - GMSMapView delegate

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    [self.webServices cancelAllOperations];
    if (self.poiBtn.tag == 1) {
        // INTEGRATION POI VIA JACCEDE.COM
        /*NSString *url = [NSString stringWithFormat:@"http://api.jaccede.com/v2/places/search/"];
         NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f", coor.latitude], @"latitude",
         [NSString stringWithFormat:@"%f", coor.longitude], @"longitude",
         nil];
         double unixTs = [[NSDate date] timeIntervalSince1970];
         NSNumber *nowSecs = [NSNumber numberWithDouble:unixTs];
         NSMutableDictionary *headers = [self.webServices jxdAuthHeadersForPath:@"/api/v2/places/search/" requestMethod:@"GET" atTime:[nowSecs longValue]];*/
        
        [self loadPoiNearMe];
    }
}

#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] == kCLErrorDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Localisation"
                                                        message:@"Afin de pouvoir vous localiser, activez la localisation dans Règlages -> Confidentialité -> Service de localisation."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        self.startField.placeholder = @"Entrez une adresse de départ";
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.mapView animateToLocation:self.locationManager.location.coordinate];
    }
}

#pragma mark - UIButtons actions

- (IBAction)clearTextField:(id)sender {
    self.activeField.text = @"";
    self.activeField.rightView = nil;
    if (self.activeField.tag == isCurrentLocation) {
        self.activeField.tag = NO;
        [self.tableView reloadData];
        return;
    }
    if (self.activeField == self.startField) {
        if (self.startGoogleObject) {
            self.startGoogleObject = nil;
        }
        self.placesStartFieldArray = [NSArray array];
    }
    else if (self.activeField == self.endField) {
        if (self.endGoogleObject) {
            self.endGoogleObject = nil;
        }
        self.placesEndFieldArray = [NSArray array];
    }
    self.placesArray = [NSArray array];
    [self.tableView reloadData];
}

- (IBAction)switchLocations:(id)sender {
    NSDictionary *tmpGoogleObject = self.endGoogleObject;
    self.endGoogleObject = self.startGoogleObject;
    self.startGoogleObject = tmpGoogleObject;
    
    NSString *stringAddress = self.startField.text;
    self.startField.text = self.endField.text;
    self.endField.text = stringAddress;
    
    BOOL isCurrentLocationTmp = self.startField.tag;
    self.startField.tag = self.endField.tag;
    self.endField.tag = isCurrentLocationTmp;
    
    NSArray *placesArrayTmp = self.placesStartFieldArray;
    self.placesStartFieldArray = self.placesEndFieldArray;
    self.placesEndFieldArray = placesArrayTmp;
}

- (IBAction)searchJourneyBtnTapped:(id)sender {
    
   if ([self.startField.text length] == 0 || [self.endField.text length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Champs vide(s)"
                                                        message:@"Veuillez entrer une adresse de départ et d'arrivée"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelFont = [UIFont fontWithName:@"Montserrat-Regular" size:13.0f];
        hud.labelText = @"Recherche itinéraire";
        NSArray *forbidden_uris = [NSArray arrayWithObjects:@"physical_mode:RapidTransit",
                                   @"physical_mode:Metro",
                                   @"physical_mode:CheckOut",
                                   @"physical_mode:CheckIn",
                                   @"physical_mode:default_physical_mode",
                                   nil];
    
      /* NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           forbidden_uris, @"forbidden_uris",
                                           @"20150118T0800", @"datetime",
                                           @"2.363221;48.815432", @"from",
                                           @"2.297907;48.844093", @"to",
                                           nil];*/
    
    //2.297719;48.845301
    // @"2.309698;48.868835", @"to",

    
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           forbidden_uris, @"forbidden_uris",
                                           @"20150118T0800", @"datetime",
                                           nil];
        
        if (self.startField.tag == isCurrentLocation) {
            [parameters setObject:[NSString stringWithFormat:@"%f;%f", self.locationManager.location.coordinate.longitude,
                                   self.locationManager.location.coordinate.latitude] forKey:@"from"];
        }
        else {
            NSDictionary *coordinates = [[self.startGoogleObject objectForKey:@"geometry"] objectForKey:@"location"];
            [parameters setObject:[NSString stringWithFormat:@"%@;%@", [coordinates objectForKey:@"lng"],
                                   [coordinates objectForKey:@"lat"]]
                           forKey:@"from"];
        }
        
        if (self.endField.tag == isCurrentLocation) {
            [parameters setObject:[NSString stringWithFormat:@"%f;%f", self.locationManager.location.coordinate.longitude,
                                   self.locationManager.location.coordinate.latitude] forKey:@"to"];
        }
        else {
            NSDictionary *coordinates = [[self.endGoogleObject objectForKey:@"geometry"] objectForKey:@"location"];
            [parameters setObject:[NSString stringWithFormat:@"%@;%@", [coordinates objectForKey:@"lng"],
                                   [coordinates objectForKey:@"lat"]]
                           forKey:@"to"];
        }
        
        
        NSMutableDictionary *header = [NSMutableDictionary
                                       dictionaryWithObjectsAndKeys:kNAVITIA_API_KEY, @"Authorization",
                                       nil];
        
        [self.webServices GEToperation:@"http://api.navitia.io/v1/journeys"
                            parameters:parameters
                                header:header
                           requestType:kGETJourney];
    }
}

- (IBAction)filterPoiDisplayChanged:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == YES) {
        btn.tag = NO;
        [btn setBackgroundColor:[UIColor whiteColor]];
        [self.mapView clear];
    }
    else {
        btn.tag = YES;
        [btn setBackgroundColor:[ColorFactory redBoldColor]];
        [self loadPoiNearMe];
    }
}

- (IBAction)filterDifficultiesDisplayChanged:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == YES) {
        btn.tag = NO;
        [btn setBackgroundColor:[UIColor whiteColor]];
        self.difficultiesBtnImage.image = [UIImage imageNamed:@"difficulty_deactivated.png"];
        // Remove markers Difficulties
    }
    else {
        btn.tag = YES;
        [btn setBackgroundColor:[ColorFactory redBoldColor]];
        self.difficultiesBtnImage.image = [UIImage imageNamed:@"difficulty_activated.png"];
        // Add markers Difficulties
    }
}

@end
