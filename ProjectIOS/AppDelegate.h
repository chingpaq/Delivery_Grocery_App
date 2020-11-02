//
//  AppDelegate.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 03/07/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;
@import GoogleSignIn;
@import FBSDKCoreKit;
@import Fabric;
@import TwitterKit;
@import SVProgressHUD;
@import GoogleMaps;


#import "Orders.h"
#import "NSObject+reSideMenuSingleton.h"
#import "NSObject+FIRDatabaseSingleton.h"
#import "DataSingletons.h"
#import "UIColor+DBColors.h"
#import <PayMayaSDK/PayMayaSDK.h>
#import "PMDAPIManager.h"
#import "PMDCustomer.h"
#import "NSObject+KVCParsing.h"
#import "Constants.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
@import UserNotifications;

@interface AppDelegate : UIResponder <UIApplicationDelegate,GIDSignInDelegate,FIRMessagingDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

