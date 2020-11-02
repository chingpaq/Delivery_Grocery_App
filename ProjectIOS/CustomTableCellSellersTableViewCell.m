//
//  CustomTableCellSellersTableViewCell.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 01/03/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import "CustomTableCellSellersTableViewCell.h"

@implementation CustomTableCellSellersTableViewCell
CLLocationManager *locationManagerrr;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self InitializeMapView];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
-(void)InitializeMapView {
    self.mapView.delegate = self;
    float zoom = 15;
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[DataSingletons sharedManager]userLocation].coordinate.latitude
                                                            longitude:[[DataSingletons sharedManager]userLocation].coordinate.longitude
                                                                 zoom:zoom];
    self.mapView.camera = camera;
    
    
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *styleUrl = [mainBundle URLForResource:@"style" withExtension:@"json"];
    NSError *error;
    
    // Set the map style by passing the URL for style.json.
    GMSMapStyle *style = [GMSMapStyle styleWithContentsOfFileURL:styleUrl error:&error];
    
    if (!style) {
        NSLog(@"The style definition could not be loaded: %@", error);
    }
    self.mapView.mapStyle = style;
    locationManagerrr = [[CLLocationManager alloc]init];
    locationManagerrr.delegate = self;
    locationManagerrr.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManagerrr.distanceFilter = kCLDistanceFilterNone;
    [locationManagerrr requestAlwaysAuthorization];
    
    
}
-(void)setSingleLocation:(NSDictionary*)mapDict{
    self.cellTitle.text= @"Location";
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[mapDict objectForKey:@"latitude"]floatValue]
                                                            longitude:[[mapDict objectForKey:@"longitude"]floatValue]
                                                                 zoom:15];
    self.mapView.camera = camera;
    GMSMarker*marker2= [[GMSMarker alloc]init];
    marker2.position = CLLocationCoordinate2DMake( [[mapDict objectForKey:@"latitude"]floatValue],[[mapDict objectForKey:@"longitude"]floatValue] );
    
    UIImageView *mapscope = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"buyer-marker"]];
    marker2.snippet = [mapDict objectForKey:@"address"];
    mapscope.frame=CGRectMake(0, 0, 60, 60);
    
    if ([[mapDict objectForKey:@"status"] isEqualToString:@"Accepted"]||[[mapDict objectForKey:@"status"] isEqualToString:@"On The Way"]||[[mapDict objectForKey:@"status"] isEqualToString:@"Completed"]||[[mapDict objectForKey:@"status"] isEqualToString:@"Closed"]){
        marker2.map=self.mapView;
        [self.markersArray addObject:marker2];
        [self.mapView setSelectedMarker:marker2];
    }
    
    
}
-(void)getSellers{
    for (NSMutableDictionary *dict in self.activeSellersArray){
        GMSMarker*marker2= [[GMSMarker alloc]init];
        marker2.position = CLLocationCoordinate2DMake([[dict objectForKey:@"latitude"] doubleValue] , [[dict objectForKey:@"longitude"] doubleValue]);
        marker2.snippet = [NSString stringWithFormat:@"%@-stars",[dict objectForKey:@"ratings"]];
        marker2.snippet = [NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
        
        UIImageView *mapscope = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"buyer-marker"]];
        mapscope.frame=CGRectMake(0, 0, 40, 40);
        marker2.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
        marker2.map=self.mapView;
        
        
    }
    
    self.marker2.map= nil;
    self.marker2= [[GMSMarker alloc]init];
    _marker2.position = CLLocationCoordinate2DMake( [[DataSingletons sharedManager]userLocation].coordinate.latitude,[[DataSingletons sharedManager]userLocation].coordinate.longitude );
    UIImageView *mapscope = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"buyer-marker"]];
    _marker2.snippet = [[NSUserDefaults standardUserDefaults] objectForKey:USER_FULL_NAME];
    mapscope.frame=CGRectMake(0, 0, 60, 60);
    _marker2.icon=mapscope.image;
    
    
    NSArray *frames = @[[UIImage imageNamed:@"step1"],
                        [UIImage imageNamed:@"step2"],
                        [UIImage imageNamed:@"step3"],
                        [UIImage imageNamed:@"step4"],
                        [UIImage imageNamed:@"step5"],
                        [UIImage imageNamed:@"step6"],
                        [UIImage imageNamed:@"step7"],
                        [UIImage imageNamed:@"step8"]];
    
    _marker2.icon = [UIImage animatedImageWithImages:frames duration:0.8];
    _marker2.groundAnchor = CGPointMake(0.5f, 0.97f); // Taking into account walker's shadow
    
    _marker2.map=self.mapView;
    [self.markersArray addObject:_marker2];
    
    self.mapView.userInteractionEnabled=NO;
}

@end

