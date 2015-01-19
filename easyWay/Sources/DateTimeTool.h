//
//  DateTool.h
//  easyWay
//
//  Created by Tchikovani on 10/01/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateTimeTool : NSObject

+ (NSString *)dateTimeToHourString:(NSString *)string;
+ (NSString *)durationStringFromDurationNumber:(NSNumber *)duration;
+ (NSString *)NSDateToHourString:(NSDate *)date;
+ (NSString *)dateTimeFromNSDate:(NSDate *)date;

@end
