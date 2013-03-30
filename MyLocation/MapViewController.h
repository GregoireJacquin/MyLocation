//
//  MapViewController.h
//  MyLocation
//
//  Created by Grégoire Jacquin on 24/12/12.
//  Copyright (c) 2012 Grégoire Jacquin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,strong) IBOutlet MKMapView *mapView;

- (IBAction)showUser;
- (IBAction)showLocations;

@end
