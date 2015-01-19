//
//  AddressTableViewCell.m
//  Moovizi
//
//  Created by Tchikovani on 28/12/2014.
//  Copyright (c) 2014 Tchikovani. All rights reserved.
//

#import "AddressTableViewCell.h"
#import "UIView+Additions.h"
#import "ColorFactory.h"

@interface AddressTableViewCell ()

@end

@implementation AddressTableViewCell

- (instancetype)init
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddressCell"];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    
        self.iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 20.0f, 20.0f)];
        [self addSubview:self.iconImage];
        
        self.mainAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 10.0f, self.contentView.width - 50.0f, 20.0f)];
        self.mainAddressLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.mainAddressLabel.textColor = [ColorFactory blackTextColor];
        self.mainAddressLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:14.0f];
        [self addSubview:self.mainAddressLabel];
        
        self.cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, self.mainAddressLabel.bottom, self.contentView.width - 50.0f, 20.0f)];
        self.cityLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.cityLabel.textColor = [ColorFactory grayBorder];
        self.cityLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:13.0f];
        [self addSubview:self.cityLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.iconImage.center = self.contentView.center;
    self.iconImage.left = 10.0f;
    if ([self.cityLabel.text length] == 0) {
        self.mainAddressLabel.center = self.contentView.center;
        self.mainAddressLabel.left = 40.0f;
    }
    else {
        self.mainAddressLabel.top = 10.0f;
    }
}

@end
