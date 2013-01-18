//
//  EBBookContactBookViewController.h
//  EBBook
//
//  Created by Kissshot HeartunderBlade on 12-6-14.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EBBookDatabase.h"
#import <MessageUI/MessageUI.h>

@interface EBBookContactBookViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
{
    NSMutableArray	*filteredListContent;	// The content filtered as a result of a search.
	
	// The saved state of the search UI if a memory warning removed the view.
    NSString		*savedSearchTerm;
    NSInteger		savedScopeButtonIndex;
    BOOL			searchWasActive;
    BOOL curled;
}

@property (nonatomic, retain) NSMutableArray *filteredListContent;
@property (nonatomic, retain) NSArray *contactNameArray;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;
@property (retain) NSMutableArray *sectionArray;

- (void)refreshAction:(NSString *)title;
- (void)refreshActionForKey:(NSString *)key withValue:(NSString *)title;
@end
