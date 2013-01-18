//
//  EBBookLocalContactViewController.h
//  EBBook
//
//  Created by 张 延晋 on 12-8-22.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "ABGroup.h"

//Address Book contact

#define BARBUTTON(TITLE, SELECTOR)		[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]//UIBarButtonItem
#define NUMBER(X) [NSNumber numberWithInt:X]

@interface EBBookLocalContactViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,ABNewPersonViewControllerDelegate,ABPersonViewControllerDelegate,MFMessageComposeViewControllerDelegate>

@property (retain) NSArray *contacts;
@property (retain) NSArray *groupArray;
@property (retain) NSMutableArray *filteredListContent;
@property (retain) NSMutableArray *contactNameArray;
@property (retain) NSMutableArray *sectionArray;

- (void)refreshAction:(ABGroup *)group;
+ (void)initDataForAllGroup:(NSMutableArray *)abArray contactArray:(NSMutableArray *)contactNamePhoneArray;
@end
