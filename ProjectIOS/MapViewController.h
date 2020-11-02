//
//  MapViewController.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/3/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "API.h"
#import "Orders.h"
#import "WRGMSMarker.h"
#import "SalesMapView.h"
#import "AZNotification.h"
#import <CZPicker/CZPicker.h>
#import "PMDCard.h"

@import AFNetworking;
@import SVProgressHUD;

@interface MapViewController : UIViewController <GMSMapViewDelegate,CLLocationManagerDelegate,CZPickerViewDelegate,CZPickerViewDataSource,PayMayaCheckoutDelegate>
@property (strong, nonatomic) IBOutlet UITextView *infoTextView;
@property (strong, nonatomic) IBOutlet UIImageView *ratings;
@property (strong, nonatomic) NSMutableArray *activeSellersArray;
@property (strong, nonatomic) NSMutableArray *markersArray;
@property (strong, nonatomic)CZPickerView *pickerView;
@property (strong, nonatomic) NSDictionary *selectedSale;
@property (strong, nonatomic) WRGMSMarker* buyerMarker;
@property (strong, nonatomic) WRGMSMarker* sellerMarker;
@property (strong, nonatomic) GMSPolyline *polyline;
typedef NS_ENUM(NSUInteger, MapMode) {
    MapModeActiveSellers    = 0,
    MapModeOngoingSales     = 1,
};

//-(void)updateSellersLocation;

@end
