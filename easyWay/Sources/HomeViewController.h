//
//  ViewController.h
//  easyWay
//
//  Created by Tchikovani on 20/12/2014.
//  Copyright (c) 2014 Tchikovani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController

@property (nonatomic, strong) UITextField *startField;
@property (nonatomic, strong) UITextField *endField;
@property (nonatomic, strong) NSDictionary *startGoogleObject;
@property (nonatomic, strong) NSDictionary *endGoogleObject;
@property (nonatomic, strong) NSArray *placesStartFieldArray;
@property (nonatomic, strong) NSArray *placesEndFieldArray;

@end

