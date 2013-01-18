//
//  EBBookChooseChatUsersViewController.m
//  EBBook
//
//  Created by Heartunderblade on 1/14/13.
//  Copyright (c) 2013 Ebupt. All rights reserved.
//

#import "EBBookChooseChatUsersViewController.h"

@interface EBBookChooseChatUsersViewController ()

@end

@implementation EBBookChooseChatUsersViewController
@synthesize contactNameArray;
#define ALPHASTRING @"ABCDEFGHIJKLMNOPQRSTUVWXYZ#"
#define ALPHAARRAY [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#", nil]
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.sectionArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [self.sectionArray release];
    [super dealloc];
}

- (void)initData
{
    NSString *sectionName;
    EBBookDatabase *myDatabase = [[EBBookDatabase alloc] init];
    [myDatabase openDB];
    contactNameArray = [myDatabase queryFromTableForKey:@"chatRegistered" withValue:@"1"];

    [myDatabase closeDB];
    [myDatabase release];
    
    [self.sectionArray removeAllObjects];
    for (int i = 0; i < 27; i++) [self.sectionArray addObject:[NSMutableArray array]];
	for (EBBookContact *aContact in contactNameArray)
	{
		sectionName = [[NSString stringWithFormat:@"%c",[aContact.uid characterAtIndex:0]] uppercaseString];
		//[self.contactNameDic setObject:string forKey:sectionName];
		NSUInteger firstLetter = [ALPHASTRING rangeOfString:[sectionName substringToIndex:1]].location;
		if (firstLetter != NSNotFound) [[self.sectionArray objectAtIndex:firstLetter] addObject:aContact];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    if (tableView == self.searchDisplayController.searchResultsTableView)
//        return [self.title stringByAppendingString: @" 内搜索结果"];
//    else {
        if ([[self.sectionArray objectAtIndex:section] count] == 0)
            return nil;
        
        return [ALPHAARRAY objectAtIndex:section];
//    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *toBeReturned = [NSMutableArray array];
    
    //    for(char c = 'A';c<='Z';c++)
    //        [toBeReturned addObject:[NSString stringWithFormat:@"%c",c]];
    //
    //    [toBeReturned addObject:@"#"];
    [toBeReturned addObjectsFromArray:ALPHAARRAY];
    
    return toBeReturned;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
//    if (title == UITableViewIndexSearch)
//	{
//		[self.tableView scrollRectToVisible:self.tableView.tableHeaderView.frame animated:NO];
//		return -1;
//	}
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 26;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/*
	 If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
	 */
    return [[self.sectionArray objectAtIndex:section] count];
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
    
    EBBookContact *toShowContact = (EBBookContact *)[[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
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
    
//    if([tableView isEditing])
//        if([selectedMultiContacts containsObject:toShowContact])
//            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatFriendChoosed" object:[[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] userInfo:nil];
    
    [self dismissViewController:nil];
}

- (IBAction)dismissViewController:(UIBarButtonItem *)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
