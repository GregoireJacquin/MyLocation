//
//  FirstViewController.m
//  MyLocation
//
//  Created by Grégoire Jacquin on 15/10/12.
//  Copyright (c) 2012 Grégoire Jacquin. All rights reserved.
//

#import "CurentLocationViewController.h"

@interface CurentLocationViewController ()

- (void)updateLabels;
- (void)stopLocationManager;
- (void)startLocationManager;
- (void)configureGetButton;
- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark;

@end

@implementation CurentLocationViewController
{
    CLLocationManager *locationManager;
    CLLocation *location;
    BOOL updatingLocation;
    NSError *lastLocationError;
    
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    BOOL performingReverseGeocoding;
    NSError *lastGeocoderError;
    
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
        geocoder = [[CLGeocoder alloc]init];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self updateLabels];
    [self configureGetButton];
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
    if (updatingLocation) {
        [self stopLocationManager];
    }
    else
    {
        location = nil;
        lastLocationError = nil;
        placemark = nil;
        lastGeocoderError = nil;
        [self startLocationManager];
    }
    
    [self updateLabels];
    [self configureGetButton];
}
- (void)updateLabels
{
    if(location != nil)
    {
        self.messageLabel.text = @"GPS Coordinate";
        self.lattitudeLabel.text = [NSString stringWithFormat:@"%f.8",location.coordinate.latitude];
        self.longitudeLabel.text = [NSString stringWithFormat:@"%f.8",location.coordinate.longitude];
        self.tagButton.hidden = NO;
        
        if (placemark != nil) {
            self.addressLabel.text = [self stringFromPlacemark:placemark];
        }
        else if (performingReverseGeocoding){
            self.addressLabel.text = @"Search address ...";
        }
        else if (lastLocationError != nil){
            self.addressLabel.text = @"Error finding address";
        }
        else{
            self.addressLabel.text = @"No address found";
        }
    }
    else
    {
        self.lattitudeLabel.text = @"";
        self.longitudeLabel.text = @"";
        self.tagButton.hidden = YES;
        
        NSString *statusMessage;
        if(lastLocationError != nil)
        {
            if([lastLocationError.domain isEqualToString:kCLErrorDomain] && lastLocationError.code == kCLErrorDenied)
            {
                statusMessage = @"Location services disabled";
            }
            else
            {
                statusMessage = @"Error getting location";
            }
        }
        else if (![CLLocationManager locationServicesEnabled])
        {
            statusMessage = @"Location services disabled";
        }
        else if (updatingLocation)
        {
            statusMessage = @"Searching...";
        }
        else
        {
            statusMessage = @"Press the button to start";
        }
        self.messageLabel.text = statusMessage;
    }
}
- (void)stopLocationManager
{
    if(updatingLocation)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
        [locationManager stopUpdatingLocation];
        locationManager.delegate = nil;
        updatingLocation = NO;
    }
}
- (void)startLocationManager
{
    if([CLLocationManager locationServicesEnabled])
    {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [locationManager startUpdatingLocation];
        updatingLocation = YES;
        
        [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60];
    }
}
- (void)didTimeOut:(id)obj
{
    NSLog(@"Time out");
    if(location == nil)
    {
        [self stopLocationManager];
        lastLocationError = [NSError errorWithDomain:@"MyLocationErrorDomain" code:1 userInfo:nil];
        [self updateLabels];
        [self configureGetButton];
    }
}
- (void)configureGetButton
{
    if(updatingLocation)
    {
        [self.getButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
    else
    {
        [self.getButton setTitle:@"Get My Location" forState:UIControlStateNormal];
    }
}
- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
    return [NSString stringWithFormat:@"%@ %@ \n%@ %@ %@",thePlacemark.subThoroughfare,thePlacemark.thoroughfare,thePlacemark.locality,thePlacemark.administrativeArea,thePlacemark.postalCode];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateLocation %@",newLocation);
    if([newLocation.timestamp timeIntervalSinceNow] < -0.5)
        return;
    if (newLocation.horizontalAccuracy < 0)
    {
        return;
    }
        //Problem no GPS >>>
        CLLocationDistance distance = MAXFLOAT;
        if (location != nil) {
            distance = [newLocation distanceFromLocation:location];
        }
        //<<<
    if (location == nil || location.horizontalAccuracy > newLocation.horizontalAccuracy)
    {
        lastLocationError = nil;
        location = newLocation;
        [self updateLabels];
        
        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            NSLog(@"We're done !");
            [self stopLocationManager];
            [self configureGetButton];
            //Problem no GPS >>>
            if(distance > 0)
            {
                performingReverseGeocoding = YES;
            }
            //<<<
        }
        
        if(!performingReverseGeocoding)
        {
            NSLog(@"*** Aller geocoder");
            performingReverseGeocoding = YES;
            
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                NSLog(@"Repere %@, Error %@",placemarks,error);
                
                lastGeocoderError = error;
                if(error == nil && [placemarks count] > 0)
                {
                    placemark = [placemarks lastObject];
                }
                else{
                    placemark = nil;
                }
                performingReverseGeocoding = NO;
                [self updateLabels];
            }];
        }
        //Problem no GPS >>>
        else if (distance < 0.1)
        {
            NSTimeInterval timerInterval = [newLocation.timestamp timeIntervalSinceDate:location.timestamp];
            if (timerInterval > 10) {
                NSLog(@"Force done!");
                [self stopLocationManager];
                [self updateLabels];
                [self configureGetButton];
            }
        }
        //<<<
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError %@",error);
    if(error.code == kCLErrorLocationUnknown)
    {
        return;
    }
    [self stopLocationManager];
    lastLocationError = error;
    
    [self updateLabels];
    [self configureGetButton];
}
@end
