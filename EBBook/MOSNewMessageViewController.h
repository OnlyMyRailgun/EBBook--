//
//  MOSNewMessageViewController.h
//  MobileOfficeSuite
//
//  Created by 张 延晋 on 12-11-28.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOSChatViewController.h"
#import "MOSSMSTableViewController.h"
#import "UIInputToolBar.h"
#import "EBBookChooseChatUsersViewController.h"

#ifndef IOS_VERSION
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#endif

@interface MOSNewMessageViewController : UIViewController<UITextFieldDelegate, UIInputToolbarDelegate>

@property (nonatomic, retain) MOSChatViewController      *chatViewController;
@property (nonatomic, retain) id  firstViewController;
@property (nonatomic, retain) NSMutableArray             *receiverArray;
@property (nonatomic, retain) NSString                   *messageString;
@property (nonatomic, assign) BOOL                       isAddReceive;
@property (nonatomic, retain) EBBookContact *contactForChating;
@property (retain, nonatomic) IBOutlet UITextField *receiverTextField;

@property (retain, nonatomic) IBOutlet UIInputToolbar *inputToolBar;

- (IBAction)cancel:(id)sender;

@end
