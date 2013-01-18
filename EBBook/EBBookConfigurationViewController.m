//
//  EBBookConfigurationViewController.m
//  EBBook
//
//  Created by Kissshot HeartunderBlade on 12-6-6.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import "EBBookConfigurationViewController.h"
#import "IIViewDeckController.h"
#import "EBBookContactBookViewController.h"
#import "EBBookAccount.h"
#import "EBBookLocalContacts.h"

@interface EBBookConfigurationViewController ()
{
    UIViewController *parentController;
    UIButton *dismissButton;
    UISwitch *synPhoto;
    UISwitch *dialConfirm;
    EBBookAccount *manualUpdateHandler;
    UIActionSheet *changeDefaultSheet;
    UIPickerView *datePicker;
    int currentDefaultTab;
}
@end

@implementation EBBookConfigurationViewController
@synthesize configurationTableView, callbackViewController;

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
   
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        parentController = self.presentingViewController;
    }
    else {
        parentController = self.parentViewController;
    }
    
    synPhoto = [[UISwitch alloc] init];
    dialConfirm = [[UISwitch alloc] init];
    
    NSDictionary *userInfo = [EBBookAccount loadDefaultAccount];
    if([[userInfo objectForKey:@"onlyWifi"] isEqualToString:@"YES"])
        synPhoto.on = YES;
    else {
        synPhoto.on = FALSE;
    }
    
    if([[userInfo objectForKey:@"dialConfirm"] isEqualToString:@"YES"])
        dialConfirm.on = YES;
    else {
        dialConfirm.on = FALSE;
    }
    
    configurationTableView.dataSource = self;
    configurationTableView.delegate = self;
    
    manualUpdateHandler = [[EBBookAccount alloc] init];
    manualUpdateHandler.callbackViewController = self.callbackViewController;
    
    currentDefaultTab = [[[EBBookAccount loadDefaultAccount] objectForKey:@"defaultTab"] intValue];
    
    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 210)];
        [dismissButton addTarget:self action:@selector(dismissThisViewController) forControlEvents:UIControlEventTouchDown];
        [self.view.window addSubview:dismissButton];
        [dismissButton release];
    }
}

- (void)dealloc
{
    [synPhoto release];
    [dialConfirm release];
    [configurationTableView release];
    [manualUpdateHandler release];
    
    [super dealloc];
}

- (void)dismissThisViewController{
    [parentController dismissModalViewControllerAnimated:YES];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [dismissButton removeFromSuperview];
    }
    
    NSString *status;
    if(synPhoto.on)
        status = @"YES";
    else {
        status = @"NO";
    }
    [EBBookAccount saveUserDefaultValue:status forKey:@"onlyWifi"];
    
    if(dialConfirm.on)
        status = @"YES";
    else {
        status = @"NO";
    }
    [EBBookAccount saveUserDefaultValue:status forKey:@"dialConfirm"];
}

- (void)viewDidUnload
{
    [self setConfigurationTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel *footerLabel = [[[UILabel alloc] init] autorelease];
    footerLabel.textAlignment = UITextAlignmentCenter;
    footerLabel.text = @"若[拨号确认]关闭，拨号后将无法自动回到EB通讯录";
    footerLabel.textColor = [UIColor whiteColor];
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.font = [UIFont systemFontOfSize:12];
    return footerLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ConfigurationCell"; 
    
    UITableViewCellStyle style =  UITableViewCellStyleValue1;
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(!cell) 
        cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"ConfigurationCell"] autorelease];
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"更改我的头像";
            NSString *userName = [[EBBookAccount loadDefaultAccount] objectForKey:@"userName"];
            //[cell.imageView setImage:[EBBookLocalContacts getPhotoForContact:userName]];
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UIImageView *currentPhotoAccessory = [[UIImageView alloc] initWithImage:[EBBookLocalContacts getPhotoForContact:userName]];
            currentPhotoAccessory.contentMode = UIViewContentModeScaleAspectFit;
            currentPhotoAccessory.frame = CGRectMake(0, 0, 71, 41);
            cell.accessoryView = currentPhotoAccessory;
            [currentPhotoAccessory release];
            break;
        case 1:
            cell.textLabel.text = @"更新员工信息";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
//        case 2:
//            cell.textLabel.text = @"默认界面设置";
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            switch (currentDefaultTab) {
//                case 0:
//                    cell.detailTextLabel.text = @"员工信息浏览";
//                    break;
//                case 1:
//                    cell.detailTextLabel.text = @"本地通讯录信息浏览";
//                    break;
//                case 2:
//                    cell.detailTextLabel.text = @"T9拨号查询";
//                    break;
//                default:
//                    cell.detailTextLabel.text = @"版本v1.2";
//                    break;
//            }
//            break;
        case 2:
            cell.textLabel.text = @"仅在Wifi下同步头像";
            cell.accessoryView = synPhoto;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        case 3:
            cell.textLabel.text = @"拨号确认";
            cell.accessoryView = dialConfirm;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        default:
            break;
    }    
    return cell;
}

#pragma - UITableViewDataDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        UIActionSheet *changePhotoSheet = [[UIActionSheet alloc] initWithTitle:@"更改头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选取", nil];
        [changePhotoSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        switch (indexPath.row) {
            case 0:
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [changePhotoSheet showInView:self.view.window];
                break;
            default:
                break;
        }
        [changePhotoSheet release];
    }
    else if (indexPath.row == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [manualUpdateHandler manualUpdate];
    }
    else if (indexPath.row == 2){
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        changeDefaultSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n"
                                                                    delegate:nil
                                                           cancelButtonTitle:nil
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles: nil];
        changeDefaultSheet.userInteractionEnabled = YES;
        [changeDefaultSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        datePicker = [[UIPickerView alloc] init];    
        datePicker.dataSource = self;
        datePicker.delegate = self;
        [datePicker setShowsSelectionIndicator:YES];
    
        UIToolbar *toolbarForChangingDefault = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [toolbarForChangingDefault setBarStyle:UIBarStyleBlackOpaque];
        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"取 消" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelDefaultSelectMode)];
        UIBarButtonItem *flexibleSpaceBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"确 定" style:UIBarButtonItemStyleDone target:self action:@selector(fowardDefaultSelect)];
        toolbarForChangingDefault.items = [NSArray arrayWithObjects:cancelBarButton, flexibleSpaceBarButton, doneBarButton, nil];
        [cancelBarButton release];
        [flexibleSpaceBarButton release];
        [doneBarButton release];
        
        UIView *changeDefaultUIView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 280)];
        [changeDefaultUIView addSubview:toolbarForChangingDefault];
        [changeDefaultUIView addSubview:datePicker];

        [changeDefaultSheet addSubview:changeDefaultUIView];
        [toolbarForChangingDefault release];
        [datePicker release];
        [changeDefaultUIView release];
        [changeDefaultSheet showInView:self.view];
        changeDefaultSheet.bounds = CGRectMake(0, 0, 320, 300);
        datePicker.frame = CGRectMake(0, 44, 320, 216);
        [datePicker selectRow:currentDefaultTab inComponent:0 animated:NO];
        [changeDefaultSheet release];
    }
}

#pragma mark - UIPickerViewDatasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
            forComponent:(NSInteger)component{
    NSString *result = nil;
    switch (row) {
        case 0:
            result = @"员工信息浏览";
            break;
        case 1:
            result = @"本地通讯录信息浏览";
            break;
        case 2:
            result = @"T9拨号查询";
            break;  
        default:
            break;
    }
    return result;
}

- (void)cancelDefaultSelectMode
{
    [changeDefaultSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)fowardDefaultSelect
{
    int selectedRow = [datePicker selectedRowInComponent:0];
    NSString *toSaveString = [NSString stringWithFormat:@"%d", selectedRow];
    [EBBookAccount saveUserDefaultValue:toSaveString forKey:@"defaultTab"];
    [changeDefaultSheet dismissWithClickedButtonIndex:0 animated:YES];
    currentDefaultTab = selectedRow;
    [configurationTableView reloadData];
}

#pragma - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self.callbackViewController;
    [picker setAllowsEditing:YES];

    if(buttonIndex == 0)
    {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            [parentController dismissModalViewControllerAnimated:NO];
            [parentController presentModalViewController:picker animated:YES];
        }
    }
    else if (buttonIndex == 1) {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [parentController dismissModalViewControllerAnimated:NO];
            [parentController presentModalViewController:picker animated:YES];

        }
    }
    [picker release];
}
@end
