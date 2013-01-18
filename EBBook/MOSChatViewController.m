//
//  MOSChatViewController.m
//  MobileOfficeSuite
//
//  Created by 张 延晋 on 12-11-27.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import "MOSChatViewController.h"
#import "MOSSMSDatabase.h"
#import "MOSTools.h"
#import "Reachability.h"
#import "EBBookAccount.h"
#import "ASIFormDataRequest.h"
#import "EBBookLocalContacts.h"

//主机地址：
//内网：
#define CHATSERVER_PRIVATE @"http://10.1.69.113:9000/clientpush/index.php"
//外网：
#define CHATSERVER_PUBLIC @"http://218.249.60.69:9000/clientpush/index.php"

@interface MOSChatViewController ()
{
    UIAlertView *notifyView;
    MOSSMSObject *newMessage;
    //CGFloat previousOffSety;
    NSMutableArray *bubbleData;
}
@end

@implementation MOSChatViewController
@synthesize viewArray;
@synthesize chatArray;
@synthesize bubbleTable;
@synthesize inputToolbar;
@synthesize titleString;
@synthesize messageString;
@synthesize isFromNewSMS;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
 
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    inputToolbar = [[UIInputToolbar alloc] initWithFrame:CGRectMake(0, 368, 320, 40)];
    [self.view addSubview:inputToolbar];
    inputToolbar.delegate = self;
    inputToolbar.textView.maximumNumberOfLines = 5;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bubbleTableViewBeginScroll) name:@"BubbleTableViewBeginScroll" object:nil];
//    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
//	self.viewArray = tempArray;
//	[tempArray release];
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.bounds];
    background.image = [UIImage imageNamed: @"mos_background.png"];
    [self.view addSubview:background];
    [self.view sendSubviewToBack:background];

    [background release];
  
    bubbleData = [[NSMutableArray alloc] init];
    bubbleTable.bubbleDataSource = self;
    
    // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
    // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
    // Groups are delimited with header which contains date and time for the first message in the group.
    
    bubbleTable.snapInterval = 120;
    
    // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
    // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
    
    bubbleTable.showAvatars = YES;
    
    // Uncomment the line below to add "Now typing" bubble
    // Possible values are
    //    - NSBubbleTypingTypeSomebody - shows "now typing" bubble on the left
    //    - NSBubbleTypingTypeMe - shows "now typing" bubble on the right
    //    - NSBubbleTypingTypeNone - no "now typing" bubble
    
//    bubbleTable.typingBubble = NSBubbleTypingTypeSomebody;
    
    [bubbleTable reloadData];
    
    
   /*
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [[self view] addGestureRecognizer:recognizer];
    [recognizer release];
   */ 
    if (IOS_VERSION < 6.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillHideNotification object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasNewMsg:) name:@"HasNewMsg" object:nil];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HasNewMsg" object:nil];
    [self setViewArray:nil];
    [self setChatArray:nil];
    [self setBubbleTable:nil];
    [self setInputToolbar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:YES];
	
    //previousOffSety = bubbleTable.contentOffset.y;

	self.title = self.titleString;
    [self reloadMemoryData];

	//[self.messageTextField setText:self.phraseString];
	if (self.isFromNewSMS)
		[self sendMassage:self.messageString];
    
    [self makeTabBarHidden:YES];
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
    //[UIView beginAnimati*****:@"TabbarHide" context:nil];
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

-(void)reloadMemoryData{
    [bubbleData removeAllObjects];
    [chatArray removeAllObjects];
    MOSSMSDatabase *myDatabase = [[MOSSMSDatabase alloc] init];
    [myDatabase openDB];
    [myDatabase createSMSTable];
    self.chatArray = [[[NSMutableArray alloc] initWithArray:[myDatabase querySMSFromTableForKey:self.toUid]]autorelease];
    [myDatabase closeDB];
    [myDatabase release];
    
    for (MOSSMSObject *message in chatArray)
    {
        NSBubbleType msgType;
        NSString *userName;
        if(message.isFromMe)
        {
            msgType = BubbleTypeMine;
            userName = [[EBBookAccount loadDefaultAccount] objectForKey:@"userName"];
        }
        else
        {
            msgType = BubbleTypeSomeoneElse;
            userName = message.phoneNumber;
        }
        NSBubbleData *megaData = [NSBubbleData dataWithText:message.content date:[NSDate dateWithTimeIntervalSince1970:message.date] type:msgType];
        megaData.avatar = [EBBookLocalContacts getPhotoForContact:userName];
        [bubbleData addObject:megaData];
    }
    [self.bubbleTable reloadData];
    [self.bubbleTable scrollToBottom];
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	
	self.isFromNewSMS = NO;
	//[self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
    [self makeTabBarHidden:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [viewArray release];
    [chatArray release];
    [bubbleTable release];
    [inputToolbar release];
    [super dealloc];
    if (IOS_VERSION < 6.0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }

}

- (void)keyboardWillChangeFrame:(NSNotification *)notification{
    
//    if (!([self isFirstResponder]||[messageTextField isFirstResponder])) {
//        return;
//    }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_2
        NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
#else
        NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
#endif
        CGRect keyboardBounds;
        [keyboardBoundsValue getValue:&keyboardBounds];
        //UIEdgeInsets e = UIEdgeInsetsMake(0, 0, keyboardBounds.size.height, 0);
        //[keyboardScrollView setScrollIndicatorInsets:e];
        //[keyboardScrollView setContentInset:e];
        
        NSInteger offset = keyboardBounds.origin.y-20-44-40;
        CGRect listFrame = CGRectMake(0, offset, 320, 40);
        CGRect tableFrame = CGRectMake(0, 0, 320, offset);
        [UIView beginAnimations:@"anim" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        
        //处理移动事件，将各视图设置最终要达到的状态
        [bubbleTable setFrame:tableFrame];
        [inputToolbar setFrame:listFrame];
        //NSLog(@"height is %f",inputView.origin.y);
        //[self reloadInputViews];
        //[keyboardScrollView setContentOffset:CGPointMake(0, offset) animated:NO];
        
        //[self scrollToBottomAnimated:NO];
        
        [UIView commitAnimations];
        
        [self.bubbleTable scrollToBottom];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
    }
#endif
}


-(void)sendMassage:(NSString *)message
{
    if ([MOSTools checkWifiStatus] == NotReachable) {
        //UIAlertView *alertViewNonet = [[UIAlertView alloc] initWithTitle:@"无网络" message:@"您处在飞行模式或无网络状态下,短信功能不可用" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        //[alertViewNonet show];
        //[alertViewNonet release];
        
        [self creteNewMessage:self.toUid withConetnt:message flag:0];
        [self saveNewMessageToDatabase:1 withInfo:@"您处在飞行模式或无网络状态下,短信功能不可用"];
    }
    else{
        NSURL *url;
        if ([EBBookAccount getIsPrivateNetFlag]) {
            NSLog(@"is private net");
            url = [NSURL URLWithString:CHATSERVER_PRIVATE];
        } else {
            NSLog(@"is public net");
            url = [NSURL URLWithString:CHATSERVER_PUBLIC];
        }
        ASIFormDataRequest *_formDataRequest = [ASIFormDataRequest requestWithURL:url];
        [_formDataRequest setPostValue:@"sendmsg" forKey:@"request"];
        
        if([EBBookAccount deviceToken])
        {
            [_formDataRequest setPostValue:[EBBookAccount deviceToken] forKey:@"device_token"];
            [_formDataRequest setPostValue:message forKey:@"msg"];
            [_formDataRequest setPostValue:[[EBBookAccount loadDefaultAccount] objectForKey:@"userName"] forKey:@"from_uid"];
            [_formDataRequest setPostValue:self.toUid forKey:@"to_uid"];
            [_formDataRequest setDelegate:self];
            [inputToolbar.inputButton setEnabled:NO];
            self.title = @"正在发送...";
            
            [self creteNewMessage:self.toUid withConetnt:message flag:1];
            [_formDataRequest startAsynchronous];
        }
        else
        {
            NSLog(@"模拟器不支持推送");
        }
//        TTURLRequest *request = [TTURLRequest requestWithURL:url delegate:self];
//        [request setHttpMethod:@"POST"];
//        request.cachePolicy = TTURLRequestCachePolicyNetwork;
//        [request.parameters setValue:titleString forKey:@"phoneNumbers"];
//        [request.parameters setValue:message forKey:@"message"];
//        
//        request.response = [[[TTURLDataResponse alloc] init] autorelease];
//
//        [request send];
    }

}

- (void)inputButtonPressed:(NSString *)inputText
{
    [self sendMassage:inputText];
}

//#pragma mark - UITableViewDelegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//
//}
//
//#pragma mark - UITableViewDataSource
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return [self.chatArray count];
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UIView *chatView = [self.viewArray objectAtIndex:[indexPath row]];
//    return chatView.frame.size.height+10;
//}
//
//// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
//// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *CommentCellIdentifier = @"CommentCell";
//	ChatCustomCell *cell = (ChatCustomCell*)[tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier];
//	if (cell == nil) {
//		cell = [[[NSBundle mainBundle] loadNibNamed:@"ChatCustomCell" owner:self options:nil] lastObject];
//	}
//    
//    cell.deleteButton.hidden = YES;
//    
//    //UIImageView *cellBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mos_cellbg"]] autorelease];
//    
//    //cell.backgroundView = cellBackgroundView;
//    MOSSMSObject *message;
//    message = [self.chatArray objectAtIndex:[indexPath row]];
//
//    UIView *chatView = [viewArray objectAtIndex:[indexPath row]];
//    [cell.contentView addSubview:chatView];
//    
//    NSString *dateString = [self getDisplayDateText:[message date]];
//   
//    UILabel *messageDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(chatView.frame.origin.x-120, chatView.frame.origin.y+7, 114, 21)];
//    [messageDateLabel setTextAlignment:UITextAlignmentRight];
//    [messageDateLabel setText:dateString];
//    [messageDateLabel setBackgroundColor:[UIColor clearColor]];
//    [messageDateLabel setTextColor:[UIColor whiteColor]];
//    [messageDateLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
//    [cell.contentView addSubview:messageDateLabel];
//    [messageDateLabel release];
//		
//    return cell;
//
//}

- (NSString *)getDisplayDateText:(NSString *)string {
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:[string doubleValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([self isToday:messageDate]) {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    }
    else {
        [dateFormatter setDateFormat:@"YY-MM-dd HH:mm"];
    }
    NSString *dateString = [dateFormatter stringFromDate:messageDate];
    [dateFormatter release];
    return dateString;
}

- (BOOL) isToday:(NSDate*)date
{
    NSDate * today = [NSDate date];
    NSDate * yesterday = [NSDate dateWithTimeIntervalSinceNow:-86400];
    NSDate * refDate = date;
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    NSString * refDateString = [[refDate description] substringToIndex:10];
    
    if ([refDateString isEqualToString:todayString])
    {
        return YES;
    }
    else if ([refDateString isEqualToString:yesterdayString])
    {
        return NO;
    }
    return NO;
}
/*
 生成泡泡UIView
 */
//#pragma mark -
//#pragma mark Table view methods
//- (UIView *)bubbleView:(NSString *)text from:(BOOL)fromSelf {
//	// build single chat bubble cell with given text
//	UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
//	returnView.backgroundColor = [UIColor clearColor];
//	
//	UIImage *bubble = [UIImage imageNamed:fromSelf?@"bubble_self.png":@"bubble_others.png"];
//	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:12 topCapHeight:10]];
//	
//	UIFont *font = [UIFont systemFontOfSize:13];
//	CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(150.0f, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
//	
//	UILabel *bubbleText = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 7.0f, size.width+10, size.height+10)];
//	bubbleText.backgroundColor = [UIColor clearColor];
//	bubbleText.font = font;
//	bubbleText.numberOfLines = 0;
//	bubbleText.lineBreakMode = UILineBreakModeWordWrap;
//	bubbleText.text = text;
//	
//	bubbleImageView.frame = CGRectMake(0.0f, 7.0f, bubbleText.frame.size.width+30.0f, bubbleText.frame.size.height+6.0f);
//	if(fromSelf)
//		returnView.frame = CGRectMake(290.0f-bubbleText.frame.size.width, 0.0f, bubbleText.frame.size.width+30.0f, bubbleText.frame.size.height+12.0f);
//	else
//		returnView.frame = CGRectMake(0.0f, 0.0f, bubbleText.frame.size.width+30.0f, bubbleText.frame.size.height+12.0f);
//	
//	[returnView addSubview:bubbleImageView];
//	[bubbleImageView release];
//	[returnView addSubview:bubbleText];
//	[bubbleText release];
//	
//	return [returnView autorelease];
//}
//
-(void)recoveryTitle
{
    self.title = self.titleString;
}
//
//-(void)dismissAlert
//{
//    [notifyView dismissWithClickedButtonIndex:0 animated:NO];
//    [notifyView release];
//}
//
-(void)creteNewMessage:(NSString *)numbers withConetnt:(NSString *)content flag:(NSInteger)sendFlag
{
    newMessage = [[MOSSMSObject alloc] init];
    [newMessage setContent:content];
    [newMessage setPhoneNumber:numbers];
    [newMessage setDate:[[NSDate date] timeIntervalSince1970]];
    [newMessage setSendSuccess:sendFlag];
    [newMessage setIsFromMe:YES];
    [newMessage setContactName:self.titleString];
    NSBubbleData *chatBubble = [NSBubbleData dataWithText:content date:[NSDate dateWithTimeIntervalSinceNow:0] type:BubbleTypeMine];
    chatBubble.avatar = [EBBookLocalContacts getPhotoForContact:[[EBBookAccount loadDefaultAccount] objectForKey:@"userName"]];
    [bubbleData addObject:chatBubble];
    
    [bubbleTable reloadData];
    [bubbleTable scrollToBottom];
}

//
-(void)saveNewMessageToDatabase:(NSInteger)flag withInfo:(NSString *)infoString
{
    MOSSMSDatabase *myDatabase = [[MOSSMSDatabase alloc] init];
    [myDatabase openDB];
    [myDatabase createSMSTable];
    
    if (flag == 0) {
        //NSLog(@"send Success");
        [newMessage setSendSuccess:1];
        self.title = @"发送成功";
        [self performSelector:@selector(recoveryTitle) withObject:nil afterDelay:1.5f];
    }
    else{
        //NSLog(@"send Failed info String is %@",infoString);
        [newMessage setSendSuccess:0];
        if (infoString) {
            self.title = @"未发送";
            [self performSelector:@selector(recoveryTitle) withObject:nil afterDelay:1.5f];
             notifyView = [[UIAlertView alloc]initWithTitle:@"未发送" message:infoString delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil ];
            [notifyView show];
            [self performSelector:@selector(dismissAlert) withObject:nil
                           afterDelay:1.5f];
        }
        else{
            [self performSelector:@selector(recoveryTitle) withObject:nil afterDelay:1.5f];
            }
        }
    [myDatabase insertMessageIntoTable:newMessage];
    
    [myDatabase closeDB];
    [myDatabase release];
}
//
//- (void)willPresentAlertView:(UIAlertView *)alertView{  // before animation and showing view
//    [notifyView setHeight:110];
//}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    [inputToolbar.inputButton setEnabled:NO];
    self.title = @"正在发送...";
}
//#pragma mark - TTURLRequestDelegate
//- (void)requestDidStartLoad:(TTURLRequest*)request {
//}
//
//
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = request.responseData;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:NSJSONReadingAllowFragments
                          error:nil];
    
    NSInteger returnCode = [[json objectForKey:@"success"] intValue];
    NSString *infoString = [json objectForKey:@"msg"];
    if(returnCode == 0)
    {
        newMessage.date = [[[json objectForKey:@"content"] objectForKey:@"timestamp"] doubleValue] -1;
    }
    [self saveNewMessageToDatabase:returnCode withInfo:infoString];
}

- (void)hasNewMsg:(NSNotification *)params
{
    if([params.object boolValue])
    {
        [self reloadMemoryData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HasNewMsg" object:[NSNumber numberWithBool:NO] userInfo:nil];
    }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////
//- (void)requestDidFinishLoad:(TTURLRequest*)request {
//    TTURLDataResponse *dataResponse = (TTURLDataResponse *)request.response;

//}
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
//- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
//    NSLog(@"error");
//    [sendBtn setEnabled:YES];
//    self.title = @"发送失败";
//    [self saveNewMessageToDatabase:0 withInfo:nil];
//}
/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    BOOL directDown;
    if (previousOffSety < scrollView.contentOffset.y) {
        directDown = YES;
    }
    else{
        directDown = NO;
    }
    
    previousOffSety = scrollView.contentOffset.y;

    if (scrollView.contentOffset.y < 0) {
        return;
    }
    NSLog(@"previousOffSety is %f,scrollviewy is %f,dirctDown is %d",previousOffSety,scrollView.contentOffset.y,directDown);

    if (directDown) {
    }
    else
    {
        [messageTextField resignFirstResponder];
    }
}


-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    
    
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionDown) {
        
        NSLog(@"swipe down");
        //执行程序
    }
    if(recognizer.direction==UISwipeGestureRecognizerDirectionUp) {
        
        NSLog(@"swipe up");
        //执行程序
    }
    
    
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
        
        NSLog(@"swipe left");
        //执行程序
    }
    
    
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        NSLog(@"swipe right");
        //执行程序
    }
    
}
*/

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [inputToolbar.textView resignFirstResponder];
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

- (void)bubbleTableViewBeginScroll
{
    [inputToolbar.textView resignFirstResponder];
}
@end
