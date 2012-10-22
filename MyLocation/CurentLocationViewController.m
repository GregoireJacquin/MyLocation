//
//  FirstViewController.m
//  MyLocation
//
//  Created by Grégoire Jacquin on 15/10/12.
//  Copyright (c) 2012 Grégoire Jacquin. All rights reserved.
//

#import "CurentLocationViewController.h"

@interface CurentLocationViewController ()

@end

@implementation CurentLocationViewController
{
    CLLocationManager *locationManager;
    CLLocation *location;
}
@synthesize messageLabel;
@synthesize lattitudeLabel;
@synthesize longitudeLabel;
@synthesize addressLabel;
@synthesize getButton;
@synthesize tagButton;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        locationManager = [[CLLocationManager alloc]init];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self updateLabels];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.messageLabel = nil;
    self.lattitudeLabel = nil;
    self.longitudeLabel = nil;
    self.addressLabel =nil;
    self.tagButton = nil;
    self.getButton = nil;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)getLocation:(id)sender
{
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];
}
- (void)updateLabels
{
    if(location != nil)
    {
        self.messageLabel.text = @"GPS Coordinate";
        self.lattitudeLabel.text = [NSString stringWithFormat:@"%f.8",location.coordinate.latitude];
        self.longitudeLabel.text = [NSString stringWithFormat:@"%f.8",location.coordinate.longitude];
        self.tagButton.hidden = NO;
    }
    else
    {
        self.messageLabel.text = @"push button for start";
        self.lattitudeLabel.text = @"";
        self.longitudeLabel.text = @"";
        self.tagButton.hidden = YES;
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateLocation %@",newLocation);
    location = newLocation;
    [self updateLabels];
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError %@",error);
}
@end
