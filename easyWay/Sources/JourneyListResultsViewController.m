//
//  JourneyListResultsViewController.m
//  Moovizi
//
//  Created by Tchikovani on 05/01/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "JourneyListResultsViewController.h"
#import "MBProgressHUD.h"
#import "AddressTableViewCell.h"
#import "HomeViewController.h"
#import "JourneyResultTableViewCell.h"
#import "JourneyDetailViewController.h"
#import "DateTimePickerViewController.h"
#import "Constants.h"

#import "DateTimeTool.h"

// UI Tools Imports
#import "WebServices.h"
#import "UIView+Additions.h"
#import "ColorFactory.h"
#import "UIImage+Additions.h"

@interface JourneyListResultsViewController () <CLLocationManagerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, WebServicesDelegate, DateTimePickerDelegate>

@property (nonatomic, strong) WebServices *webServices;

@property (nonatomic, strong) UITextField *activeField;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UIView *deleteTextView;
@property (nonatomic, strong) UIButton *switchBtn;

@property (nonatomic, strong) UIView *selectedIndicator;
@property (nonatomic, strong) UIImageView *walkingIcon;
@property (nonatomic, strong) UIImageView *transportIcon;
@property (nonatomic, assign) BOOL isPublicTransportation;

@property (nonatomic, strong) NSDate *dateSelected;
@property (nonatomic, assign) kDateTimeType dateTimeType;
@property (nonatomic, strong) UILabel *dateSelectedLabel;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *placesNearMeArray;
@property (nonatomic, strong) NSArray *placesArray;

@property (nonatomic, strong) NSArray *journeys;
@property (nonatomic, strong) UITableView *journeysTableView;
@property (nonatomic, strong) UITableView *placesTableView;

@end

@implementation JourneyListResultsViewController

static const BOOL isCurrentLocation = YES;
static BOOL isHeightTableViewSet = NO;

- (instancetype)initWithJourneys:(NSArray *)journeys {
    self = [super init];
    if (self) {
        self.journeys = journeys;
        self.startField = [[UITextField alloc] init];
        self.endField = [[UITextField alloc] init];
        self.dateTimeType = kDepartureTime;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.activeField = nil;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    self.webServices = [[WebServices alloc] init];
    self.webServices.delegate = self;
    self.isPublicTransportation = YES;

    self.dateSelected = [NSDate date];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (UIView *)loadFieldsContainer {
    UIView *fieldsContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.width, 90.0f)];
    [fieldsContainer setBackgroundColor:[ColorFactory redLightColor]];
    
    self.startField.frame = CGRectMake(20.0f, 15.0f, self.view.width - (20.0f * 2) - 30.0f - 10, 30.0f);
    self.startField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 4.0f, 20.0f)];
    self.startField.leftViewMode = UITextFieldViewModeAlways;
    self.startField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.startField.placeholder = @"Entrez une adresse de départ";
    self.startField.font = [UIFont fontWithName:@"Montserrat-Regular" size:14.0f];
    self.startField.textColor = [UIColor whiteColor];
    self.startField.delegate = self;
    self.startField.rightViewMode = UITextFieldViewModeWhileEditing;
    [self.startField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [fieldsContainer addSubview:self.startField];
    
    self.separator = [[UIView alloc] initWithFrame:CGRectMake(self.startField.left, self.startField.bottom + 2.5f, self.view.width - 80.0f, 1.0f)];
    [self.separator setBackgroundColor:[ColorFactory beigeColor]];
    [fieldsContainer addSubview:self.separator];
    
    self.endField.frame = CGRectMake(self.startField.left, self.startField.bottom + 5.0f, self.startField.width , 30.0f);
    self.endField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4.0f, 20.0f)];
    self.endField.leftViewMode = UITextFieldViewModeAlways;
    self.endField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.endField.placeholder = @"Entrez une adresse d'arrivée";
    self.endField.font = [UIFont fontWithName:@"Montserrat-Regular" size:14.0f];
    self.endField.textColor = [UIColor whiteColor];
    self.endField.delegate = self;
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
    self.switchBtn.frame = CGRectMake(self.view.right - 40.0f, self.startField.bottom + 2.5f - 15.0f, 30.0f, 30.0f);
    [self.switchBtn setBackgroundImage:[UIImage imageNamed:@"switch.png"] forState:UIControlStateNormal];
    [self.switchBtn addTarget:self action:@selector(switchLocations:) forControlEvents:UIControlEventTouchUpInside];
    [fieldsContainer addSubview:self.switchBtn];
    return fieldsContainer;
}

- (void)loadView {
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]
                                  initWithTitle:@"Annuler"
                                  style:UIBarButtonItemStyleDone
                                  target:self
                                  action:@selector(cancel:)];
    [cancelBtn setTitleTextAttributes:@{
                                         NSFontAttributeName:[UIFont fontWithName:@"Montserrat-Regular" size:20.0f],
                                         NSForegroundColorAttributeName: [ColorFactory yellowColor]
                                         } forState:UIControlStateNormal];

    self.navigationItem.rightBarButtonItem = cancelBtn;
    
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view setBackgroundColor:[ColorFactory redLightColor]];
    
    UIView *fieldsContainer = [self loadFieldsContainer];
    [self.view addSubview:fieldsContainer];
    
    UIButton *transportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [transportBtn setBackgroundColor:[ColorFactory redBoldColor]];
    transportBtn.layer.borderWidth = 1.0f;
    transportBtn.layer.borderColor = [ColorFactory grayBorder].CGColor;
    transportBtn.frame = CGRectMake(0.0f, fieldsContainer.bottom, self.view.width / 2.0f, 40.0f);
    self.transportIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
    self.transportIcon.center = CGPointMake(transportBtn.width / 2, transportBtn.height / 2);
    self.transportIcon.image = [UIImage imageNamed:@"public_transport_white.png"];
    self.transportIcon.contentMode = UIViewContentModeScaleAspectFit;
    [transportBtn addSubview:self.transportIcon];
    [transportBtn addTarget:self action:@selector(changeTypeJourney:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:transportBtn];
    
    UIButton *walkingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [walkingBtn setBackgroundColor:[ColorFactory redBoldColor]];
    walkingBtn.layer.borderWidth = 1.0f;
    walkingBtn.layer.borderColor = [ColorFactory grayBorder].CGColor;
    walkingBtn.frame = CGRectMake(transportBtn.right, transportBtn.top, self.view.width / 2.0f, 40.0f);
    self.walkingIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
    self.walkingIcon.center = CGPointMake(walkingBtn.width / 2, walkingBtn.height / 2);
    self.walkingIcon.image = [UIImage imageNamed:@"walking_unselected.png"];
    self.walkingIcon.contentMode = UIViewContentModeScaleAspectFit;
    [walkingBtn addSubview:self.walkingIcon];
    [walkingBtn addTarget:self action:@selector(changeTypeJourney:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:walkingBtn];
    
    self.selectedIndicator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.width / 2, 5.0f)];
    [self.selectedIndicator setBackgroundColor:[ColorFactory yellowColor]];
    [transportBtn addSubview:self.selectedIndicator];
    
    UIView *dateSelectedView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, walkingBtn.bottom - 1, fieldsContainer.width, 40.0f)];
    dateSelectedView.layer.borderColor = [ColorFactory grayBorder].CGColor;
    dateSelectedView.layer.borderWidth = 1.0f;
    [dateSelectedView setBackgroundColor:[ColorFactory redBoldColor]];
    self.dateSelectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(self. startField.left, 10.0f, 200.0f, 20.0f)];
    self.dateSelectedLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:13.0f];
    self.dateSelectedLabel.textColor = [UIColor whiteColor];
    self.dateSelectedLabel.text = [NSString stringWithFormat:@"Départ à %@", [DateTimeTool NSDateToHourString:[NSDate date]]];
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDateTimePicker:)];
    [dateSelectedView addGestureRecognizer:singleFingerTap];
    [dateSelectedView addSubview:self.dateSelectedLabel];
    
    UIImageView *settingsIcon = [[UIImageView alloc] initWithFrame:CGRectMake(dateSelectedView.right - 30.0f, 10.0f, 20.0f, 20.0f)];
    settingsIcon.image = [UIImage imageNamed:@"settings.png"];
    [dateSelectedView addSubview:settingsIcon];
    [self.view addSubview:dateSelectedView];
    
    self.placesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 50.0f, self.view.width, self.view.height - 50.0f) style:UITableViewStylePlain];
    self.placesTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.placesTableView.delegate = self;
    self.placesTableView.dataSource = self;
    self.placesTableView.hidden = YES;
    [self.view addSubview:self.placesTableView];
    
    self.journeysTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, dateSelectedView.bottom, self.view.width, self.view.height - fieldsContainer.height) style:UITableViewStylePlain];
    self.journeysTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.journeysTableView.delegate = self;
    self.journeysTableView.dataSource = self;
    [self.journeysTableView setBackgroundColor:[ColorFactory whiteBackgroundColor]];

    [self.view addSubview:self.journeysTableView];
}

- (void)viewDidLayoutSubviews {
    if ([self.placesTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.placesTableView setSeparatorInset:UIEdgeInsetsZero];
        [self.journeysTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.placesTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.placesTableView setLayoutMargins:UIEdgeInsetsZero];
        [self.journeysTableView setLayoutMargins:UIEdgeInsetsZero];
    }
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
            [self.placesTableView reloadData];
        }
    }
    else if (requestType == kGETDetailsStartInput || requestType == kGETDetailsDestinationInput) {
        NSDictionary *result = [response objectForKey:@"result"];
        if (result) {
            HomeViewController *homeVC = (HomeViewController *)((UINavigationController *)self.presentingViewController).topViewController;
            if (requestType == kGETDetailsStartInput) {
                self.startGoogleObject = result;
                homeVC.startGoogleObject = [result copy];
            }
            else {
                self.endGoogleObject = result;
                homeVC.endGoogleObject = [result copy];
            }
        }
        [self GETJourney];
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
            self.journeys = [response objectForKey:@"journeys"];
            [self.journeysTableView reloadData];
        }
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

- (void)GETJourney {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelFont = [UIFont fontWithName:@"Montserrat-Regular" size:13.0f];
    hud.labelText = @"Mise à jour de l'itinéraire";
    
    NSMutableArray *forbidden_uris = [NSMutableArray arrayWithObjects:@"physical_mode:RapidTransit",
                               @"physical_mode:Metro",
                               @"physical_mode:CheckOut",
                               @"physical_mode:CheckIn",
                               @"physical_mode:default_physical_mode",
                               nil];
    
    NSString *dateTimeType = (self.dateTimeType == kDepartureTime ? @"departure" : @"arrival");
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [DateTimeTool dateTimeFromNSDate:self.dateSelected], @"datetime",
                                       dateTimeType, @"datetime_represents",
                                       nil];
    
    if (self.isPublicTransportation == NO) {
        [forbidden_uris addObjectsFromArray:@[@"physical_mode:Trolleybus",
                                              @"physical_mode:Tramway",
                                              @"physical_mode:Bus"]];
        
        [parameters setObject:@"90000" forKey:@"max_duration_to_pt"];
    }
    
    [parameters setObject:forbidden_uris forKey:@"forbidden_uris"];
    

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
                                   dictionaryWithObjectsAndKeys:kNAVITIA_API_KEY,
                                   @"Authorization",
                                   nil];
    
    [self.webServices GEToperation:@"http://api.navitia.io/v1/journeys"
                        parameters:parameters
                            header:header
                       requestType:kGETJourney];
}

#pragma mark - UITableView datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    
    if (tableView == self.journeysTableView) {
        NSDictionary *journey = [self.journeys objectAtIndex:indexPath.row];
        NSArray *sections = [journey objectForKey:@"sections"];
        CGFloat typePosX = 0.0f;
        height = 65.0f;
        NSInteger index = 0;
        if ([sections count] > 1) {
            for (NSDictionary *section in sections) {
                if ([[section objectForKey:@"type"] isEqualToString:@"transfer"] ||
                    [[section objectForKey:@"type"] isEqualToString:@"waiting"]) {
                    index++;
                    continue;
                }
                if ([[section objectForKey:@"type"] isEqualToString:@"street_network"]) {
                    typePosX += 15.0f;
                }
                else if ([[section objectForKey:@"type"] isEqualToString:@"public_transport"])  {
                    typePosX += 23.0f;
                    typePosX += 35.0f;
                }
                if ([sections count] > 0 && index < [sections count] - 1) {
                    typePosX += 20.0f;
                }
                if (typePosX > self.view.width - 60) {
                    typePosX = 0.0f;
                    height += 25.0f;
                }
                index++;
            }
        }
    }
    else if (tableView == self.placesTableView) {
        height = 70.0f;
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.placesTableView) {
        if (![self isThereCurrentLocationSelected] &&
            [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
            return 2;
        }
        return 1;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 1;
    if (tableView == self.placesTableView) {
        if (![self isThereCurrentLocationSelected] &&
            [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse &&
            section == 0) {
            return 1;
        }
        numberOfRows = [self.placesArray count];
    }
    else if (tableView == self.journeysTableView) {
        numberOfRows = [self.journeys count];
    }
    return numberOfRows;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)addressCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressTableViewCell *cell = [self.placesTableView dequeueReusableCellWithIdentifier:@"AddressCell"];
    
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
        cell.iconImage.image = [UIImage imageNamed:@"poi_pin.png"];
    }
    return cell;
 
}

- (UITableViewCell *)jouyrneyResultCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JourneyResultTableViewCell *cell = [self.journeysTableView dequeueReusableCellWithIdentifier:@"JourneyResultCell"];
    
    if (cell == nil) {
        cell = [[JourneyResultTableViewCell alloc] init];
    }
    
    [cell initContentCell:[self.journeys objectAtIndex:indexPath.row]];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (tableView == self.placesTableView) {
        cell = [self addressCellForRowAtIndexPath:indexPath];
    }
    else if (tableView == self.journeysTableView) {
        cell = [self jouyrneyResultCellForRowAtIndexPath:indexPath];
    }
    return  cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.placesTableView) {
        HomeViewController *homeVC = (HomeViewController *)((UINavigationController *)self.presentingViewController).topViewController;
        if (![self isThereCurrentLocationSelected] &&
            [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse &&
            indexPath.section == 0) {
            self.activeField.tag = isCurrentLocation;
            self.activeField.text = @"Votre position actuelle";
            if (self.activeField == self.startField) {
                homeVC.startField.text = @"Votre position actuelle";
            }
            else {
                homeVC.endField.text = @"Votre position actuelle";
            }
            if (self.activeField == self.startField && self.startGoogleObject) {
                self.startGoogleObject = nil;
                homeVC.startGoogleObject = nil;
            }
            else if (self.activeField == self.endField && self.endGoogleObject) {
                self.endGoogleObject = nil;
                homeVC.endGoogleObject = nil;
            }
            [self GETJourney];
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
            if (self.activeField == self.startField) {
                homeVC.startField.text = self.activeField.text;
            }
            else {
                homeVC.endField.text = self.activeField.text;
            }
        }
        [self.activeField resignFirstResponder];
    }
    else if (tableView == self.journeysTableView) {
        JourneyDetailViewController *journeyDetailVC = [[JourneyDetailViewController alloc] initWithJourney:[self.journeys objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:journeyDetailVC animated:YES];
    }
}

#pragma mark - NSNotification observers

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    if (isHeightTableViewSet == NO) {
        self.placesTableView.height -= keyboardFrameEndRect.size.height;;
        isHeightTableViewSet = YES;
    }
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag != isCurrentLocation) {
        HomeViewController *homeVC = (HomeViewController *)((UINavigationController *)self.presentingViewController).topViewController;
        if (textField == self.startField &&
            self.startGoogleObject == nil) {
            textField.text = homeVC.startField.text;
        }
        else if (textField == self.endField &&
                 self.endGoogleObject == nil) {
            textField.text = homeVC.endField.text;
        }
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.tag == isCurrentLocation) {
        textField.text = @"";
        textField.tag = NO;
        textField.rightView = nil;
        [self.placesTableView reloadData];
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
        [self.placesTableView reloadData];
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
    [self.placesTableView reloadData];
    [UIView animateWithDuration:0.3f animations:^{
        self.placesTableView.hidden = NO;
        self.journeysTableView.hidden = YES;
        self.switchBtn.hidden = YES;
        self.separator.hidden = YES;
        if (textField == self.endField) {
            self.startField.hidden = YES;
        }
        textField.frame = CGRectMake(20.0f, 10.0f, self.view.width - (20.0f * 2), 30.0f);
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
        newFrame = CGRectMake(self.endField.left, 15.0f, self.endField.width, 30.0f);
    }
    else {
        self.startField.hidden = NO;
        newFrame = CGRectMake(self.startField.left, self.startField.bottom + 5.0f, self.startField.width , 30.0f);
    }
    self.separator.hidden = NO;
    self.placesTableView.hidden = YES;
    self.placesArray = [NSArray array];
    [self.placesTableView reloadData];
    self.switchBtn.hidden = NO;
    self.journeysTableView.hidden = NO;
    textField.rightView = nil;
    [UIView animateWithDuration:0.3f animations:^{
        textField.frame = newFrame;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - DateTime Picker delegate 

- (void)dateTimeChanged:(NSDate *)date type:(kDateTimeType)type {
    NSLog(@"NEW DATE ==== %@", date);
    self.dateSelected  = date;
    self.dateTimeType = type;
    if (type == kDepartureTime) {
        self.dateSelectedLabel.text = [NSString stringWithFormat:@"Départ à %@", [DateTimeTool NSDateToHourString:date]];
    }
    else if (type == kArrivedTime) {
        self.dateSelectedLabel.text = [NSString stringWithFormat:@"Arrivée à %@", [DateTimeTool NSDateToHourString:date]];
    }
    [self GETJourney];
}

#pragma mark - UIButtons actions

- (IBAction)changeTypeJourney:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [btn addSubview:self.selectedIndicator];
    if (self.isPublicTransportation == YES) {
        self.isPublicTransportation = NO;
        self.walkingIcon.image = [UIImage imageNamed:@"walking_white.png"];
        self.transportIcon.image = [UIImage imageNamed:@"public_transport_unselected.png"];
    }
    else {
        self.isPublicTransportation = YES;
        self.walkingIcon.image = [UIImage imageNamed:@"walking_unselected.png"];
        self.transportIcon.image = [UIImage imageNamed:@"public_transport_white.png"];
    }
    [self GETJourney];
}

- (IBAction)showDateTimePicker:(id)sender {
    DateTimePickerViewController *dateTimePicker = [[DateTimePickerViewController alloc] init];
    dateTimePicker.dateTimeType = self.dateTimeType;
    [dateTimePicker.view setBackgroundColor:[UIColor clearColor]];
    dateTimePicker.datePicker.date = self.dateSelected;
    dateTimePicker.delegate = self;
    [self.navigationController presentViewController:dateTimePicker animated:NO completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clearTextField:(id)sender {
    self.activeField.text = @"";
    self.activeField.rightView = nil;
    if (self.activeField.tag == isCurrentLocation) {
        self.activeField.tag = NO;
        [self.placesTableView reloadData];
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
    [self.placesTableView reloadData];
}

- (IBAction)switchLocations:(id)sender {
    HomeViewController *homeVC = (HomeViewController *)((UINavigationController *)self.presentingViewController).topViewController;
    NSDictionary *tmpGoogleObject = self.endGoogleObject;
    self.endGoogleObject = self.startGoogleObject;
    homeVC.endGoogleObject = [self.startGoogleObject copy];
    self.startGoogleObject = tmpGoogleObject;
    homeVC.startGoogleObject = [tmpGoogleObject copy];
    
    NSString *stringAddress = self.startField.text;
    self.startField.text = self.endField.text;
    homeVC.startField.text = self.endField.text;
    self.endField.text = stringAddress;
    homeVC.endField.text = stringAddress;
    
    BOOL isCurrentLocationTmp = self.startField.tag;
    self.startField.tag = self.endField.tag;
    homeVC.startField.tag = self.endField.tag;
    self.endField.tag = isCurrentLocationTmp;
    homeVC.endField.tag = isCurrentLocationTmp;
    
    NSArray *placesArrayTmp = self.placesStartFieldArray;
    self.placesStartFieldArray = self.placesEndFieldArray;
    homeVC.placesStartFieldArray = [self.placesEndFieldArray copy];
    self.placesEndFieldArray = placesArrayTmp;
    homeVC.placesEndFieldArray = [placesArrayTmp copy];
    
    [self GETJourney];
}


@end
