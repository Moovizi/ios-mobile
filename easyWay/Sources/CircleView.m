//
//  CircleView.m
//  easyWay
//
//  Created by Tchikovani on 16/01/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

#import "CircleView.h"

@interface CircleView ()

@property (nonatomic, strong) UIColor *color;

@end

@implementation CircleView

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color {
    self = [super initWithFrame:frame];
    if (self) {
        self.color = color;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextSetAlpha(context, 1.0f);
    CGContextFillEllipseInRect(context, CGRectMake(0,0,self.frame.size.width,self.frame.size.height));
}

@end
