//
//  EBBookLocationViewController.m
//  EBBook
//
//  Created by 延晋 张 on 12-7-13.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import "EBBookLocationViewController.h"
#import "EBBookLocalContacts.h"
#import "EBBookAccount.h"

@interface EBBookLocationViewController ()
{
    CLLocationManager *locManager;
    CLLocationDistance distance;
}
@end

@implementation EBBookLocationViewController
@synthesize coordinate;
@synthesize map;
@synthesize titleBar;
@synthesize locManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    titleBar.tintColor = [UIColor blackColor];
    
	self.locManager = [[[CLLocationManager alloc] init] autorelease];
	if (![CLLocationManager locationServicesEnabled])
	{
		NSLog(@"User has opted out of location services");
		return;
	}
	else 
	{
		// User generally allows location calls
		self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
	}
    
   
    //
}

- (void) viewWillAppear:(BOOL)animated
{
    distance = 510.0f;
    [map addAnnotation:self];
    
    [self.locManager startUpdatingLocation];
    
    [NSThread sleepForTimeInterval:1];
    [self findMe];
    //[NSThread detachNewThreadSelector:@selector(findMe) toTarget:self withObject:nil];
}

- (void)viewDidUnload
{
    [self setMap:nil];
    [self setMap:nil];
    [self setTitleBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)back:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)locateMe:(id)sender {
    //distance = 310.0f;
    [self findMe];
}

- (void) findMe
{
    [self.locManager startUpdatingLocation];
	[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(tick:) userInfo:nil repeats:YES];
}

- (void)dealloc {
    [map release];
    [map release];
    [titleBar release];
    [super dealloc];
}

- (void) tick: (NSTimer *) timer
{
    if (fabsf(distance) < 10.000001 || -distance > 0.000001) {
        NSLog(@"time invalidate is %f",distance);
        [timer invalidate];
        return;
    }
    distance = distance - 100.0f;

    NSLog(@"distance is %f",distance);
	if (map.userLocation)
        [map setRegion:MKCoordinateRegionMakeWithDistance(map.userLocation.location.coordinate, distance, distance) animated:YES];
		//[map setRegion:MKCoordinateRegionMake(map.userLocation.location.coordinate, MKCoordinateSpanMake(0.005f, 0.005f)) animated:NO];
	map.userLocation.title = @"Location Coordinates";
	map.userLocation.subtitle = [NSString stringWithFormat:@"%f, %f", map.userLocation.location.coordinate.latitude, map.userLocation.location.coordinate.longitude];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for(MKPinAnnotationView *mkaview in views)
    {
        
        NSString *userName = [[EBBookAccount loadDefaultAccount] objectForKey:@"userName"];
        UIImage *headImage = [EBBookLocalContacts getPhotoForContact:userName];
        //UIImage *headImage2 = [self scaleFromImage:headImage toSize:CGSizeMake(40,40)];
        UIImageView *headView = [[UIImageView alloc] initWithImage:[self scaleFromImage:headImage toSize:CGSizeMake(30, 30)]];
        [mkaview addSubview:headView];
        [headView release];
       // if (mkaview.annotation) {
        //    <#statements#>
        //}
    }
}

- (UIImage *) scaleFromImage: (UIImage *) image toSize: (CGSize) size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
