//
//  JourneyStepTableViewCell.m
//  Moovizi
//
//  Created by Tchikovani on 12/01/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

#import "JourneyWalkingStepTableViewCell.h"
#import "UIView+Additions.h"
#import "ColorFactory.h"
#import "HexColor.h"
#import "CircleView.h"
#import "DateTimeTool.h"

@interface JourneyWalkingStepTableViewCell ()

@property (nonatomic, strong) NSDictionary *stepTransport;

@property (nonatomic, strong) UILabel *hourStepLabel;
@property (nonatomic, strong) UILabel *durationStepLabel;
@property (nonatomic, strong) UIImageView *typeStepImage;
@property (nonatomic, strong) UILabel *walkingText;
@property (nonatomic, strong) UILabel *destinationLabel;

@end

@implementation JourneyWalkingStepTableViewCell

- (instancetype)init {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JourneyWalkingStepCell"];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.hourStepLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 5.0f, 40.0f, 10.0f)];
        self.hourStepLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:10.0f];
        self.hourStepLabel.textAlignment = NSTextAlignmentCenter;
        self.hourStepLabel.textColor = [ColorFactory blackTextColor];
        [self addSubview:self.hourStepLabel];
        
        self.typeStepImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, self.hourStepLabel.bottom + 5.0f, 15.0f, 15.0f)];
        self.typeStepImage.contentMode = UIViewContentModeScaleAspectFit;
        self.typeStepImage.image = [UIImage imageNamed:@"walking.png"];
        [self addSubview:self.typeStepImage];
        
        self.durationStepLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.typeStepImage.bottom + 5.0f, 40.0f, 10.0f)];
        self.durationStepLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:8.0f];
        self.durationStepLabel.textAlignment = NSTextAlignmentCenter;
        self.durationStepLabel.textColor = [ColorFactory blackTextColor];
        [self addSubview:self.durationStepLabel];
        
        self.walkingText = [[UILabel alloc] initWithFrame:CGRectMake(self.hourStepLabel.right + 15.0f,
                                                                    5.0f,
                                                                    self.contentView.width - 45.0f,
                                                                     20.0f)];
        self.walkingText.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.walkingText.font = [UIFont fontWithName:@"Montserrat-Regular" size:12.0f];
        self.walkingText.textColor = [ColorFactory blackTextColor];
        [self addSubview:self.walkingText];
        
        self.destinationLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.walkingText.left,
                                                                     self.walkingText.bottom,
                                                                     self.contentView.width - 50.0f,
                                                                     20.0f)];
        self.destinationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.destinationLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:11.0f];
        self.destinationLabel.textColor = [ColorFactory blackTextColor];
        [self addSubview:self.destinationLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (CGFloat posY = 3.0f; posY < self.contentView.height - 3.0f; posY += 5.0f) {
        CircleView *circle = [[CircleView alloc] initWithFrame:CGRectMake(self.hourStepLabel.right, posY, 3.0f, 3.0f)
                                                         color:[ColorFactory blackTextColor]];
        [self addSubview:circle];
    }
    
    if ([[self.stepTransport objectForKey:@"type"] isEqualToString:@"street_network"]) {
        self.destinationLabel.hidden = NO;
        self.walkingText.top = 5.0f;
        self.walkingText.height = 20.0f;
    }
    else if ([[self.stepTransport objectForKey:@"type"] isEqualToString:@"transfer"]) {
        self.destinationLabel.hidden = YES;
        self.walkingText.top = 0.0f;
        self.walkingText.height = self.contentView.height;
    }
}

- (void)initContentCell:(NSDictionary *)stepTransport {
    self.stepTransport = stepTransport;
    self.hourStepLabel.text = [DateTimeTool dateTimeToHourString:[stepTransport objectForKey:@"departure_date_time"]];
    self.durationStepLabel.text = [DateTimeTool durationStringFromDurationNumber:[stepTransport objectForKey:@"duration"]];
    
    if ([[stepTransport objectForKey:@"type"] isEqualToString:@"street_network"]) {
        self.walkingText.text = @"Aller jusqu'à:";
        NSString *destination;
        if ([[[stepTransport objectForKey:@"to"] objectForKey:@"embedded_type"]
             isEqualToString:@"stop_point"]) {
            destination = [NSString stringWithFormat:@"Station - %@", [[[stepTransport objectForKey:@"to"]
                                                                        objectForKey:@"stop_point"]
                                                                       objectForKey:@"name"]];
        }
        else if ([[[stepTransport objectForKey:@"to"] objectForKey:@"embedded_type"]
                  isEqualToString:@"address"]) {
            destination = [[stepTransport objectForKey:@"to"]
                           objectForKey:@"name"];
        }
        self.destinationLabel.text = destination;
    }
    else if ([[stepTransport objectForKey:@"type"] isEqualToString:@"transfer"]) {
        self.walkingText.text = @"Correspondance";
    }
}

@end
