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

@interface JourneyTransportStepTableViewCell ()

@property (nonatomic, strong) UIImageView *typeStepImage;
@property (nonatomic, strong) TransportStepView *transportStepView;

@end

@implementation JourneyTransportStepTableViewCell


- (instancetype)init
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JourneyTransportStepCell"];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        self.typeStepImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 15.0f, 15.0f, 15.0f)];
        self.typeStepImage.contentMode = UIViewContentModeScaleAspectFit;
        self.typeStepImage.image = [UIImage imageNamed:@"public_transport.png"];
        [self addSubview:self.typeStepImage];
        
        self.transportStepView = [[TransportStepView alloc] initWithFrame:CGRectMake(self.typeStepImage.right + 10.0f, 10.0f, 300.0f, 20.0f)];
        [self addSubview:self.transportStepView];
    }
    return self;
}

- (void)initContentCell:(NSDictionary *)stepTransport {
    [self.transportStepView updateTheContent:stepTransport];
}

@end
