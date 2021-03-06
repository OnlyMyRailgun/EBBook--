//
//  EBBookContactBookViewController.m
//  EBBook
//
//  Created by Kissshot HeartunderBlade on 12-6-14.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import "EBBookContactBookViewController.h"
#import "EBBookContact.h"
#import "EBBookConfigurationViewController.h"
#import "EBADBookDetailViewController.h"
#import "EBBookLocalContacts.h"
#import "EBBookAccount.h"
#import <QuartzCore/QuartzCore.h>
#import "EBBookContactBookCustomCell.h"
#import "IIViewDeckController.h"
#import "EBBookAppDelegate.h"

@interface EBBookContactBookViewController()
{
    NSMutableSet *selectedMultiContacts;
    UIAlertView *progressAlert;
    NSString *searchKeyWordstr;
    NSString *titleKey;
}
#define ALPHASTRING @"ABCDEFGHIJKLMNOPQRSTUVWXYZ#"
#define ALPHAARRAY [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#", nil]
@end

@implementation EBBookContactBookViewController

@synthesize contactNameArray, filteredListContent, savedSearchTerm, savedScopeButtonIndex, searchWasActive, sectionArray;

#pragma mark - 
#pragma mark Lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"EB通讯录";
    
    selectedMultiContacts = [[NSMutableSet alloc] init];
    
    UIBarButtonItem *multiSelectBarItem = [[UIBarButtonItem alloc] initWithTitle:@"多选" style:UIBarButtonItemStyleBordered target:self action:@selector(multiSelect)];
    self.navigationItem.leftBarButtonItem = multiSelectBarItem;
    [multiSelectBarItem release];
    
    UIBarButtonItem *configBarItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStyleBordered target:self action:@selector(showConfiguration)];
    self.navigationItem.rightBarButtonItem = configBarItem;
    [configBarItem release];
	
	// create a filtered list that will contain products for the search results table.
	self.filteredListContent = [NSMutableArray arrayWithCapacity:[self.contactNameArray count]];
	
	// restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    [self initDataForKey:nil withValue:@"全体员工"];
}

- (void)initDataForKey:(NSString *)key withValue:(NSString *)value
{
    titleKey = key;
    NSString *sectionName;
    EBBookDatabase *myDatabase = [[EBBookDatabase alloc] init];
    [myDatabase openDB];
    [contactNameArray release];
    contactNameArray = nil;
    if([value isEqualToString:@"全体员工"])
        contactNameArray = [myDatabase queryFromTableForKey:nil withValue:nil];
    else if ([value isEqualToString:@"收藏夹"]) {
        contactNameArray = [myDatabase queryFromTableForKey:@"Favorite" withValue:@"1"];
    }
    else {
        contactNameArray = [myDatabase queryFromTableForKey:key withValue:value];
    }
    [contactNameArray retain];
    [myDatabase closeDB];
    [myDatabase release];
    
    [self.sectionArray removeAllObjects];
    self.sectionArray = [NSMutableArray array];
    for (int i = 0; i < 27; i++) [self.sectionArray addObject:[NSMutableArray array]];
	for (EBBookContact *aContact in contactNameArray) 
	{
		sectionName = [[NSString stringWithFormat:@"%c",[aContact.uid characterAtIndex:0]] uppercaseString];
		//[self.contactNameDic setObject:string forKey:sectionName];
		NSUInteger firstLetter = [ALPHASTRING rangeOfString:[sectionName substringToIndex:1]].location;
		if (firstLetter != NSNotFound) [[self.sectionArray objectAtIndex:firstLetter] addObject:aContact];
	}

    NSString *titleString;
    //NSLog(@"key is %@,value is %@",key,value);
    if ([key isEqualToString:@"Band"]) {
        if ([value isEqualToString:@"待定"]) {
            self.title = @"级别待定";
        } else {
            titleString = [[NSString alloc] initWithFormat:@"技术%@级员工",value ];
            self.title = titleString;
            [titleString release];
        }
    }
    else
    {
        self.title = value;
    }
    
    if([self.searchDisplayController isActive])
    {
        [self filterContentForSearchText:searchKeyWordstr];
        NSLog(@"search %@", searchKeyWordstr);
        [self.searchDisplayController.searchResultsTableView reloadData];
        
    }
    else {
        [self.tableView reloadData];
    }
    if([self.tableView isEditing])
        [self cancelMultiSelectMode];
}

- (void)viewDidUnload
{
	self.filteredListContent = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

- (void)dealloc
{
    [selectedMultiContacts release];
	[contactNameArray release];
	[filteredListContent release];
	
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self.title isEqualToString:@"收藏夹"])
    {
        [self initDataForKey:nil withValue:@"收藏夹"];
    }
}

- (void)refreshActionForKey:(NSString *)key withValue:(NSString *)title
{
    NSString *value = title;
    if(title == nil)
        value = self.title;
    [self initDataForKey:key withValue:value];
}

- (void)refreshAction:(NSString *)title
{
    NSString *value = title;
    if(title == nil)
        value = self.title;
    [self initDataForKey:titleKey withValue:value];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark - nav button item
- (void)showConfiguration
{
    EBBookConfigurationViewController *configViewController = [[EBBookConfigurationViewController alloc] initWithNibName:@"EBBookConfigurationViewController" bundle:nil];
    configViewController.callbackViewController = self;
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    configViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self presentModalViewController:configViewController animated:YES];
    [configViewController release];
}

- (void)makeTabBarHidden:(BOOL)hide
{
    if ( [self.tabBarController.view.subviews count] < 2 )
    {
        return;
    }
    UIView *contentView;
    
    if ( [[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] )
    {
        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
    }
    else
    {
        contentView = [self.tabBarController.view.subviews objectAtIndex:0];
    }
    //    [UIView beginAnimati*****:@"TabbarHide" context:nil];
    if ( hide )
    {
        contentView.frame = self.tabBarController.view.bounds;        
    }
    else
    {
        contentView.frame = CGRectMake(self.tabBarController.view.bounds.origin.x,
                                       self.tabBarController.view.bounds.origin.y,
                                       self.tabBarController.view.bounds.size.width,
                                       self.tabBarController.view.bounds.size.height - self.tabBarController.tabBar.frame.size.height);
    }
    
    self.tabBarController.tabBar.hidden = hide;
    //    [UIView commitAnimati*****];    
}

- (void)multiSelect
{
    [self makeTabBarHidden:YES];
    if([selectedMultiContacts count] > 0)
        [selectedMultiContacts removeAllObjects];

    self.navigationController.toolbar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"取 消" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelMultiSelectMode)];
    UIBarButtonItem *flexibleSpaceBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *selectAllBarButton = [[UIBarButtonItem alloc] initWithTitle:@"全 选" style:UIBarButtonItemStyleBordered target:self action:@selector(allMultiSelect)];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"完 成" style:UIBarButtonItemStyleDone target:self action:@selector(fowardMultiSelect)];
    
    self.toolbarItems = [NSArray arrayWithObjects:cancelBarButton, flexibleSpaceBarButton, selectAllBarButton, doneBarButton, nil];
    
    [cancelBarButton release];
    [flexibleSpaceBarButton release];
    [selectAllBarButton release];
    [doneBarButton release];
    
    [self.tableView setEditing:![self.tableView isEditing]];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)cancelMultiSelectMode
{    
    if([self.searchDisplayController isActive])
        [self.searchDisplayController setActive:NO];
    
    [self.tableView setEditing:NO];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self makeTabBarHidden:NO];
}

- (void)allMultiSelect
{    
    if([self.searchDisplayController isActive])
    {
        [selectedMultiContacts addObjectsFromArray:filteredListContent];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else {
        [selectedMultiContacts addObjectsFromArray:contactNameArray];
        [self.tableView reloadData];
    }
}


- (void)fowardMultiSelect
{
    if([selectedMultiContacts count] > 0)
    {
        NSString *allAddToFavoriteStr = @"批量加入收藏夹";
        NSString *removeAllFromFavoriteStr = nil;
        if([self.title isEqualToString:@"收藏夹"])
        {
            allAddToFavoriteStr = nil;
            removeAllFromFavoriteStr = @"批量移出收藏夹";
        }
        UIActionSheet *multiSelectSheet = [[UIActionSheet alloc] initWithTitle:@"批量操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:removeAllFromFavoriteStr otherButtonTitles:@"群发短信", @"群发邮件", @"批量添加到本地通讯录", allAddToFavoriteStr,nil];
        [multiSelectSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        [multiSelectSheet showInView:self.view.window];
        [multiSelectSheet release];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                        message:@"请至少选择一个联系人" 
                                                       delegate:self 
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

#pragma - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{    
    if([[self title] isEqualToString:@"收藏夹"])
    {
        switch (buttonIndex) {
            case 0:
                [self addAllToFavorite:@"0"];
                break;
            case 1:
                [self showMultiMessageView];
                break;
            case 2:
                [self showMultiMailView];
                break;
            case 3:
                progressAlert = [EBBookLocalContacts alertSaving:@"正在保存联系人..."];
                [NSThread detachNewThreadSelector:@selector(addAllToLocal) toTarget:self withObject:nil];
                break;
            default:
                break;
        }
    }
    else {
        switch (buttonIndex) {
            case 0:
                [self showMultiMessageView];
                break;
            case 1:
                [self showMultiMailView];
                break;
            case 2:
                progressAlert = [EBBookLocalContacts alertSaving:@"正在保存联系人..."];
                [NSThread detachNewThreadSelector:@selector(addAllToLocal) toTarget:self withObject:nil];
                break;
            case 3:
                [self addAllToFavorite:@"1"];
                break;
            default:
                break;
        }
    }
}

- (void)addAllToLocal
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [EBBookLocalContacts addAllContactsToDevice:[selectedMultiContacts allObjects]];
    
    EBBookAppDelegate *appdelegate = (EBBookAppDelegate *)[UIApplication sharedApplication].delegate;
    [appdelegate reloadLocalContacts];
    
    [self performSelectorOnMainThread:@selector(finishSavingToLocal) withObject:nil waitUntilDone:NO];
    
    [pool release];
}

- (void)finishSavingToLocal
{
    [self cancelMultiSelectMode];
    [EBBookLocalContacts finishSaving:progressAlert];
}

- (void)addAllToFavorite:(NSString *)status
{
    EBBookDatabase *myDatabase = [[EBBookDatabase alloc] init];
    [myDatabase openDB];
    
    for(EBBookContact *selectedContactResult in selectedMultiContacts)
        [myDatabase updateFavoriteStatusForContact:selectedContactResult.uid withInt:status];
    
    [myDatabase closeDB];
    [myDatabase release];
    
    NSString *message = @"成功添加到收藏夹";
    if([[self title] isEqualToString:@"收藏夹"])
        message = @"成功移出收藏夹";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" 
                                                    message:message 
                                                   delegate:self 
                                          cancelButtonTitle:@"好的" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    [self cancelMultiSelectMode];
    if([[self title] isEqualToString:@"收藏夹"])
        [self refreshAction:@"收藏夹"];
}

- (void)showMultiMessageView
{
    if( [MFMessageComposeViewController canSendText] )
    {
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init]; //autorelease];
        NSMutableArray *messageRecipients = [NSMutableArray array];
        for(EBBookContact *selectedContactResult in selectedMultiContacts)
            [messageRecipients addObject:selectedContactResult.mobile];
        controller.recipients = messageRecipients;
        controller.messageComposeDelegate = self;
        
        [self presentModalViewController:controller animated:YES];
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:@"群发短信"];//修改短信界面标题
        [controller release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" 
                                                        message:@"该设备不支持短信功能" 
                                                       delegate:self 
                                              cancelButtonTitle:@"知道了" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)showMultiMailView
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
	if (mailClass != nil) {
        //[self displayMailComposerSheet];
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail]) {
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;     
            
            [[[[picker viewControllers] lastObject] navigationItem] setTitle:@"群发邮件"];//修改短信界面标题
            // Set up recipients
            NSMutableArray *toRecipients = [NSMutableArray array];
            for(EBBookContact *selectedContactResult in selectedMultiContacts)
                [toRecipients addObject:selectedContactResult.mail];

            [picker setToRecipients:toRecipients];
            
            [self presentModalViewController:picker animated:YES];
            [picker release];
		}
		else {
            //邮箱设置
			NSString *mailString = [[NSString alloc] initWithFormat:@"mailto:%@",@""];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
            [mailString release];
		}
	}
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                        message:@"该设备不支持邮件功能" 
                                                       delegate:self 
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}
#pragma mark -
#pragma mark Dismiss Mail/SMS view controller

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the 
// message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//feedbackMsg.text = @"Result: Mail sending canceled";
			break;
		case MFMailComposeResultSaved:
			//feedbackMsg.text = @"Result: Mail saved";
			break;
		case MFMailComposeResultSent:
			//feedbackMsg.text = @"Result: Mail sent";
			break;
		case MFMailComposeResultFailed:
			//feedbackMsg.text = @"Result: Mail sending failed";
			break;
		default:
			//feedbackMsg.text = @"Result: Mail not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}


// Dismisses the message composition interface when users tap Cancel or Send. Proceeds to update the 
// feedback message field with the result of the operation.
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller 
                 didFinishWithResult:(MessageComposeResult)result {
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MessageComposeResultCancelled:
			//feedbackMsg.text = @"Result: SMS sending canceled";
			break;
		case MessageComposeResultSent:
			//feedbackMsg.text = @"Result: SMS sent";
            [self cancelMultiSelectMode];
			break;
		case MessageComposeResultFailed:
			//feedbackMsg.text = @"Result: SMS sending failed";
            [self cancelMultiSelectMode];
			break;
		default:
			//feedbackMsg.text = @"Result: SMS not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view data source
#pragma mark -
#pragma mark UITableView data source and delegate methods
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *toBeReturned = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
    
//    for(char c = 'A';c<='Z';c++)
//        [toBeReturned addObject:[NSString stringWithFormat:@"%c",c]];
//    
//    [toBeReturned addObject:@"#"];
    [toBeReturned addObjectsFromArray:ALPHAARRAY];
    
    return toBeReturned;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (title == UITableViewIndexSearch) 
	{
		[self.tableView scrollRectToVisible:self.tableView.tableHeaderView.frame animated:NO];
		return -1;
	}

    NSInteger count = 0;
    
    for(NSString *character in ALPHAARRAY)
    {
        
        if([character isEqualToString:title])
        {
            return count;
        }
        
        count ++;
    }
    
    return 0;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return [self.title stringByAppendingString: @" 内搜索结果"];
    else {
        if ([[self.sectionArray objectAtIndex:section] count] == 0)
            return nil;
        
        return [ALPHAARRAY objectAtIndex:section];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return 1;
    return 27;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/*
	 If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
	 */
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [self.filteredListContent count];
    }
	else
	{
        return [[self.sectionArray objectAtIndex:section] count];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EBBookContact* selectedContact = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        selectedContact = (EBBookContact*)[self.filteredListContent objectAtIndex:indexPath.row];
    }
    else
    {
        selectedContact = (EBBookContact*)([[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]);
    }
    if([tableView isEditing] == NO)
    {
        EBADBookDetailViewController *detailViewController = [[EBADBookDetailViewController alloc] initWithEBContact: selectedContact];
        detailViewController.callbackViewController = self;
        detailViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        detailViewController.freeJump = YES;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
        [navController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
        [self presentModalViewController:navController animated:YES];
        [detailViewController release];
        [navController release];
    }
    else {
        [selectedMultiContacts addObject:selectedContact];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EBBookContact* selectedContact = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        selectedContact = (EBBookContact*)[self.filteredListContent objectAtIndex:indexPath.row];
    }
    else
    {
        selectedContact = (EBBookContact*)([[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]);
    }
    if([selectedMultiContacts containsObject:selectedContact] && [tableView isEditing] == YES)
        [selectedMultiContacts removeObject:selectedContact];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    /*
    UIImageView *footer = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@""] ]autorelease];
    return footer;
    */
    
    if (section == [sectionArray count] -1) {
        UILabel	*countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
        //countLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        countLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
        countLabel.textColor = [UIColor grayColor];
        countLabel.textAlignment = UITextAlignmentCenter;
        countLabel.backgroundColor = [UIColor clearColor];
        
        NSInteger mainCount = 0;
        for (NSInteger i=0; i<27; i++) {
            mainCount = mainCount + [[sectionArray objectAtIndex:i] count];
        }
        countLabel.text = [NSString stringWithFormat:@"%d位联系人",mainCount];
        
        return countLabel;
    }
    
    else {
        UIImageView *footer = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@""] ]autorelease];
        return footer;
    }


}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == [sectionArray count] -1)
    {
        return 40;

    }
    else {
        return 0;
    }
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText// scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
    if(searchText.length < 1)
        return;
    
    NSString *subString = [searchText substringWithRange:NSMakeRange(0, 1)];
    const char *cString = [subString UTF8String];
    
    if (strlen(cString) == 3)
    {
        NSLog(@"hanzi");
        for (EBBookContact *product in contactNameArray)
        {
            //		if ([scope isEqualToString:@"All"] || [product.type isEqualToString:scope])
            //		{
			NSComparisonResult result = [product.name compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame)
			{
				[self.filteredListContent addObject:product];
                continue;
            }
        }
    }
    else {
        if(isalpha((int)[searchText characterAtIndex:0]))
        {
            NSLog(@"pinyin");
            NSString *sectionName = [[NSString stringWithFormat:@"%c",[searchText characterAtIndex:0]] uppercaseString];
            int sectionNum = [@"ABCDEFGHIJKLMNOPQRSTUVWXYZ#" rangeOfString:sectionName].location;
            
            for (EBBookContact *product in [sectionArray objectAtIndex:sectionNum])
            {                   
                NSString *match = @"";
                for(int i = 0; i < searchText.length; i++)
                    match = [[match stringByAppendingString:[NSString stringWithFormat:@"%c",[searchText characterAtIndex:i]]]stringByAppendingString:@"*"]; 
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF LIKE[cd] %@)", match];
                
                BOOL findUid = [predicate evaluateWithObject:product.uid];
                if(findUid)
                {
                    [self.filteredListContent addObject:product];
                    continue;
                }                    
            }
        }
        else if([subString intValue] < 10 && [subString intValue] > 0){
            NSLog(@"number");
            for (EBBookContact *product in contactNameArray)
            {
                //		if ([scope isEqualToString:@"All"] || [product.type isEqualToString:scope])
                //		{
                NSComparisonResult result = [product.mobile compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
                if (result == NSOrderedSame)
                {
                    [self.filteredListContent addObject:product];
                    continue;
                }
            }
        }
    }    
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    searchKeyWordstr = searchString;
    NSLog(@"search %@", searchKeyWordstr);
    [searchKeyWordstr retain];
    [self filterContentForSearchText:searchString];// scope:
     //[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    [self.searchDisplayController.searchResultsTableView setEditing:[self.tableView isEditing]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self.tableView reloadData];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    if([self.tableView isEditing] && self.navigationController.navigationBar.hidden == NO)
        [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"开始体验EB通讯录！"])
        [self.viewDeckController openLeftViewAnimated:YES];
}

#define CONTACTBOOKIMAGEVIEW ((UIImageView *)[cell viewWithTag:601])
#define TITLELABEL ((UILabel *)[cell viewWithTag:602])
#define DETAILLABEL ((UILabel *)[cell viewWithTag:603])

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CustomCellIdentifier = @"contactBookCustomCell";
    
    EBBookContactBookCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    
    if(cell == nil)
    {
        //UINib *nib = [UINib nibWithNibName:@"EBBookContactBookCustomCell" bundle:nil];  
        //[tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EBBookContactBookCustomCell" owner:self options:nil] lastObject];
    }

    EBBookContact *toShowContact;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        toShowContact = (EBBookContact *)[self.filteredListContent objectAtIndex:indexPath.row];
        //cell.textLabel.text = [toShowSearchContact name];
        
//        TITLELABEL.text = [toShowContact name];
//        
//        //cell.detailTextLabel.text = [toShowSearchContact mobile];
//        NSString *detailStr;
//        if([[toShowContact tel] isEqualToString:@"0"])
//            detailStr = [NSString stringWithFormat:@"%@", [toShowContact mobile]];
//        else {
//            detailStr = [NSString stringWithFormat:@"%@  分机:%@", [toShowContact mobile], [toShowContact tel]];
//        }
//        DETAILLABEL.text = detailStr;
//        
//        //[cell.imageView setImage:[EBBookLocalContacts getPhotoForContact:[toShowSearchContact uid]]];
//        UIImage *headPortraitPhoto = [EBBookLocalContacts getPhotoForContact:[toShowContact uid]];
//        if (headPortraitPhoto.size.height > 0.0000001) {
//            // [cell.imageView setImage:headPortraitPhoto];
//            [CONTACTBOOKIMAGEVIEW setImage:headPortraitPhoto];
//        }
//        else {
//            NSString *path = [[NSBundle mainBundle] pathForResource:@"adressbook_default@2x" ofType:@"png"];
//            //[cell.imageView setImage:[UIImage imageWithContentsOfFile:path]];
//            [CONTACTBOOKIMAGEVIEW setImage:[UIImage imageWithContentsOfFile:path]];
//
//        }
//                
//        if([tableView isEditing])
//            if([selectedMultiContacts containsObject:toShowContact])
//                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

    }
	else
	{
        toShowContact = (EBBookContact *)[[sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];        
    }
    NSString *titleLabel;
    if([[EBBookAccount currentDateToString] isEqualToString:toShowContact.birthdate])
    {
        titleLabel = [[toShowContact name] stringByAppendingString:@"  🎂"];
        NSLog(@"%@", toShowContact.uid);
    }
    else {
        titleLabel = [toShowContact name];
    }
    TITLELABEL.text = titleLabel;
    //cell.detailTextLabel.text = [toShowContact mobile];
    NSString *detailStr;
    if([[toShowContact tel] isEqualToString:@"0"])
        detailStr = [NSString stringWithFormat:@"%@", [toShowContact mobile]];
    else {
        detailStr = [NSString stringWithFormat:@"%@  分机:%@", [toShowContact mobile], [toShowContact tel]];
    }
    DETAILLABEL.text = detailStr;
    
    //[cell.imageView setImage:[EBBookLocalContacts getPhotoForContact:[toShowContact uid]]];
    UIImage *headPortraitPhoto = [EBBookLocalContacts getPhotoForContact:[toShowContact uid]];
    if (headPortraitPhoto.size.height > 0.0000001) {
        // [cell.imageView setImage:headPortraitPhoto];
        [CONTACTBOOKIMAGEVIEW setImage:headPortraitPhoto];
    }
    else {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"adressbook_default@2x" ofType:@"png"];
        //[cell.imageView setImage:[UIImage imageWithContentsOfFile:path]];
        [CONTACTBOOKIMAGEVIEW setImage:[UIImage imageWithContentsOfFile:path]];
        
    }
    
    //[contactToIndexPath setValue:indexPath forKey:toShowContact.uid];
    
    if([tableView isEditing])
        if([selectedMultiContacts containsObject:toShowContact])
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark - ImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        NSLog(@"found an image");
        [NSThread detachNewThreadSelector:@selector(uploadPhotoAfterPick:) toTarget:self withObject:image];
    }
    [picker dismissModalViewControllerAnimated:YES];
    //[self showConfiguration];
}

//In thread
- (void) uploadPhotoAfterPick:(UIImage *)image
{
    EBBookAccount *handle = [[EBBookAccount alloc] init];
    handle.callbackViewController = self;
    UIImage *updateImage;
    if (image.size.height > 200.0f) {
        updateImage = [self scaleFromImage:image toSize:CGSizeMake(200.0f, 200.0f)];
    }
    else {
        updateImage = image;
    }
    [handle uploadPhoto:updateImage];
    [handle release];
}

- (UIImage *) scaleFromImage: (UIImage *) image toSize: (CGSize) size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
    //[self showConfiguration];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSLog(@"%@",[paths objectAtIndex:0]);
}
@end
