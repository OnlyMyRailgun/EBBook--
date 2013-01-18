//
//  MOSEditGroupViewController.m
//  MobileOfficeSuite
//
//  Created by 张 延晋 on 12-10-15.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import "EBBookLocalEditGroupViewController.h"
#import "ContactData.h"
#import "EBBookAppDelegate.h"

@interface EBBookLocalEditGroupViewController ()

@end

@implementation EBBookLocalEditGroupViewController
@synthesize contactGroup;

- (void) back {
    [self dismissModalViewControllerAnimated:YES];
}

-(void)dealloc
{
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initwithGroup:(NSArray*)group
{
    self = [super init];
    if (self) {
        self.contactGroup = [[[NSMutableArray alloc] initWithArray:group] autorelease];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"群组管理";
    [self.tableView setEditing:YES];
    
    UIBarButtonItem *backTarbarItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    [backTarbarItem setTintColor:[UIColor blackColor]];
    self.navigationItem.leftBarButtonItem = backTarbarItem;
    [backTarbarItem release];
 
     UIBarButtonItem *multiSelectBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewGroup)];
    [multiSelectBarItem setTintColor:[UIColor blackColor]];
    self.navigationItem.rightBarButtonItem = multiSelectBarItem;
    [multiSelectBarItem release];
    
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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


#pragma mark - alertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"确定"]){
        UITextField *groupTextField = [alertView textFieldAtIndex:0];
        NSString *groupName = [groupTextField text];
        NSLog(@"%@",groupName);
        [self addABGroup:groupName];
    }
    else{
    }
}

- (void)addNewGroup
{
    UIAlertView *groupAlertView = [[UIAlertView alloc] initWithTitle:@"新群组名"
                                                             message:nil delegate:self
                                                   cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [groupAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [groupAlertView textFieldAtIndex:0].placeholder = @"请输入新的群组名";
    if(![groupAlertView isVisible])
        [groupAlertView show];
    [groupAlertView release];
}

-  (void)addABGroup:(NSString *)name
{
	if ([name length] != 0)
	{
		CFErrorRef error = NULL;
		ABRecordRef newGroup = ABGroupCreate();
		ABRecordSetValue(newGroup,kABGroupNameProperty,name,&error);

		ABAddressBookAddRecord(addressBook, newGroup, &error);
		ABAddressBookSave(addressBook, &error);

        [contactGroup addObject:[ABGroup groupWithRecord:(ABRecordRef)newGroup]];
        
        [self.tableView reloadData];
		
		CFRelease(newGroup);
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [contactGroup count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	ABGroup *group = [self.contactGroup objectAtIndex:indexPath.row];
    cell.textLabel.text = group.name;
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

// Handle the deletion of a group
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		ABGroup *group = [contactGroup objectAtIndex:indexPath.row];
		
		// Remove the group from the address book
		[self deleteGroup:group.record fromAddressBook:addressBook];
        [self.contactGroup removeObjectAtIndex:indexPath.row];

		// Update the table view
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		
		// Remove the section from the table if the associated source does not contain any groups
		if ([contactGroup count] == 0)
		{
			// Remove the source from sourcesAndGroups
			
			[tableView deleteSections: [NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
		}
	}
}

// Remove a group from the given address book
- (void)deleteGroup:(ABRecordRef)group fromAddressBook:(ABAddressBookRef)myAddressBook
{
	CFErrorRef error = NULL;
	ABAddressBookRemoveRecord(myAddressBook, group, &error);
	ABAddressBookSave(myAddressBook,&error);
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
