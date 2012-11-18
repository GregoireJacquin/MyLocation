//
//  Locations.h
//  MyLocation
//
//  Created by Grégoire Jacquin on 07/11/12.
//  Copyright (c) 2012 Grégoire Jacquin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Location : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) CLPlacemark *placemark;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * locationDescription;

@end
