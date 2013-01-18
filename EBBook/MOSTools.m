//
//  MOSTools.m
//  MobileOfficeSuite
//
//  Created by Asce on 10/25/12.
//  Copyright (c) 2012 Ebupt. All rights reserved.
//

#import "MOSTools.h"
#import "Reachability.h"

@implementation MOSTools
+ (NSString *)getFilePathInDocument:(NSString *)name
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:name];
}

+ (BOOL)isFileExistInDocument:(NSString *)name
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    return [file_manager fileExistsAtPath:[MOSTools getFilePathInDocument:name]];
}

+ (UIAlertView *)alertVerify:(NSString *)appisdoing
{
    UIAlertView *verifyView = [[UIAlertView alloc] initWithTitle:appisdoing message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    UIActivityIndicatorView *activeView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activeView.center = CGPointMake(verifyView.bounds.size.width/2.0f+140.0f, verifyView.bounds.size.height+75.0f);
    //activeView.center = CGPointMake(verifyView.bounds.size.width/2.0f, verifyView.bounds.size.height-40.0f);
    [activeView startAnimating];
    [verifyView addSubview:activeView];
    [activeView release];
    [verifyView show];
    return [verifyView autorelease];
}

+ (void)dismissAlertVerify:(UIAlertView *)alertShowing
{
    [alertShowing dismissWithClickedButtonIndex:0 animated:YES];
}

+ (int)checkWifiStatus
{
    if([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable)
    {
        return ReachableViaWiFi;
    }
    else if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable){
        return ReachableViaWWAN;
    }
    else {
        return NotReachable;
    }
}

+ (BOOL)savePhotoToCurrentPhoto:(UIImage *)image
{
    BOOL success = NO;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *imageFile = [documentsDirectory stringByAppendingPathComponent:@"default.jpg"];
    
    success = [[self class] savePhoto:image toPath:imageFile];
    return success;
}

+ (BOOL)savePhoto:(UIImage *)image toPath:(NSString *)path
{
    BOOL success = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    [fileManager fileExistsAtPath:path];
    //if(success) {
    [fileManager removeItemAtPath:path error:&error];
    //}
    
    NSData *data;
    
    if (UIImagePNGRepresentation(image) == nil) {
        
        data = UIImageJPEGRepresentation(image, 1);
        
    } else {
        
        data = UIImagePNGRepresentation(image);
        
    }
    
    success = [data writeToFile:path atomically:YES];
    return success;
}

@end
