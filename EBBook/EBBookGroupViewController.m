//
//  EBBookGroupViewController.m
//  EBBook
//
//  Created by Kissshot HeartunderBlade on 12-6-19.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import "EBBookGroupViewController.h"
#import "IIViewDeckController.h"
#import "EBBookContactBookViewController.h"
#import "UIExpandableTableView.h"
#import "GHCollapsingAndSpinningTableViewCell.h"

#define RowsInSection0 2
@interface EBBookGroupViewController (){
    NSArray *centerNameArray;
    NSArray *departmentNameArray;
    int expandingSection;//正打开的section
    int expandingRow;//正打开的row
}

@end

@implementation EBBookGroupViewController

- (void)loadView {
    self.tableView = [[[UIExpandableTableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 480.0f) style:UITableViewStylePlain] autorelease];
    expandingSection = 0;
    expandingRow = 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    centerNameArray = [NSArray arrayWithObjects:@"全体员工", @"收藏夹",@"市场营销中心", @"工程与支持服务中心", @"移动互联网产品中心", @"支撑产品中心", @"电信业务产品中心", @"测试部", @"战略研究部", @"质量部", @"财务部", @"商务部", @"综合管理部", nil];
    [centerNameArray retain];
    
    departmentNameArray = [NSArray arrayWithObjects:[NSArray arrayWithObjects:@"市场部",  @"销售部", @"运营技术部", @"技术支持部", nil], [NSArray arrayWithObjects:@"客户服务部", @"工程部", @"工程技术部", nil], [NSArray arrayWithObjects:@"业务发展部", @"产品创新部", @"平台系统部", nil], [NSArray arrayWithObjects:@"商业智能部", @"支撑软件部", @"系统支撑部", nil],  [NSArray arrayWithObjects:@"媒体业务产品部", @"智能业务产品部", nil], nil];
    [departmentNameArray retain];

    self.tableView.tableHeaderView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"files_manager_top"]] autorelease];
    
    self.tableView.tableFooterView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"files_manager_bottom_shadow"]] autorelease];
    
    self.tableView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    [self.tableView reloadData];
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

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    // return YES, if the section should be expandable
    if (section > 0 && section < 6) {
        return YES;
    }
    return NO;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    // return YES, if you need to download data to expand this section. tableView will call tableView:downloadDataForExpandableSection: for this section
    if(section > 0 && section < 6 && (section != expandingSection ||(section == expandingSection && expandingRow != 0)))//打开未展开的section或者打开已展开的section的row0
        return YES;
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    static NSString *CellIdentifier = @"GroupExpandableCell";
    
    GHCollapsingAndSpinningTableViewCell *cell = (GHCollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[GHCollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell...
    if(section > 0 && section < 6)
    {
        cell.textLabel.text = [centerNameArray objectAtIndex:section+1];
        cell.textLabel.backgroundColor = [UIColor clearColor];
    }
   
    return cell;
}

#pragma mark - UIExpandableTableViewDelegate
- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    // download your data here
    NSString *selectedGroup;
    NSString *key = @"Center";
    if(section > 0 && section < 6)
    {
        selectedGroup = [centerNameArray objectAtIndex:section+1];
        UINavigationController * centerNav = (UINavigationController *)self.viewDeckController.centerController;
        [((EBBookContactBookViewController *)[centerNav topViewController]) refreshActionForKey:key withValue:selectedGroup];
        for(int i = 1; i < 6; i++)
        {
            if (i != section) {
                [tableView collapseSection:i animated:YES];
            }
        }
        expandingSection = section;
        expandingRow = 0;
        if([tableView isSectionExpanded:section])
            [tableView collapseSection:section animated:YES];
        else {
            [tableView expandSection:section animated:YES];
        }
    }
    
     //if download was successful
    // call [tableView cancelDownloadInSection:section]; if your download was NOT successful
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if(section > 0 && section < 6){
        return [[departmentNameArray  objectAtIndex:section-1] count]+1;// return +1 here, because this section can be expanded

    }
    else if(section == 0)
        return RowsInSection0;
    else
        return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SubCell"; 
    
    UITableViewCellStyle style =  UITableViewCellStyleSubtitle;
    UITableViewCell *cell;
    // Configure the cell...
    if(indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
        if(!cell)
            cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"GroupCell"] autorelease];
        UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"files_manager_bg"]];
        cell.backgroundView = cellBackgroundView;
        cell.textLabel.text = [centerNameArray objectAtIndex:indexPath.row];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        //cell.detailTextLabel.text = [(EBBookContact *)[[sectionArray objectAtIndex:
        [cellBackgroundView release];
        
        if(indexPath.row == 0)
            [cell.imageView setImage:[UIImage imageNamed: @"全体员工"]];
        else if(indexPath.row == 1)
            [cell.imageView setImage:[UIImage imageNamed: @"收藏"]];
    }
    else if(indexPath.section == 6){
        cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
        if(!cell) 
            cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"GroupCell"] autorelease];
        UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"files_manager_bg"]];
        cell.backgroundView = cellBackgroundView;
        cell.textLabel.text = [centerNameArray objectAtIndex:indexPath.row+7];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        [cell.imageView setImage:nil];
        
        //cell.detailTextLabel.text = [(EBBookContact *)[[sectionArray objectAtIndex:
        [cellBackgroundView release];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell){
            cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:CellIdentifier] autorelease];
            cell.indentationWidth = 30.0f;
            cell.indentationLevel = 1;
        }
        cell.textLabel.text = [[departmentNameArray objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row - 1];// use -1 here, because the expanding cell is always at row 0
        UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edged_paper"]];
        cell.backgroundView = cellBackgroundView;
        [cellBackgroundView release];
        cell.textLabel.backgroundColor = [UIColor clearColor];        
    }
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section > 0 && indexPath.section < 6)
        if(indexPath.row > 0)
            return 50;
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger indentationLevel = 0;
    if(indexPath.section > 0 && indexPath.section < 6)
        if(indexPath.row > 0)
            indentationLevel = 1;
    return indentationLevel;
}

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
    NSString *selectedGroup;
    NSString *key;
    if(indexPath.section == 0)
    {
        for(int i = 1; i < 6; i++)
            [(UIExpandableTableView *)tableView collapseSection:i animated:YES];
        expandingSection = 0;
        selectedGroup = [centerNameArray objectAtIndex:indexPath.row];
        key = nil;
    }
    else if(indexPath.section == 6){
        for(int i = 1; i < 6; i++)
            [(UIExpandableTableView *)tableView collapseSection:i animated:YES];
        expandingSection = 0;
        selectedGroup = [centerNameArray objectAtIndex:indexPath.row+7];
        key = @"Department";
    }
    else {
        if(indexPath.row == 0)
        {
            selectedGroup = [centerNameArray objectAtIndex:indexPath.section+1];
            key = @"Center";
        }
        else{
            expandingRow = indexPath.row;
            selectedGroup = [[departmentNameArray objectAtIndex:(indexPath.section-1)] objectAtIndex:indexPath.row-1];
            key = @"Department";
        }
    }
    NSLog(@"index section is %d, index row is %d，selectedGroup is %@",indexPath.section,indexPath.row,selectedGroup);
    UINavigationController * centerNav = (UINavigationController *)self.viewDeckController.centerController;
    [((EBBookContactBookViewController *)[centerNav topViewController]) refreshActionForKey:key withValue:selectedGroup];
}
@end
