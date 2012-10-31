//
//  HudView.h
//  MyLocation
//
//  Created by Grégoire Jacquin on 31/10/12.
//  Copyright (c) 2012 Grégoire Jacquin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HudView : UIView

+ (HudView *)hudInView:(UIView *)view animated:(BOOL)animated;

@property (nonatomic,strong) NSString *text;

@end
