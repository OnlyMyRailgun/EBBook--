//
//  EBBookBlogViewController.m
//  EBBook
//
//  Created by Heartunderblade on 1/15/13.
//  Copyright (c) 2013 Ebupt. All rights reserved.
//

#import "EBBookBlogViewController.h"

@interface EBBookBlogViewController ()

@end

@implementation EBBookBlogViewController
@synthesize blogWebView;
@synthesize activityIndicatorView;

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
    blogWebView.delegate = self;
}

- (void)viewDidUnload
{
    [self setBlogWebView:nil];
    [self setActivityIndicatorView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [blogWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://hrad.ebupt.net/blog/"]]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [blogWebView stopLoading];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [blogWebView release];
    [activityIndicatorView release];
    [super dealloc];
}

- (IBAction)previousPage:(id)sender {
    [blogWebView goBack];
}

- (IBAction)nextPage:(id)sender {
    [blogWebView goForward];
}

- (IBAction)refreshPage:(id)sender {
    [blogWebView reload];
}

- (IBAction)homePage:(id)sender {
    [blogWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://hrad.ebupt.net/blog/"]]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [activityIndicatorView startAnimating] ;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
//    UIAlertView *alterview = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//    [alterview show];
//    [alterview release];
}
@end
