//
//  ActiveSellersViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 08/12/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "ActiveSellersViewController.h"

@interface ActiveSellersViewController ()

@end

@implementation ActiveSellersViewController


CLLocationManager *locationManagerr;
//GMSMarker*marker;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self InitializeMapView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)InitializeMapView {
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = true;
    float zoom = 15;
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[DataSingletons sharedManager]userLocation].coordinate.latitude
                                                            longitude:[[DataSingletons sharedManager]userLocation].coordinate.longitude
                                                                 zoom:zoom];
    self.mapView.camera = camera;
    self.mapView.settings.myLocationButton=YES;
    self.mapView.settings.compassButton=YES;
    locationManagerr = [[CLLocationManager alloc]init];
    locationManagerr.delegate = self;
    locationManagerr.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManagerr.distanceFilter = kCLDistanceFilterNone;
    [locationManagerr requestAlwaysAuthorization];
    
    
    
    
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    for (NSDictionary *dict in self.activeSellersArray){
        GMSMarker*marker2= [[GMSMarker alloc]init];
        marker2.position = CLLocationCoordinate2DMake([[dict objectForKey:@"latitude"] doubleValue] , [[dict objectForKey:@"longitude"] doubleValue]);
        marker2.snippet = [dict objectForKey:@"sellerId"];
        UIImageView *mapscope = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ant-seller-marker"]];
        mapscope.frame=CGRectMake(0, 0, 60, 60);
        marker2.icon=mapscope.image;
        marker2.map=self.mapView;
        [self.markersArray addObject:marker2];
        
        if ([self.markersArray count]==1){
            [self.mapView setSelectedMarker:marker2];
        }
    }
    
    GMSMarker*marker2= [[GMSMarker alloc]init];
    marker2.position = CLLocationCoordinate2DMake( [[DataSingletons sharedManager]userLocation].coordinate.latitude,[[DataSingletons sharedManager]userLocation].coordinate.longitude );
    UIImageView *mapscope = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"buyer-marker"]];
    mapscope.frame=CGRectMake(0, 0, 60, 60);
    marker2.icon=mapscope.image;
    marker2.map=self.mapView;
    [self.markersArray addObject:marker2];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
