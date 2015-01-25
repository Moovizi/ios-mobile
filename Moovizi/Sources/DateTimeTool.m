//
//  DateTool.m
//  Moozivi
//
//  Created by Tchikovani on 10/01/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

#import "DateTimeTool.h"

@implementation DateTimeTool

+ (NSString *)dateTimeToHourString:(NSString *)string {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd'T'HHmmss"];
    NSDate *date = [dateFormat dateFromString:string];
    [dateFormat setDateFormat:@"HH:mm"];
    NSString *hourString = [dateFormat stringFromDate:date];
    return hourString;
}

+ (NSString *)NSDateToHourString:(NSDate *)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    NSString *hourString = [dateFormat stringFromDate:date];
    return hourString;
}

+ (NSString *)dateTimeFromNSDate:(NSDate *)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd'T'HHmmss"];
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
}

+ (NSString *)durationStringFromDurationNumber:(NSNumber *)duration {
    long seconds = [duration longValue];
    long days = seconds / (60 * 60 * 24);
    seconds -= (days * (60 * 60 * 24));
    long hours = seconds / (60 * 60);
    seconds -= hours * (60 * 60);
    long minutes = seconds / 60;
    
    if (hours == 0) {
        if (minutes == 0) {
            minutes = 1;
        }
        return [NSString stringWithFormat:@"%ld min", minutes];
    }
    return [NSString stringWithFormat:@"%ld h %ld min", hours, minutes];
}

@end
