//
//  JourneyDetailViewController.m
//  easyWay
//
//  Created by Tchikovani on 11/01/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>

#import "JourneyDetailViewController.h"
#import "JourneyWalkingStepTableViewCell.h"
#import "JourneyTransportStepTableViewCell.h"
#import "TransportStepView.h"

// UI Customization
#import "UIView+Additions.h"
#import "ColorFactory.h"
#import "HexColor.h"

#import "DateTimeTool.h"

typedef enum kWalkingType {
    kWalking,
    kTransfer,
} kWalkingType;

@interface JourneyDetailViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, GMSMapViewDelegate>

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) GMSCoordinateBounds *bounds;

@property (nonatomic, strong) UIView *journeySummary;
@property (nonatomic, strong) UITableView *stepsTableView;

@property (nonatomic, strong) NSDictionary *journey;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

static const BOOL isMapFullScreen = YES;

@implementation JourneyDetailViewController

- (instancetype)initWithJourney:(NSDictionary *)journey {
    self = [super init];
    if (self) {
        self.journey = journey;
        self.sections = [NSMutableArray arrayWithArray:[self.journey objectForKey:@"sections"]];
        NSInteger index = 0;
        while (index < [self.sections count]) {
            NSDictionary *section = [self.sections objectAtIndex:index];
            if ([[section objectForKey:@"type"] isEqualToString:@"waiting"]) {
                [self.sections removeObjectAtIndex:index];
            }
            index++;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Itinéraire";
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.journeySummary.top = self.mapView.bottom;
    self.stepsTableView.top = self.journeySummary.bottom;
    self.stepsTableView.height = self.view.height - self.mapView.height - self.journeySummary.height;
    
    if ([self.stepsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.stepsTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.stepsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.stepsTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - LoadView methods

- (void)drawPolyLine:(GMSMutablePath *)path color:(UIColor *)color {
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeColor = color;
    polyline.strokeWidth = 5.f;
    polyline.map = self.mapView;
}

- (void)loadMapView {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.locationManager.location.coordinate.latitude
                                                            longitude:self.locationManager.location.coordinate.longitude
                                                                 zoom:16];
    
    self.mapView = [GMSMapView mapWithFrame:CGRectMake(0.0f, 0.0f, self.view.width, 200.0f) camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.delegate = self;
    self.mapView.tag = NO;
    [self.view addSubview:self.mapView];
    
    self.bounds = [[GMSCoordinateBounds alloc] init];
    NSArray *sections = [self.journey objectForKey:@"sections"];
    for (NSDictionary *section in sections) {
        GMSMutablePath *path = [GMSMutablePath path];
        NSArray *coordinatesArray = [[section objectForKey:@"geojson"] objectForKey:@"coordinates"];
        for (NSArray *coordinates in coordinatesArray) {
            self.bounds = [self.bounds includingCoordinate:CLLocationCoordinate2DMake([coordinates[1] doubleValue],
                                                                            [coordinates[0] doubleValue])];
            [path addLatitude:[coordinates[1] doubleValue] longitude:[coordinates[0] doubleValue]];
        }
        if ([[section objectForKey:@"type"] isEqualToString:@"street_network"]) {
            [self drawPolyLine:path color:[ColorFactory yellowColor]];
        }
        else if ([[section objectForKey:@"type"] isEqualToString:@"public_transport"]) {
            [self drawPolyLine:path color:[ColorFactory redLightColor]];
        }
    }
    
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:self.bounds];
    [self.mapView moveCamera:update];
    [self.mapView animateToZoom:self.mapView.camera.zoom - 0.2];
}

- (void)loadJourneySummary {
    self.self.journeySummary = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.mapView.bottom, self.view.width, 70.0f)];
    self.journeySummary.layer.borderWidth = 1.0f;
    self.journeySummary.layer.borderColor = [ColorFactory grayBorder].CGColor;
    [self.journeySummary setBackgroundColor:[UIColor whiteColor]];
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(changeModeMap:)];
    [self.journeySummary addGestureRecognizer:singleFingerTap];
    
    
    UIImageView *typeImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 15.0f, 15.0f)];
    typeImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.journeySummary addSubview:typeImage];
    
    UILabel *timesLabel = [[UILabel alloc] initWithFrame:CGRectMake(35.0f, typeImage.top, 170.0f, 15.0f)];
    timesLabel.textColor = [ColorFactory blackTextColor];
    timesLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:13.0f];
    [self.journeySummary addSubview:timesLabel];
    
    UIView *stepsView = [[UIView alloc] initWithFrame:CGRectMake(timesLabel.left, timesLabel.bottom + 3.0f, self.view.width - 40.0f, 25.0f)];
    
    if ([[self.journey objectForKey:@"type"] isEqualToString:@"non_pt_walk"]) {
        typeImage.image = [UIImage imageNamed:@"walking.png"];
        UILabel *walking = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 2.5f, 100.0f, 20.0f)];
        walking.text = @"Chemin piéton";
        walking.textColor = [ColorFactory blackTextColor];
        walking.font = [UIFont fontWithName:@"Montserrat-Regular" size:13.0f];
        [stepsView addSubview:walking];
    }
    else {
        typeImage.image = [UIImage imageNamed:@"public_transport.png"];
    }

    timesLabel.text = [NSString stringWithFormat:@"%@ - %@ (%@)",
                            [DateTimeTool dateTimeToHourString:[self.journey objectForKey:@"departure_date_time"]],
                            [DateTimeTool dateTimeToHourString:[self.journey objectForKey:@"arrival_date_time"]],
                            [DateTimeTool timeFromDuration:[self.journey objectForKey:@"duration"]]];

    NSArray *sections = [self.journey objectForKey:@"sections"];
    
    CGFloat typePosX = 0.0f;
    CGFloat typePosY = 0.0f;
    NSInteger index = 0;
    if ([sections count] > 1) {
        for (NSDictionary *section in sections) {
            if ([[section objectForKey:@"type"] isEqualToString:@"transfer"] ||
                [[section objectForKey:@"type"] isEqualToString:@"waiting"]) {
                index++;
                continue;
            }
            if ([[section objectForKey:@"type"] isEqualToString:@"street_network"]) {
                UIImageView *walk = [[UIImageView alloc] initWithFrame:CGRectMake(typePosX, typePosY + 5.0f, 15.0f, 15.0f)];
                walk.image = [UIImage imageNamed:@"walking.png"];
                walk.contentMode = UIViewContentModeScaleAspectFit;
                typePosX += 15.0f;
                [stepsView addSubview:walk];
            }
            else if ([[section objectForKey:@"type"] isEqualToString:@"public_transport"])  {
                TransportStepView *transportStepView = [[TransportStepView alloc] initWithFrame:CGRectMake(typePosX, typePosY, 300.0f, 20.0f)
                                                                                  stepTransport:section];
                if (transportStepView.right > stepsView.width) {
                    typePosX = 0.0f;
                    typePosY += 25.0f;
                    stepsView.height += 25.0f;
                    transportStepView.left = typePosX;
                    transportStepView.top = typePosY;
                }
                typePosX += transportStepView.width + 5.0f;
                [stepsView addSubview:transportStepView];
            }
            if ([sections count] > 0 && index < [sections count] - 1) {
                UIImageView *nextStep = [[UIImageView alloc] initWithFrame:CGRectMake(typePosX, typePosY + 5.0f, 15.0f, 15.0f)];
                nextStep.image = [UIImage imageNamed:@"next_step.png"];
                nextStep.contentMode = UIViewContentModeScaleAspectFit;
                typePosX += 20.0f;
                [stepsView addSubview:nextStep];
            }
            if (index < [sections count] - 1 && typePosX > self.journeySummary.width - 60) {
                typePosX = 0.0f;
                stepsView.height += 25.0f;
                typePosY += 25.0f;
            }
            index++;
        }
        self.journeySummary.height = stepsView.bottom + 10.0f;
    }

    [self.journeySummary addSubview:stepsView];
    [self.view addSubview:self.journeySummary];
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    [self loadMapView];
    
    self.stepsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, self.mapView.bottom, self.view.width, self.view.height - self.mapView.height) style:UITableViewStylePlain];
    self.stepsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.stepsTableView.delegate = self;
    self.stepsTableView.dataSource = self;
    
    [self loadJourneySummary];
    [self.view addSubview:self.stepsTableView];
}

#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    NSDictionary *section = [self.sections objectAtIndex:indexPath.row];
    if ([[section objectForKey:@"type"] isEqualToString:@"street_network"] ||
        [[section objectForKey:@"type"] isEqualToString:@"transfer"]) {
        height = 50.0f;
    }
    else if ([[section objectForKey:@"type"] isEqualToString:@"public_transport"]) {
        height = 70.0f;
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sections count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)cellWalkingStepForSection:(NSDictionary *)section {
    
    JourneyWalkingStepTableViewCell *cell = [self.stepsTableView dequeueReusableCellWithIdentifier:@"JourneyWalkingStepCell"];
    if (cell == nil) {
        cell = [[JourneyWalkingStepTableViewCell alloc] init];
    }
    [cell initContentCell:section];
    return cell;
}

- (UITableViewCell *)cellTransportStepForSection:(NSDictionary *)section {
    
    JourneyTransportStepTableViewCell *cell = [self.stepsTableView dequeueReusableCellWithIdentifier:@"JourneyTransportStepCell"];
    if (cell == nil) {
        cell = [[JourneyTransportStepTableViewCell alloc] init];
    }
    [cell initContentCell:section];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    NSDictionary *section = [self.sections objectAtIndex:indexPath.row];
    if ([[section objectForKey:@"type"] isEqualToString:@"street_network"] ||
        [[section objectForKey:@"type"] isEqualToString:@"transfer"]) {
        cell = [self cellWalkingStepForSection:section];
    }
    else if ([[section objectForKey:@"type"] isEqualToString:@"public_transport"]) {
        cell = [self cellTransportStepForSection:section];
    }
    return  cell;
}

#pragma mark - GMSMapView delegate

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if (self.mapView.tag != isMapFullScreen) {
        [UIView animateWithDuration:0.3f animations:^{
            self.mapView.tag = isMapFullScreen;
            self.mapView.height = self.view.height - self.journeySummary.height;
            self.journeySummary.bottom = self.view.bottom;
            self.stepsTableView.top = self.journeySummary.bottom;
        } completion:^(BOOL finished) {
            GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:self.bounds];
            [self.mapView moveCamera:update];
        }];
    }
}

#pragma mark - UIActions 

- (IBAction)changeModeMap:(id)sender {
    if (self.mapView.tag == isMapFullScreen) {
        [UIView animateWithDuration:0.3f animations:^{
            self.mapView.tag = NO;
            self.mapView.height = 200.0f;
            self.journeySummary.top = self.mapView.bottom;
            self.stepsTableView.top = self.journeySummary.bottom;
        } completion:^(BOOL finished) {
            GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:self.bounds];
            [self.mapView moveCamera:update];
        }];
    }
}

@end
