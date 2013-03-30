//
//  LocationViewController.h
//  MyLocation
//
//  Created by Grégoire Jacquin on 08/11/12.
//  Copyright (c) 2012 Grégoire Jacquin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
