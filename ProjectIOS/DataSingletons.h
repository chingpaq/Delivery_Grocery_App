//
//  DataSingletons.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 19/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "API.h"

@import Firebase;

@interface DataSingletons : NSObject<CLLocationManagerDelegate>
+ (id)sharedManager;
- (id)init;

@property (strong, nonatomic) CLLocation *userLocation;
@property (strong, nonatomic) CLLocation *previousLocation;
@property (strong, nonatomic)NSString *active;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSTimer *locationTimer;
@property (nonatomic) FIRDatabaseHandle zipAddedhandle;
@property (nonatomic) FIRDatabaseHandle zipCangedhandle;
@property (nonatomic) FIRDatabaseHandle zipDeletedhandle;
@property (nonatomic) FIRDatabaseHandle zipUserAddedhandle;
@property (nonatomic) FIRDatabaseHandle zipUserCangedhandle;
@property (nonatomic) FIRDatabaseHandle zipUserDeletedhandle;
@property (nonatomic) BOOL receivedOffer;
@property (strong, nonatomic)FIRDatabaseReference *sellerOrdersReference;
@property (strong, nonatomic)FIRDatabaseReference *sellerRoutesReference;
@property (strong, nonatomic)NSMutableArray *paymentHistory;
@property (strong, nonatomic)NSMutableArray *routeArray;
@end
