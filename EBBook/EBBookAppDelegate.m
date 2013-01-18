//
//  EBBookAppDelegate.m
//  EBBook
//
//  Created by Kissshot HeartunderBlade on 12-6-6.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import "EBBookAppDelegate.h"
#import "ASIFormDataRequest.h"
#import "IIViewDeckController.h"
#import "EBBookGroupViewController.h"
#import "EBBookLocalGroupViewController.h"
#import "EBBookAccount.h"
#import "EBBookLocalContactViewController.h"
#import <MobClick.h>
#import "EBExT9KeyboardViewController.h"
#import "MOSSMSTableViewController.h"
#import "ContactData.h"

@implementation EBBookAppDelegate

@synthesize window = _window;
@synthesize localNamePhoneContact;
@synthesize localEBContact;
- (void)dealloc
{
    [localEBContact release];
    [localNamePhoneContact release];
    [checkUser release];
    [_window release];
    [super dealloc];
}

- (void)openLocalData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"EBContacts" ofType:@"db"];
    NSData *responseData = [NSData dataWithContentsOfFile:path];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *dbFile = [documentsDirectory stringByAppendingPathComponent:@"EBContacts.db"];
    
    [responseData writeToFile:dbFile atomically:YES];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    if(addressBook == nil)
		addressBook = ABAddressBookCreate();

    self.localEBContact = [NSMutableArray array];
    self.localNamePhoneContact = [NSMutableArray array];
    
    [self reloadLocalContacts];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

    //中间View
    EBBookContactBookViewController *contactBookViewController = [[EBBookContactBookViewController alloc] initWithNibName:@"EBBookContactBookViewController" bundle:nil];
    
    // Add create and configure the navigation controller.
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contactBookViewController];
    if(checkUser == nil)
    {
        checkUser = [[EBBookAccount alloc] init];
    }
    checkUser.callbackViewController = contactBookViewController;
    [contactBookViewController release];
    [navigationController.navigationBar setBarStyle:UIBarStyleBlack];

    //本地
    EBBookLocalContactViewController *localContactViewController = [[EBBookLocalContactViewController alloc] initWithNibName:@"EBBookLocalContactViewController" bundle:nil];
    
    UINavigationController *navigationlocalController = [[UINavigationController alloc] initWithRootViewController:localContactViewController];
    [localContactViewController release];
    [navigationlocalController.navigationBar setBarStyle:UIBarStyleBlack];
    
    //左侧View
    EBBookGroupViewController *groupViewController = [[EBBookGroupViewController alloc] init];
    EBBookLocalGroupViewController *localGroupViewController = [[EBBookLocalGroupViewController alloc] init];
    
    //deckView
    IIViewDeckController *deckController = [[IIViewDeckController alloc] initWithCenterViewController:navigationController leftViewController:groupViewController];
    deckController.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
    deckController.leftLedge = 132;

    //deckView
    IIViewDeckController *localDeckController = [[IIViewDeckController alloc] initWithCenterViewController:navigationlocalController leftViewController:localGroupViewController];
    localDeckController.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
    localDeckController.leftLedge = 132;
    
    //T9
    EBExT9KeyboardViewController *exT9ViewController = [[EBExT9KeyboardViewController alloc] initWithNibName:@"EBExT9KeyboardViewController" bundle:nil];
    
    //Chat
    MOSSMSTableViewController *messageListViewController = [[MOSSMSTableViewController alloc] initWithNibName:@"MOSSMSTableViewController" bundle:nil];
    UINavigationController *messageListViewControllerNav = [[UINavigationController alloc] initWithRootViewController:messageListViewController];
    [messageListViewControllerNav.navigationBar setBarStyle:UIBarStyleBlack];
    
    //Blog
    EBBookBlogViewController *blogViewController = [[EBBookBlogViewController alloc] initWithNibName:@"EBBookBlogViewController" bundle:nil];
    
    //tabbar
    UITabBarItem *firstTabItem = [[UITabBarItem alloc] initWithTitle:@"集团通讯录" image:[UIImage imageNamed:@"集团通讯录"] tag:0];
    deckController.tabBarItem = firstTabItem;
    [firstTabItem release];
    
    UITabBarItem *secondTabItem = [[UITabBarItem alloc] initWithTitle:@"本地通讯录" image:[UIImage imageNamed:@"个人通讯录"] tag:1];
    localDeckController.tabBarItem = secondTabItem;
    [secondTabItem release];

    UITabBarItem *thirdTabItem = [[UITabBarItem alloc] initWithTitle:@"拨号" image:[UIImage imageNamed:@"键盘弹出"] tag:2];
    exT9ViewController.tabBarItem = thirdTabItem;
    [thirdTabItem release];
    
    _forthTabItem = [[UITabBarItem alloc] initWithTitle:@"集团短信" image:[UIImage imageNamed:@"短信"] tag:3];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasNewMsg:) name:@"HasNewMsg" object:nil];
    messageListViewController.tabBarItem = _forthTabItem;

    UITabBarItem *fifthTabItem = [[UITabBarItem alloc] initWithTitle:@"公告" image:[UIImage imageNamed:@"综合管理部"] tag:4];
    blogViewController.tabBarItem = fifthTabItem;
    [fifthTabItem release];
    
    UITabBarController *_mainTabController = [[UITabBarController alloc] init];
    NSArray *threeViewControllers = [[NSArray alloc]
                                   initWithObjects: messageListViewControllerNav, deckController, exT9ViewController, localDeckController, blogViewController, nil];
    [exT9ViewController release];
    [_mainTabController setViewControllers:threeViewControllers];
    [threeViewControllers release];
    [messageListViewController release];
    [messageListViewControllerNav release];
    [blogViewController release];
//    [mainTabController setSelectedIndex:[[[EBBookAccount loadDefaultAccount] objectForKey:@"defaultTab"] intValue]];
   [_mainTabController setSelectedIndex:1];
    //rootView
    self.window.rootViewController = _mainTabController;
    
    [navigationlocalController release];
    [localGroupViewController release];
    [navigationController release];
    [groupViewController release];
    [localDeckController release];
    [deckController release];
    [_mainTabController release];
    
    [MobClick startWithAppkey:@"4ff2a8125270153a270000c8" reportPolicy:REALTIME channelId:nil];
    [MobClick setLogEnabled:YES];
    [MobClick setCrashReportEnabled:YES];
 
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSString *dtString = [NSString stringWithFormat:@"%@",deviceToken];//
    NSString *dt = [dtString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    //目标字符 用指定的字符替换
    NSString *dn = [dt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.globalDeviceToken = [dn stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if(![[EBBookAccount loadDefaultAccount] objectForKey:@"userName"])
        exit(0);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [checkUser checkUserActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HasNewMsg" object:nil];
    CFRelease(addressBook);
    [_forthTabItem release];
}

-(void)reloadLocalContacts{
    [localEBContact removeAllObjects];
    [localNamePhoneContact removeAllObjects];
    
    [EBBookLocalContactViewController initDataForAllGroup:self.localEBContact contactArray:self.localNamePhoneContact];
}

- (void)hasNewMsg:(NSNotification *)params
{
    if([params.object boolValue])
        _forthTabItem.badgeValue = @"新消息";
    else
        _forthTabItem.badgeValue = nil;
}
@end
