//
//  CircleView.m
//  Moovizi
//
//  Created by Tchikovani on 16/01/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

#import "CircleView.h"

@interface CircleView ()

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *borderColor;

@end

@implementation CircleView

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color {
    self = [super initWithFrame:frame];
    if (self) {
        self.color = color;
        self.borderColor = nil;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color borderColor:(UIColor *)borderColor {
    self = [super initWithFrame:frame];
    if (self) {
        self.color = color;
        self.borderColor = borderColor;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextSetAlpha(context, 1.0f);
    CGContextFillEllipseInRect(context, CGRectMake(0,0,self.frame.size.width,self.frame.size.height));
    
    if (self.borderColor) {
        CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
        CGContextStrokeEllipseInRect(context, CGRectMake(0,0,self.frame.size.width,self.frame.size.height));
    }
}

@end
