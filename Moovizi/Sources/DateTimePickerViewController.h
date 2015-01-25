//
//  DateTimePickerViewController.h
//  easyWay
//
//  Created by Tchikovani on 20/01/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum kDateTimeType {
    kDepartureTime,
    kArrivedTime,
} kDateTimeType;

@protocol DateTimePickerDelegate <NSObject>

@required
- (void)dateTimeChanged:(NSDate *)date type:(kDateTimeType)type;

@end


@interface DateTimePickerViewController : UIViewController

@property (nonatomic, assign) kDateTimeType dateTimeType;
@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, weak) id <DateTimePickerDelegate> delegate;

@end
