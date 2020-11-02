//
//  MapViewController.m
//  Dashboard
//
//  Created by  on 3/3/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "MapViewController.h"
#import "UIColor+DBColors.h"

@interface MapViewController()

@property (strong, nonatomic) IBOutlet GMSMapView *mapView;


@end

@implementation MapViewController
BOOL userAddressExists;
CLLocationManager *locationManager;
GMSMarker*marker;
SalesMapView *cardView;
NSArray *pppickerData;
BOOL paymentMode=NO;
BOOL mapMoved=NO;

#pragma mark - Override Methods

- (void)dealloc {
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}




- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.infoTextView.text = @"";
    self.ratings.hidden=YES;
    [self initializeMapView];
    
    
    /*
    if ([[UIApplication sharedApplication]
         canOpenURL:[NSURL URLWithString:@"waze://"]]) {
        // Waze is installed. Launch Waze and start navigation
        NSString *urlStr =
        [NSString stringWithFormat:@"https://waze.com/ul?ll=%f,%f&navigate=yes",
         latitude, longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    } else {
        // Waze is not installed. Launch AppStore to install Waze app
        [[UIApplication sharedApplication] openURL:[NSURL
                                                    URLWithString:@"http://itunes.apple.com/us/app/id323229106"]];
    }
     */

    for (NSDictionary *salesDict in [[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status CONTAINS[cd]%@",@"On The Way"]]){
        //[API drawMapRoute:[salesDict objectForKey:@"sellerRoute"] usingMap:self.mapView withLatitude:[[salesDict objectForKey:@"latitude"]floatValue] andLongitude:[[salesDict objectForKey:@"longitude"]floatValue] withLineColor:[UIColor whiteColor] andStrokeWidth:3.f];
        
        self.buyerMarker.map = nil; // remove any existing buyer marker
        
        self.buyerMarker= [[WRGMSMarker alloc]init];
        self.buyerMarker.position = CLLocationCoordinate2DMake([[salesDict objectForKey:@"latitude"]floatValue] , [[salesDict objectForKey:@"longitude"]floatValue]);
        self.buyerMarker.snippet=@"Seller";
        self.buyerMarker.sellerId=[salesDict objectForKey:@"ratings"];
        self.buyerMarker.title=[salesDict objectForKey:@"address"];
        self.buyerMarker.map=self.mapView;
        
         //UIImageView *mapscope = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"profile-pic"]];
        UIImageView *mapscope = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ant-approved"]];
        
        
         mapscope.frame=CGRectMake(0, 0, 60, 60);
         self.buyerMarker.icon=mapscope.image;
        

        NSDictionary * dictionary =[API getSellerRoute:[salesDict objectForKey:@"sellerId"]
                  queryType:FIRDataEventTypeValue
                    success:^(NSDictionary *dict){
                        NSDictionary *found =[[[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId CONTAINS[cd]%@", [salesDict objectForKey:@"orderId"]]] firstObject];
                        if (found){
                            if ([[found objectForKey:@"status"] isEqualToString:@"Closed"]){
                                return;
                            }
                        }
                        self.sellerMarker.map = nil;
                        
                        self.sellerMarker= [[WRGMSMarker alloc]init];
                        self.sellerMarker.position = CLLocationCoordinate2DMake([[dict objectForKey:@"latitude"] doubleValue] , [[dict objectForKey:@"longitude"] doubleValue]);
                        
                        self.sellerMarker.snippet= [salesDict objectForKey:@"sellerId"];
                        self.sellerMarker.sellerId= [salesDict objectForKey:@"sellerId"];
                        self.sellerMarker.title= [dict objectForKey:@"eta"];
                        self.sellerMarker.orderId=[salesDict objectForKey:@"orderId"];
                        
                        Seller *seller = [API getSeller:[salesDict objectForKey:@"sellerId"]];
                        
                        self.sellerMarker.sellerInfo =@{@"firstName":seller.firstName,
                                                        @"lastName":seller.lastName,
                                                        @"mobileNumber": seller.mobileNumber,
                                                        @"ratings": seller.ratings
                                                        };
                        self.sellerMarker.map=self.mapView;
                        
                        NSArray *frames = @[[UIImage imageNamed:@"step1"],
                                            [UIImage imageNamed:@"step2"],
                                            [UIImage imageNamed:@"step3"],
                                            [UIImage imageNamed:@"step4"],
                                            [UIImage imageNamed:@"step5"],
                                            [UIImage imageNamed:@"step6"],
                                            [UIImage imageNamed:@"step7"],
                                            [UIImage imageNamed:@"step8"]];
                        if ([[dict objectForKey:@"course"] doubleValue]>180){
                            frames = @[[UIImage imageNamed:@"270step1"],
                                       [UIImage imageNamed:@"270step2"],
                                       [UIImage imageNamed:@"270step3"],
                                       [UIImage imageNamed:@"270step4"],
                                       [UIImage imageNamed:@"270step5"],
                                       [UIImage imageNamed:@"270step6"],
                                       [UIImage imageNamed:@"270step7"],
                                       [UIImage imageNamed:@"270step8"]];
                        }else if ([[dict objectForKey:@"course"] doubleValue]<0){
                            self.sellerMarker.icon = [UIImage imageNamed:@"270step7"];
                        }
                        if ([[dict objectForKey:@"course"] doubleValue]>0){
                            self.sellerMarker.icon = [UIImage animatedImageWithImages:frames duration:0.8];
                        }
                            
                        self.sellerMarker.groundAnchor = CGPointMake(0.5f, 0.97f); // Taking into account walker's shadow
                        
                        
                        
                        self.sellerMarker.map=self.mapView;
                        
                        //[self.markersArray addObject:self.sellerMarker];
                        
                        [self.mapView setSelectedMarker:self.sellerMarker];
                        
                        
                        if (mapMoved==NO){
                            [self centerButtonPressed:nil];
                        }

                        
                        if (![[[DataSingletons sharedManager] routeArray] isEqual:[dict objectForKey:@"sellerRouteV2"]]){
                            
                            
                            GMSMutablePath *pathToDraw = [[GMSMutablePath alloc]init];
                            
                            for (NSDictionary *dictx in [dict objectForKey:@"sellerRouteV2"]){
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
                            
                            
                        /*
                        [API snapPathToRoad:[dict objectForKey:@"sellerRoute"]
                                    success:^(GMSMutablePath *pathToDraw){
                                        self.polyline.map=nil;
                                        //Draw polyline with path
                                        self.polyline = [GMSPolyline polylineWithPath:pathToDraw];
                                        self.polyline.map = self.mapView;
                                        self.polyline.strokeColor = [UIColor darkGrayColor];
                                        self.polyline.strokeWidth = 6;
                                        
                                    } failure:^(NSString *message) {
                                        NSLog(@"Fail");
                                    }];
                         */
                        }
                        
                        [[DataSingletons sharedManager] setRouteArray:[[NSMutableArray alloc]initWithArray:[dict objectForKey:@"sellerRouteV2"]]];
                        
                    } failure:^(NSString *message) {
                        NSLog(@"Fail");
                    }];
                
        [[DataSingletons sharedManager]setSellerRoutesReference:[dictionary objectForKey:@"reference"]];
        
        
    }
    
}

#pragma mark - Private Methods

- (IBAction)centerButtonPressed:(id)sender {
    float zoom = 15+2;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.sellerMarker.position.latitude
                                                            longitude:self.sellerMarker.position.longitude
                                                                 zoom:zoom];
    self.mapView.camera = camera;
    
    mapMoved=NO;
}
-(void)initializeMapView {
    self.mapView.delegate = self;
    //self.mapView.myLocationEnabled = true;
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[DataSingletons sharedManager]userLocation].coordinate.latitude
                                                            longitude:[[DataSingletons sharedManager]userLocation].coordinate.longitude
                                                                 zoom:17];
    self.mapView.camera = camera;
    //self.mapView.settings.myLocationButton=YES;
    //self.mapView.settings.compassButton=YES;
    
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *styleUrl = [mainBundle URLForResource:@"style" withExtension:@"json"];
    NSError *error;
    
    // Set the map style by passing the URL for style.json.
    GMSMapStyle *style = [GMSMapStyle styleWithContentsOfFileURL:styleUrl error:&error];
    
    if (!style) {
        NSLog(@"The style definition could not be loaded: %@", error);
    }
    self.mapView.mapStyle = style;
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager requestAlwaysAuthorization];
    marker= [[GMSMarker alloc]init];
    //[self startUpdating];
    
    
}

-(void)startUpdating{
    [locationManager startUpdatingLocation];
}

-(void) stopUpdating{
    [locationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [self stopUpdating];
}

-(void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position{
    CLLocationCoordinate2D center=self.mapView.camera.target;
    
    ;
    
    if ([API distanceBetweenLocations:[[CLLocation alloc]initWithLatitude:center.latitude longitude:center.longitude] andLocation:[[CLLocation alloc]initWithLatitude:self.sellerMarker.position.latitude longitude:self.sellerMarker.position.longitude]]>300 && mapMoved==NO){
        mapMoved=YES;
    }
}


#pragma mark - GMSMapView Delegate Methods
//-(BOOL) mapView:(GMSMapView *) mapView didTapMarker:(GMSMarker *)marker{
//    NSLog(@"%@",marker.snippet);
//    return YES;
//}
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(WRGMSMarker *)marker {
    
    //marker.sellerInfo
    NSDictionary*dict =[[[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId like %@", marker.orderId]] firstObject];
    
    
    self.selectedSale = dict;
    paymentMode=NO;
    [self showCompleteOrShowCodeModePicker];
    
    
    
}
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(WRGMSMarker *)marker {
    if ([marker.snippet isEqualToString:@"Seller"]){
        SalesMapView *cardView = [[SalesMapView alloc]initWithSales:nil];
        
        cardView.mainLabel.text =marker.title;
        
        [cardView.tableView reloadData];
        return cardView;
    }
    
    mapMoved=NO;
    
    NSDictionary*dict =[[[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId like %@", marker.orderId]] firstObject];
    
    NSDate *date2 = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[[dict objectForKey:@"commitedDeliveryDate"] intValue]];
    
    NSTimeInterval secondsBetween = [date2 timeIntervalSinceDate:[NSDate date]];
    int numberOfDays = secondsBetween / 86400;
    
    NSLog(@"Commited Date: %@ = %d",date2,numberOfDays);
    NSString *name=[NSString stringWithFormat:@"%@ %@",[marker.sellerInfo objectForKey:@"firstName"],[marker.sellerInfo objectForKey:@"lastName"]];
    
    
    self.infoTextView.text = [NSString stringWithFormat:@"Seller: %@\nMobile: %@",[name substringWithRange:NSMakeRange(0, name.length<20 ? name.length:19)],[marker.sellerInfo objectForKey:@"mobileNumber"]];
    
    if (marker.sellerInfo==nil){
        //self.infoTextView.hidden=YES;
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
    
    cardView = [[SalesMapView alloc]initWithSales:dict];
    cardView.mainLabel.text = [NSString stringWithFormat:@"Seller will arrive in %@",marker.title];
    //    if ([userAddress isEqualToString:@""]){
    //        cardView.mainLabel.text = @"Click me to complete";
    //    }else{
    //        cardView.mainLabel.text =userAddress;
    //    }
    cardView.totalPrice = [dict objectForKey:@"totalPrice"];
    
    for (NSDictionary*x in [dict objectForKey:@"orderItems"]){
        
        [cardView.tableViewArray addObject:x];
        
    }
    [cardView.tableView reloadData];
    return cardView;
}



#pragma mark - Picker View Delegate

- (NSAttributedString *)czpickerView:(CZPickerView *)pickerView
               attributedTitleForRow:(NSInteger)row{
    
    NSAttributedString *att = [[NSAttributedString alloc]
                               initWithString:pppickerData[row]
                               attributes:@{
                                            NSFontAttributeName:[UIFont fontWithName:@"Avenir-Light" size:18.0]
                                            }];
    return att;
}

- (NSString *)czpickerView:(CZPickerView *)pickerView
               titleForRow:(NSInteger)row{
    return pppickerData[row];
}

- (UIImage *)czpickerView:(CZPickerView *)pickerView imageForRow:(NSInteger)row {
    //    if([pickerView isEqual:self.pickerWithImage]) {
    //        return pickerData[row];
    //    }
    return nil;
}

- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView {
    return pppickerData.count;
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row {
    if (paymentMode==NO){
        
        if (row==0){
            
            NSString *code = [[self.selectedSale objectForKey:@"orderId"] substringFromIndex: [[self.selectedSale objectForKey:@"orderId"] length] - 4];
            
            [self showMessagePrompt:[NSString stringWithFormat:@"Give this code to seller to complete this transaction: \n%@",code]];
            [AZNotification showNotificationWithTitle:[NSString stringWithFormat:@"GIVE THIS CODE TO SELLER: %@",code]  controller:self notificationType:AZNotificationTypeMessage shouldShowNotificationUnderNavigationBar:YES];
            
            
        }else if (row==2){
            paymentMode=YES;
            [self showCompleteOrShowCodeModePicker];
        }else{
            [self processPaymentSales:self.selectedSale];
        }
    }else{
        NSString *paymentMode;
        
        if (row==0){
            paymentMode=@"Cash";
        }else{
            paymentMode=@"Credit";
        }
        
        if (![paymentMode isEqualToString:[self.selectedSale objectForKey:@"paymentMode"]]){
            // change payment mode
            [self.selectedSale setValue:paymentMode forKey:@"paymentMode"];
            [API updateSalesOrder:[self.selectedSale objectForKey:@"orderId"] withStatus:[self.selectedSale objectForKey:@"status"] withSellerId:[self.selectedSale objectForKey:@"sellerId"] withItems:nil withDict:self.selectedSale
                          success:^(NSDictionary *dict){
                              
                              [AZNotification showNotificationWithTitle:[NSString stringWithFormat:@"Payment Mode changed to %@",paymentMode]  controller:self notificationType:AZNotificationTypeMessage shouldShowNotificationUnderNavigationBar:YES];
                              
                          } failure:^(NSString *message) {
                              NSLog(@"Fail");
                          }];
        }
    }
}

//- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemsAtRows:(NSArray *)rows {
//    for (NSNumber *n in rows) {
//        NSInteger row = [n integerValue];
//        NSLog(@"%@ is chosen!", pppickerData[row]);
//
//
//        if (row==0){
//            [AZNotification showNotificationWithTitle:[self.selectedSale objectForKey:@"orderId"]  controller:self notificationType:AZNotificationTypeSuccess shouldShowNotificationUnderNavigationBar:YES];
//        }else{
//            [self processPaymentSales:self.selectedSale];
//        }
//    }
//}

- (void)czpickerViewDidClickCancelButton:(CZPickerView *)pickerView {
    //[self.navigationController setNavigationBarHidden:YES];
    NSLog(@"Canceled.");
}


-(void)showCompleteOrShowCodeModePicker{
    if (paymentMode==NO){
        pppickerData = [[NSArray alloc]initWithObjects:@"Give Code to Seller",[NSString stringWithFormat:@"Complete Now (%@)",[self.selectedSale objectForKey:@"paymentMode"]], @"Change Payment Mode",nil];
    }else{
        
        if ([[API sharedManager] checkIfIncentivesFeesDone:self.selectedSale]==YES){
            [AZNotification showNotificationWithTitle:[NSString stringWithFormat:@"You cannot change payment mode"]  controller:self notificationType:AZNotificationTypeMessage shouldShowNotificationUnderNavigationBar:YES];
            return;
        }
        if ([[self.selectedSale objectForKey:@"paymentMode"] isEqualToString:@"Cash"]){
            pppickerData = [[NSArray alloc]initWithObjects:@"Cash (Current)",[NSString stringWithFormat:@"Credit Card"],nil];
        }else{
            pppickerData = [[NSArray alloc]initWithObjects:@"Cash",[NSString stringWithFormat:@"Credit Card  (Current)"],nil];
        }
//        PMDCard *card=nil;
//        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"PayMayaCustomerCard"]) {
//            NSData *customerData = [[NSUserDefaults standardUserDefaults] objectForKey:@"PayMayaCustomerCard"];
//            card = [NSKeyedUnarchiver unarchiveObjectWithData:customerData];
//
//            if ([[self.selectedSale objectForKey:@"paymentMode"] isEqualToString:@"Cash"]){
//                pppickerData = [[NSArray alloc]initWithObjects:@"Cash (Current)",[NSString stringWithFormat:@"Credit Card"],nil];
//            }else{
//                pppickerData = [[NSArray alloc]initWithObjects:@"Cash",[NSString stringWithFormat:@"Credit Card  (Current)"],nil];
//            }
//        }else{
//            paymentMode=NO;
//            pppickerData = [[NSArray alloc]initWithObjects:@"Give Code to Seller",@"Complete Now (Cash)", @"Change Payment Mode",nil];
//        }
        
        
    }
    self.pickerView = [[CZPickerView alloc] initWithHeaderTitle:@"Select Completion Type" cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Complete"];
    self.pickerView.headerTitleFont = [UIFont fontWithName:@"SEOptimistLight" size:18.0];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.needFooterView = NO;
    self.pickerView.frame = CGRectMake(self.pickerView.frame.origin.x, self.pickerView.frame.origin.y, self.pickerView.frame.size.width, self.pickerView.frame.size.height);
    self.pickerView.headerBackgroundColor=[UIColor colorWithHexString:@"#F78320"];
    
    
    [self.pickerView show];
    
    
    
}
- (void)showMessagePrompt:(NSString *)message {
    //if ([self supportsAlertController]) {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:nil
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction =
    [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    //    } else {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
    //                                                        message:message
    //                                                       delegate:nil
    //                                              cancelButtonTitle:nil
    //                                              otherButtonTitles:kOK, nil];
    //        [alert show];
    //    }
}

#pragma mark - completion of sale/order
-(void)processPaymentSales:(id)sender{
    
    
    
    NSDictionary *dictProposal =sender;
    [[API sharedManager] completeSales:dictProposal
                               success:^(id response){
                                   
                                   [[[DataSingletons sharedManager]sellerRoutesReference] removeAllObservers];
                                   
                                   self.infoTextView.text = @"There are no sellers en route";
                                   self.ratings.hidden=YES;
                                   [self.mapView clear];
    
                                   //[[mainFirebaseReference child:@"sellerRoute"]child:[dictProposal object sellerId]]
                                   
                                   [[Orders sharedManager]setActiveOrders:[[NSMutableArray alloc]initWithArray:
                                                                           [[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(orderId CONTAINS[cd] %@)", [dictProposal objectForKey:@"orderId"]]]]];
                                   
                                   [SVProgressHUD dismiss];
                                   //[AZNotification showNotificationWithTitle:@"Payment successful"  controller:self notificationType:AZNotificationTypeSuccess shouldShowNotificationUnderNavigationBar:YES];
                               }failure:^(NSString *error) {
                                   [AZNotification showNotificationWithTitle:@"Payment not successful"  controller:self notificationType:AZNotificationTypeError shouldShowNotificationUnderNavigationBar:YES];
                               }];
    /*
    [API createPayMayaCheckoutPayment:dictProposal
                    withDelegateTarget:self
                          successBlock:^(id response){
                              //[self addPayments:debitcreditDict];
                          }failureBlock:^(NSError *error) {
                              
                          }];
    */
}

- (void)checkoutDidFinishWithResult:(PMSDKCheckoutResult *)result
{
    if (result.status == PMSDKCheckoutStatusUnknown) {
        // handle unknown status
    }
    else if (result.status == PMSDKCheckoutStatusCanceled) {
        // handle canceled status
    }
    else if (result.status == PMSDKCheckoutStatusFailed) {
        // handle failed status
    }
    else if (result.status == PMSDKCheckoutStatusSuccess) {
        // handle success status
    }
}

- (void)checkoutDidFailWithError:(NSError *)error
{
    // handle error
}

@end



