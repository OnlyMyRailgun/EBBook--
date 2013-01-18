//
//  MOSSMSTableViewController.h
//  MobileOfficeSuite
//
//  Created by 张 延晋 on 12-11-27.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EBBookAccount.h"
#import "ASIFormDataRequest.h"
#import "EBBookDatabase.h"

@class MOSNewMessageViewController;
@class MOSChatViewController;

@interface MOSSMSTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, ASIHTTPRequestDelegate>

@property (retain, nonatomic) IBOutlet UITableView *uiTableView;

@property (nonatomic, retain) NSMutableArray *listArray;
@property (nonatomic, retain) MOSNewMessageViewController   *smsViewController;
@property (nonatomic, retain) MOSChatViewController         *chatViewController;

-(void)newSMSClick;
@end
