//
//  MOSLocalDetalViewController.h
//  MobileOfficeSuite
//
//  Created by 张 延晋 on 12-10-17.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>

@interface EBBookLocalDetailViewController : ABPersonViewController

@property (retain) NSString *contactName;

- (id)initWithNibTitle:(NSString *)Title;
- (void)addLeftButtonItem;

@end
