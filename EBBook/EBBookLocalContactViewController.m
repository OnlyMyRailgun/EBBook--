//
//  EBBookLocalContactViewController.m
//  EBBook
//
//  Created by 张 延晋 on 12-8-22.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import "EBBookLocalContactViewController.h"
#import "EBBookContactBookCustomCell.h"
#import "EBBookConfigurationViewController.h"
#import "EBBookLocalDetailViewController.h"
#import "EBBookAppDelegate.h"
#import "ContactData.h"
#import "EBBookAppDelegate.h"
#import "POAPinyin.h"
#import "EBBookLocalContacts.h"
#import "pinyin.h"

@interface EBBookLocalContactViewController ()
{
    NSString *sectionName;
    NSString *searchKeyWordstr;
    NSMutableSet *selectedMultiContacts;
    UIAlertView *progressAlert;
}
#define ALPHAARRAY [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#", nil]
@end

@implementation EBBookLocalContactViewController
@synthesize filteredListContent;
@synthesize contactNameArray;
@synthesize contacts;
@synthesize sectionArray;
@synthesize groupArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [selectedMultiContacts release];
	[contactNameArray release];
	[filteredListContent release];
    [groupArray release];
    [contacts release];
    [sectionArray release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.title = @"本地通讯录";
    
    selectedMultiContacts = [[NSMutableSet alloc] init];

    UIBarButtonItem *multiSelectBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewPerson)];
    self.navigationItem.rightBarButtonItem = multiSelectBarItem;
    [multiSelectBarItem release];
    
    UIBarButtonItem *configBarItem = [[UIBarButtonItem alloc] initWithTitle:@"多选" style:UIBarButtonItemStyleBordered target:self action:@selector(multiSelect)];
    self.navigationItem.leftBarButtonItem = configBarItem;
    [configBarItem release];
   
	NSMutableArray *filterearray =  [[NSMutableArray alloc] init];
	self.filteredListContent = filterearray;
	[filterearray release];
	
	NSMutableArray *namearray =  [[NSMutableArray alloc] init];
	self.contactNameArray = namearray;
	[namearray release];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    [self initDataForGroup:nil];

}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
    if (!searchKeyWordstr) {
        [self initDataForGroup:nil];
        [self.tableView reloadData];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)initDataForGroup:(ABGroup *)group{
    
    ABGroup *currentGroup = group;
    if (currentGroup == nil){
        [contactNameArray removeAllObjects];
		[sectionArray removeAllObjects];
        
        self.title = @"本地通讯录";

        self.sectionArray = [NSMutableArray arrayWithArray:[((EBBookAppDelegate *)[UIApplication sharedApplication].delegate) localEBContact]] ;
        self.contactNameArray = [NSMutableArray arrayWithArray:[((EBBookAppDelegate *)[UIApplication sharedApplication].delegate) localNamePhoneContact]] ;
        
        [self.tableView reloadData];
        return;
    }
    else{
        self.title = [currentGroup name];
        self.contacts = [currentGroup members];
    }
    
    [contactNameArray removeAllObjects];

	if([contacts count] <1)
	{
		for (int i = 0; i < 27; i++) [self.sectionArray replaceObjectAtIndex:i withObject:[NSMutableArray array]];
        [self.tableView reloadData];
		return;
	}
    
	for(ABContact *contact in contacts)
	{
        NSArray *phoneArray = [contact phoneArray];
        NSString *pinyinString = [[POAPinyin quickConvert:contact.contactName] lowercaseString];
        NSDictionary *contactDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:contact,@"contact",contact.contactName,@"name",pinyinString,@"pinyin",phoneArray,@"mobile", nil];
        [contactNameArray addObject:contactDictionary];
        [contactDictionary release];
      
	}
	
    [self.sectionArray removeAllObjects];
	self.sectionArray = [NSMutableArray array];
	for (int i = 0; i < 27; i++) [self.sectionArray addObject:[NSMutableArray array]];
	for (NSDictionary *contactDictionary in contactNameArray)
	{
        NSString *string = [contactDictionary objectForKey:@"name"];
		if([ContactData searchResult:string searchText:@"曾"])
			sectionName = @"Z";
		else if([ContactData searchResult:string searchText:@"解"])
			sectionName = @"X";
		else if([ContactData searchResult:string searchText:@"仇"])
			sectionName = @"Q";
		else if([ContactData searchResult:string searchText:@"朴"])
			sectionName = @"P";
		else if([ContactData searchResult:string searchText:@"查"])
			sectionName = @"Z";
		else if([ContactData searchResult:string searchText:@"能"])
			sectionName = @"N";
		else if([ContactData searchResult:string searchText:@"乐"])
			sectionName = @"Y";
		else if([ContactData searchResult:string searchText:@"单"])
			sectionName = @"S";
		else
			sectionName = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([string characterAtIndex:0])] uppercaseString];

		NSUInteger firstLetter = [ALPHA rangeOfString:[sectionName substringToIndex:1]].location;
		if (firstLetter != NSNotFound)
            [[self.sectionArray objectAtIndex:firstLetter] addObject:contactDictionary];
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
}

+(void)initDataForAllGroup:(NSMutableArray *)abArray contactArray:(NSMutableArray *)contactNamePhoneArray{
        
    NSArray *allABContactArray = [NSArray arrayWithArray:[ContactData contactsArray]];
	if([allABContactArray count] <1)
	{
		for (int i = 0; i < 27; i++)
            [abArray addObject:[NSMutableArray array]];
		return;
	}
    
	for(ABContact *contact in allABContactArray)
	{        
        NSArray *phoneArray = [contact phoneArray];
        NSString *pinyinString = [[POAPinyin quickConvert:contact.contactName] lowercaseString];
        NSDictionary *contactDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:contact,@"contact",contact.contactName,@"name",pinyinString,@"pinyin",phoneArray,@"mobile", nil];
        [contactNamePhoneArray addObject:contactDictionary];
        [contactDictionary release];
        
	}
	
    NSString *sectionNameName;
	for (int i = 0; i < 27; i++)
        [abArray addObject:[NSMutableArray array]];
	for (NSDictionary *contactDictionary in contactNamePhoneArray)
	{
        NSString *string = [contactDictionary objectForKey:@"name"];
		if([ContactData searchResult:string searchText:@"曾"])
			sectionNameName = @"Z";
		else if([ContactData searchResult:string searchText:@"解"])
			sectionNameName = @"X";
		else if([ContactData searchResult:string searchText:@"仇"])
			sectionNameName = @"Q";
		else if([ContactData searchResult:string searchText:@"朴"])
			sectionNameName = @"P";
		else if([ContactData searchResult:string searchText:@"查"])
			sectionNameName = @"Z";
		else if([ContactData searchResult:string searchText:@"能"])
			sectionNameName = @"N";
		else if([ContactData searchResult:string searchText:@"乐"])
			sectionNameName = @"Y";
		else if([ContactData searchResult:string searchText:@"单"])
			sectionNameName = @"S";
		else
			sectionNameName = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([string characterAtIndex:0])] uppercaseString];
        
		NSUInteger firstLetter = [ALPHA rangeOfString:[sectionNameName substringToIndex:1]].location;
		if (firstLetter != NSNotFound)
            [[abArray objectAtIndex:firstLetter] addObject:contactDictionary];
	}
}


- (void)refreshAction:(ABGroup *)group
{
    ABGroup *value = group;
    [self initDataForGroup:value];
}

#pragma mark - nav button item
- (void)addNewPerson
{
    ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
	picker.newPersonViewDelegate = self;
	picker.addressBook = addressBook;
	UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
    
    navigation.navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigation animated:YES];
	
	[picker release];
	[navigation release];
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
        if([self.title isEqualToString:@"本地通讯录"]){
            UIActionSheet *multiSelectSheet = [[UIActionSheet alloc] initWithTitle:@"批量操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"加入群组",@"群发短信",@"删除联系人", nil];
            multiSelectSheet.tag = 301;
            [multiSelectSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
            [multiSelectSheet showInView:self.view.window];
            [multiSelectSheet release];
        }
        else{
            UIActionSheet *multiSelectSheet = [[UIActionSheet alloc] initWithTitle:@"批量操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"从群组中删除" otherButtonTitles:@"群发短信",@"删除联系人",nil];
            multiSelectSheet.tag = 302;
            [multiSelectSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
            [multiSelectSheet showInView:self.view.window];
            [multiSelectSheet release];
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                        message:@"请至少选择一个联系人"
                                                       delegate:self
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
        alert.tag = 601;
        [alert show];
        [alert release];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 301) {
        switch (buttonIndex) {
            case 0:
                [self addToGroup:@"1"];
                break;
            case 1:
                [self showMultiMessageView];
                break;
            case 2:
                progressAlert = [EBBookLocalContacts alertSaving:@"正在删除联系人..."];
                [NSThread detachNewThreadSelector:@selector(deleteContacts) toTarget:self withObject:nil];
                break;
            default:
                break;
        }
    }
    else if(actionSheet.tag == 302){
        switch (buttonIndex) {
            case 0:
                [self addToGroup:@"0"];
                break;
            case 1:
                [self showMultiMessageView];
                break;
            case 2:
                progressAlert = [EBBookLocalContacts alertSaving:@"正在删除联系人..."];
                [NSThread detachNewThreadSelector:@selector(deleteContacts) toTarget:self withObject:nil];
                break;
            default:
                break;
        }
    }
    else if(actionSheet.tag == 303){
        if (buttonIndex < [groupArray count]) {
            [self addToLocalGroup:buttonIndex];
        }
            
    }
}

- (void)deleteContacts{
    NSError *error = nil;
    if ([selectedMultiContacts count] > 0) {
        for (NSDictionary *dic in selectedMultiContacts) {
            ABContact *contact = [dic objectForKey:@"contact"];
            [ContactData removeSelfFromAddressBook:contact withErrow:&error];
        }
        
        EBBookAppDelegate *appdelegate = (EBBookAppDelegate *)[UIApplication sharedApplication].delegate;
        [appdelegate reloadLocalContacts];
        [self initDataForGroup:nil];
        [self.tableView reloadData];
    }
    [EBBookLocalContacts  finishSaving:progressAlert];
    
}

- (void)addToLocalGroup:(NSInteger)index
{
    ABGroup *group = [groupArray objectAtIndex:index];
    NSError *error = nil;
    
    for (NSDictionary *dic in selectedMultiContacts) {
        ABContact *contact = [dic objectForKey:@"contact"];
        NSLog(@"contact is %@,group is %@",contact.contactName,group.name);
        [group addMember:contact withError:&error];
        [group saveChange:&error];
    }
}

- (void)addToGroup:(NSString *)status
{
    NSArray *array = [[NSArray alloc] initWithArray:[ContactData groupArray]];
    self.groupArray = array;
    [array release];
    
    if ([status isEqualToString:@"1"]) {
        UIActionSheet *groupSheet = [[UIActionSheet alloc] initWithTitle:@"请选择群组" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil,nil];
        for (ABGroup *group in groupArray) {
            [groupSheet addButtonWithTitle:[group name]];
        }
        groupSheet.tag = 303;
        [groupSheet addButtonWithTitle:@"取消"];
        [groupSheet setCancelButtonIndex:[groupArray count]];
        [groupSheet showInView:self.view.window];
        [groupSheet release];
    }
    else {
        for (ABGroup *group in groupArray) {
            if ([self.title isEqualToString:[group name]]) {
                NSError *error = nil;
                for (NSDictionary *dic in selectedMultiContacts) {
                    ABContact *contact = [dic objectForKey:@"contact"];
                    [group removeMember:contact withError:&error];
                    [group saveChange:&error];
                    [self.sectionArray removeObject:dic];
                }
                [self refreshAction:group];
            }
        }
        
    }
}

- (void)showMultiMessageView
{
    if( [MFMessageComposeViewController canSendText] )
    {
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init]; //autorelease];
        NSMutableArray *messageRecipients = [NSMutableArray array];
        for(NSDictionary *selectedContactResult in selectedMultiContacts)
        {
            NSArray *mobileArray = [selectedContactResult objectForKey:@"mobile"];
            for (NSString* mobileNumber in mobileArray) {
                [messageRecipients addObject:mobileNumber];
            }
            
        }
        controller.recipients = messageRecipients;
        controller.messageComposeDelegate = self;
        
        [self presentModalViewController:controller animated:NO];
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
        //汉字
        for (NSDictionary *contactDictionary  in contactNameArray)
        {
            NSString *nameString = [contactDictionary objectForKey:@"name"];
            //		if ([scope isEqualToString:@"All"] || [product.type isEqualToString:scope])
            //		{
			NSComparisonResult result = [nameString compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame)
			{
				[self.filteredListContent addObject:contactDictionary];
                continue;
            }
        }
    }
    else {
        if(isalpha((int)[searchText characterAtIndex:0]))
        {
            //拼音
            NSString *sectionNameString = [[NSString stringWithFormat:@"%c",[searchText characterAtIndex:0]] uppercaseString];
            int sectionNum = [@"ABCDEFGHIJKLMNOPQRSTUVWXYZ#" rangeOfString:sectionNameString].location;
            
            for (NSDictionary *contactDictionary in [sectionArray objectAtIndex:sectionNum])
            {
                NSString *match = @"";
                for(int i = 0; i < searchText.length; i++)
                    match = [[match stringByAppendingString:[NSString stringWithFormat:@"%c",[searchText characterAtIndex:i]]]stringByAppendingString:@"*"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF LIKE[cd] %@)", match];
                
                NSString *pinyinString = [contactDictionary objectForKey:@"pinyin"];
                BOOL findUid = [predicate evaluateWithObject:pinyinString];
                if(findUid)
                {
                    [self.filteredListContent addObject:contactDictionary];
                    continue;
                }
            }
        }
        else if([subString intValue] < 10 && [subString intValue] > 0){
            //数字
            for (NSDictionary *contactDictionary  in contactNameArray)
            {
                //		if ([scope isEqualToString:@"All"] || [product.type isEqualToString:scope])
                //		{
                NSArray *mobileArray = [contactDictionary objectForKey:@"mobile"];
                for (NSString* mobileNumber in mobileArray) {
                    NSString *mobile = [[mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
                    
                    NSComparisonResult result = [mobile compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
                    if (result == NSOrderedSame)
                    {
                        [self.filteredListContent addObject:contactDictionary];
                        break;
                    }
                }

            }
        }
    }
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    searchKeyWordstr = searchString;
    
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
    searchKeyWordstr = nil;
}


#pragma mark - ABNewPersonViewControllerDelegate methods
// Dismisses the new-person view controller.
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
	[self dismissModalViewControllerAnimated:YES];
    if (person) {
        EBBookAppDelegate *appdelegate = (EBBookAppDelegate *)[UIApplication sharedApplication].delegate;
        [appdelegate reloadLocalContacts];
        [self initDataForGroup:nil];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [self.filteredListContent count];
    }
	else
	{
        return [[self.sectionArray objectAtIndex:section] count];
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return 1;
    return 27;
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
    
	NSString *contactName;
    NSArray *phoneNumberArry;
    NSString *mobileNumber = nil;
    ABContact *contact;
	
	// Retrieve the crayon and its color
	if (tableView == self.tableView)
    {
        contactName = [[[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"];
        phoneNumberArry = [[[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"mobile"];
        contact = [[[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"contact"];
    }
	else
    {
        contactName = [[self.filteredListContent objectAtIndex:indexPath.row] objectForKey:@"name"];
        phoneNumberArry = [[self.filteredListContent objectAtIndex:indexPath.row]  objectForKey:@"mobile"];
        contact = [[self.filteredListContent objectAtIndex:indexPath.row]  objectForKey:@"contact"];
    }
	TITLELABEL.text = [NSString stringWithCString:[contactName UTF8String] encoding:NSUTF8StringEncoding];

    if ([phoneNumberArry count] > 0) {
        mobileNumber = [phoneNumberArry objectAtIndex:0];
        NSMutableString *phone = [[NSMutableString alloc] initWithString:mobileNumber];
        if ([phoneNumberArry count] > 1) {
            [phone appendFormat:@"  (%d个号)",[phoneNumberArry count]];
        }
        NSString *detailString = [[phone stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        [phone release];
        DETAILLABEL.text = detailString;
    }
    else
    {
        DETAILLABEL.text = @"";
    }
    
    if (contact.image) {
        [CONTACTBOOKIMAGEVIEW setImage:contact.image];
    }
    else {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"adressbook_default@2x" ofType:@"png"];
        [CONTACTBOOKIMAGEVIEW setImage:[UIImage imageWithContentsOfFile:path]];
        
    }

	return cell;

}

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
    
    [toBeReturned addObjectsFromArray:ALPHAARRAY];
    
    return toBeReturned;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[self.sectionArray objectAtIndex:section] count] > 0) {
        return 27;
    }
    else
        return 0;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectedContact = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        selectedContact = [self.filteredListContent objectAtIndex:indexPath.row];
    }
    else
    {
        selectedContact = ([[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]);
    }
    if([tableView isEditing] == NO)
    {
        NSString *contactName = @"";
        NSDictionary *dic;
        if (tableView == self.tableView)
        {
            dic = [[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        }
        else
        {
            dic = [self.filteredListContent objectAtIndex:indexPath.row];
        }
        contactName = [dic objectForKey:@"name"];
        ABContact *contact = [dic objectForKey:@"contact"];
        
        EBBookLocalDetailViewController *pvc = [[[EBBookLocalDetailViewController alloc] initWithNibTitle:contactName] autorelease];
        
        [pvc.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        pvc.displayedPerson = contact.record;
        pvc.allowsEditing = YES;
        //pvc.allowsActions = YES;
        pvc.personViewDelegate = self;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:pvc];
        navi.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:navi animated:YES];
        [navi release];
    }
    else {
        [selectedMultiContacts addObject:selectedContact];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* selectedContact = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        selectedContact = [self.filteredListContent objectAtIndex:indexPath.row];
    }
    else
    {
        selectedContact = ([[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]);
    }
    if([selectedMultiContacts containsObject:selectedContact] && [tableView isEditing] == YES)
        [selectedMultiContacts removeObject:selectedContact];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.title stringByAppendingString: @" 内搜索结果"];
    }
    else {
        if ([[self.sectionArray objectAtIndex:section] count] == 0)
            return nil;
        
        return [ALPHAARRAY objectAtIndex:section];
    }
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

-(ABContact *) getABContactByDictionary:(NSDictionary*)dictionary {
    NSString *contactName = @"";
    NSArray *phoneNumberArry;
    NSString *mobileNumber = @"";
    
    contactName = [dictionary objectForKey:@"name"];
    phoneNumberArry = [dictionary objectForKey:@"mobile"];
    if ([phoneNumberArry count] > 0) {
        mobileNumber = [phoneNumberArry objectAtIndex:0];
    }
    
    return [ContactData byPhoneNumberAndNameToGetContact:contactName withPhone:mobileNumber];
}

#pragma mark - ABPersonViewControllerDelegate
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;
{
    ABContact *contact = [ABContact contactWithRecord:person];

    NSArray *array = [ABContact arrayForProperty:property inRecord:contact.record];
    if (kABPersonPhoneProperty == property) {
        /*
         NSString *stringNumber = [array objectAtIndex:identifier];
         NSString *phoneString = [[NSString alloc] initWithFormat:@"telprompt:%@",stringNumber];
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneString]];
         [phoneString release];
         */
        NSString *stringNumber = [array objectAtIndex:identifier];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请选择" message:stringNumber delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"电话",@"短信", nil ];
        alert.tag = 401;
        [alert show];
        [alert release];
        return NO;
    }
    else if (kABPersonEmailProperty == property) {
        NSString *mailAddress = [array objectAtIndex:identifier];
        NSString *mailString = [[NSString alloc] initWithFormat:@"mailto:%@",mailAddress];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
        [mailString release];
        return NO;

    }
    
	return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 401) {
        if (buttonIndex == 1) {
            NSString *phoneString = [[NSString alloc] initWithFormat:@"tel:%@",alertView.message];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneString]];
            [phoneString release];
        }
        else if (buttonIndex == 2){
            NSString *phoneString = [[NSString alloc] initWithFormat:@"sms:%@",alertView.message];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneString]];
            [phoneString release];
        }
    }
}

@end
