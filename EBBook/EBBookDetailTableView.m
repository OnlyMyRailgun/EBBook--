//
//  EBBookDetailTableView.m
//  EBBook
//
//  Created by 延晋 张 on 12-6-19.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EBBookDetailTableView.h"
#import "EBBookContact.h"
#import "EBBookContactDetailCell.h"

@interface EBBookDetailTableView ()
{
	NSMutableArray  *theTitles;
    NSMutableArray	*theDetails;
    NSMutableArray	*theKeys;
    //NSMutableArray  *theFlagArray;
    NSInteger abilityCount;
    NSInteger infoSection;
    NSString *newReport;
}

- (void) initDetials:(EBBookContact* ) eber;
@end

@implementation EBBookDetailTableView
@synthesize viewDelegate;
@synthesize dialFlag;

- (id)initWithFrame:(CGRect)frame ebContact:(EBBookContact*) eber
{
    self = [super initWithFrame:frame style:UITableViewStyleGrouped];
    if (self) {
        self.delegate = self;
		self.dataSource = self;
        self.scrollEnabled = false;
        dialFlag = NO;
        [self initDetials:eber];
    }
    return self;
}

- (void)dealloc
{
    [theDetails release];
	[theTitles release];
    [theKeys release];
    [newReport release];
    //[theFlagArray release];
	
	[super dealloc];
}

- (void) initDetials:(EBBookContact* ) eber
{
    theTitles = [[NSMutableArray alloc] initWithObjects:@"移动电话",@"电子邮箱",@"部门",@"性别", @"地点",@"级别",nil];
    theKeys = [[NSMutableArray alloc] initWithObjects:@"Mobile",@"mail",@"Department",@"Gender",@"Office",@"Band", nil];
    theDetails = [[NSMutableArray alloc] initWithObjects:eber.mobile,eber.mail,eber.department,eber.gender,eber.office,eber.band,nil ];
    abilityCount = 2;
    infoSection = 4;
    newReport = [[NSString alloc] initWithFormat:@"%@", eber.reportNew] ;
    if(eber.vpmn.length == 6)
    {
        [theTitles insertObject:@"VPMN" atIndex:abilityCount];
        [theKeys insertObject:@"VPMN" atIndex:abilityCount];
        [theDetails insertObject:eber.vpmn atIndex:abilityCount];
        abilityCount++;
    }
    if (eber.tel.length > 1) {
        [theTitles insertObject:@"办公电话" atIndex:abilityCount];
        [theKeys insertObject:@"Tel" atIndex:abilityCount];
        if (eber.tel.length == 4) {
            NSString *officeString = [NSString stringWithFormat:@"010-82325588-%@",eber.tel];
            [theDetails insertObject:officeString atIndex:abilityCount];
        }
        else {
            [theDetails insertObject:eber.tel atIndex:abilityCount];
        }
        abilityCount++;
    }
    if (eber.center.length > 0) {
        [theTitles insertObject:@"中心" atIndex:abilityCount];
        [theKeys insertObject:@"Center" atIndex:abilityCount];
        [theDetails insertObject:eber.center atIndex:abilityCount];
        infoSection++;

    }
    if (eber.birthdate.length > 1) {
        [theTitles insertObject:@"生日" atIndex:abilityCount+3 ];
        [theKeys insertObject:@"Birth" atIndex:abilityCount+3];
        [theDetails insertObject:eber.birthdate atIndex:abilityCount+3];
        infoSection++;
    }
    if (eber.seat.length == 4) {
        [theTitles addObject:@"工位" ];
        [theKeys addObject:@"Seat"];
        [theDetails addObject:eber.seat];
        infoSection++;
    }
    
    if (eber.report.length > 0) {
        [theTitles addObject:@"汇报人" ];
        [theKeys addObject:@"Report"];
        [theDetails addObject:eber.report];
               infoSection++;
    }

}

- (void) selectRows:(NSInteger) row
{
#if 0
    switch (row) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
            [self.viewDelegate selectEberForKey:[theDetails objectAtIndex:row+abilityCount] withValue: [theDetails objectAtIndex:row+abilityCount]];
            break;
        case 5:
            if (infoSection == 6) {
                [self jumpToReportList:[theDetails objectAtIndex:row+abilityCount]];
            }
            break;
        case 6:
            [self jumpToReportList:[theDetails objectAtIndex:row+abilityCount]];
            break;
        default:
            break;
    }
#endif
    //NSLog(@"%@",[theKeys objectAtIndex:row+abilityCount ]);
    if ([theKeys objectAtIndex:row+abilityCount ] == @"Report") {
        NSLog(@"theDetails is %@, row is %d",theDetails,row+abilityCount);
        [self jumpToReportList:[theDetails objectAtIndex:(row+abilityCount-1)]];
    }
    else  if([theKeys objectAtIndex:row+abilityCount ] == @"Seat"){
    }
    else{
        [self.viewDelegate selectEberForKey:[theKeys objectAtIndex:row+abilityCount] withValue: [theDetails objectAtIndex:row+abilityCount]];
    }
}

- (void) jumpToReportList:(NSString *) reportString
{
    /*
    NSString *value = reportString;
    [self.viewDelegate jumpToLeader:value withUidString:newReport];
     */
}

#pragma mark -
#pragma mark Selected Method
- (void) call:(NSInteger) index{
    if ([[UIDevice currentDevice].model isEqualToString:@"iPod touch"] ||
        [[UIDevice currentDevice].model isEqualToString:@"iPad"]  ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"对不起，您的设备不支持电话功能"  message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView setTag:5]; 
        [alertView show];
        [alertView release];
        
        return;
    }
    
    
    NSString *mobString;
    if ([[theDetails objectAtIndex:index] length] == 17) {
        NSString *detailNumber = [[theDetails objectAtIndex:index] substringFromIndex:13];
        if (dialFlag) {
            mobString = [[NSString alloc] initWithFormat:@"telprompt:01082325588,%@",detailNumber];
        }
        else {
            mobString = [[NSString alloc] initWithFormat:@"tel:01082325588,%@",detailNumber];
        }
    }
    else {
        if (dialFlag) {
            mobString = [[NSString alloc] initWithFormat:@"telprompt:%@",[theDetails objectAtIndex:index]];
        }
        else {
            mobString = [[NSString alloc] initWithFormat:@"tel:%@",[theDetails objectAtIndex:index]];
        }
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mobString]];
    [mobString release];
}

- (void) sendEmail:(NSInteger )index {
    [self.viewDelegate viewSendMail:[theDetails objectAtIndex:index]];
}

- (void) cellSendMessage{
    [self.viewDelegate viewSendMessage];
}

#pragma mark -
#pragma mark Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return abilityCount+1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{	
	if(section < abilityCount)
    {
        return 1;
    }
    else 
    {
        return infoSection;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section < abilityCount)
    {
        return 44;
    }
    else 
    {
        if ([theTitles objectAtIndex:(abilityCount+infoSection-1)] == @"汇报人" &&
            indexPath.row == (infoSection-1)) {
            NSInteger divisor = [[theDetails objectAtIndex:(abilityCount+infoSection-1)] length]/16;
            NSInteger remainder = [[theDetails objectAtIndex:(abilityCount+infoSection-1)] length]%16;
            if (remainder == 0) {
                divisor--;
            }
            return (44 + 18*divisor);
        }
        return 40;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *_cellIdentifier = @"contactdetailcell";
    static NSString *_firstCell = @"firstCell";
    static NSString *_reportCell = @"reportCell";
    EBBookContactDetailCell *_cell = nil;
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        _cell = (EBBookContactDetailCell *)[tableView dequeueReusableCellWithIdentifier:_firstCell];
    }
    else if([theTitles objectAtIndex:(abilityCount+infoSection-1)] == @"汇报人" &&
            indexPath.row == (infoSection-1)){
        _cell = (EBBookContactDetailCell *)[tableView dequeueReusableCellWithIdentifier:_reportCell];
    }
    else {
        _cell = (EBBookContactDetailCell *)[tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    }

    BOOL flag = YES;
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        flag = NO;
    }
	if (!_cell)
	{
        if ((indexPath.section == 0) && (indexPath.row == 0)) {
            _cell = [[[EBBookContactDetailCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:_firstCell flag:flag] autorelease];
        }
        else if([theTitles objectAtIndex:(abilityCount+infoSection-1)] == @"汇报人" &&
                indexPath.row == (infoSection-1)){
            _cell = [[[EBBookContactDetailCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:_reportCell flag:flag] autorelease];
        }
        else {
            _cell = [[[EBBookContactDetailCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:_cellIdentifier flag:flag] autorelease];
        }

	}
    _cell.delegate = self;
    //self = _cell.delegate;
 
    if (indexPath.section < abilityCount) {
        _cell.title = [theTitles objectAtIndex:indexPath.section];
        _cell.detail = [theDetails objectAtIndex:indexPath.section];
    }
    else {
        _cell.title = [theTitles objectAtIndex:indexPath.section+indexPath.row];
        _cell.detail = [theDetails objectAtIndex:indexPath.section+indexPath.row];
    }
    
    if (_cell.reuseIdentifier == @"reportCell") {
        [_cell changeLines];
    }
        
    return _cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
           [self call:indexPath.section];
            break;
        case 1:
           [self sendEmail:indexPath.section];
            break;
        case 2:
        case 3:
            if (indexPath.section < abilityCount) {
                [self call:indexPath.section];
            }
            else if(indexPath.section == abilityCount)
            {
                [self selectRows:indexPath.row];
            }
            break;
        if (abilityCount == 4) {
            case 4:
                [self selectRows:indexPath.row];
            break;
        }
            
        default:
            break;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIImageView *footer = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@""] ]autorelease];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2;
}


@end
