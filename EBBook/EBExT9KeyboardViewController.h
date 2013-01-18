//
//  EBExT9KeyboardViewController.h
//  Experiment
//
//  Created by Kissshot HeartUnderBlade on 12-7-5.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface EBExT9KeyboardViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,ABPersonViewControllerDelegate>
{
    //NSMutableSet	*filteredListContent;	// The content filtered as a result of a search.
    //NSMutableArray *searchKeywordArray;
    //NSArray *searchRangeArray;
}

@property (retain, nonatomic) IBOutlet UITableView *searchResultKeyboard;
@property (retain, nonatomic) IBOutlet UILabel *keyboardMonitor;
@property (nonatomic, retain) NSArray *contactNameArray;
@property (nonatomic, retain) NSArray *localContactNameArray;
@property (retain, nonatomic) IBOutlet UIView *keyboardUIView;
@property (retain, nonatomic) NSMutableString *searchKeyword;
@end
