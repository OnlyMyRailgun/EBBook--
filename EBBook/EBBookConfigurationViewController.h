//
//  EBBookConfigurationViewController.h
//  EBBook
//
//  Created by Kissshot HeartunderBlade on 12-6-6.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EBBookContactBookViewController;
@class EBBookLocalContactViewController;

@interface EBBookConfigurationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView *configurationTableView;
@property (retain, nonatomic) EBBookContactBookViewController *callbackViewController;
@end
