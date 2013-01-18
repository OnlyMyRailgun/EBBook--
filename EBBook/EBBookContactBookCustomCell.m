//
//  EBBookContactBookCustomCell.m
//  EBBook
//
//  Created by Kissshot HeartUnderBlade on 12-7-4.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import "EBBookContactBookCustomCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation EBBookContactBookCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIImageView *imageView = (UIImageView *)[self viewWithTag:601];
    //imageView.layer.cornerRadius = 5.0f;
    imageView.layer.borderWidth = 0.8f;//设置边框的宽度，当然可以不要
    imageView.layer.borderColor = [[UIColor grayColor] CGColor];//设置边框的颜色
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    //[CONTACTBOOKIMAGEVIEW setContentMode:UIViewContentModeCenter];
    imageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
