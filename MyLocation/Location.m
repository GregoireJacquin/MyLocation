//
//  Locations.m
//  MyLocation
//
//  Created by Grégoire Jacquin on 07/11/12.
//  Copyright (c) 2012 Grégoire Jacquin. All rights reserved.
//

#import "Location.h"


@implementation Location

@dynamic latitude;
@dynamic longitude;
@dynamic category;
@dynamic placemark;
@dynamic date;
@dynamic locationDescription;
@dynamic photoId;

-(CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake([self.latitude doubleValue],[self.longitude doubleValue]);
}
-(NSString *)title
{
    if([self.locationDescription length] > 0)
    {
        return  self.locationDescription;
    }
    else {
        return @"Pas de description";
    }
}
-(NSString *)subtitle
{
    return self.category;
}
- (BOOL)hasPhoto
{
    return (self.photoId != nil) && ([self.photoId intValue] != -1);
}
- (NSString *) documentsDirectory
{
    NSArray * chemins = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [chemins objectAtIndex:0];
    return  documentsDirectory;
}
- (NSString *)photoPath
{
    NSString *fileName = [NSString stringWithFormat:@"photo-%d.png",[self.photoId intValue]];
    return [[self documentsDirectory]stringByAppendingPathComponent:fileName];
}
- (UIImage *)photoImage
{
    NSAssert(self.photoId != Nil, @"Pas d'identité avec photo");
    NSAssert([self.photoId intValue] != -1, @ "Photo d'identité est -1");
    
    return [UIImage imageWithContentsOfFile:[self photoPath]];
}
- (void)removePhotoFile
{
    NSString *path = [self photoPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *erreur;
        if (![fileManager removeItemAtPath:path error:&erreur]) {
            NSLog(@"Erreur à la suppression du fichier:%@", erreur);
        }
    }
}
@end
