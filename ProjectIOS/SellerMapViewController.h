//
//  SellerMapViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 02/04/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "API.h"
#import "Orders.h"
#import "WRGMSMarker.h"
#import "SalesMapView.h"
#import "AZNotification.h"
#import <CZPicker/CZPicker.h>
#import "UIColor+DBColors.h"
@import SVProgressHUD;

@interface SellerMapViewController : UIViewController
<GMSMapViewDelegate,CLLocationManagerDelegate,CZPickerViewDelegate,CZPickerViewDataSource, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextView *infoTextView;
@property (strong, nonatomic) IBOutlet UIImageView *ratings;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) NSMutableArray *activeSellersArray;
@property (strong, nonatomic) NSMutableArray *activeOrdersArray;
@property (strong, nonatomic) NSMutableArray *markersArray;
@property (strong, nonatomic)CZPickerView *pickerView;
@property (strong, nonatomic) NSString *selectedSale;
@property (strong, nonatomic) IBOutlet UITextField *codeTextBox;
@property (strong, nonatomic) WRGMSMarker* buyerMarker;
@property (strong, nonatomic) WRGMSMarker* sellerMarker;
@property (strong, nonatomic) GMSPolyline *polyline;
@property (strong, nonatomic) IBOutlet UIButton *centerButton;


typedef NS_ENUM(NSUInteger, MapMode) {
    MapModeActiveSellers    = 0,
    MapModeOngoingSales     = 1,
};

//-(void)updateSellersLocation;
@end
