//
//  EBBookChatReceiver.m
//  EBBook
//
//  Created by Heartunderblade on 1/14/13.
//  Copyright (c) 2013 Ebupt. All rights reserved.
//

#import "EBBookChatReceiver.h"
@interface EBBookChatReceiver ()
@property (nonatomic, retain) NSTimer *timerOfReceiver;
@property (nonatomic, retain) ASIFormDataRequest *formDataRequest;
@end

@implementation EBBookChatReceiver
static EBBookChatReceiver *staticReceiver = nil;
+ (id)shared
{
    if(staticReceiver == nil)
    {
        staticReceiver = [[EBBookChatReceiver alloc] init];
        [staticReceiver initializor];
    }
    return staticReceiver;
}

- (void)initializor
{
}

- (void)runReceiver
{
    int timeDelay = 10;
    _timerOfReceiver = [NSTimer scheduledTimerWithTimeInterval:timeDelay target:self selector:@selector(taskFlow) userInfo:nil repeats:YES];
}

- (void)taskFlow
{
    NSString *urlStr;
    if([EBBookAccount getIsPrivateNetFlag])
    {
        urlStr = @"http://10.1.69.113:9000/clientpush/index.php";
    }
    else
        urlStr = @"http://218.249.60.69:9000/clientpush/index.php";
    _formDataRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [_formDataRequest setPostValue:@"detectmsg" forKey:@"request"];
    [_formDataRequest setPostValue:[EBBookAccount deviceToken] forKey:@"device_token"];
    [_formDataRequest setPostValue:[[EBBookAccount loadDefaultAccount] objectForKey:@"userName"] forKey:@"uid"];
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
    if(returnCode == 0)
    {
        NSArray *msgArray = [jsonDic objectForKey:@"content"];
        NSMutableArray *msgObjectArray = [NSMutableArray array];
        for(NSDictionary *msgDic in msgArray)
        {
            MOSSMSObject *msgBit = [[MOSSMSObject alloc] init];
            msgBit.phoneNumber = [msgDic objectForKey:@"from_uid"];
            msgBit.content = [msgDic objectForKey:@"msg"];
            msgBit.sendSuccess = 1;
            msgBit.date = [[msgDic objectForKey:@"push_time"] doubleValue];
            msgBit.isFromMe = NO;
            msgBit.contactName = [msgDic objectForKey:@"from_username"];
            [msgObjectArray addObject:msgBit];
            
            [msgBit release];
        }
        if(msgObjectArray.count > 0)
        {
            MOSSMSDatabase *db = [[MOSSMSDatabase alloc] init];
            [db insertMsgsFromArray:msgObjectArray];
            [db release];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HasNewMsg" object:[NSNumber numberWithBool:YES] userInfo:nil];
            AudioServicesPlaySystemSound(1003);
        }
    }
}
@end
