//
//  JourneyListResultsViewController.h
//  Moovizi
//
//  Created by Tchikovani on 05/01/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JourneyListResultsViewController : UIViewController

@property (nonatomic, strong) NSArray *placesStartFieldArray;
@property (nonatomic, strong) NSArray *placesEndFieldArray;
@property (nonatomic, strong) UITextField *startField;
@property (nonatomic, strong) UITextField *endField;
@property (nonatomic, strong) NSDictionary *startGoogleObject;
@property (nonatomic, strong) NSDictionary *endGoogleObject;

- (instancetype)initWithJourneys:(NSArray *)journeys;

@end
