//
//  EBViewController.m
//  EB_ADBook
//
//  Created by 延晋 张 on 12-6-15.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EBADBookDetailViewController.h"
#import "EBBookContact.h"
#import "EBBookDetailTableView.h"
#import "EBBookLocalContacts.h"
#import "EBBookDatabase.h"
#import "UIImageView+Addition.h"
#import "EBBookAccount.h"
#import "EBBookAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface EBADBookDetailViewController ()
{
    EBBookContact * _eBer;
    EBBookDetailTableView * detailView;
    UIImageView *HeadPortraitView;
    NSMutableArray  *uidList;
    UIAlertView *warningView;
    SuperLink *TitleLabel;
}
@end

@interface EBADBookDetailViewController (Private)
- (void) statusInit;
- (void) makeCall:(NSString* ) phoneNumber;
- (void) initDetials:(EBBookContact* ) eber;
- (void)sendMessage:(NSString *)messageContent to:(NSString*)recevier;
@end

@implementation EBADBookDetailViewController
@synthesize topBarItem;
@synthesize UIDLabel;
@synthesize headerView;
@synthesize NameLabel;
@synthesize locManager;
@synthesize freeJump;
@synthesize progressView;
@synthesize callbackViewController;

#pragma mark - OutLet
- (IBAction)back:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Interface

- (id) initWithEBContact:(EBBookContact* ) contact 
{
    self = [super init];
    if(self){
        _eBer = contact;
    }
    return self;
}

#pragma mark - Private
#pragma mark SaveToContact
-(void) finishSaving:(UIAlertView *)alertView
{
    [EBBookLocalContacts finishSaving:alertView];
}

- (void) addContact
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [EBBookLocalContacts addContactToDevice:_eBer];
    EBBookAppDelegate *appdelegate = (EBBookAppDelegate *)[UIApplication sharedApplication].delegate;
    [appdelegate reloadLocalContacts];
    [self performSelectorOnMainThread:@selector(finishSaving:) withObject:warningView waitUntilDone:NO];
    [pool release];
}

- (void)sendMessage:(NSString *)messageContent to:(NSString*)recevier
{
    NSString *message = messageContent;
    NSString *rever = recevier;
    if( [MFMessageComposeViewController canSendText] )
    {
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init] ;
        controller.recipients = [NSArray arrayWithObjects:rever, nil];
        controller.messageComposeDelegate = self;
        controller.body = message;
        
        [self presentModalViewController:controller animated:YES];
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:@"新信息"];//修改短信界面标题
        [controller release];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                        message:@"该设备不支持短信功能"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确定", nil];
        [alert show];
        [alert release];
    }
}

#pragma mark saveToFavourite
- (void) savetoFavourite:(NSString *) status
{
    EBBookDatabase *myDatabase = [[EBBookDatabase alloc] init];
    [myDatabase openDB];

    [myDatabase updateFavoriteStatusForContact:_eBer.uid withInt:status];
    
    [myDatabase closeDB];
    [myDatabase release];
    
    NSString *message;
    if([status isEqualToString:@"1"])
    {
        message = @"成功添加到收藏夹";
        _eBer.isFavorite = @"1";
    }
    else {
        message = @"成功移出收藏夹";
        _eBer.isFavorite = @"0";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" 
                                                    message: message
                                                   delegate:self 
                                          cancelButtonTitle:@"好的" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark Init
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    TitleLabel = [[SuperLink alloc] initWithFrame:CGRectMake(127, 81, 170, 20) freeJump:self.freeJump];
    TitleLabel.delegate = self;
    [headerView addSubview:TitleLabel];
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions)];
    topBarItem.rightBarButtonItem = actionButton;
    [actionButton release];
    [self statusInit];
    
    self.locManager = [[[CLLocationManager alloc] init] autorelease];
    [self.locManager setDelegate:self];
	if (![CLLocationManager locationServicesEnabled])
	{
		NSLog(@"User has opted out of location services");
		return;
	}
	else
	{
		// User generally allows location calls
		self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
	}
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"正在获取位置信息..." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    UIActivityIndicatorView *activeView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activeView.center = CGPointMake(alertView.bounds.size.width/2.0f+140.0f, alertView.bounds.size.height+75.0f);
    //activeView.center = CGPointMake(verifyView.bounds.size.width/2.0f, verifyView.bounds.size.height-40.0f);
    [activeView startAnimating];
    [alertView addSubview:activeView];
    [activeView release];
    self.progressView = alertView;
    [alertView release];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidUnload
{
    [self setNameLabel:nil];
    [self setUIDLabel:nil];
    [self setTopBarItem:nil];
    [self setHeaderView:nil];
    [self setProgressView:nil];
    [super viewDidUnload];
}

- (void) dealloc
{
    [uidList release];
    [HeadPortraitView release];
    [NameLabel release];
    [TitleLabel release];
    [detailView release];
    [UIDLabel release];
    [topBarItem release];
    [headerView release];
    [TitleLabel release];
    [progressView release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) statusInit
{
    HeadPortraitView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 23, 75, 75)];
    HeadPortraitView.userInteractionEnabled = YES;
    HeadPortraitView.contentMode = UIViewContentModeScaleAspectFill;
    HeadPortraitView.clipsToBounds = YES;
    HeadPortraitView.layer.cornerRadius = 5.0f;
    HeadPortraitView.layer.borderWidth = 0.8f;
    HeadPortraitView.layer.borderColor = [[UIColor grayColor] CGColor];
    [headerView addSubview:HeadPortraitView];
    [HeadPortraitView addDetailShow];
    
    UIImage *headPortraitPhoto = [EBBookLocalContacts getPhotoForContact:_eBer.uid];
    
    if (headPortraitPhoto.size.height > 0.0000001) {
        HeadPortraitView.image = headPortraitPhoto;
    }
    else {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"adressbook_default@2x" ofType:@"png"];
        HeadPortraitView.image = [UIImage imageWithContentsOfFile:path];
    }
   
    NSString *nameLabel;
    if([[EBBookAccount currentDateToString] isEqualToString:_eBer.birthdate])
    {
        nameLabel = [_eBer.name stringByAppendingString:@"  🎂"];
    }
    else {
        nameLabel = _eBer.name;
    }

    NameLabel.text = nameLabel;
    UIDLabel.text = _eBer.salaryId;
    
    TitleLabel.text = _eBer.title;
#if 0
    if (_eBer.center.length == 0) {
        CentreLabel.text = _eBer.department;
        CentreLabel.numberOfLines = 1;
        CentreLabel.contentMode = UIViewContentModeCenter;
    }
    else {
        NSString *depString = [[NSString alloc] initWithFormat:@"%@\n%@",_eBer.center,_eBer.department];
        
        CentreLabel.contentMode = UIViewContentModeTop;
        CentreLabel.text = depString;
        CentreLabel.numberOfLines = 2;
        [depString release];
        //NSLog(@"%@",depString);
    }
#endif
    
    NSInteger rouCount = 2;
    if (_eBer.vpmn.length == 6) {
        rouCount++;
    }
    if (_eBer.tel.length > 1) {
        rouCount++;
    }
    
    detailView = [[EBBookDetailTableView alloc ] initWithFrame:CGRectMake(0, 44, 320, 460-44)  ebContact:_eBer];
    detailView.viewDelegate = self;
    
    NSDictionary *userInfo = [EBBookAccount loadDefaultAccount];
    if([[userInfo objectForKey:@"dialConfirm"] isEqualToString:@"YES"])
        detailView.dialFlag = YES;
    else {
        detailView.dialFlag = NO;
    }
    
    if(_eBer.hasRegisteredForChat)
    {
        headerView.frame = CGRectMake(0, 44, 320, 167);
    }
    detailView.scrollEnabled = YES;
    detailView.tableHeaderView = headerView;
    [self.view addSubview:detailView];
              
}

- (IBAction)sendChatMsgBtnPressed:(UIButton *)sender {
    MOSNewMessageViewController *temp = [[MOSNewMessageViewController alloc] initWithNibName:@"MOSNewMessageViewController" bundle:nil];
    temp.firstViewController = self;
	[self presentModalViewController:temp animated:YES];
    temp.contactForChating = _eBer;
    temp.receiverTextField.text = _eBer.name;
    [temp release];
}
#pragma mark - Delegate
#pragma mark SuperLinkDelegate
- (void)superLink:(SuperLink *)superLink touchesWtihTag:(NSInteger)tag
{
    NSString *titleValue = [[[NSString alloc] initWithFormat:@"%@",_eBer.title ] autorelease];
    [self selectEberForKey:@"title" withValue:titleValue];
}

#pragma mark UIActionSheetDelegate

- (void) showActions
{
    NSString *addToFavoriteStr;
    NSString *removeFromFavoriteStr;
    if([_eBer.isFavorite isEqualToString:@"1"])
    {
        addToFavoriteStr = nil;
        removeFromFavoriteStr = @"从收藏夹移出";
    }
    else {
        addToFavoriteStr = @"添加到收藏夹";
        removeFromFavoriteStr = nil;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择需要的操作" delegate:self cancelButtonTitle:nil destructiveButtonTitle:removeFromFavoriteStr otherButtonTitles:@"添加到本地通讯录", addToFavoriteStr, nil];
    [actionSheet addButtonWithTitle:@"分享联系人"];
    [actionSheet addButtonWithTitle:@"分享位置"];
    [actionSheet addButtonWithTitle:@"取消"];
    actionSheet.cancelButtonIndex = 4;
    actionSheet.tag = 301;
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [actionSheet showInView:self.view.window];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 301) {
        if([_eBer.isFavorite isEqualToString:@"1"])
        {
            if(buttonIndex == 0)
            {
                //remove
                [self savetoFavourite:@"0"];
            }
            else if (buttonIndex == 1) {
                warningView = [EBBookLocalContacts alertSaving:@"正在保存联系人..."];
                [NSThread detachNewThreadSelector:@selector(addContact) toTarget:self withObject:nil];
            }
        }
        else {
            if(buttonIndex == 0)
            {
                warningView = [EBBookLocalContacts alertSaving:@"正在保存联系人..."];
                [NSThread detachNewThreadSelector:@selector(addContact) toTarget:self withObject:nil];
            }
            else if (buttonIndex == 1) {
                //add
                [self savetoFavourite:@"1"];
            }
        }
        if(buttonIndex == 2){
            NSMutableString *contactString = [[NSMutableString alloc] initWithFormat:@"[姓名]%@;\n[手机]%@;",_eBer.name,_eBer.mobile];
            if (_eBer.tel.length > 1) {
                [contactString appendFormat:@"\n[办公电话]%@;",_eBer.tel ];
            }
            [self sendMessage:contactString to:nil];
            [contactString release];
        }
        if (buttonIndex == 3) {
            if ([CLLocationManager locationServicesEnabled]) {
                [self.progressView show];
            }
            //warningView = [EBBookLocalContacts alertSaving:@"正在定位..."];
            [locManager startUpdatingLocation];
        }
    }
    else if (actionSheet.tag == 302)
    {
        if (buttonIndex < uidList.count) {
            EBBookDatabase *myDatabase = [[EBBookDatabase alloc] init];
            [myDatabase openDB];
            
            EBBookContact *selectedContact = [myDatabase getEBerFromTableForValue:[uidList objectAtIndex:buttonIndex]];
            //NSLog(@"uid is %@ ",selectedContact.uid);
            EBADBookDetailViewController *detailViewController = [[EBADBookDetailViewController alloc] initWithEBContact: selectedContact];
            detailViewController.callbackViewController = self.callbackViewController;
            detailViewController.freeJump = NO;
            detailViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentModalViewController:detailViewController animated:YES];
            [detailViewController release];
            [myDatabase closeDB];
            [myDatabase release];
        }
    }
}

#pragma mark LocateDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSLog(@"didUpdateToLocation");
    CLLocationCoordinate2D loc = [newLocation coordinate];
    NSString *lat =[[NSString alloc] initWithFormat:@"%f",loc.latitude];//get latitude
    NSString *lon =[[NSString alloc] initWithFormat:@"%f",loc.longitude];//get longitude
    [self performCoordinateGeocode:loc];
    //NSLog(@"%@ %@",lat,lon);
    [lat release];
    [lon release];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError is %@",[error localizedDescription]);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法获取你的位置信息" message:@"请到手机系统的[设置]->[隐私]->[定位服务]中打开定位服务，并允许EBBook使用定位服务" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
    [self.progressView dismissWithClickedButtonIndex:0 animated:YES];

}

- (void)performCoordinateGeocode:(CLLocationCoordinate2D ) coord
{
    NSLog(@"performCoordinateGeocode");
    CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
    coord.latitude = coord.latitude + 0.001395;
    coord.longitude = coord.longitude + 0.006088;
    CLLocation *location = [[[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude] autorelease];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
            [self displayError:error];
            return;
        }
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        NSDictionary *locateDic = [[[NSDictionary alloc] initWithDictionary:placemark.addressDictionary] autorelease];
        NSString *cnName = [locateDic objectForKey:@"Name"];
        //NSString *messageContent = [[NSString alloc] initWithFormat:@"http://www.EBBook.com/(%f,%f)%@[EB通讯录]",placemark.location.coordinate.latitude,placemark.location.coordinate.longitude,cnName ];
        NSString *messageContent = [[NSString alloc] initWithFormat:@"(%f,%f)%@",placemark.location.coordinate.latitude,placemark.location.coordinate.longitude,cnName ];
        [self sendMessage:messageContent to:_eBer.mobile];
        [self.progressView dismissWithClickedButtonIndex:0 animated:YES];

        [messageContent release];
        [locManager stopUpdatingLocation];
    }];
}

- (void)displayError:(NSError*)error
{
    NSLog(@"displayError");
    dispatch_async(dispatch_get_main_queue(),^ {
        
        NSString *message;
        switch ([error code])
        {
            case kCLErrorGeocodeFoundNoResult: message = @"kCLErrorGeocodeFoundNoResult";
                break;
            case kCLErrorGeocodeCanceled: message = @"kCLErrorGeocodeCanceled";
                break;
            case kCLErrorGeocodeFoundPartialResult: message = @"kCLErrorGeocodeFoundNoResult";
                break;
            default: message = [error description];
                break;
        }
        
        UIAlertView *alert =  [[[UIAlertView alloc] initWithTitle:@"An error occurred."
                                                          message:message
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil] autorelease];;
        [alert show];
    });
}

#pragma mark EBBookDetailTableViewDelegate

-(void) selectEberForKey:(NSString *)key withValue:(NSString *)value
{
    if (freeJump) {
        [self dismissModalViewControllerAnimated:YES];
        [callbackViewController refreshActionForKey:key withValue:value];
    }
}

-(void) jumpToLeader:(NSString *)leader withUidString:(NSString *)uidString
{
    if (freeJump) {
        NSString *value = leader;
        NSArray *reportList = [value componentsSeparatedByString:@"->"];
        NSMutableArray *leaderList = [NSMutableArray arrayWithArray:reportList];
        [leaderList removeObjectAtIndex:0];
        UIActionSheet *reportView = [[UIActionSheet alloc] initWithTitle:@"选择联系人" delegate:self cancelButtonTitle:nil   destructiveButtonTitle:nil otherButtonTitles:nil, nil];
        reportView.tag = 302;
        for (NSString *boss in leaderList) {
            [reportView addButtonWithTitle:boss];
        }
        [reportView addButtonWithTitle:@"取消"];
        reportView.cancelButtonIndex = leaderList.count;
        [reportView showInView:self.view.window];
        [reportView release];
    
        NSLog(@"uidString is %@",uidString);
        NSString *uid = @"anxinchao->zhengwei->tangzhou->liaojianxin";
        NSArray *uidLeaderList = [uid componentsSeparatedByString:@"->"];
        uidList = [[NSMutableArray alloc ] initWithArray:uidLeaderList];
        [uidList removeObjectAtIndex:0];
    }
}

-(void) viewSendMessage
{
    [self sendMessage:nil to:_eBer.mobile];
}

- (void)viewSendMail:(NSString*)mail
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
	if (mailClass != nil) {
        // We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail]) {
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;     
            
            [[[[picker viewControllers] lastObject] navigationItem] setTitle:@"新邮件"];//修改短信界面标题
            // Set up recipients
            NSArray *toRecipients = [NSArray arrayWithObjects:mail, nil]; 
            
            [picker setToRecipients:toRecipients];
            
            [self presentModalViewController:picker animated:YES];
            [picker release];
		}
		else {
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
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确定", nil];
        [alert show];
        [alert release];
    }
}

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
            //[self cancelMultiSelectMode];
			break;
		case MessageComposeResultFailed:
			//feedbackMsg.text = @"Result: SMS sending failed";
            //[self cancelMultiSelectMode];
			break;
		default:
			//feedbackMsg.text = @"Result: SMS not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}


@end
