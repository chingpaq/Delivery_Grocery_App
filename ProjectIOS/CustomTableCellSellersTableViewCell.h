//
//  CustomTableCellSellersTableViewCell.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 01/03/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "API.h"
#import "Orders.h"
#import "WRGMSMarker.h"
#import "SalesMapView.h"
#import "AZNotification.h"
#import "Constants.h"

@interface CustomTableCellSellersTableViewCell : UITableViewCell<GMSMapViewDelegate,CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *cellTitle;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) NSMutableArray *activeSellersArray;
@property (strong, nonatomic) NSMutableArray *markersArray;
@property (strong, nonatomic) GMSMarker *marker2;
-(void)getSellers;
-(void)setSingleLocation:(NSDictionary*)mapDict;

@end
