//
//  MOSLocalDetalViewController.m
//  MobileOfficeSuite
//
//  Created by 张 延晋 on 12-10-17.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import "EBBookLocalDetailViewController.h"
#import "EBBookAppDelegate.h"

@interface EBBookLocalDetailViewController ()

@end

@implementation EBBookLocalDetailViewController
@synthesize contactName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibTitle:(NSString *)Title
{
    self = [super init];
    if (self) {
        contactName = Title;
        [self addLeftButtonItem];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = contactName;
    [self.editButtonItem setTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
}

- (void)cancelBtnAction{
	[self dismissModalViewControllerAnimated:YES];
    //[self popupViewController];
}

- (void)addLeftButtonItem{
    if (self.navigationItem.leftBarButtonItem == nil) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelBtnAction)];
        [cancelButton setTintColor:[UIColor blackColor]];
        self.navigationItem.backBarButtonItem = cancelButton;
        //self.navigationItem.hidesBackButton = NO;
        [cancelButton release];
    }
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

- (void)dealloc {
    [super dealloc];
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor blackColor]];
    NSLog(@"editing is %d",editing);
    if (editing == 0) {
        EBBookAppDelegate *appdelegate = (EBBookAppDelegate *)[UIApplication sharedApplication].delegate;
        [appdelegate reloadLocalContacts];
    }
}
@end
