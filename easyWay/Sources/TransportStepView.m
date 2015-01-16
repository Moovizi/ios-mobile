//
//  TransportStepView.m
//  easyWay
//
//  Created by Tchikovani on 15/01/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

#import "TransportStepView.h"
#import "ColorFactory.h"
#import "UIView+Additions.h"
#import "HexColor.h"

@interface TransportStepView ()

@property (nonatomic, strong) NSDictionary *stepTransport;
@property (nonatomic, strong) UILabel *transportType;
@property (nonatomic, strong) UILabel *lineCode;

@end

@implementation TransportStepView

- (instancetype)initWithFrame:(CGRect)frame stepTransport:(NSDictionary *)stepTransport {
    self = [super initWithFrame:frame];
    if (self) {
        NSDictionary *infoLine = [stepTransport objectForKey:@"display_informations"];
        NSString *transportMode = [[stepTransport objectForKey:@"display_informations"] objectForKey:@"physical_mode"];
        NSString *code = [infoLine objectForKey:@"code"];
        self.transportType = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 2.5f, 20.0f, 20.0f)];
        self.transportType.textAlignment = NSTextAlignmentCenter;
        if ([transportMode isEqualToString:@"Tramway"]) {
            self.transportType.text = @"T";
            code = [[infoLine objectForKey:@"code"] substringFromIndex:1];
        }
        else if ([transportMode isEqualToString:@"Bus"] &&
                 [[infoLine objectForKey:@"network"] isEqualToString:@"RATP"]) {
            self.transportType.text = @"B";
        }
        else if ([transportMode isEqualToString:@"Bus"] &&
                 [[infoLine objectForKey:@"network"] isEqualToString:@"Noctilien"]) {
            self.transportType.text = @"N";
            code = [[infoLine objectForKey:@"code"] substringFromIndex:1];
        }
        self.transportType.textColor = [ColorFactory blueTransportText];
        self.transportType.font = [UIFont fontWithName:@"Montserrat-Regular" size:13.0f];
        self.transportType.layer.borderWidth = 2.0f;
        self.transportType.layer.borderColor = [ColorFactory blueTransportText].CGColor;
        self.transportType.layer.cornerRadius = 9;
        [self addSubview:self.transportType];
        
        UIColor *color;
        if ([[infoLine objectForKey:@"color"] isEqualToString:@"FFFFFF"]) {
            color = [ColorFactory redLightColor];
        }
        else {
            color = [UIColor colorWithHexString:[infoLine objectForKey:@"color"]];
        }
        
        self.lineCode = [[UILabel alloc] initWithFrame:CGRectMake(self.transportType.right + 3.0f, 2.5f, 300.0f, 20.0f)];
        [self.lineCode setBackgroundColor:color];
        self.lineCode.textAlignment = NSTextAlignmentCenter;
        self.lineCode.textColor = [UIColor whiteColor];
        self.lineCode.font = [UIFont fontWithName:@"Montserrat-Regular" size:13.0f];
        self.lineCode.text = code;
        self.lineCode.numberOfLines = 0;
        self.lineCode.lineBreakMode = NSLineBreakByWordWrapping;
    
        CGSize maximumLabelSize = CGSizeMake(300.0f, 20.0f);
        CGSize expectSize = [self.lineCode sizeThatFits:maximumLabelSize];
        
        [self.lineCode sizeToFit];
        self.lineCode.width = expectSize.width + 10.0f;
        self.lineCode.height = 20.0f;
        [self addSubview:self.lineCode];
        self.width = self.lineCode.right;
    }
    return self;
}

@end
