//
//  LocationCell.m
//  MyLocation
//
//  Created by Grégoire Jacquin on 08/11/12.
//  Copyright (c) 2012 Grégoire Jacquin. All rights reserved.
//

#import "LocationCell.h"

@implementation LocationCell
@synthesize descriptionLabel,addressLabel,imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
