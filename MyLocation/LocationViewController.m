//
//  LocationViewController.m
//  MyLocation
//
//  Created by Grégoire Jacquin on 08/11/12.
//  Copyright (c) 2012 Grégoire Jacquin. All rights reserved.
//

#import "LocationViewController.h"
#import "LocationCell.h"
#import "Location.h"
#import "LocationDetailsViewController.h"
#import "UIImage+Resize.h"
#import "NSMutableString+AddText.h"

@interface LocationViewController ()

@end

@implementation LocationViewController
{
    NSArray *locations;
    NSFetchedResultsController *fetchedResultsController;
}
@synthesize managedObjectContext;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (NSFetchedResultsController *)fetchedResultsController
{
    if(fetchedResultsController == nil)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor1,sortDescriptor2, nil]];
        [fetchRequest setFetchBatchSize:20];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"category" cacheName:@"Locations"];
        fetchedResultsController.delegate = self;
    }
    return  fetchedResultsController;
}
- (void)performFetch
{
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self performFetch];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    LocationCell *locationCell = (LocationCell *)cell;
    Location *location = [fetchedResultsController objectAtIndexPath:indexPath];
    
    if (location.locationDescription > 0) {
        locationCell.descriptionLabel.text = location.locationDescription;
    } else {
        locationCell.descriptionLabel.text = @"(No description)";
    }
    if(location.placemark != nil) {
        NSMutableString *string = [NSMutableString stringWithCapacity:100];
        
        [string addText:location.placemark.subThoroughfare withSeparator:@""];
        [string addText:location.placemark.thoroughfare withSeparator:@" "];
        [string addText:location.placemark.locality withSeparator:@", "];
        
        locationCell.addressLabel.text = string;
    } else {
        locationCell.addressLabel.text = [NSString stringWithFormat:@"Lat: %.8f Long: %.8f",[location.latitude doubleValue],[location.longitude doubleValue]];
    }
    UIImage *image = nil;
    if([location hasPhoto])
    {
        image = [location photoImage];
        if(image != nil)
            image = [image resizedImageWithBounds:CGSizeMake(66, 66)];
    }

    locationCell.imageView.image = image;
}
- (void)dealloc
{
    fetchedResultsController.delegate = nil;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Location"];
    [self configureCell:cell indexPath:indexPath];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditLocation"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        LocationDetailsViewController *controller = (LocationDetailsViewController*)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Location* location = [fetchedResultsController objectAtIndexPath:indexPath];
        controller.editLocation = location;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:location];
        [location removePhotoFile];
        [self.managedObjectContext deleteObject:location];
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeInsert");
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeDelete");
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeUpdate");
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] indexPath:newIndexPath];
            break;
        case NSFetchedResultsChangeMove:
            NSLog(@"*** controllerDidChangeObject - NSFetchedResultsChangeMove");
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }

}
-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"*** controllerDidChangeSection - NSFetchedResultsChangeInsert");
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            NSLog(@"*** controllerDidChangeSection - NSFetchedResultsChangeDelete"); [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
        break; }
}
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}
@end
