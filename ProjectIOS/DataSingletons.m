//
//  DataSingletons.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 19/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "DataSingletons.h"

@implementation DataSingletons
static DataSingletons *manager = nil;

+ (DataSingletons *)sharedManager;{
    if (manager == nil) {
        manager = [[self alloc] init];
    }
    
    return manager;
}


- (id)init{
    self = [super init];
    
    if (self) {
        self.paymentHistory = [[NSMutableArray alloc]init];
        [self initLocationManager];
        
    }
    return self;
}
#pragma mark - maps
- (void)initLocationManager{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    [self.locationManager requestAlwaysAuthorization];
    [self startUpdating];
    [self startTimer];
}
-(void)startUpdating{
    [self.locationManager startUpdatingLocation];
}

-(void) stopUpdating{
    [self.locationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:
(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    [self setUserLocation:newLocation];
    
    if(self.previousLocation==nil){
        [self setPreviousLocation:self.userLocation];
    }
    
}

-(void)startTimer{
    [self.locationTimer invalidate];
    
    self.locationTimer = [[NSTimer alloc] initWithFireDate:[[NSDate date] dateByAddingTimeInterval:10] interval:10
                                                    target:self
                                                  selector:@selector(locationTimerUpdates:)
                                                  userInfo:nil
                                                   repeats:YES];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:self.locationTimer forMode:NSDefaultRunLoopMode];
}

-(void)locationTimerUpdates:(id)sender{
    if ([[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] isEqualToString:@"Main_seller"]){
        
        [API updateSeller:nil success:^{
        } failure:^(NSString *message) {}];
        
        CLLocation * location = [[DataSingletons sharedManager] userLocation];
        
        if ([self distanceBetweenLocations:self.previousLocation andLocation:self.userLocation]>[[[NSUserDefaults standardUserDefaults] objectForKey:MAP_ROUTING_DIST] integerValue]){
            [self setPreviousLocation:self.userLocation];
            
            for (NSDictionary *salesDict in [[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status CONTAINS[cd]%@",@"On The Way"]]){
                
                
                [API getRouteAndTimeToArriveWithCurrentLatitude:location.coordinate.latitude andCurrentLongitude:location.coordinate.longitude andUserLatitude:[[salesDict objectForKey:@"latitude"]floatValue] andUserLongitude:[[salesDict objectForKey:@"longitude"]floatValue] withTransportMode:[[NSUserDefaults standardUserDefaults] objectForKey:MAP_ROUTING_TYPE] success:^(NSDictionary *dictleg){
                    
                    
                    
                    [API snapPathToRoadv2:[dictleg objectForKey:@"steps"]
                                  success:^(id dict){
                                      
                                      [[DataSingletons sharedManager] setRouteArray:[[NSMutableArray alloc]initWithArray:[dict objectForKey:@"snappedPoints"]]];
                                      
                                      [API updateSellerRoute:@{@"sellerRoute":[dictleg objectForKey:@"steps"],
                                                               @"sellerRouteV2": [dict objectForKey:@"snappedPoints"]
                                                               } ofSeller:[salesDict objectForKey:@"sellerId"] eta: [[dictleg objectForKey:@"duration"]objectForKey:@"text"]
                                                     success:^(NSDictionary *dict){}
                                                     failure:^(NSString *message) {}];
                                      
                                  } failure:^(NSString *message) {
                                      NSLog(@"Fail1234");
                                  }];
                    
                    
                    
                } failure:^(NSString *message) {
                    NSLog(@"Fail");
                }];
                
            }
        }else{
            for (NSDictionary *salesDict in [[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status CONTAINS[cd]%@",@"On The Way"]]){
                [API updateSellerRoute:nil ofSeller:[salesDict objectForKey:@"sellerId"] eta: nil
                               success:^(NSDictionary *dict){}
                               failure:^(NSString *message) {}];
                
            }
        }
        
    }else{
        [API createOrUpdateBuyer:nil success:^{} failure:^(NSString *message) {}];
    }
    
    
}

-(int)distanceBetweenLocations:(CLLocation*)oldLocation andLocation:(CLLocation*)newLocation{
    
    int  totalDistance =0;
    CLLocationDistance meters = [newLocation distanceFromLocation:oldLocation];
    
    
    totalDistance = totalDistance + (meters / 1000);
    return meters;
    return totalDistance;
}
@end



