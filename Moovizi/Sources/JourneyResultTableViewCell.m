//
//  JourneyResultTableViewCell.m
//  Moovizi
//
//  Created by Tchikovani on 10/01/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

#import "JourneyResultTableViewCell.h"
#import "UIView+Additions.h"
#import "ColorFactory.h"
#import "DateTimeTool.h"
#import "HexColor.h"
#import "TransportStepView.h"

@interface JourneyResultTableViewCell ()

@property (nonatomic, strong) UIImageView *typeImage;
@property (nonatomic, strong) UILabel *timesLabel;
@property (nonatomic, strong) UIView *stepsView;
@property (nonatomic, strong) NSDictionary *journey;

@end

@implementation JourneyResultTableViewCell

- (instancetype)init {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JourneyResultCell"];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setBackgroundColor:[UIColor clearColor]];
        self.typeImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 15.0f, 15.0f)];
        self.typeImage.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.typeImage];
        
        self.timesLabel = [[UILabel alloc] initWithFrame:CGRectMake(35.0f, self.typeImage.top, 170.0f, 15.0f)];
        self.timesLabel.textColor = [ColorFactory blackTextColor];
        self.timesLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:13.0f];
        [self addSubview:self.timesLabel];
        
        self.stepsView = [[UIView alloc] initWithFrame:CGRectMake(self.timesLabel.left, self.timesLabel.bottom + 3.0f, self.contentView.width - 40.0f, 25.0f)];
        self.stepsView.layer.borderColor = [UIColor redColor].CGColor;
        self.stepsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.stepsView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    /*
     *  If it's not a walking path, we draw the steps in the stepsView
     */
    NSArray *sections = [self.journey objectForKey:@"sections"];
    CGFloat typePosX = 0.0f;
    CGFloat typePosY = 0.0f;
    NSInteger index = 0;
    if ([sections count] > 1) {
        for (NSDictionary *section in sections) {
            if ([[section objectForKey:@"type"] isEqualToString:@"transfer"] ||
                [[section objectForKey:@"type"] isEqualToString:@"waiting"]) {
                index++;
                continue;
            }
            if ([[section objectForKey:@"type"] isEqualToString:@"street_network"]) {
                UIImageView *walk = [[UIImageView alloc] initWithFrame:CGRectMake(typePosX, typePosY + 5.0f, 15.0f, 15.0f)];
                walk.image = [UIImage imageNamed:@"walking.png"];
                walk.contentMode = UIViewContentModeScaleAspectFit;
                typePosX += 15.0f;
                [self.stepsView addSubview:walk];
            }
            else if ([[section objectForKey:@"type"] isEqualToString:@"public_transport"])  {
                TransportStepView *transportStepView = [[TransportStepView alloc] initWithFrame:CGRectMake(typePosX, typePosY, 300.0f, 20.0f)
                                                                                  stepTransport:section];
                if (transportStepView.right > self.stepsView.width) {
                    typePosY += 25.0f;
                    typePosX = 0.0f;
                    transportStepView.left = typePosX;
                    transportStepView.top = typePosY;
                }
                typePosX += transportStepView.width + 5.0f;
                [self.stepsView addSubview:transportStepView];
            }
            if ([sections count] > 0 && index < [sections count] - 1) {
                UIImageView *nextStep = [[UIImageView alloc] initWithFrame:CGRectMake(typePosX, typePosY + 5.0f, 15.0f, 15.0f)];
                nextStep.image = [UIImage imageNamed:@"next_step.png"];
                nextStep.contentMode = UIViewContentModeScaleAspectFit;
                typePosX += 20.0f;
                [self.stepsView addSubview:nextStep];
            }
            if (index < [sections count] - 1 && typePosX > self.stepsView.width - 60) {
                typePosX = 0.0f;
                self.stepsView.height += 25.0f;
                typePosY += 25.0f;
            }
            index++;
        }
    }
}

- (void)initContentCell:(NSDictionary *)journey {
    self.journey = journey;
    [self.stepsView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    if ([[self.journey objectForKey:@"type"] isEqualToString:@"non_pt_walk"]) {
        self.typeImage.image = [UIImage imageNamed:@"walking.png"];
        UILabel *walking = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 2.5f, 100.0f, 20.0f)];
        walking.text = @"Chemin piéton";
        walking.textColor = [ColorFactory blackTextColor];
        walking.font = [UIFont fontWithName:@"Montserrat-Regular" size:13.0f];
        [self.stepsView addSubview:walking];
    }
    else {
        self.typeImage.image = [UIImage imageNamed:@"public_transport.png"];
    }
    
    self.timesLabel.text = [NSString stringWithFormat:@"%@ - %@ (%@)",
                            [DateTimeTool dateTimeToHourString:[self.journey objectForKey:@"departure_date_time"]],
                            [DateTimeTool dateTimeToHourString:[self.journey objectForKey:@"arrival_date_time"]],
                            [DateTimeTool durationStringFromDurationNumber:[self.journey objectForKey:@"duration"]]];
}

@end
