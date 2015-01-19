//
//  JourneyTransportStepTableViewCell.m
//  easyWay
//
//  Created by Tchikovani on 12/01/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

#import "JourneyTransportStepTableViewCell.h"
#import "TransportStepView.h"
#import "UIView+Additions.h"
#import "ColorFactory.h"
#import "DateTimeTool.h"
#import "HexColor.h"

@interface JourneyTransportStepTableViewCell ()

@property (nonatomic, strong) UILabel *hourStepLabel;
@property (nonatomic, strong) UILabel *durationStepLabel;
@property (nonatomic, strong) UILabel *transportType;
@property (nonatomic, strong) UIView *lineColor;

@property (nonatomic, strong) UILabel *fromLabel;
@property (nonatomic, strong) UILabel *directionLabel;
@property (nonatomic, strong) UILabel *destinationLabel;

@end

@implementation JourneyTransportStepTableViewCell

- (instancetype)init {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JourneyTransportStepCell"];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        self.hourStepLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 5.0f, 40.0f, 10.0f)];
        self.hourStepLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:10.0f];
        self.hourStepLabel.textAlignment = NSTextAlignmentCenter;
        self.hourStepLabel.textColor = [ColorFactory blackTextColor];
        [self addSubview:self.hourStepLabel];
        
        self.transportType = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, self.hourStepLabel.bottom + 5.0f, 20.0f, 20.0f)];
        self.transportType.textAlignment = NSTextAlignmentCenter;
        self.transportType.textColor = [ColorFactory blueTransportText];
        self.transportType.font = [UIFont fontWithName:@"Montserrat-Regular" size:13.0f];
        self.transportType.layer.borderWidth = 2.0f;
        self.transportType.layer.borderColor = [ColorFactory blueTransportText].CGColor;
        self.transportType.layer.cornerRadius = 9;
        [self addSubview:self.transportType];
        
        self.durationStepLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.transportType.bottom + 5.0f, 40.0f, 10.0f)];
        self.durationStepLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:8.0f];
        self.durationStepLabel.textAlignment = NSTextAlignmentCenter;
        self.durationStepLabel.textColor = [ColorFactory blackTextColor];
        [self addSubview:self.durationStepLabel];
        
        self.lineColor = [[UIView alloc] initWithFrame:CGRectMake(self.hourStepLabel.right, 0.0f, 3.0f, self.contentView.height)];
        self.lineColor.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.lineColor];
        
        self.fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.lineColor.right + 5.0f, 10.0f, self.contentView.width - self.lineColor.right + 5.0f, 15.0f)];
        self.fromLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:11.0f];
        self.fromLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.fromLabel.textColor = [ColorFactory blackTextColor];
        [self addSubview:self.fromLabel];
        
        self.directionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.fromLabel.left, self.fromLabel.bottom, self.fromLabel.width, 15.0f)];
        self.directionLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:11.0f];
        self.directionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.directionLabel.textColor = [ColorFactory blackTextColor];
        [self addSubview:self.directionLabel];
        
        self.destinationLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.directionLabel.left, self.directionLabel.bottom, self.directionLabel.width, 15.0f)];
        self.destinationLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:11.0f];
        self.destinationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.destinationLabel.textColor = [ColorFactory blackTextColor];
        [self addSubview:self.destinationLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.fromLabel.width = self.contentView.width - self.lineColor.right + 10.0f;
    self.directionLabel.width = self.contentView.width - self.lineColor.right + 10.0f;
    self.destinationLabel.width = self.contentView.width - self.lineColor.right + 10.0f;
}

- (void)initContentCell:(NSDictionary *)stepTransport {
    self.hourStepLabel.text = [DateTimeTool dateTimeToHourString:[stepTransport objectForKey:@"departure_date_time"]];
    self.durationStepLabel.text = [DateTimeTool timeFromDuration:[stepTransport objectForKey:@"duration"]];
    
    NSString *transportMode = [[stepTransport objectForKey:@"display_informations"] objectForKey:@"physical_mode"];
    NSDictionary *infoLine = [stepTransport objectForKey:@"display_informations"];
    if ([transportMode isEqualToString:@"Tramway"]) {
        self.transportType.text = @"T";
    }
    else if ([transportMode isEqualToString:@"Bus"] &&
             [[infoLine objectForKey:@"network"] isEqualToString:@"RATP"]) {
        self.transportType.text = @"B";
    }
    else if ([transportMode isEqualToString:@"Bus"] &&
             [[infoLine objectForKey:@"network"] isEqualToString:@"Noctilien"]) {
        self.transportType.text = @"N";
    }
    
    UIColor *color;
    if ([[infoLine objectForKey:@"color"] isEqualToString:@"FFFFFF"]) {
        color = [ColorFactory redLightColor];
    }
    else {
        color = [UIColor colorWithHexString:[infoLine objectForKey:@"color"]];
    }
    [self.lineColor setBackgroundColor:color];
    
    NSMutableAttributedString *fromText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Depuis: %@", [[[stepTransport objectForKey:@"from"] objectForKey:@"stop_point"] objectForKey:@"name"]]];
    [fromText setAttributes:@{
                              NSFontAttributeName : [UIFont fontWithName:@"Montserrat-Regular" size:11.0f]
                              } range:NSMakeRange(0, 8)];
    [fromText setAttributes:@{
                              NSFontAttributeName : [UIFont fontWithName:@"Montserrat-Bold" size:11.0f]
                              } range:NSMakeRange(8, fromText.length - 8)];
    [self.fromLabel setAttributedText:fromText];
    
    NSMutableAttributedString *directionText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Direction: %@", [infoLine objectForKey:@"direction"]]];
    [directionText setAttributes:@{
                                   NSFontAttributeName : [UIFont fontWithName:@"Montserrat-Regular" size:11.0f]
                                   } range:NSMakeRange(0, 11)];
    [directionText setAttributes:@{
                              NSFontAttributeName : [UIFont fontWithName:@"Montserrat-Bold" size:11.0f]
                              } range:NSMakeRange(11, directionText.length - 11)];
    [self.directionLabel setAttributedText:directionText];
    
    
    NSMutableAttributedString *destinationText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Jusqu'à: %@", [[[stepTransport objectForKey:@"to"] objectForKey:@"stop_point"] objectForKey:@"name"]]];
    [destinationText setAttributes:@{
                                   NSFontAttributeName : [UIFont fontWithName:@"Montserrat-Regular" size:11.0f]
                                   } range:NSMakeRange(0, 9)];
    [destinationText setAttributes:@{
                                   NSFontAttributeName : [UIFont fontWithName:@"Montserrat-Bold" size:11.0f]
                                   } range:NSMakeRange(9, destinationText.length - 9)];
    [self.destinationLabel setAttributedText:destinationText];
}

@end
