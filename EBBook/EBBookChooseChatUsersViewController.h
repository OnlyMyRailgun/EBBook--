//
//  EBBookChooseChatUsersViewController.h
//  EBBook
//
//  Created by Heartunderblade on 1/14/13.
//  Copyright (c) 2013 Ebupt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EBBookDatabase.h"
#import "EBBookLocalContacts.h"
#import "EBBookContactBookCustomCell.h"
#import "EBBookContact.h"
#import "EBBookAccount.h"

@interface EBBookChooseChatUsersViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) NSArray *contactNameArray;
@property (retain) NSMutableArray *sectionArray;
@end
