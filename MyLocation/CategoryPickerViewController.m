//
//  CategoryPickerViewController.m
//  MyLocation
//
//  Created by Grégoire Jacquin on 30/10/12.
//  Copyright (c) 2012 Grégoire Jacquin. All rights reserved.
//

#import "CategoryPickerViewController.h"

@interface CategoryPickerViewController ()

@end

@implementation CategoryPickerViewController
{
    NSArray *categories;
    NSIndexPath *selectedIndexPath;
}
@synthesize delegate,selectedCategoryName;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    categories = [NSArray arrayWithObjects:@"No Category",
                  @"Apple Store",
                  @"Bar",
                  @"Bookstore",
                  @"Club",
                  @"Grocery Store",
                  @"Historic Building",
                  @"House",
                  @"Icecream Vendor",
                  @"Landmark",
                  @"Park",
                  nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [categories count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *categoryName = [categories objectAtIndex:indexPath.row];
    cell.textLabel.text = categoryName;
    
    if ([categoryName isEqualToString:self.selectedCategoryName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        selectedIndexPath = indexPath;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != selectedIndexPath.row) {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:indexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        
        selectedIndexPath = indexPath;
    }
    NSString *categoryName = [categories objectAtIndex:indexPath.row];
    [self.delegate CategoryPicker:self didPickCategory:categoryName];
}

@end
