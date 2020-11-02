//
//  OrdersMapViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 16/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

//#import <UIKit/UIKit.h>
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

@protocol OrdersMapViewControllerDelegate <NSObject>
@optional
-(void)proposalsReceived:(id)sender;
-(void)backPressedFrom;
@end


@interface OrdersMapViewController : UIViewController <GMSMapViewDelegate, CLLocationManagerDelegate,CZPickerViewDelegate,CZPickerViewDataSource, WaitingViewControllerDelegate,UITextViewDelegate>
@property (strong, nonatomic) id<OrdersMapViewControllerDelegate>delegate;
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
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentHeight;

@end
