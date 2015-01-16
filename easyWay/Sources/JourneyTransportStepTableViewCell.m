//
//  JourneyTransportStepTableViewCell.m
//  easyWay
//
//  Created by Tchikovani on 12/01/2015.
//  Copyright (c) 2015 Tchikovani. All rights reserved.
//

#import "JourneyTransportStepTableViewCell.h"
#import "TransportStepView.h"

@interface JourneyTransportStepTableViewCell ()

@property (nonatomic, strong) UIImageView *typeStepImage;
//@property (nonatomic, strong) TransportStepView *transportView;

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
        
        //self.transportView = [TransportStepView alloc] initWithFrame:CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
    }
    return self;
}

- (void)initContentCell:(NSDictionary *)stepTransport {
    
}

@end
