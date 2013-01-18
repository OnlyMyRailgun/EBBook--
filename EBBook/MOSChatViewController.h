//
//  MOSChatViewController.h
//  MobileOfficeSuite
//
//  Created by 张 延晋 on 12-11-27.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "ASIHttpRequest.h"
#import "UIInputToolbar.h"

#ifndef IOS_VERSION
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#endif
@interface MOSChatViewController : UIViewController<UIBubbleTableViewDataSource,UITextFieldDelegate,UIAlertViewDelegate,UIScrollViewDelegate, ASIHTTPRequestDelegate, UIInputToolbarDelegate>
@property (retain, nonatomic) IBOutlet UIBubbleTableView *bubbleTable;
@property (retain, nonatomic) IBOutlet UIInputToolbar *inputToolbar;


@property (nonatomic, retain) NSString               *toUid;
@property (nonatomic, retain) NSString               *titleString;
@property (nonatomic, retain) NSString               *messageString;
@property (nonatomic, assign) BOOL                   isFromNewSMS;
@property (nonatomic, retain) NSMutableArray		 *chatArray;
@property (nonatomic, retain) NSMutableArray		 *viewArray;
@end
