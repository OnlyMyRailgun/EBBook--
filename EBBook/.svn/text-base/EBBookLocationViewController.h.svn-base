//
//  EBBookLocationViewController.h
//  EBBook
//
//  Created by 延晋 张 on 12-7-13.
//  Copyright (c) 2012年 Ebupt. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#

@interface EBBookLocationViewController : UIViewController<CLLocationManagerDelegate,MKAnnotation>
- (IBAction)back:(id)sender;
- (IBAction)locateMe:(id)sender;
@property (retain, nonatomic) IBOutlet MKMapView *map;
@property (retain, nonatomic) IBOutlet UINavigationBar *titleBar;
@property (retain) CLLocationManager *locManager;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@end
