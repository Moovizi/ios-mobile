//
//  JourneyStepTableViewCell.m
//  easyWay
//
//  Created by Tchikovani on 12/01/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

#import "JourneyWalkingStepTableViewCell.h"
#import "UIView+Additions.h"
#import "ColorFactory.h"
#import "HexColor.h"

@interface JourneyWalkingStepTableViewCell ()

@property (nonatomic, strong) UIImageView *typeStepImage;
@property (nonatomic, strong) UILabel *walkingText;
@property (nonatomic, strong) UILabel *destinationLabel;

@end

@implementation JourneyWalkingStepTableViewCell

- (instancetype)init
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JourneyWalkingStepCell"];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.typeStepImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 15.0f, 15.0f, 15.0f)];
        self.typeStepImage.contentMode = UIViewContentModeScaleAspectFit;
        self.typeStepImage.image = [UIImage imageNamed:@"walking.png"];
        [self addSubview:self.typeStepImage];
        
        self.walkingText = [[UILabel alloc] initWithFrame:CGRectMake(self.typeStepImage.right + 10.0f,
                                                                    5.0f,
                                                                    self.contentView.width - 45.0f,
                                                                     20.0f)];
        self.walkingText.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.walkingText.font = [UIFont fontWithName:@"Montserrat-Regular" size:13.0f];
        self.walkingText.textColor = [ColorFactory blackTextColor];
        [self addSubview:self.walkingText];
        
        self.destinationLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.walkingText.left,
                                                                     self.walkingText.bottom,
                                                                     self.contentView.width - 45.0f,
                                                                     20.0f)];
        self.destinationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.destinationLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:13.0f];
        self.destinationLabel.textColor = [ColorFactory blackTextColor];
        [self addSubview:self.destinationLabel];
    }
    return self;
}

- (void)initContentCell:(NSDictionary *)stepTransport {
    if ([[stepTransport objectForKey:@"type"] isEqualToString:@"street_network"]) {
        self.walkingText.text = @"Aller jusqu'à:";
    }
    else if ([[stepTransport objectForKey:@"type"] isEqualToString:@"transfer"]) {
        self.walkingText.text = @"Correspondance";
    }
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

@end
