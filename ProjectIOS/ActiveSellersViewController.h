//
//  ActiveSellersViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 08/12/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//


#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "API.h"
#import "Orders.h"
#import "WRGMSMarker.h"
#import "SalesMapView.h"
#import "AZNotification.h"


@interface ActiveSellersViewController : UIViewController<GMSMapViewDelegate,CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) NSMutableArray *activeSellersArray;
@property (strong, nonatomic) NSMutableArray *markersArray;


@end
