//
//  LocationCell.h
//  MyLocation
//
//  Created by Grégoire Jacquin on 08/11/12.
//  Copyright (c) 2012 Grégoire Jacquin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel * descriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel * addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
