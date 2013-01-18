//
//  MOSSMSTableViewController.m
//  MobileOfficeSuite
//
//  Created by 张 延晋 on 12-11-27.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import "MOSSMSTableViewController.h"
#import "MOSNewMessageViewController.h"
#import "SMSCustomCell.h"
#import "MOSSMSDatabase.h"
#import "MOSSMSObject.h"

@interface MOSSMSTableViewController ()

@end

@implementation MOSSMSTableViewController
@synthesize uiTableView;
@synthesize listArray;
@synthesize smsViewController;
@synthesize chatViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:self.title style:UIBarButtonItemStyleBordered target:self action:nil];
        [backItem setTintColor:[UIColor grayColor]];
        self.navigationItem.backBarButtonItem = backItem;
        [backItem release];
        
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
        
        [self initData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"集团短信";
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"新建"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(newSMSClick)];
    [rightItem setTintColor:[UIColor grayColor]];
	self.navigationItem.rightBarButtonItem = rightItem;
	[rightItem release];
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.bounds];
    background.image = [UIImage imageNamed: @"mos_background.png"];
    [self.view addSubview:background];
    [self.view sendSubviewToBack:background];
    
    [background release];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasNewMsg:) name:@"HasNewMsg" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self initData];
    [uiTableView reloadData];
    
    [self updateRegisteredUsers];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HasNewMsg" object:nil];
    
    [self setUiTableView:nil];
    [self setListArray:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HasNewMsg" object:[NSNumber numberWithBool:NO] userInfo:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)updateRegisteredUsers
{
    NSString *urlStr;
    if([EBBookAccount getIsPrivateNetFlag])
    {
        urlStr = @"http://10.1.69.113:9000/clientpush/index.php";
    }
    else
        urlStr = @"http://218.249.60.69:9000/clientpush/index.php";
    ASIFormDataRequest *_formDataRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [_formDataRequest setPostValue:@"updateregistion" forKey:@"request"];
    [_formDataRequest setPostValue:[EBBookAccount deviceToken] forKey:@"device_token"];
    [_formDataRequest setPostValue:[[EBBookAccount loadDefaultAccount] objectForKey:@"friendTimestamp"] forKey:@"timestamp"];
    [_formDataRequest setDelegate:self];
    
    [_formDataRequest startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = request.responseData;
    NSDictionary* jsonDic = [NSJSONSerialization
                             JSONObjectWithData:responseData
                             options:NSJSONReadingAllowFragments
                             error:nil];
    NSInteger returnCode = [[jsonDic objectForKey:@"success"] integerValue];
    if(returnCode == 0)
    {
        NSDictionary *contentDic = [jsonDic objectForKey:@"content"];
        [EBBookAccount saveUserDefaultValue:[contentDic objectForKey:@"timestamp"] forKey:@"friendTimestamp"];
        EBBookDatabase *db = [[EBBookDatabase alloc] init];
        NSArray *newStaff = [contentDic objectForKey:@"list"];
        [db openDB];
        for(NSDictionary *dicStaff in newStaff)
        {
            [db setChatRegisteredForContact: [dicStaff objectForKey:@"uid"]];
        }
        [db closeDB];
    }
}

-(void)initData
{
    MOSSMSDatabase *myDatabase = [[MOSSMSDatabase alloc] init];
    [myDatabase openDB];
    [myDatabase createSMSTable];
    self.listArray = [[[NSMutableArray alloc] initWithArray:[myDatabase queryLastSMSFromTable]] autorelease];
    //[listArray retain];
    [myDatabase closeDB];
    [myDatabase release];
}

- (void)dealloc {
    [listArray release];
    [uiTableView release];
    [super dealloc];
}

-(void)newSMSClick{
	
	if (self.smsViewController == nil) {
		MOSNewMessageViewController *temp = [[MOSNewMessageViewController alloc] initWithNibName:@"MOSNewMessageViewController" bundle:nil];
		self.smsViewController = temp;
		[temp release];
		self.smsViewController.firstViewController = self;
	}
	[self presentModalViewController:self.smsViewController animated:YES];
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return [self.listArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CustomCellIdentifier = @"CustomCellIdentifier ";
    
    SMSCustomCell *cell = [tableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SMSCustomCell" owner:self options:nil] lastObject];
    }
    
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *cellBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mos_cellbg"]] autorelease];
    UIImageView *rightView = [[[UIImageView alloc] initWithFrame:CGRectMake(295, 27, 11, 15.5)] autorelease];
    [rightView setImage:[UIImage imageNamed:@"rightArrow"]];
    [cellBackgroundView addSubview:rightView];
    [cell setBackgroundView:cellBackgroundView];
    UIImageView *selectedCellBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mos_cellbg_pressed"]] autorelease];
    UIImageView *rightViewSelected = [[[UIImageView alloc] initWithFrame:CGRectMake(295, 27, 11, 15.5)] autorelease];
    [rightViewSelected setImage:[UIImage imageNamed:@"rightArrow_selected"]];
    [selectedCellBackgroundView addSubview:rightViewSelected];
    [cell setSelectedBackgroundView:selectedCellBackgroundView];
	//显示当前日期
    MOSSMSObject *message = [self.listArray objectAtIndex:[indexPath row]];
    cell.nameLabel.text = [message contactName];
    cell.contentLabel.text = [message content];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    
    NSString *dateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[message date]]];
    cell.dateLabel.text = dateString;
    [dateFormatter release];
	//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell initializeImageView];
    [cell.avatarImageView setImage:[EBBookLocalContacts getPhotoForContact:message.phoneNumber]];
    return cell;
	
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (self.chatViewController == nil) {
		MOSChatViewController *temp = [[MOSChatViewController alloc] initWithNibName:@"MOSChatViewController" bundle:nil];
		self.chatViewController = temp;
		[temp release];
	}
	self.chatViewController.toUid = [[self.listArray objectAtIndex:[indexPath row]] phoneNumber];
    self.chatViewController.titleString = [[self.listArray objectAtIndex:[indexPath row]] contactName];
	[self.navigationController pushViewController:self.chatViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 70;
}

- (void)hasNewMsg:(NSNotification *)params
{
    if([params.object boolValue])
    {
        [self initData];
        [uiTableView reloadData];
    }
}
/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    [self.listArray removeObjectAtIndex:row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                     withRowAnimation:UITableViewRowAnimationFade];
}
*/

@end
