//
//  EBBookDetailTableView.h
//  EBBook
//
//  Created by 延晋 张 on 12-6-19.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EBBookContactDetailCell.h"

@class EBBookContact;

@protocol EBBookDetailTableViewDelegate

- (void)viewSendMessage;
- (void)viewSendMail:(NSString*)mail;
- (void)selectEberForKey:(NSString *)key withValue:(NSString *)value;
- (void)jumpToLeader:(NSString *)leader withUidString:(NSString *)uidString;

@end

@interface EBBookDetailTableView : UITableView
    <UITableViewDelegate,UITableViewDataSource,EBBookContactDetailCellDelegate> 
{
    id <EBBookDetailTableViewDelegate> viewDelegate;
}

@property (nonatomic,assign) id <EBBookDetailTableViewDelegate> viewDelegate;
@property (nonatomic,assign) BOOL dialFlag;
- (id)initWithFrame:(CGRect)frame ebContact:(EBBookContact*) eber;

@end
