//
//  EBBookContactDetailCell.h
//  EBBook
//
//  Created by 延晋 张 on 12-6-20.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@protocol EBBookContactDetailCellDelegate

- (void)cellSendMessage;

@end

@interface EBBookContactDetailCell : UITableViewCell
{
    id <EBBookContactDetailCellDelegate> delegate;
}

@property (nonatomic,assign) id <EBBookContactDetailCellDelegate> delegate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *detail;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier flag:(BOOL) hidden;
- (void) changeLines;
@end
