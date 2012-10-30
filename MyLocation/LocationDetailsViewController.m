//
//  LocationDetailsViewController.m
//  MyLocation
//
//  Created by Grégoire Jacquin on 28/10/12.
//  Copyright (c) 2012 Grégoire Jacquin. All rights reserved.
//

#import "LocationDetailsViewController.h"

@interface LocationDetailsViewController ()

@end

@implementation LocationDetailsViewController {
    NSString *descriptionText;
}
@synthesize descriptionTextView;
@synthesize categoryLabel;
@synthesize latitudeLabel;
@synthesize longitudeLabel;
@synthesize addressLabel;
@synthesize dateLabel;
@synthesize coordinate;
@synthesize placemark;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        descriptionText = @"";
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.descriptionTextView.text = descriptionText;
    self.categoryLabel.text = @"";
    
    self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f",self.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f",self.coordinate.longitude];
    
    if(placemark != nil)
    {
        self.addressLabel.text = [self stringFromPlacemark:self.placemark];
    }
    else {
        self.addressLabel.text = @"No Address found";
    }
    self.dateLabel.text = [self formatDate:[NSDate date]];
}
- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
    return [NSString stringWithFormat:@"%@ %@, %@ %@, %@ %@",placemark.subThoroughfare,placemark.thoroughfare
            ,placemark.locality,placemark.administrativeArea,placemark.postalCode,placemark.country];
}
- (NSString *)formatDate:(NSDate *)theDate
{
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return [formatter stringFromDate:theDate];
}
-(void)done:(id)sender
{
    [self closeScreen];
}
- (void)cancel:(id)sender
{
    [self closeScreen];
}
- (void) closeScreen
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 && indexPath.section == 0)
    {
        return 88;
    }
    else if (indexPath.row == 2 && indexPath.row == 2)
    {
        CGRect rect = CGRectMake(100, 10, 190, 1000);
        self.addressLabel.frame = rect;
        [self.addressLabel sizeToFit];
        
        rect.size.height = self.addressLabel.frame.size.height;
        self.addressLabel.frame = rect;
        
        return self.addressLabel.frame.size.height + 20;
        
    }
    else
    {
        return 44;
    }
    
}

@end