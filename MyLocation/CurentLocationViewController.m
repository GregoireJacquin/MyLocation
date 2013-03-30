//
//  FirstViewController.m
//  MyLocation
//
//  Created by Grégoire Jacquin on 15/10/12.
//  Copyright (c) 2012 Grégoire Jacquin. All rights reserved.
//

#import "CurentLocationViewController.h"
#import "LocationDetailsViewController.h"
#import "NSMutableString+AddText.h"
#import <QuartzCore/QuartzCore.h>

@interface CurentLocationViewController ()

- (void)updateLabels;
- (void)stopLocationManager;
- (void)startLocationManager;
- (void)configureGetButton;
- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark;
- (void)showLogoView;
- (void)hideLogoViewAnimated:(BOOL) animated;

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
    UIActivityIndicatorView *activity;
    
    UIImageView *logoImageView;
    bool firstTime;
    
}
@synthesize messageLabel;
@synthesize lattitudeLabel;
@synthesize longitudeLabel;
@synthesize addressLabel;
@synthesize getButton;
@synthesize tagButton;
@synthesize managedObjectContext;
@synthesize longitudeTextLabel;
@synthesize latitudeTextLabel;
@synthesize panelView;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        locationManager = [[CLLocationManager alloc]init];
        geocoder = [[CLGeocoder alloc]init];
        firstTime = YES;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self updateLabels];
    [self configureGetButton];
    if (firstTime) {
        [self showLogoView];
    } else {
        [self hideLogoViewAnimated:NO];
    }
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
    if(firstTime) {
        firstTime = NO;
        [self hideLogoViewAnimated:YES];
    }
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
        self.longitudeTextLabel.hidden = NO;
        self.latitudeTextLabel.hidden = NO;
        
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
        self.longitudeTextLabel.hidden = YES;
        self.latitudeTextLabel.hidden = YES;
        
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
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activity.center = CGPointMake(self.getButton.bounds.size.width - activity.bounds.size.width/2.0f - 10, self.getButton.bounds.size.height / 2.0f);
        [activity startAnimating];
        [self.getButton addSubview:activity];
    }
    else
    {
        [self.getButton setTitle:@"Get My Location" forState:UIControlStateNormal];
        [activity removeFromSuperview];
        activity = nil;
    }
}
- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
    NSMutableString *line1 = [NSMutableString stringWithCapacity:100];
    [line1 addText:thePlacemark.subThoroughfare withSeparator:@""];
    [line1 addText:thePlacemark.thoroughfare withSeparator:@" "];
    
    NSMutableString *line2 = [NSMutableString stringWithCapacity:100];
    [line2 addText:thePlacemark.locality withSeparator:@""];
    [line2 addText:thePlacemark.administrativeArea withSeparator:@" "];
    [line2 addText:thePlacemark.postalCode withSeparator:@" "];
    
    if ([line1 length] == 0) {
        [line2 appendString:@"\n "];  // need two lines or UILabel will vertically center the text
        return line2;
    } else {
        [line1 appendString:@"\n"];
        [line1 appendString:line2];
        return line1;
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"TagLocation"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        LocationDetailsViewController *controller = (LocationDetailsViewController *)navigationController.topViewController;
        controller.managedObjectContext = managedObjectContext;
        controller.placemark = placemark;
        controller.coordinate = location.coordinate;
    }
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

#pragma mark - Logo

- (void)showLogoView
{
    self.panelView.hidden = YES;
    
    logoImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @ "Logo"]];
    logoImageView.center = CGPointMake (160.0f, 140.0f);
    [self.view addSubview:logoImageView];
}

- (void)hideLogoViewAnimated:(BOOL)animated
{
    self.panelView.hidden = NO;
    
    if (animated) {
        
        self.panelView.center = CGPointMake (600.0f, 140.0f);
        CABasicAnimation *panelMover = [CABasicAnimation animationWithKeyPath:@"position"];
        panelMover.removedOnCompletion = NO;
        panelMover.fillMode = kCAFillModeForwards;
        panelMover.duration = 0.6f;
        panelMover.fromValue = [NSValue valueWithCGPoint:self.panelView.center];
        panelMover.toValue = [NSValue valueWithCGPoint: CGPointMake (160.0f, self.panelView.center.y)];
        panelMover.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        panelMover.delegate = self;
        [self.panelView.layer addAnimation: panelMover forKey:@"PanelMover"];
        
        CABasicAnimation * logoMover = [CABasicAnimation animationWithKeyPath: @ "position"];
        logoMover.removedOnCompletion = NO;
        logoMover.fillMode = kCAFillModeForwards;
        logoMover.duration = 0.5f;
        logoMover.fromValue = [NSValue valueWithCGPoint: logoImageView.center];
        logoMover.toValue = [NSValue valueWithCGPoint: CGPointMake (- 160.0f, logoImageView.center.y)];
        logoMover.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn];
        [logoImageView.layer addAnimation: logoMover forKey: @ "logoMover"];
        
        CABasicAnimation * logoRotator = [CABasicAnimation animationWithKeyPath: @ "transform.rotation.z"];
        logoRotator.removedOnCompletion = NO;
        logoRotator.fillMode = kCAFillModeForwards;
        logoRotator.duration = 0.5f;
        logoRotator.fromValue = [NSNumber numberWithFloat: 0];
        logoRotator.toValue = [NSNumber numberWithFloat: - 2 * M_PI];
        logoRotator.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn];
        [logoImageView.layer addAnimation:logoRotator forKey:@"logoRotator"];
        
    } else {
        [logoImageView removeFromSuperview];
        logoImageView = nil;
    }
}
- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.panelView.layer removeAllAnimations];
    self.panelView.center = CGPointMake (160.0f, 140.0f);
    
    [logoImageView.layer removeAllAnimations];
    [logoImageView removeFromSuperview];
    logoImageView = nil;
}
@end
