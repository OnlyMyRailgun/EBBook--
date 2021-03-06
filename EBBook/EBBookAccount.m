//
//  EBBookAccount.m
//  EBBook
//
//  Created by Kissshot HeartUnderBlade on 12-6-28.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import "EBBookAccount.h"
#import <libetpan/libetpan.h>
#import "EBSurfPopAccount.h"
#import "MAlertView.h"
#import "EBBookContactBookViewController.h"
#import "EBBookDatabase.h"
#import "Ebbook.pb.h"
#import "ASIHTTPRequest.h"
#import <MobClick.h>
#import "SimplePingHelper.h"
#import "EBBookAppDelegate.h"

@interface EBBookAccount()
{
    id activeAlertView;
    UITextField *accountField;
    UITextField *passwdField;
    UIAlertView *verifyView;
    NSString *userNameToSave;
    //UIView *helpView;
}
@end

@implementation EBBookAccount

@synthesize callbackViewController;
static BOOL isPrivateNet = YES;
#define MAILPORT 110
#define HOSTSERVER @"pop.exmail.qq.com"
#define PRIVATENETHOST @"10.1.69.113"
#define PUBLICNETHOST @"218.249.60.69"
#define ReleaseTimeStamp @"1358167521"
#define ReleasePhotoTimeStamp @"1358167589"

- (id)init
{
    if(self = [super init])
    {
        _isPinging = NO;
    }
    return self;
}

+ (BOOL)connectToMail:(NSString *)userName withPassword:(NSString *)password
{ 
    BOOL connectSuccess = NO;
    int	encryption = CONNECTION_TYPE_PLAIN;
	int authentication = POP3_AUTH_TYPE_PLAIN;
    EBSurfPopAccount *account = [[EBSurfPopAccount alloc] init];
    
	@try   {
        [account connectToServer:HOSTSERVER port:MAILPORT connectionType:encryption authType:authentication login:[userName stringByAppendingString:@"@ebupt.com"] password:password];
        connectSuccess = YES;
    } @catch (NSException *exp) {
        NSLog(@"connect exception: %@", exp);
        connectSuccess = NO;
	}
    [account release];
    return connectSuccess;
}

+ (NSDictionary *)loadDefaultAccount
{
    NSMutableDictionary *userInfoDictionary = [NSMutableDictionary dictionary];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    @try {
        [userInfoDictionary setValue:[userDefaults objectForKey:@"userName"] forKey:@"userName"];
        [userInfoDictionary setValue:[userDefaults objectForKey:@"onlyWifi"] forKey:@"onlyWifi"];
        [userInfoDictionary setValue:[userDefaults objectForKey:@"dialConfirm"] forKey:@"dialConfirm"];
        [userInfoDictionary setValue:[userDefaults objectForKey:@"needUploadPhoto"] forKey:@"needUploadPhoto"];
        [userInfoDictionary setValue:[userDefaults objectForKey:@"updateTimeStamp"] forKey:@"updateTimeStamp"];
        [userInfoDictionary setValue:[userDefaults objectForKey:@"updatePhotoTimeStamp"] forKey:@"updatePhotoTimeStamp"];
        [userInfoDictionary setValue:[userDefaults objectForKey:@"checkTimeStamp"] forKey:@"checkTimeStamp"];
        [userInfoDictionary setValue:[userDefaults objectForKey:@"version"] forKey:@"version"];
        [userInfoDictionary setValue:[userDefaults objectForKey:@"defaultTab"] forKey:@"defaultTab"];
        [userInfoDictionary setValue:[userDefaults objectForKey:@"friendTimestamp"] forKey:@"friendTimestamp"];
    }
    @catch (NSException *exception) {
        NSLog(@"load userInfo err:%@",exception);
    }
    return userInfoDictionary;
}

+ (void)saveUserDefaultValue:(NSString *)value forKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
    
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

- (void)pingResultBeforeParseFromProtoBuf:(NSNumber*)success {
	if (success.boolValue) {
		NSLog(@"is private net");
        isPrivateNet = YES;
	} else {
		NSLog(@"is public net");
        isPrivateNet = NO;
	}
}

- (void)checkUserActive
{
    BOOL needActive = YES;
    NSDictionary *usrInfo = [EBBookAccount loadDefaultAccount];
    if([usrInfo objectForKey:@"userName"])
        needActive = NO;
    if(needActive)
    {
        UIAlertView *noInternet = [[UIAlertView alloc] initWithTitle:@"用户验证"
                                                             message:@"没有可用的网络连接" delegate:self
                                                   cancelButtonTitle:nil otherButtonTitles:nil];
        if([[self class] checkWifiStatus] == NotReachable)
        {
            if(![noInternet isVisible])
            {
                [noInternet show];
            }
            [noInternet release];
            return;
        }

        [noInternet dismissWithClickedButtonIndex:0 animated:NO];
        [noInternet release];
        UILabel *mail = [[UILabel alloc] init];
        mail.frame = CGRectMake(0, 0, 100, 20);
        mail.backgroundColor = [UIColor clearColor];
        mail.text = @"@ebupt.com";
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
            activeAlertView = [[UIAlertView alloc] initWithTitle:@"用户验证"
                                                        message:@"请输入您公司邮箱的用户名和密码" delegate:self
                                              cancelButtonTitle:nil otherButtonTitles:@"验证", nil];
            [activeAlertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
            [activeAlertView textFieldAtIndex:0].rightView = mail;
            [activeAlertView textFieldAtIndex:0].placeholder = @"公司邮箱";
            [activeAlertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeASCIICapable;
            [activeAlertView textFieldAtIndex:0].rightViewMode = UITextFieldViewModeAlways;
            [activeAlertView textFieldAtIndex:1].placeholder = @"邮箱密码";
        }
        else {
            activeAlertView = [[MAlertView alloc] initWithTitle:@"用户验证"
                                                        message:@"请输入您公司邮箱的用户名和密码" delegate:self
                                              cancelButtonTitle:nil otherButtonTitles:@"验证", nil];
            accountField = [[UITextField alloc] init];
            [accountField setKeyboardType:UIKeyboardTypeASCIICapable];
            [accountField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            [accountField setAutocorrectionType:UITextAutocorrectionTypeNo];
            accountField.rightView = mail;
            accountField.rightViewMode = UITextFieldViewModeAlways;
            accountField.keyboardType = UIKeyboardTypeEmailAddress;
            passwdField = [[UITextField alloc] init];
            [passwdField setSecureTextEntry:YES];

            [activeAlertView addTextField:accountField placeHolder:@"邮箱用户名"];
            [activeAlertView addTextField:passwdField placeHolder:@"邮箱密码"];
            
            [accountField release];
            [passwdField release];
        }
        [mail release];
        if(![activeAlertView isVisible])
            [activeAlertView show];
    }
    else {
        [self removeOldDB];
        [self activeUserUpdate];
        [NSThread detachNewThreadSelector:@selector(waitForClientReady) toTarget:self withObject:nil];
    }
}

- (void)waitForClientReady
{
    if([EBBookAccount checkWifiStatus] != NotReachable)
    {
        _isPinging = NO;
        [self pingServer];
        while (_isPinging) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        while (![EBBookAccount deviceToken])
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        [self performSelectorOnMainThread:@selector(runChatClient) withObject:nil waitUntilDone:NO];
    }

}

- (void)runChatClient
{
    [self chatRegister];
    [[EBBookChatReceiver shared] runReceiver];
}

- (void)removeOldDB
{
    NSDictionary *versionInfoDic = [EBBookAccount loadDefaultAccount];
    NSString *oldVersion = [versionInfoDic objectForKey:@"version"];
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if([currentVersion floatValue] > [oldVersion floatValue])
    {
        [EBBookAccount saveUserDefaultValue:ReleaseTimeStamp forKey:@"updateTimeStamp"];
        [EBBookAccount saveUserDefaultValue:ReleasePhotoTimeStamp forKey:@"updatePhotoTimeStamp"];
        //remove
        NSLog(@"remove old db");
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        for(int i=0;i<[fileList count]; i++)
        {
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[fileList objectAtIndex:i]];
            //NSLog(filePath);
            //NSURL *filepaht1=[NSURL fileURLWithPath:filePath];
            if([fileManager fileExistsAtPath:filePath]) {
                [fileManager removeItemAtPath:filePath error:&error];
            }
        }

        [EBBookAccount openLocalData];
        
        [EBBookAccount saveUserDefaultValue:currentVersion forKey:@"version"];
        
        if([[[EBBookAccount loadDefaultAccount] objectForKey:@"defaultTab"] intValue] == 0)
        {
            UIAlertView *updateSuccessAlert = [[UIAlertView alloc] initWithTitle:@"版本升级成功" message:nil delegate:self.callbackViewController cancelButtonTitle:nil otherButtonTitles:@"开始体验EB通讯录！", nil];
            [updateSuccessAlert show];
            [updateSuccessAlert release];
        }
    }
}

- (void)activeUserUpdate
{
    NSDictionary *usrInfo = [EBBookAccount loadDefaultAccount];
    //已激活用户更新
    NSString *onlyWifiValue = [usrInfo objectForKey:@"onlyWifi"];
    NSString *needUploadPhotoValue = [usrInfo objectForKey:@"needUploadPhoto"];
    if([[self class] checkWifiStatus] == NotReachable)
        return;
    
    int checkDayValue = [[usrInfo objectForKey:@"checkTimeStamp"] intValue];
    int currentDays = [[NSDate date] timeIntervalSince1970]/60/60/24;
    int days = currentDays - checkDayValue;
    
    if(days > 7)
    {
        NSLog(@"days %d",days);
        
        UIAlertView *updateOrNotAlert = [[UIAlertView alloc] initWithTitle:@"员工信息提示" message:[NSString stringWithFormat:@"员工信息已经%d天没有更新了，是否需要更新员工信息?", days] delegate:self cancelButtonTitle:@"暂不更新" otherButtonTitles:@"现在更新", nil];
        [updateOrNotAlert show];
        [updateOrNotAlert release];
    }
    
    //是否有照片需要上传
    if([needUploadPhotoValue isEqualToString:@"NO"])
    {
        NSLog(@"no need to upload");
        return;
    }
    NSLog(@"need to upload photo");
    if([[self class] checkWifiStatus] == ReachableViaWWAN){
        if([onlyWifiValue isEqualToString:@"YES"])
            return;
    }
    
    [NSThread detachNewThreadSelector:@selector(uploadPhotoToServer:) toTarget:self withObject:[[self class] getCurrentPhoto]];
}

- (void)manualUpdate
{
    [self alertVerify:@"正在更新，请稍后..."];
    [SimplePingHelper ping:PRIVATENETHOST target:self sel:@selector(pingResultBeforeParseFromProtoBuf:)];
}

- (void)pingServer
{
    _isPinging = YES;
    [SimplePingHelper ping:PRIVATENETHOST target:self sel:@selector(pingServerResult:)];
}

- (void)pingServerResult:(NSNumber *)success
{
    if(success.boolValue)
    {
        NSLog(@"pingServerResult private");
        [EBBookAccount setIsPrivateNetFlag:YES];
    }
    else {
        NSLog(@"pingServerResult public");
        [EBBookAccount setIsPrivateNetFlag:NO];
    }
    _isPinging = NO;
}

#pragma mark - alertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"验证"])
    {
        UITextField *textFieldName;
        UITextField *textFieldPassword;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) 
        {
            textFieldName = [alertView textFieldAtIndex:0];
            textFieldPassword = [alertView textFieldAtIndex:1];
        }
        else {
            textFieldName = accountField;
            textFieldPassword = passwdField;
        }
        
        if(textFieldName.text.length < 1)
        {
            UIAlertView *shortName = [[UIAlertView alloc] initWithTitle:@"信息错误" message:@"公司邮箱用户名不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [shortName show];
            [shortName release];
        }
        else if(textFieldPassword.text.length < 1)
        {
            UIAlertView *shortName = [[UIAlertView alloc] initWithTitle:@"信息错误" message:@"公司邮箱密码不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [shortName show];
            [shortName release];
        }
        else{
            [self alertVerify:@"正在联网验证，请稍后..."];
            [NSThread detachNewThreadSelector:@selector(activeAppForUser:) toTarget:self withObject:[NSArray arrayWithObjects:textFieldName.text, textFieldPassword.text, nil]];
        }
    }
    else if ([buttonTitle isEqualToString:@"确定"]) {
        [activeAlertView show];
    }
    else if ([buttonTitle isEqualToString:@"现在更新"]) {
        [self alertVerify:@"正在更新，请稍后..."];
//        [SimplePingHelper ping:PRIVATENETHOST target:self sel:@selector(pingResultBeforeParseFromProtoBuf:)];
        _isPinging = NO;
        [self pingServer];
        while (_isPinging) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        NSDictionary *usrInfo = [EBBookAccount loadDefaultAccount];
        NSString *onlyWifiValue = [usrInfo objectForKey:@"onlyWifi"];
        int currentDays = [[NSDate date] timeIntervalSince1970]/60/60/24;
        [EBBookAccount saveUserDefaultValue:[NSString stringWithFormat:@"%d",currentDays] forKey:@"checkTimeStamp"];
        [NSThread detachNewThreadSelector:@selector(parseFromProtoBuf:) toTarget:self withObject:onlyWifiValue];
    }
    else if ([buttonTitle isEqualToString:@"在线升级"]) {
        NSString *urlString = @"itms-services://?action=download-manifest&url=http://mi.ebupt.net:9002/mobile/EBBook.plist";
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)activeAppForUser:(NSArray *)infoArray
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    userNameToSave = [infoArray objectAtIndex:0];
    NSString *psword = [infoArray objectAtIndex:1];
    BOOL result = [EBBookAccount connectToMail:userNameToSave withPassword:psword];
    
    [self performSelectorOnMainThread:@selector(activeResult:) withObject:[NSNumber numberWithBool:result] waitUntilDone:NO];
    
    [pool release];
}

- (void)alertVerify:(NSString *)appisdoing
{
    verifyView = [[UIAlertView alloc] initWithTitle:appisdoing message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    UIActivityIndicatorView *activeView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activeView.center = CGPointMake(verifyView.bounds.size.width/2.0f+140.0f, verifyView.bounds.size.height+75.0f);
    //activeView.center = CGPointMake(verifyView.bounds.size.width/2.0f, verifyView.bounds.size.height-40.0f);
    [activeView startAnimating];
    [verifyView addSubview:activeView];
    [activeView release];
    [verifyView show];
    [verifyView release];
}

- (void)activeResult:(NSNumber *)result
{
    [verifyView dismissWithClickedButtonIndex:0 animated:YES];
    BOOL activeSuccess = [result boolValue];
    if(activeSuccess)
    {
        [EBBookAccount saveUserDefaultValue:userNameToSave forKey:@"userName"];
        [MobClick event:@"loginSuccess" label:userNameToSave];
        [EBBookAccount saveUserDefaultValue:@"YES" forKey:@"onlyWifi"];
        [EBBookAccount saveUserDefaultValue:@"YES" forKey:@"dialConfirm"];
        [EBBookAccount saveUserDefaultValue:@"0" forKey:@"friendTimestamp"];
        [EBBookAccount saveUserDefaultValue:ReleaseTimeStamp forKey:@"updateTimeStamp"];
        [EBBookAccount saveUserDefaultValue:ReleasePhotoTimeStamp forKey:@"updatePhotoTimeStamp"];
        int day = [ReleaseTimeStamp intValue]/60/60/24;
        [EBBookAccount saveUserDefaultValue:[NSString stringWithFormat:@"%d", day] forKey:@"checkTimeStamp"];
        [EBBookAccount saveUserDefaultValue:[NSString stringWithFormat:@"%d", 1] forKey:@"defaultTab"];
        [EBBookAccount saveUserDefaultValue:@"NO" forKey:@"needUploadPhoto"];
        NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        [EBBookAccount saveUserDefaultValue:currentVersion forKey:@"version"];

        [[self class] openLocalData];
        //int seconds = [[NSDate date] timeIntervalSince1970];
        //NSLog(@"%d",seconds);
        //[self parseFromProtoBuf:@"NO"];
        
        [[self class] savePhotoToCurrentPhoto:[UIImage imageNamed:[userNameToSave stringByAppendingString:@".jpg"]]];
        
        [self.callbackViewController refreshAction:@"全体员工"];
        [NSThread detachNewThreadSelector:@selector(waitForClientReady) toTarget:self withObject:nil];
        //[self activeUserUpdate];
        UIAlertView *verifySuccessAlert = [[UIAlertView alloc] initWithTitle:@"验证成功" message:nil delegate:self.callbackViewController cancelButtonTitle:nil otherButtonTitles:@"开始体验EB通讯录！", nil];
        [verifySuccessAlert show];
        [verifySuccessAlert release];
    }
    else {
        [MobClick event:@"loginFail" label:userNameToSave];
        UIAlertView *shortName = [[UIAlertView alloc] initWithTitle:@"未通过验证" message:@"请检查您的用户名和密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [shortName show];
        [shortName release];
    }
}

- (void)chatRegister
{
    NSString *urlStr;
    if([EBBookAccount getIsPrivateNetFlag])
    {
        urlStr = @"http://10.1.69.113:9000/clientpush/index.php";
    }
    else
        urlStr = @"http://218.249.60.69:9000/clientpush/index.php";
    ASIFormDataRequest *_formDataRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [_formDataRequest setPostValue:@"register" forKey:@"request"];
    [_formDataRequest setPostValue:[EBBookAccount deviceToken] forKey:@"device_token"];
    [_formDataRequest setPostValue:[[EBBookAccount loadDefaultAccount] objectForKey:@"userName"] forKey:@"device_uid"];
    [_formDataRequest setPostValue:@"ios" forKey:@"device_type"];
    [_formDataRequest setDelegate:self];
    
    [_formDataRequest startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = request.responseData;
    NSDictionary* jsonDic = [NSJSONSerialization
                             JSONObjectWithData:responseData
                             options:NSJSONReadingAllowFragments
                             error:nil];
    NSInteger returnCode = [[jsonDic objectForKey:@"success"] integerValue];
    if(returnCode != 0)
    {
        NSLog(@"注册失败 %@", [jsonDic objectForKey:@"msg"]);
    }
}

//- (void)dismissHelp
//{
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//    [UIView setAnimationDuration:0.6f];
//    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:[[[UIApplication sharedApplication] delegate ] window] cache:NO];
//    [helpView removeFromSuperview];
//    [UIView commitAnimations];
//}

#pragma mark - getData
- (BOOL)downloadPhoto:(NSString *)uid
{
    NSString *dataHost;
    if([[self class] getIsPrivateNetFlag])
        dataHost = PRIVATENETHOST;
    else {
        dataHost = PUBLICNETHOST;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:9000/pic/%@.jpg", dataHost, uid]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    //int statusCode = [request responseStatusCode];
    NSData *responseData = [request responseData];
    UIImage *downloadImage = [UIImage imageWithData:responseData];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *imageFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",uid]];
    return [[self class] savePhoto:downloadImage toPath:imageFile];
}

- (void)parseFromProtoBuf:(NSString *)onlyWifiOrNot
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //int seconds = [[NSDate date] timeIntervalSince1970];
    int seconds = [[[EBBookAccount loadDefaultAccount] objectForKey:@"updateTimeStamp"] intValue];
//    seconds = -1;
    NSString *dataHost;
    if([[self class] getIsPrivateNetFlag])
        dataHost = PRIVATENETHOST;
    else {
        dataHost = PUBLICNETHOST;
    }
    [MobClick event:@"update" label:[[EBBookAccount loadDefaultAccount] objectForKey:@"userName"]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:8888/contact/UpdateContact?timestamp=%d", dataHost, seconds]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setTimeOutSeconds:10];
    [request startSynchronous];
    //int statusCode = [request responseStatusCode];
    NSData *responseData = [request responseData];
    //NSString *statusMessage = [request responseStatusMessage];
    EBBookDatabase *myDatabase = [[EBBookDatabase alloc] init];
    [myDatabase openDB];
    [myDatabase createTable];
    int updateCount = 0;
    @try{
        EBContact *ebcontact = 
        [EBContact parseFromData:(responseData)];
        if([ebcontact eber].count > 0)
        {   
            updateCount = [ebcontact eber].count;
            [myDatabase createTable];
            for(EBer *eber in [ebcontact eber])
            {
                //NSLog(@"%@ %@", eber.uid,eber.newreport);
                NSLog(@"%@ ", eber.uid);
                if([myDatabase insertIntoTable:eber])
                    NSLog(@"write success");
                else {
                    NSLog(@"write fail");
                }
            }
            int currentSeconds = [[NSDate date] timeIntervalSince1970];
            NSLog(@"currentSeconds %d",currentSeconds);
            [EBBookAccount saveUserDefaultValue:[NSString stringWithFormat:@"%d",currentSeconds] forKey:@"updateTimeStamp"];
        }
        else {
            NSLog(@"No update data");
        }
    } 
    @catch (NSException *exp){
        NSLog(@"parseFromEBer error:%@", exp);
    }
    [myDatabase closeDB];
    [myDatabase release];
    
    //更新头像
    if(([[self class] checkWifiStatus] == ReachableViaWWAN) && [onlyWifiOrNot isEqualToString:@"YES"]){
        NSLog(@"won't download photos");
    }
    else {
        int secondsPhoto = [[[EBBookAccount loadDefaultAccount] objectForKey:@"updatePhotoTimeStamp"] intValue];
//        secondsPhoto = -1;
        NSURL *photoCheckUpdateUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:8888/contact/UpdateOthersPhoto?phototimestamp=%d", dataHost, secondsPhoto]];
        ASIHTTPRequest *photoCheckUpdateRequest = [ASIHTTPRequest requestWithURL:photoCheckUpdateUrl];
        [photoCheckUpdateRequest setTimeOutSeconds:10];
        [photoCheckUpdateRequest startSynchronous];
        //int statusCode = [request responseStatusCode];
        NSData *staffNeedDownloadPhotoResponseData = [photoCheckUpdateRequest responseData];
        NSString *staffNeedToDownloadPhotoStr = [[NSString alloc] initWithData:staffNeedDownloadPhotoResponseData encoding:NSUTF8StringEncoding];
        NSArray *staffNeedToDownloadPhoto = [staffNeedToDownloadPhotoStr componentsSeparatedByString:@","];
        for(NSString *peopleInStaffArray in staffNeedToDownloadPhoto)
            [self downloadPhoto:peopleInStaffArray];
        //更新新的时间戳
        if([staffNeedToDownloadPhoto count] > 0)
        {
            int currentPhotoSeconds = [[NSDate date] timeIntervalSince1970];
            NSLog(@"currentPhotoSeconds %d",currentPhotoSeconds);
            [EBBookAccount saveUserDefaultValue:[NSString stringWithFormat:@"%d",currentPhotoSeconds] forKey:@"updatePhotoTimeStamp"];
        }
    }
    
    [self performSelectorOnMainThread:@selector(updateDone:) withObject:[NSNumber numberWithInt:updateCount] waitUntilDone:NO];
    
    [pool release];
}

+ (BOOL)getIsPrivateNetFlag
{
    return isPrivateNet;
}

+ (void)setIsPrivateNetFlag:(BOOL)newflag
{
    isPrivateNet = newflag;
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

- (void)updateDone:(NSNumber *)updateCount
{
    [verifyView dismissWithClickedButtonIndex:0 animated:YES];
    //[EBBookAccount setNeedRefreshFlag:YES];
    [self.callbackViewController refreshAction:nil];
    NSString *dataHost;
    if([[self class] getIsPrivateNetFlag])
        dataHost = PRIVATENETHOST;
    else {
        dataHost = PUBLICNETHOST;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:9000/ebbook_version_ios.php", dataHost]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    //int statusCode = [request responseStatusCode];
    NSData *responseData = [request responseData];
    NSString *versionInfo = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSString *version;
    NSString *versionMessage;
    if([versionInfo rangeOfString:@"<br/>"].length > 0)
    {
        NSArray *versionInfoArray = [versionInfo componentsSeparatedByString:@"<br/>"];
        version = [versionInfoArray objectAtIndex:0];
        versionMessage = [versionInfoArray objectAtIndex:1];
    }else {
        version = versionInfo;
        versionMessage = @"当前有新版本可用，请下载更新";
    }
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSLog(@"%@, current:%@",version, currentVersion);
    if([version floatValue] > [currentVersion floatValue])
    {
        UIAlertView *updateVersionAlert;
        if([[self class] getIsPrivateNetFlag])
           updateVersionAlert = [[UIAlertView alloc] initWithTitle:@"版本更新" message:versionMessage delegate:self cancelButtonTitle:@"暂不升级" otherButtonTitles:@"在线升级", nil];
        else {
            updateVersionAlert = [[UIAlertView alloc] initWithTitle:@"版本更新" message:versionMessage delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        }

        [updateVersionAlert show];
        [updateVersionAlert release];
    }
    [versionInfo release];
    NSString *updateResultStr;
    if([updateCount intValue] > 0)
        updateResultStr = [NSString stringWithFormat:@"员工信息更新完成!共更新%d条数据",[updateCount intValue]];
    else {
        updateResultStr = @"当前没有数据需要更新~";
    }
    UIAlertView *finishUpdate = [[UIAlertView alloc] initWithTitle:@"更新完毕" message:updateResultStr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [finishUpdate show];
    [finishUpdate release];
}

+ (void)openLocalData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"EBContacts" ofType:@"db"];
    NSData *responseData = [NSData dataWithContentsOfFile:path];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *dbFile = [documentsDirectory stringByAppendingPathComponent:@"EBContacts.db"];
    
    [responseData writeToFile:dbFile atomically:YES];
}

+ (UIImage *)getCurrentPhoto
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *imageFile = [documentsDirectory stringByAppendingPathComponent:@"currentPhoto.jpg"];
    return [UIImage imageWithContentsOfFile:imageFile];
}

+ (BOOL)savePhotoToCurrentPhoto:(UIImage *)image
{
    BOOL success = NO;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *imageFile = [documentsDirectory stringByAppendingPathComponent:@"currentPhoto.jpg"];
    NSString *contactImageFileName = [[[EBBookAccount loadDefaultAccount] objectForKey:@"userName"] stringByAppendingString:@".jpg"];
    NSString *contactImageFile = [documentsDirectory stringByAppendingPathComponent:contactImageFileName];
    
    [[self class] savePhoto:image toPath:imageFile];
    success = [[self class] savePhoto:image toPath:contactImageFile];
    return success;
}

+ (BOOL)savePhoto:(UIImage *)image toPath:(NSString *)path
{
    BOOL success = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
      
    success = [fileManager fileExistsAtPath:path];
    if(success) {
        success = [fileManager removeItemAtPath:path error:&error];
    }
    
    success = [UIImageJPEGRepresentation(image, 1.0f) writeToFile:path atomically:YES];
    return success;
}

//- (void)pingResultBeforeUploadPhotoToServer:(NSNumber*)success { 
//    if(success.boolValue)
//    {
//        NSLog(@"private");
//        [EBBookAccount setIsPrivateNetFlag:YES];
//    }
//    else {
//        NSLog(@"public");
//        [EBBookAccount setIsPrivateNetFlag:NO];
//    }
//}

- (void)uploadPhotoToServer:(UIImage *)imageToUpload
{
    NSURL *url;
	if ([EBBookAccount getIsPrivateNetFlag]) {
		NSLog(@"is private net");
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:8888/contact/UpdatePhoto", PRIVATENETHOST]];
        //url = [NSURL URLWithString:[NSString stringWithFormat:@"http://10.1.72.125:8080/contact/UpdatePhoto", PRIVATENETHOST]];
	} else {
		NSLog(@"is public net");
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:8888/contact/UpdatePhoto", PUBLICNETHOST]];
	}
    BOOL toServerSuccess = NO;
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    //UIImage *myPhoto = [UIImage imageNamed:@"IMG_0029.PNG"];
    //[request setRequestMethod:@"POST"];
    NSDictionary *usrInfo = [EBBookAccount loadDefaultAccount];
    NSString *usrName = [usrInfo objectForKey:@"userName"];
    [request setData:UIImagePNGRepresentation(imageToUpload) withFileName:[usrName stringByAppendingString:@".jpg"] andContentType:@"image/jpg" forKey:@"file"];
    [request startSynchronous];
    int statusCode = [request responseStatusCode];
    NSData *responseData = [request responseData];
    NSString *statusMessage = [request responseStatusMessage];
    NSLog(@"%d,%@", statusCode, statusMessage);
    NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",result);
    if([result isEqualToString:@"UPLOAD_SUCCESS"])
    {
        toServerSuccess = YES;
        [[self class] saveUserDefaultValue:@"NO" forKey:@"needUploadPhoto"];
        UIAlertView *uploadSuccess = [[UIAlertView alloc] initWithTitle:@"头像上传成功" message:@"头像已成功上传到服务器" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [uploadSuccess show];
        [uploadSuccess release];
    }else {
        [[self class] saveUserDefaultValue:@"YES" forKey:@"needUploadPhoto"];
        UIAlertView *uploadError = [[UIAlertView alloc] initWithTitle:@"头像上传失败" message:@"   本地头像保存成功，但是目测服务器出了点状况，下次启动时EB通讯录会自动尝试帮您上传" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [uploadError show];
        [uploadError release];
    }
    [result release];
}

- (void)refreshCallbackTableView
{
    NSArray *refreshCells = [self.callbackViewController.tableView indexPathsForVisibleRows];
    [self.callbackViewController.tableView layoutIfNeeded];
    [self.callbackViewController.tableView reloadRowsAtIndexPaths:refreshCells withRowAnimation:UITableViewRowAnimationNone];
}

- (BOOL)uploadPhoto:(UIImage *)imageToUpload
{
    BOOL saveSuccess = [[self class] savePhotoToCurrentPhoto:imageToUpload];
    [self performSelectorOnMainThread:@selector(refreshCallbackTableView) withObject:nil waitUntilDone:NO];
    
    if([[self class] checkWifiStatus] == NotReachable)
    {
        UIAlertView *noInternet = [[UIAlertView alloc] initWithTitle:@"网络不可用" message:@"头像保存成功!\n由于当前网络不可用，EB通讯录会在有网络连接时自动帮您上传" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [noInternet show];
        [noInternet release];

        [[self class] saveUserDefaultValue:@"YES" forKey:@"needUploadPhoto"];
    }
    else {
        NSDictionary *usrInfo = [EBBookAccount loadDefaultAccount];
        NSString *onlyWifi = [usrInfo objectForKey:@"onlyWifi"];
        if([onlyWifi isEqualToString:@"YES"])
        {
            if([[self class] checkWifiStatus] == ReachableViaWiFi)
            {
                [self uploadPhotoToServer:imageToUpload];
            }
            else {
                UIAlertView *noInternet = [[UIAlertView alloc] initWithTitle:@"WIFI不可用" message:@"头像保存成功!\n由于WIFI不可用，EB通讯录会在有WIFI连接时自动帮您上传" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
                [noInternet show];
                [noInternet release];
                
                [[self class] saveUserDefaultValue:@"YES" forKey:@"needUploadPhoto"];
            }
        }
        else {
            [self uploadPhotoToServer:imageToUpload];
        }
    }
    //[EBBookAccount setNeedRefreshFlag:YES];
    return saveSuccess;
}

+ (NSString *)currentDateToString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    return strDate;
}

+ (NSString *)deviceToken
{
    return ((EBBookAppDelegate *)[UIApplication sharedApplication].delegate).globalDeviceToken;
}
@end
