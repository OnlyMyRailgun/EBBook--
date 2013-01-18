//
//  EBBookChatReceiver.h
//  EBBook
//
//  Created by Heartunderblade on 1/14/13.
//  Copyright (c) 2013 Ebupt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "EBBookAccount.h"
#import "MOSSMSObject.h"
#import "MOSSMSDatabase.h"
#import <AudioToolbox/AudioToolbox.h>
@interface EBBookChatReceiver : NSObject<ASIHTTPRequestDelegate>
+ (id)shared;
- (void)runReceiver;
@end
