//
//  UIImage+Additions.h
//  easyWay
//
//  Created by Tchikovani on 20/12/2014.
//  Copyright (c) 2014 Tchikovani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)

- (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
