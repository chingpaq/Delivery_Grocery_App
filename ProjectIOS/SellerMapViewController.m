//
//  SellerMapViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 02/04/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import "SellerMapViewController.h"

@interface SellerMapViewController ()

@end

@implementation SellerMapViewController
BOOL SMuserAddressExists;
CLLocationManager *SMlocationManager;
GMSMarker*SMmarker;
BOOL sellerMapMoved=NO;
NSArray *SMpppickerData;
NSArray *sellerRouteArray;

#pragma mark - Override Methods

- (void)dealloc {
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(initializeMapView)
                                                 name:@"reloadMapViewController"
                                               object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.codeTextBox.hidden=YES;
    self.infoTextView.text = @"There are no ongoing transactions";
    self.infoTextView.text = @"";
    self.ratings.hidden=YES;
    [self initializeMapView];
    
    for (NSDictionary *salesDict in [[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status CONTAINS[cd]%@",@"On The Way"]]){
        
        Seller *seller = [API getSeller:[salesDict objectForKey:@"sellerId"]];
        
        self.buyerMarker.map = nil; // remove any existing buyer marker
        
        self.buyerMarker= [[WRGMSMarker alloc]init];
        self.buyerMarker.position = CLLocationCoordinate2DMake([[salesDict objectForKey:@"latitude"]floatValue] , [[salesDict objectForKey:@"longitude"]floatValue]);
        self.buyerMarker.snippet=@"Seller";
        self.buyerMarker.sellerId=[salesDict objectForKey:@"ratings"];
        self.buyerMarker.title=[salesDict objectForKey:@"address"];
        self.buyerMarker.snippet= [salesDict objectForKey:@"sellerId"];
        self.buyerMarker.sellerId= [salesDict objectForKey:@"sellerId"];
        self.buyerMarker.title= [salesDict objectForKey:@"orderId"];
        self.buyerMarker.orderId=[salesDict objectForKey:@"orderId"];
        
        
        
        self.buyerMarker.sellerInfo =@{@"firstName":seller.firstName,
                                       @"lastName":seller.lastName,
                                       @"mobileNumber": seller.mobileNumber,
                                       @"ratings": seller.ratings
                                       };
        
        
        
        
        //UIImageView *mapscope = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"profile-pic"]];
        UIImageView *mapscope = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ant-approved"]];
        mapscope.frame=CGRectMake(0, 0, 60, 60);
        self.buyerMarker.icon=mapscope.image;
        
        self.buyerMarker.map=self.mapView;
        CLLocation * location = [[DataSingletons sharedManager] userLocation];
        
        self.sellerMarker.map = nil;
        self.sellerMarker= [[WRGMSMarker alloc]init];
        
        self.sellerMarker.position = CLLocationCoordinate2DMake(location.coordinate.latitude , location.coordinate.longitude);
        
        self.sellerMarker.snippet= [salesDict objectForKey:@"sellerId"];
        self.sellerMarker.sellerId= [salesDict objectForKey:@"sellerId"];
        self.sellerMarker.title= [salesDict objectForKey:@"orderId"];
        self.sellerMarker.orderId=[salesDict objectForKey:@"orderId"];
        
        self.sellerMarker.sellerInfo =@{@"firstName":seller.firstName,
                                        @"lastName":seller.lastName,
                                        @"mobileNumber": seller.mobileNumber,
                                        @"ratings": seller.ratings
                                        };
        self.sellerMarker.map=self.mapView;
        
        [self.mapView setSelectedMarker:self.sellerMarker];
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.sellerMarker.position.latitude
                                                                longitude:self.sellerMarker.position.longitude
                                                                     zoom:15+2];
        self.mapView.camera = camera;
        
        [API getBuyerDetails:[salesDict objectForKey:@"buyerId"]
                   eventType:FIRDataEventTypeValue
                     success:^(NSDictionary *dict){
                         NSString *name=[dict objectForKey:@"name"];
                         self.infoTextView.text = [NSString stringWithFormat:@"Buyer: %@\nMobile: %@\n",[name substringWithRange:NSMakeRange(0, name.length<20 ? name.length:19)],[dict objectForKey:@"mobileNumber"]];
                         NSLog(@"%@",dict);
                     } failure:^(NSString *message) {
                         NSLog(@"Fail");
                     }];
        
        Buyer *buyerDetails=[API getBuyer:[salesDict objectForKey:@"buyerId"]];
        if (buyerDetails!=nil){
            NSString *name=buyerDetails.name;
            self.infoTextView.text = [NSString stringWithFormat:@"Buyer: %@\nMobile: %@\n",[name substringWithRange:NSMakeRange(0, name.length<20 ? name.length:19)],buyerDetails.mobileNumber];
            
        }
        
        
        
        
        if ([[DataSingletons sharedManager] routeArray]==nil || [[DataSingletons sharedManager] routeArray].count==0){
            
            
            [API getRouteAndTimeToArriveWithCurrentLatitude:location.coordinate.latitude andCurrentLongitude:location.coordinate.longitude andUserLatitude:[[salesDict objectForKey:@"latitude"]floatValue] andUserLongitude:[[salesDict objectForKey:@"longitude"]floatValue] withTransportMode:[[NSUserDefaults standardUserDefaults] objectForKey:MAP_ROUTING_TYPE] success:^(NSDictionary *dictleg){
                
                CLLocation * location = [[DataSingletons sharedManager] userLocation];
                
                self.sellerMarker.map = nil;
                
                self.sellerMarker= [[WRGMSMarker alloc]init];
                self.sellerMarker.position = CLLocationCoordinate2DMake(location.coordinate.latitude , location.coordinate.longitude);
                
                self.sellerMarker.snippet= [salesDict objectForKey:@"sellerId"];
                self.sellerMarker.sellerId= [salesDict objectForKey:@"sellerId"];
                self.sellerMarker.title= [salesDict objectForKey:@"orderId"];
                self.sellerMarker.orderId=[salesDict objectForKey:@"orderId"];
                
                Seller *seller = [API getSeller:[salesDict objectForKey:@"sellerId"]];
                
                self.sellerMarker.sellerInfo =@{@"firstName":seller.firstName,
                                                @"lastName":seller.lastName,
                                                @"mobileNumber": seller.mobileNumber,
                                                @"ratings": seller.ratings
                                                };
                //self.sellerMarker.map=self.mapView;
                /*
                 UIImageView *mapscope1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ant-seller-marker"]];
                 self.sellerMarker.frame=CGRectMake(0, 0, 60, 60);
                 self.sellerMarker.icon=mapscope1.image;
                 */
                
                [self.markersArray addObject:self.sellerMarker];
                
                [self.mapView setSelectedMarker:self.sellerMarker];
                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.sellerMarker.position.latitude
                                                                        longitude:self.sellerMarker.position.longitude
                                                                             zoom:15+2];
                self.mapView.camera = camera;
                
                
                
                
                
                
                //stop monitoring this
                [[[[FIRDatabase database] reference] child:@"sellerRoute"] removeAllObservers];
                
                [API snapPathToRoadv2:[dictleg objectForKey:@"steps"]
                              success:^(id dict){
                                  GMSMutablePath *pathToDraw = [[GMSMutablePath alloc]init];
                                  
                                  for (NSDictionary *dictx in [dict objectForKey:@"snappedPoints"]){
                                      NSDictionary *location = [dictx objectForKey:@"location"];
                                      double latitude = [[location objectForKey:@"latitude"] doubleValue];
                                      double longitude = [[location objectForKey:@"longitude"] doubleValue];
                                      [pathToDraw addCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
                                  }
                                  
                                  self.polyline.map=nil;
                                  //Draw polyline with path
                                  self.polyline = [GMSPolyline polylineWithPath:pathToDraw];
                                  self.polyline.map = self.mapView;
                                  self.polyline.strokeColor = [UIColor darkGrayColor];
                                  self.polyline.strokeWidth = 6;
                                  
                                  
                                  [[DataSingletons sharedManager] setRouteArray:[[NSMutableArray alloc]initWithArray:[dict objectForKey:@"snappedPoints"]]];
                                  
                                  [API updateSellerRoute:@{@"sellerRoute":[dictleg objectForKey:@"steps"],
                                                           @"sellerRouteV2": [dict objectForKey:@"snappedPoints"]
                                                           } ofSeller:[salesDict objectForKey:@"sellerId"] eta: [[dictleg objectForKey:@"duration"]objectForKey:@"text"]
                                                 success:^(NSDictionary *dict){}
                                                 failure:^(NSString *message) {}];
                                  
                              } failure:^(NSString *message) {
                                  NSLog(@"Failxxxx");
                              }];
                
                /*
                 [API updateSellerRoute:[dictleg objectForKey:@"steps"] ofSeller:[salesDict objectForKey:@"sellerId"] eta: [[dictleg objectForKey:@"duration"]objectForKey:@"text"]
                 success:^(NSDictionary *dict){}
                 failure:^(NSString *message) {}];
                 */
            } failure:^(NSString *message) {
                NSLog(@"Fail");
            }];
        }else{
            
            if ([[[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status CONTAINS[cd]%@",@"On The Way"]] count]>0){
                
                
                GMSMutablePath *pathToDraw = [[GMSMutablePath alloc]init];
                
                for (NSDictionary *dictx in [[DataSingletons sharedManager] routeArray]){
                    NSDictionary *location = [dictx objectForKey:@"location"];
                    double latitude = [[location objectForKey:@"latitude"] doubleValue];
                    double longitude = [[location objectForKey:@"longitude"] doubleValue];
                    [pathToDraw addCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
                }
                
                self.polyline.map=nil;
                self.polyline = [GMSPolyline polylineWithPath:pathToDraw];
                self.polyline.map = self.mapView;
                self.polyline.strokeColor = [UIColor darkGrayColor];
                self.polyline.strokeWidth = 6;
                
            }
        }
        
        
        
    }
    
}

#pragma mark - Private Methods

-(void)initializeMapView {
    
    [self.mapView clear];
    self.mapView.delegate = self;
    //self.mapView.myLocationEnabled = true;
    float zoom = 15+2;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[DataSingletons sharedManager]userLocation].coordinate.latitude
                                                            longitude:[[DataSingletons sharedManager]userLocation].coordinate.longitude
                                                                 zoom:zoom];
    self.mapView.camera = camera;
    //self.mapView.settings.myLocationButton=YES;
    self.mapView.settings.compassButton=YES;
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *styleUrl = [mainBundle URLForResource:@"style" withExtension:@"json"];
    NSError *error;
    
    // Set the map style by passing the URL for style.json.
    GMSMapStyle *style = [GMSMapStyle styleWithContentsOfFileURL:styleUrl error:&error];
    
    if (!style) {
        NSLog(@"The style definition could not be loaded: %@", error);
    }
    self.mapView.mapStyle = style;
    SMlocationManager = [[CLLocationManager alloc]init];
    SMlocationManager.delegate = self;
    SMlocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    SMlocationManager.distanceFilter = kCLDistanceFilterNone;
    [SMlocationManager requestAlwaysAuthorization];
    SMmarker= [[GMSMarker alloc]init];
    [self startUpdating];
    
    
}

-(void)startUpdating{
    [SMlocationManager startUpdatingLocation];
}

-(void) stopUpdating{
    [SMlocationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:
(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    CLLocation * location = [[DataSingletons sharedManager] userLocation];
    self.sellerMarker.map = nil;
    
    if ([[[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status CONTAINS[cd]%@",@"On The Way"]] count]>0){
        
        
        self.sellerMarker.position = CLLocationCoordinate2DMake(location.coordinate.latitude , location.coordinate.longitude);
        
        
        NSArray *frames = @[[UIImage imageNamed:@"step1"],
                            [UIImage imageNamed:@"step2"],
                            [UIImage imageNamed:@"step3"],
                            [UIImage imageNamed:@"step4"],
                            [UIImage imageNamed:@"step5"],
                            [UIImage imageNamed:@"step6"],
                            [UIImage imageNamed:@"step7"],
                            [UIImage imageNamed:@"step8"]];
        if (newLocation.course>180){
            frames = @[[UIImage imageNamed:@"270step1"],
                       [UIImage imageNamed:@"270step2"],
                       [UIImage imageNamed:@"270step3"],
                       [UIImage imageNamed:@"270step4"],
                       [UIImage imageNamed:@"270step5"],
                       [UIImage imageNamed:@"270step6"],
                       [UIImage imageNamed:@"270step7"],
                       [UIImage imageNamed:@"270step8"]];
        }else if (newLocation.course<0){
            self.sellerMarker.icon = [UIImage imageNamed:@"270step7"];
        }
        if (newLocation.course>0){
            self.sellerMarker.icon = [UIImage animatedImageWithImages:frames duration:0.8];
        }
        
        self.sellerMarker.groundAnchor = CGPointMake(0.5f, 0.97f); // Taking into account walker's shadow
        
        
        if (newLocation.course>0){
            self.sellerMarker.icon = [UIImage animatedImageWithImages:frames duration:0.8];
            self.sellerMarker.groundAnchor = CGPointMake(0.5f, 0.97f); // Taking into account walker's shadow
        }
        
        self.sellerMarker.map=self.mapView;
        
        
        if (sellerMapMoved==NO){
            [self centerButtonPressed:nil];
            [self.mapView setSelectedMarker:self.sellerMarker];
        }
        
        if (![[[DataSingletons sharedManager]routeArray] isEqualToArray:sellerRouteArray]){
            GMSMutablePath *pathToDraw = [[GMSMutablePath alloc]init];
            
            for (NSDictionary *dictx in [[DataSingletons sharedManager] routeArray]){
                NSDictionary *location = [dictx objectForKey:@"location"];
                double latitude = [[location objectForKey:@"latitude"] doubleValue];
                double longitude = [[location objectForKey:@"longitude"] doubleValue];
                [pathToDraw addCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
            }
            self.polyline.map=nil;
            self.polyline = [GMSPolyline polylineWithPath:pathToDraw];
            self.polyline.map = self.mapView;
            self.polyline.strokeColor = [UIColor darkGrayColor];
            self.polyline.strokeWidth = 6;
            
            sellerRouteArray = [[NSArray alloc]initWithArray:[[DataSingletons sharedManager]routeArray]];
        }
        
    }
}


-(void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position{
    CLLocationCoordinate2D center=self.mapView.camera.target;
    if ([API distanceBetweenLocations:[[CLLocation alloc]initWithLatitude:center.latitude longitude:center.longitude] andLocation:[[DataSingletons sharedManager]userLocation]]>300 && sellerMapMoved==NO){
        sellerMapMoved=YES;
    }
}



- (IBAction)centerButtonPressed:(id)sender {
    float zoom = 15+2;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[DataSingletons sharedManager]userLocation].coordinate.latitude
                                                            longitude:[[DataSingletons sharedManager]userLocation].coordinate.longitude
                                                                 zoom:zoom];
    self.mapView.camera = camera;
    
    sellerMapMoved=NO;
    
}


#pragma mark - GMSMapView Delegate Methods

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(WRGMSMarker *)marker {
    
    self.codeTextBox.hidden=NO;
    self.codeTextBox.delegate=self;
    self.selectedSale= marker.orderId;
    
}
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(WRGMSMarker *)marker {
    
    if ([marker.snippet isEqualToString:@"Seller"]){
        SalesMapView *cardView = [[SalesMapView alloc]initWithSales:nil];
        
        cardView.mainLabel.text =marker.title;
        
        [cardView.tableView reloadData];
        return cardView;
    }
    
    NSDictionary*dict =[[[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId like %@", marker.title]] firstObject];
    
    NSLog(@"%@",dict);
    NSLog(@"%@",marker.sellerInfo);
    NSDate *date2 = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[[dict objectForKey:@"commitedDeliveryDate"] intValue]];
    
    NSTimeInterval secondsBetween = [date2 timeIntervalSinceDate:[NSDate date]];
    int numberOfDays = secondsBetween / 86400;
    
    NSLog(@"Commited Date: %@ = %d",date2,numberOfDays);
    
    //    NSString *name=[marker.sellerInfo objectForKey:@"name"];
    //
    //    self.infoTextView.text = [NSString stringWithFormat:@"Seller: %@\n",[name substringWithRange:NSMakeRange(0, name.length<20 ? name.length:19)]];
    
    if (marker.sellerInfo==nil){
        self.ratings.hidden=YES;
    }else{
        self.infoTextView.hidden=NO;
        self.ratings.hidden=NO;
    }
    
    switch ([[marker.sellerInfo objectForKey:@"ratings"] intValue]) {
        case 1:
            self.ratings.image= [UIImage imageNamed:@"profile-rating-1"];
            break;
        case 2:
            self.ratings.image= [UIImage imageNamed:@"profile-rating-2"];
            break;
        case 3:
            self.ratings.image= [UIImage imageNamed:@"profile-rating-3"];
            break;
        case 4:
            self.ratings.image= [UIImage imageNamed:@"profile-rating-4"];
            break;
        case 5:
            self.ratings.image= [UIImage imageNamed:@"profile-rating-5"];
            break;
        default:
            break;
    }
    
    
    
    SalesMapView *cardView = [[SalesMapView alloc]initWithSales:dict];
    cardView.mainLabel.text = [dict objectForKey:@"orderId"];
    cardView.mainLabel.text = @"Click to enter completion code";
    cardView.totalPrice = [dict objectForKey:@"totalPrice"];
    //int y=1;
    for (NSDictionary*x in [dict objectForKey:@"orderItems"]){
        //[cardView.tableViewArray addObject:[NSString stringWithFormat:@"Item %i %@%@",++y,[x objectForKey:@"currency"],[x objectForKey:@"buyingPrice"]]];
        [cardView.tableViewArray addObject:x];
        //productName currency description buyingPrice productId
    }
    
    
    [cardView.tableView reloadData];
    return cardView;
}

-(void)completeSales:(id)sender{
    
    [SVProgressHUD show];
    
    NSDictionary *dictProposal =sender;
    
    [[Orders sharedManager]setActiveOrders:[[NSMutableArray alloc]initWithArray:
                                            [[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(orderId CONTAINS[cd] %@)", [dictProposal objectForKey:@"orderId"]]]]];
    float cut = [[[NSUserDefaults standardUserDefaults] objectForKey:SERVICEFEE] floatValue]-[[[NSUserDefaults standardUserDefaults] objectForKey:INCENTIVE] floatValue];
    
    if ([[dictProposal objectForKey:@"paymentMode"] isEqualToString:@"Cash"]){
        [API addDebits:@{@"paidBy": [dictProposal objectForKey:@"sellerId"],
                         @"amount" : [NSString stringWithFormat:@"%.2f",cut],
                         @"code" : [dictProposal objectForKey:@"orderId"],
                         @"paymentMethod" : @"Cash",
                         @"type" : @"Cut"
                         }
               success:^(){
               } failure:^(NSString *message) {
                   NSLog(@"Fail");
               }];
    }else{
        [API addCredits:@{@"paidBy": [dictProposal objectForKey:@"sellerId"],
                          @"amount" : [[NSUserDefaults standardUserDefaults] objectForKey:INCENTIVE],
                          @"code" : [dictProposal objectForKey:@"orderId"],
                          @"paymentMethod" : @"Cash",
                          @"type" : @"Incentive"
                          }
                success:^(){
                } failure:^(NSString *message) {
                    NSLog(@"Fail");
                }];
    }
    
    [API updateSalesOrder:[dictProposal objectForKey:@"orderId"] withStatus:@"Completed" withSellerId:[dictProposal objectForKey:@"sellerId"] withItems:[dictProposal objectForKey:@"orderItems"] withDict:dictProposal
                  success:^(NSDictionary *dict){
                      
                      [API deleteProposals:[dictProposal objectForKey:@"orderId"]
                                   success:^(NSDictionary *dict){
                                       //
                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTab" object:dict userInfo:@{@"tab" : [NSNumber numberWithInt:2]}];// show map
                                   } failure:^(NSString *message) {
                                       NSLog(@"Fail");
                                   }];
                  } failure:^(NSString *message) {
                      NSLog(@"Fail");
                  }];
    
    
    
    self.infoTextView.text = @"There are no ongoing transactions";
    self.infoTextView.text = @"";
    self.ratings.hidden=YES;
    
    //[self viewDidAppear:YES];
}

-(void)processPaymentSales:(id)sender{
    
    NSDictionary *dict = sender;
    if ([[dict objectForKey:@"paymentMode"] isEqualToString:@"Credit"]){
        [[API sharedManager] createCheckoutPayment:  @{@"amount" : [dict objectForKey:@"totalPrice"],@"currency" : [dict objectForKey:@"currency"]}
                                      successBlock:^(id response){
                                          [self completeSales:dict];
                                          [AZNotification showNotificationWithTitle:@"Payment via Credit Card successful"  controller:self notificationType:AZNotificationTypeSuccess shouldShowNotificationUnderNavigationBar:YES];
                                      }failureBlock:^(NSError *error) {
                                          [AZNotification showNotificationWithTitle:@"Payment not successful"  controller:self notificationType:AZNotificationTypeError shouldShowNotificationUnderNavigationBar:YES];
                                      }];
    }else{
        
        [self completeSales:dict];
        
        //[AZNotification showNotificationWithTitle:@"Cash Payment successful"  controller:self notificationType:AZNotificationTypeSuccess shouldShowNotificationUnderNavigationBar:NO];
    }
    
    
    
    //[self showCompleteOrShowCodeModePicker];
    
}


#pragma mark - Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    self.codeTextBox.hidden=YES;
    if (![self.codeTextBox.text isEqualToString:@""]){
        
        NSString *code = [self.selectedSale substringFromIndex: [self.selectedSale length] - 4];
        if ([code isEqualToString:self.codeTextBox.text]){
            NSDictionary *dict = [[[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId CONTAINS[cd] %@", self.selectedSale]] firstObject];
            if ([[dict objectForKey:@"paymentMode"] isEqualToString:@"Cash"]){
                [self completeSales:dict];
            }else{
                [AZNotification showNotificationWithTitle:@"Credit card transactions should be completed by buyer"  controller:self notificationType:AZNotificationTypeWarning shouldShowNotificationUnderNavigationBar:YES];
            }
        }else{
            [AZNotification showNotificationWithTitle:@"Wrong Code entered"  controller:self notificationType:AZNotificationTypeWarning shouldShowNotificationUnderNavigationBar:YES];
        }
    }
    self.codeTextBox.text=@"";
    [self.codeTextBox resignFirstResponder];
    return YES;
}


@end




