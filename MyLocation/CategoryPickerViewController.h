//
//  CategoryPickerViewController.h
//  MyLocation
//
//  Created by Grégoire Jacquin on 30/10/12.
//  Copyright (c) 2012 Grégoire Jacquin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CategoryPickerViewController;

@protocol CategoryPickerViewControllerDelegate <NSObject>

- (void)CategoryPicker:(CategoryPickerViewController *)controller didPickCategory:(NSString *)categoryName;

@end

@interface CategoryPickerViewController : UITableViewController

@property (nonatomic, weak) id <CategoryPickerViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *selectedCategoryName;

@end
