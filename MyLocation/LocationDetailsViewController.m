//
//  LocationDetailsViewController.m
//  MyLocation
//
//  Created by Grégoire Jacquin on 28/10/12.
//  Copyright (c) 2012 Grégoire Jacquin. All rights reserved.
//

#import "LocationDetailsViewController.h"
#import "HudView.H"
#import "Location.h"
#import "NSMutableString+AddText.h"


@interface LocationDetailsViewController ()

@end

@implementation LocationDetailsViewController {
    NSString *descriptionText;
    NSString *categoryName;
    NSDate *date;
    UIImage *image;
    UIActionSheet * actionSheet;
    UIImagePickerController * imagePicker;
}
@synthesize descriptionTextView;
@synthesize categoryLabel;
@synthesize latitudeLabel;
@synthesize longitudeLabel;
@synthesize addressLabel;
@synthesize dateLabel;
@synthesize coordinate;
@synthesize placemark;
@synthesize managedObjectContext;
@synthesize imageView;
@synthesize photoLabel;

@synthesize editLocation;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        descriptionText = @"";
        categoryName = @"No Category";
        date = [NSDate date];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (editLocation != nil) {
        self.title = @"Edit location";
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        
        if ([self.editLocation hasPhoto] && image == nil)
        {
            UIImage *existingImage = [self.editLocation photoImage];
            if (existingImage!= Nil)
            {
                [self showImage:existingImage];
            }
        }
    }
    if (image != nil) {
        [self showImage:image];
    }
    
    self.descriptionTextView.text = descriptionText;
    self.categoryLabel.text = categoryName;
    
    self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f",self.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f",self.coordinate.longitude];
    
    if(placemark != nil)
    {
        self.addressLabel.text = [self stringFromPlacemark:self.placemark];
    }
    else {
        self.addressLabel.text = @"No Address found";
    }
    self.dateLabel.text = [self formatDate:date];
    
    UITapGestureRecognizer *gestureReconizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard:)];
    gestureReconizer.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:gestureReconizer];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}
- (void) applicationDidEnterBackground
{
    if (imagePicker!= nil)
    {
        [self.navigationController dismissViewControllerAnimated:NO completion: Nil];
        imagePicker = nil;
    }
    if (actionSheet!=Nil)
    {
        [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated: NO];
        actionSheet = nil;
    }
            
    [self.descriptionTextView resignFirstResponder];
}
- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
    NSMutableString *line = [NSMutableString stringWithCapacity: 100];
    
    [line addText:thePlacemark.subThoroughfare withSeparator:@""];
    [line addText:thePlacemark.thoroughfare withSeparator:@""];
    [line addText:thePlacemark.locality withSeparator:@","];
    [line addText:thePlacemark.administrativeArea withSeparator:@", "];
    [line addText:thePlacemark.postalCode withSeparator:@" "];
    [line addText:thePlacemark.country withSeparator:@", "];
    
    return line;
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
- (int)nextPhotoId
{
    int photoId = [[NSUserDefaults standardUserDefaults] integerForKey:@"photoId"];
    [[NSUserDefaults standardUserDefaults] setInteger:photoId + 1 forKey: @"photoId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return photoId;
}
-(IBAction)done:(id)sender
{
    HudView *hudView = [HudView hudInView:self.navigationController.view animated:YES];
    
    
    Location *location = nil;
    if(editLocation != nil)
    {
        hudView.text = @"Update";
        location = editLocation;
    }
    else {
        hudView.text = @"Tagged";
        location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:managedObjectContext];
        location.photoId = [NSNumber numberWithInt:-1];
    }
    location.locationDescription = descriptionText;
    location.latitude = [NSNumber numberWithDouble:self.coordinate.latitude];
    location.longitude = [NSNumber numberWithDouble:self.coordinate.longitude]; location.date = date;
    location.placemark = self.placemark;
    location.category = categoryName;
    if (image!=Nil)
    {
        if (![location hasPhoto]) {
            location.photoId = [NSNumber numberWithInt:[self nextPhotoId]];
        }
        NSData * data = UIImagePNGRepresentation (image);
        NSError *erreur;
        if (![data writeToFile:[location photoPath] options:NSDataWritingAtomic error:&erreur]) {
            NSLog (@"Erreur d'écriture du fichier:%@", erreur);
        }
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error %@",error);
        FATAL_CORE_DATA_ERROR(error);
    }
    
    [self performSelector:@selector(closeScreen) withObject:self afterDelay:0.8];
    //[self closeScreen];
}
- (IBAction)cancel:(id)sender
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
- (void)takePhoto
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}
-(void)choosePhotoFromLibrary
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}
- (void)showPhotoMenu
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
        
        [actionSheet showInView:self.view];
    } else {
        [self choosePhotoFromLibrary];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && self.view.window == nil) {
        self.view = nil;
    }
    
    if (! [self isViewLoaded]) {
        self.descriptionTextView = nil;
        self.categoryLabel = nil;
        self.latitudeLabel = nil;
        self.longitudeLabel = nil;
        self.addressLabel = nil;
        self.dateLabel = nil;
        self.imageView = nil;
        self.photoLabel = nil;
    }
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 || indexPath.section == 1)
    {
        return indexPath;
    } else {
        return nil;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        [self.descriptionTextView becomeFirstResponder];
    } else if (indexPath.section == 1 && indexPath.row == 0)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self showPhotoMenu];
    }
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 && indexPath.section == 0)
    {
        return 88;
    }
    else if (indexPath.section == 1)
    {
        if (self.imageView.hidden) {
            return 44;
        } else {
            return 280;
        }
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
-(void)showImage:(UIImage *)theImage
{
    self.imageView.image = theImage;
    self.imageView.hidden = NO;
    self.imageView.frame = CGRectMake(10, 10, 260, 260);
    self.photoLabel.hidden = NO;
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

#pragma mark - Getter & Setter
- (void)setEditLocation:(Location *)newLocation
{
    if (newLocation != nil) {
        editLocation = newLocation;
        
        descriptionText = editLocation.locationDescription;
        categoryName = editLocation.category;
        
        self.coordinate = CLLocationCoordinate2DMake([editLocation.latitude doubleValue], [editLocation.longitude doubleValue]);
        self.placemark = editLocation.placemark;
        
        date = editLocation.date;
        
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if([self isViewLoaded])
    {
        [self showImage:image];
        [self.tableView reloadData];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    actionSheet = nil;
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    actionSheet = nil;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)theActionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self takePhoto];
    } else if (buttonIndex == 1) {
        [self choosePhotoFromLibrary];
    }
    actionSheet = nil;
}

@end
