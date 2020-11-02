//
//  SellerOrdersMapViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 25/03/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "UIColor+DBColors.h"
#import "NSObject+FIRDatabaseSingleton.h"
#import "Orders.h"
#import "WaitingViewController.h"
#import "SCLAlertView.h"
#import "AZNotification.h"
#import <CZPicker/CZPicker.h>
@import Firebase;
#import "WRGMSMarker.h"
@protocol SellerOrdersMapViewControllerDelegate <NSObject>
@optional
-(void)proposalsSent:(id)sender;
-(void)backPressedFrom;
@end

@interface SellerOrdersMapViewController : UIViewController<GMSMapViewDelegate, CLLocationManagerDelegate,CZPickerViewDelegate,CZPickerViewDataSource, WaitingViewControllerDelegate,UITextViewDelegate>
@property (strong, nonatomic) id<SellerOrdersMapViewControllerDelegate>delegate;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textBoxConstraint;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet UITextView *addressTextView;
@property (strong, nonatomic) IBOutlet UIButton *submitOrdersButton;
@property (strong, nonatomic) WaitingViewController *waitingViewController;
@property (strong, nonatomic) IBOutlet UITextView *commentTextView;
@property (strong, nonatomic) IBOutlet UIButton *commentButton;
@property (strong, nonatomic) IBOutlet UIButton *paymentOptionButton;
@property (strong, nonatomic) IBOutlet UITextView *paymentModeTextBox;
@property (strong, nonatomic)CZPickerView *pickerView;
@property (strong, nonatomic)PMDCard *card;
@property (strong, nonatomic)NSMutableDictionary *orderDict;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentHeight;
@property (strong, nonatomic) NSMutableArray *routeArray;
-(void)initializeMapView;
@end
