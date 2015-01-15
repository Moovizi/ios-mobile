//
//  ColorFactory.m
//  PrettyAndGoPrestataire
//
//  Created by Gauthier Beignie on 04/11/2014.
//  Copyright (c) 2014 EkkoTime. All rights reserved.
//

#import "ColorFactory.h"

@implementation ColorFactory

/*
 *  red
 */

+ (UIColor *) redLightColor {
    return [UIColor colorWithRed:200.0f/255.0f green:79.0f/255.0f blue:75.0f/255.0f alpha:1.0f];
}

+ (UIColor *) redBoldColor {
    return [UIColor colorWithRed:182.0f/255.0f green:33.0f/255.0f blue:47.0f/255.0f alpha:1.0f];
}

/*
 *  Yellow
 */

+ (UIColor *) yellowColor {
    return [UIColor colorWithRed:214.0f/255.0f green:163.0f/255.0f blue:75.0f/255.0f alpha:1.0f];
}

/*
 *  Beige
 */

+ (UIColor *) beigeColor {
    return [UIColor colorWithRed:251.0f/255.0f green:212.0f/255.0f blue:172.0f/255.0f alpha:1.0f];
}

/*
 *  Brown
 */

+ (UIColor *) brownColor {
    return [UIColor colorWithRed:175.0f/255.0f green:153.0f/255.0f blue:113.0f/255.0f alpha:1.0f];
}


/*
 *  Gray
 */

+ (UIColor *) grayBorder {
    return [UIColor colorWithRed:185.0f/255.0f green:185.0f/255.0f blue:185.0f/255.0f alpha:1.0f];
}

/*
 *  Black
 */

+ (UIColor *) blackTextColor {
    return [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1];
}

/*
 *  Blue
 */

+ (UIColor *) blueTransportText {
    return [UIColor colorWithRed:21.0f/255.0f green:16.0f/255.0f blue:137.0f/255.0f alpha:1];
}

@end
