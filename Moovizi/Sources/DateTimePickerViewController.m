//
//  DateTimePickerViewController.m
//  easyWay
//
//  Created by Tchikovani on 20/01/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

#import "DateTimePickerViewController.h"
#import "UIView+Additions.h"
#import "ColorFactory.h"

@interface DateTimePickerViewController ()

@property (nonatomic, strong) UIView *pickerContainer;
@property (nonatomic, strong) UIView *selectedIndicator;
@property (nonatomic, strong) UIView *realView;

@end

@implementation DateTimePickerViewController

- (void)loadView {
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    self.realView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.realView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.7]];
    
    self.pickerContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.width, 300.0f)];
    [self.pickerContainer setBackgroundColor:[ColorFactory redLightColor]];
    
    UIButton *nowBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [nowBtn setTitle:@"Maintenant" forState:UIControlStateNormal];
    [nowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nowBtn setBackgroundColor:[ColorFactory redLightColor]];
    [nowBtn.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:14.0f]];
    nowBtn.frame = CGRectMake(0.0f, 0.0f, self.view.width, 40.0f);
    nowBtn.layer.borderColor = [ColorFactory grayBorder].CGColor;
    nowBtn.layer.borderWidth = 1.0f;
    [nowBtn addTarget:self action:@selector(nowBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.pickerContainer addSubview:nowBtn];
    
    UIButton *departBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [departBtn setTitle:@"Départ" forState:UIControlStateNormal];
    departBtn.tag = kDepartureTime;
    [departBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [departBtn setBackgroundColor:[ColorFactory redLightColor]];
    [departBtn.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:14.0f]];
    departBtn.frame = CGRectMake(0.0f, nowBtn.bottom - 1.0f, self.view.width / 2, 40.0f);
    departBtn.layer.borderColor = [ColorFactory grayBorder].CGColor;
    departBtn.layer.borderWidth = 1.0f;
    [departBtn addTarget:self action:@selector(changeDateTimeType:) forControlEvents:UIControlEventTouchUpInside];
    [self.pickerContainer addSubview:departBtn];
    
    UIButton *arrivedBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [arrivedBtn setTitle:@"Arrivée" forState:UIControlStateNormal];
    arrivedBtn.tag = kArrivedTime;
    [arrivedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [arrivedBtn setBackgroundColor:[ColorFactory redLightColor]];
    [arrivedBtn.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:14.0f]];
    arrivedBtn.frame = CGRectMake(departBtn.right, departBtn.top, self.view.width / 2, 40.0f);
    arrivedBtn.layer.borderColor = [ColorFactory grayBorder].CGColor;
    arrivedBtn.layer.borderWidth = 1.0f;
    [arrivedBtn addTarget:self action:@selector(changeDateTimeType:) forControlEvents:UIControlEventTouchUpInside];
    [self.pickerContainer addSubview:arrivedBtn];
    
    self.selectedIndicator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.width / 2, 5.0f)];
    [self.selectedIndicator setBackgroundColor:[ColorFactory yellowColor]];
    if (self.dateTimeType == kDepartureTime) {
        [departBtn addSubview:self.selectedIndicator];
    }
    else if (self.dateTimeType == kArrivedTime) {
        [arrivedBtn addSubview:self.selectedIndicator];
    }
    
    self.datePicker = [[UIDatePicker alloc] init];
    [self.datePicker setBackgroundColor:[ColorFactory whiteBackgroundColor]];
    self.datePicker.top = departBtn.bottom;
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [self.pickerContainer addSubview:self.datePicker];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn setBackgroundColor:[ColorFactory yellowColor]];
    [cancelBtn.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:14.0f]];
    [cancelBtn setTitle:@"Annuler" forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(0.0f, self.datePicker.bottom, self.view.width / 2, 40.0f);
    cancelBtn.layer.borderColor = [ColorFactory grayBorder].CGColor;
    cancelBtn.layer.borderWidth = 1.0f;
    [cancelBtn addTarget:self action:@selector(cancelBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.pickerContainer addSubview:cancelBtn];
    
    UIButton *okayBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [okayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [okayBtn setBackgroundColor:[ColorFactory yellowColor]];
    [okayBtn.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:14.0f]];
    [okayBtn setTitle:@"Valider" forState:UIControlStateNormal];
    okayBtn.frame = CGRectMake(cancelBtn.right, cancelBtn.top, self.view.width / 2, 40.0f);
    okayBtn.layer.borderColor = [ColorFactory grayBorder].CGColor;
    okayBtn.layer.borderWidth = 1.0f;
    [okayBtn addTarget:self action:@selector(validateBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.pickerContainer addSubview:okayBtn];
    self.pickerContainer.height = nowBtn.height + departBtn.height + self.datePicker.height + cancelBtn.height - 1;
    self.pickerContainer.top = self.realView.bottom;
    [self.realView addSubview:self.pickerContainer];
    [self.view addSubview:self.realView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self setModalPresentationStyle:UIModalPresentationOverCurrentContext];
}

- (void)viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:0.3f animations:^{
        self.pickerContainer.bottom = self.realView.bottom;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - Button actions

- (IBAction)changeDateTimeType:(id)sender {
    UIButton *typeDateTimeBtn = (UIButton *)sender;
    self.dateTimeType = (kDateTimeType)typeDateTimeBtn.tag;
    [typeDateTimeBtn addSubview:self.selectedIndicator];
}

- (IBAction)nowBtnTapped:(id)sender {
    self.datePicker.date = [NSDate date];
}

- (IBAction)validateBtnTapped:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    if ([self.delegate respondsToSelector:@selector(dateTimeChanged:type:)]) {
        [self.delegate dateTimeChanged:self.datePicker.date type:self.dateTimeType];
    }
}

- (IBAction)cancelBtnTapped:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
