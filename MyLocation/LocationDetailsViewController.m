//
//  LocationDetailsViewController.m
//  MyLocation
//
//  Created by Grégoire Jacquin on 28/10/12.
//  Copyright (c) 2012 Grégoire Jacquin. All rights reserved.
//

#import "LocationDetailsViewController.h"
#import "HudView.H"


@interface LocationDetailsViewController ()

@end

@implementation LocationDetailsViewController {
    NSString *descriptionText;
    NSString *categoryName;
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
        categoryName = @"No Category";
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
    
    UITapGestureRecognizer *gestureReconizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard:)];
    gestureReconizer.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:gestureReconizer];
}
- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
    return [NSString stringWithFormat:@"%@ %@, %@ %@, %@ %@",thePlacemark.subThoroughfare,thePlacemark.thoroughfare
            ,thePlacemark.locality,thePlacemark.administrativeArea,thePlacemark.postalCode,thePlacemark.country];
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
    HudView *hudView = [HudView hudInView:self.navigationController.view animated:YES];
    hudView.text = @"Tagged";
    
    [self performSelector:@selector(closeScreen) withObject:self afterDelay:0.8];
    //[self closeScreen];
}
- (void)cancel:(id)sender
{
    [self closeScreen];
}
- (void) closeScreen
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)hideKeyboard:(UIGestureRecognizer *)gestureReconizer
{
    CGPoint point = [gestureReconizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if (indexPath != 0 && indexPath.row == 0 && indexPath.section ==0) {
        return;
    }
    [self.descriptionTextView resignFirstResponder];
}
#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.section == 1)
    {
        return indexPath;
    } else {
        return nil;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 && indexPath.section == 0)
    {
        [self.descriptionTextView becomeFirstResponder];
    }
}
- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 && indexPath.section == 0)
    {
        return 88;
    }
    else if (indexPath.row == 2 && indexPath.section == 2)
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PickCategory"])
    {
        CategoryPickerViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.selectedCategoryName = categoryName;
    }
}
#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    descriptionText = [theTextView.text stringByReplacingCharactersInRange:range withString:text];
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    descriptionText = textView.text;
}
#pragma mark - CategoryPickerDelegate
- (void)CategoryPicker:(CategoryPickerViewController *)controller didPickCategory:(NSString *)theCategoryName
{
    categoryName = theCategoryName;
    self.categoryLabel.text = categoryName;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
