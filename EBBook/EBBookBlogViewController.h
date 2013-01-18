//
//  EBBookBlogViewController.h
//  EBBook
//
//  Created by Heartunderblade on 1/15/13.
//  Copyright (c) 2013 Ebupt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EBBookBlogViewController : UIViewController<UIWebViewDelegate>

@property (retain, nonatomic) IBOutlet UIWebView *blogWebView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end
