//
//  MapViewController.m
//  MyLocation
//
//  Created by Grégoire Jacquin on 24/12/12.
//  Copyright (c) 2012 Grégoire Jacquin. All rights reserved.
//

#import "MapViewController.h"
#import "Location.h"
#import "LocationDetailsViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController {
    NSArray *locations;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.managedObjectContext];
    }
    return self;
}
- (void)contextDidChange:(NSNotification *)notification
{
    if([self isViewLoaded])
    {
        [self updateLocations];
    }
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:self.managedObjectContext];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateLocations];
    if ([locations count] > 0) {
        [self showLocations];
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showUser {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate,1000,1000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
}
- (IBAction)showLocations {
    MKCoordinateRegion region = [self regionForAnnotations:locations];
    [self.mapView setRegion:region animated:YES];
}
-(void)updateLocations
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(foundObjects == nil)
    {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    if(locations != nil)
        [self.mapView removeAnnotations:locations];
    
    locations  = foundObjects;
    [self.mapView addAnnotations:locations];
}
-(MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations
{
    MKCoordinateRegion region;
    if([annotations count] == 0)
    {
        region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
    }else if ([annotations count] == 1)
    {
        id<MKAnnotation> annotation = [annotations lastObject];
        region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000);
    } else {
        CLLocationCoordinate2D topLeftCoord;
        topLeftCoord.latitude = -90;
        topLeftCoord.longitude = 180;
        
        CLLocationCoordinate2D bottomLeftCoord;
        topLeftCoord.latitude = 90;
        topLeftCoord.longitude = -180;
        
        for (id<MKAnnotation> annotation in annotations) {
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
            topLeftCoord.longitude = fmax(topLeftCoord.longitude, annotation.coordinate.longitude);
            bottomLeftCoord.latitude = fmax(bottomLeftCoord.latitude, annotation.coordinate.latitude);
            bottomLeftCoord.longitude = fmax(bottomLeftCoord.longitude, annotation.coordinate.longitude);
        }
        const double extraSpace = 1.1;
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomLeftCoord.latitude) / 2.0;
        region.center.longitude = topLeftCoord.longitude - (topLeftCoord.longitude - bottomLeftCoord.longitude) / 2.0;
        
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomLeftCoord.latitude) * extraSpace;
        region.span.longitudeDelta = fabs(topLeftCoord.longitude - bottomLeftCoord.longitude) * extraSpace;
        
    }
    
    return [self.mapView regionThatFits:region];
}
- (void)showLocationsDetails:(UIButton *)button
{
    [self performSegueWithIdentifier:@"EditLocation" sender:button];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"EditLocation"])
    {
        UINavigationController *navigationController = segue.destinationViewController;
        LocationDetailsViewController *controller = (LocationDetailsViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        Location *location = [locations objectAtIndex:((UIButton *)sender).tag];
        controller.editLocation = location;
    }
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[Location class]])
    {
        static NSString *identifiant = @"Location";
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifiant];
        if(annotationView == nil)
        {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifiant];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.animatesDrop = NO;
            annotationView.pinColor = MKPinAnnotationColorGreen;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(showLocationsDetails:) forControlEvents:UIControlEventTouchUpInside];
            annotationView.rightCalloutAccessoryView = rightButton;
        } else {
            annotationView.annotation = annotation;
        }
        UIButton *button = (UIButton *)annotationView.rightCalloutAccessoryView;
        button.tag = [locations indexOfObject:(Location *)annotation];
        
        return annotationView;
    }
    return nil;
}


@end
