//
//  SuperLink.h
//  TestProject
//
//  Created by 张 延晋 on 12-8-3.
//  Copyright (c) 2012年 张 延晋. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SuperLink;
@protocol SuperLinkDelegate <NSObject>
@required
- (void)superLink:(SuperLink *)superLink touchesWtihTag:(NSInteger)tag;
@end

@interface SuperLink : UILabel {
    id <SuperLinkDelegate> delegate;
}
@property (nonatomic, assign) id <SuperLinkDelegate> delegate;

- (id)initWithFrame:(CGRect)frame freeJump:(BOOL)freeJump;
@end
