//
//  EBBookAccount.h
//  EBBook
//
//  Created by Kissshot HeartUnderBlade on 12-6-28.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "EBBookChatReceiver.h"
#import "ASIFormDataRequest.h"

@class EBBookContactBookViewController;

@interface EBBookAccount : NSObject<ASIHTTPRequestDelegate>
{
    EBBookContactBookViewController *callbackViewController;
}
@property (strong, nonatomic) EBBookContactBookViewController *callbackViewController;
@property BOOL isPinging;
+ (int)checkWifiStatus;
+ (BOOL)getIsPrivateNetFlag;
+ (NSDictionary *)loadDefaultAccount;
+ (void)saveUserDefaultValue:(NSString *)value forKey:(NSString *)key;
- (BOOL)uploadPhoto:(UIImage *)imageToUpload;
- (void)checkUserActive;
- (void)manualUpdate;
+ (NSString *)currentDateToString;
+ (UIAlertView *)alertVerify:(NSString *)appisdoing;
+ (void)dismissAlertVerify:(UIAlertView *)alertShowing;
+ (NSString *)deviceToken;
- (void)pingServer;
@end
