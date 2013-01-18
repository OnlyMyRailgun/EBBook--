//
//  MOSNewMessageViewController.m
//  MobileOfficeSuite
//
//  Created by 张 延晋 on 12-11-28.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import "MOSNewMessageViewController.h"

@implementation MOSNewMessageViewController
@synthesize receiverTextField;
@synthesize inputToolBar;
@synthesize firstViewController;
@synthesize chatViewController;
@synthesize receiverArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.bounds];
    background.image = [UIImage imageNamed: @"mos_background.png"];
    [self.view addSubview:background];
    [self.view sendSubviewToBack:background];
    
    [background release];
    
    if (IOS_VERSION < 6.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillHideNotification object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    
    inputToolBar = [[UIInputToolbar alloc] initWithFrame:CGRectMake(0, 204, 320, 40)];
    [self.view addSubview:inputToolBar];
    inputToolBar.delegate = self;
    inputToolBar.textView.maximumNumberOfLines = 5;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChooseChatFriend:) name:@"ChatFriendChoosed" object:nil];
}

- (void)viewDidUnload
{
    [self setReceiverTextField:nil];
    [self setInputToolBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES];
	
	[self.receiverTextField resignFirstResponder];
	[inputToolBar.textView.internalTextView becomeFirstResponder];
	if (self.isAddReceive)
		[self addReceiver];
    
    [super viewWillAppear:animated];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification{
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
            
            NSInteger offset = keyboardBounds.origin.y - 60;
            CGRect listFrame = CGRectMake(0, offset, 320, 40);
            [UIView beginAnimations:@"anim" context:NULL];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:0.3];
            
            //处理移动事件，将各视图设置最终要达到的状态
            //[tableviewbo setFrame:listFrame];
            [inputToolBar setFrame:listFrame];
            [self reloadInputViews];
            //[keyboardScrollView setContentOffset:CGPointMake(0, offset) animated:NO];
            
            //[self scrollToBottomAnimated:NO];
            
            [UIView commitAnimations];
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
        }
#endif
}

-(void)addReceiver
{
	NSMutableString *receiver = [[NSMutableString alloc] init];
	for (int i = 0 ; i < self.receiverArray.count; i++) {
		if (i == self.receiverArray.count - 1) {
			[receiver appendFormat:@"%@",[self.receiverArray objectAtIndex:i]];
		}else {
			[receiver appendFormat:@"%@,",[self.receiverArray objectAtIndex:i]];
		}
	}
	
	if (receiver==nil||[receiver length]<=0)
		self.receiverTextField.text = @"";
	else
		self.receiverTextField.text = receiver;
	
    [receiver release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [receiverTextField release];
    [inputToolBar release];
    [super dealloc];
    if (IOS_VERSION < 6.0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    NSInteger strLength = textField.text.length - range.length + string.length;
//    if([[receiverTextField text] length] > 0)
//        [inputToolBar.inputButton setEnabled:YES];
//    else
//        [inputToolBar.inputButton setEnabled:NO];
    return YES;
}

-(void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	self.isAddReceive = NO;
	self.receiverTextField.text = @"";
}

-(void)inputButtonPressed:(NSString *)inputText
{
    /* Called when toolbar button is pressed */
    NSLog(@"Pressed button with text: '%@'", inputText);
    if(_contactForChating == nil)
    {
        [self showAlternativeUsers:nil];
    }
    else
    {
        if (self.firstViewController == nil) {
            NSLog(@"没有回调");
        }
        
        if (self.chatViewController == nil) {
            MOSChatViewController *temp = [[MOSChatViewController alloc] initWithNibName:@"MOSChatViewController" bundle:nil];
            self.chatViewController = temp;
            [temp release];
        }
        
        self.chatViewController.titleString = _contactForChating.name;
        self.chatViewController.toUid = _contactForChating.uid;
        self.chatViewController.isFromNewSMS = YES;
        self.chatViewController.messageString = inputText;
        
        [self dismissModalViewControllerAnimated:YES];
        [((UIViewController *)self.firstViewController).navigationController pushViewController:self.chatViewController animated:YES];
    }
}

- (IBAction)showAlternativeUsers:(UIButton *)sender {
    EBBookChooseChatUsersViewController *chooseFriendsViewController = [[EBBookChooseChatUsersViewController alloc] init];
    [self presentModalViewController:chooseFriendsViewController animated:YES];
    [chooseFriendsViewController release];
}

- (void)didChooseChatFriend:(NSNotification *)param
{
    _contactForChating = param.object;
    receiverTextField.text = _contactForChating.name;
}
@end
