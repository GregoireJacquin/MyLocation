//
//  NSMutableString+AddText.m
//  MyLocation
//
//  Created by Grégoire Jacquin on 24/03/13.
//  Copyright (c) 2013 Grégoire Jacquin. All rights reserved.
//

#import "NSMutableString+AddText.h"

@implementation NSMutableString (AddText)
- (void)addText:(NSString *)text withSeparator:(NSString *)separator
{
    if (text != nil) {
        if ([self length] > 0) {
            [self appendString:separator];
        }
        [self appendString:text];
    }
}
@end
