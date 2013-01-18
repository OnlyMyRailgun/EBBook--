//
//  MOSTools.h
//  MobileOfficeSuite
//
//  Created by Asce on 10/25/12.
//  Copyright (c) 2012 Ebupt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOSTools : NSObject
+ (NSString *)getFilePathInDocument:(NSString *)name;
+ (BOOL)isFileExistInDocument:(NSString *)name;
+ (UIAlertView *)alertVerify:(NSString *)appisdoing;
+ (void)dismissAlertVerify:(UIAlertView *)alertShowing;
+ (int)checkWifiStatus;
+ (BOOL)savePhotoToCurrentPhoto:(UIImage *)image;
@end