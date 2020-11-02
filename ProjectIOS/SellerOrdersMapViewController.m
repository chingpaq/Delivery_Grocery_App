//
//  SellerOrdersMapViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 25/03/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import "SellerOrdersMapViewController.h"

@interface SellerOrdersMapViewController ()

@end

@implementation SellerOrdersMapViewController



BOOL SuserAddressExist;
NSMutableArray *SppickerData;
CLLocationManager *SlocationManagers;
GMSMarker*Smarkers;
NSString *SpostalCode;
NSString * Scardname;
NSString *timeToArrive;
GMSMutablePath *pathToDraw;

- (void)dealloc {
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.commentTextView.delegate=self;
    [self.commentTextView setText:@"Note to buyer (optional)"];
    self.commentTextView.textColor = [UIColor lightGrayColor];
    self.addressTextView.hidden=YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIImageView *imageBorder = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"description-box"]];
    imageBorder.frame = CGRectMake(0, 0, self.commentTextView.frame.size.width, self.commentTextView.frame.size.height);
    
    [self initializeMapView];
    
    
    
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) {
        
        //[self.delegate backPressedFrom];
    }
}
#pragma mark - Private Methods

-(void)initializeMapView {
    self.mapView.delegate = self;
    float zoom = 15;
    [self.addressTextView setNeedsDisplay];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[self.orderDict objectForKey:@"latitude"]floatValue]
                                                            longitude:[[self.orderDict objectForKey:@"longitude"]floatValue]
                                                                 zoom:zoom];
    self.mapView.camera = camera;
    self.mapView.settings.myLocationButton=YES;
    self.mapView.settings.compassButton=YES;
    self.mapView.myLocationEnabled = true;
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *styleUrl = [mainBundle URLForResource:@"style" withExtension:@"json"];
    NSError *error;
    
    // Set the map style by passing the URL for style.json.
    GMSMapStyle *style = [GMSMapStyle styleWithContentsOfFileURL:styleUrl error:&error];
    
    if (!style) {
        NSLog(@"The style definition could not be loaded: %@", error);
    }
    self.mapView.mapStyle = style;
    
    
    SlocationManagers = [[CLLocationManager alloc]init];
    SlocationManagers.delegate = self;
    SlocationManagers.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    SlocationManagers.distanceFilter = kCLDistanceFilterNone;
    
    [SlocationManagers requestAlwaysAuthorization];
    Smarkers= [[GMSMarker alloc]init];
    [self startUpdating];
    
    float low_bound = -0.0001;
    float high_bound = 0.0001;
    float rndValue = (((float)arc4random()/0x100000000)*(high_bound-low_bound)+low_bound);
    
    CLLocationCoordinate2D circleCenter = CLLocationCoordinate2DMake([[self.orderDict objectForKey:@"latitude"]floatValue]+rndValue, [[self.orderDict objectForKey:@"longitude"]floatValue]+rndValue);
    GMSCircle *circ = [GMSCircle circleWithPosition:circleCenter
                                             radius:700];
    circ.fillColor = [UIColor lightGrayColor];//[UIColor colorWithRed:0.25 green:0 blue:0 alpha:0.05];
    circ.strokeColor = [UIColor whiteColor];
    circ.strokeWidth = 5;
    circ.map = self.mapView;
}
-(void)startUpdating{
    [SlocationManagers startUpdatingLocation];
}

-(void) stopUpdating{
    [SlocationManagers stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:
(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self getTimeToArrive];
    
    [self stopUpdating];
    
}
-(void)getTimeToArrive{
    float lat = [[self.orderDict objectForKey:@"latitude"] floatValue];// current location of seller
    float longi= [[self.orderDict objectForKey:@"longitude"] floatValue];//current location of seller
    float userLat=self.mapView.myLocation.coordinate.latitude;
    float userLong =self.mapView.myLocation.coordinate.longitude;
    timeToArrive=@"";
    NSString *strUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false&mode=%@&key=%@", lat,  longi, userLat,  userLong, [[NSUserDefaults standardUserDefaults] objectForKey:MAP_ROUTING_TYPE],@"AIzaSyDff1g4RwfDN0saC4gXvS9B4R6Ql78LyRw"];
    ;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:strUrl
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSMutableArray *arrDistance=[responseObject objectForKey:@"routes"];
             if ([arrDistance count]>0) {
                 
                 NSMutableArray *arrLeg=[[arrDistance objectAtIndex:0]objectForKey:@"legs"];
                 NSMutableDictionary *dictleg=[arrLeg objectAtIndex:0];
                 self.routeArray = [[NSMutableArray alloc]initWithArray:[dictleg objectForKey:@"steps"]];
                 
                 timeToArrive = [NSString stringWithFormat:@"%@",[[dictleg   objectForKey:@"duration"] objectForKey:@"text"]];
                 self.commentTextView.text = [NSString stringWithFormat:@"I will arrive in %@",timeToArrive];
             }
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
             if (response.statusCode == 404) {
                 
             } else {
                 //failure(response.statusCode);
             }
         }];
}

-(void)drawMapRoute:(NSMutableArray*)array{
    self.addressTextView.text = [NSString stringWithFormat:@"%@",[self.orderDict objectForKey:@"address"]];
    WRGMSMarker*marker2= [[WRGMSMarker alloc]init];
    marker2.position = CLLocationCoordinate2DMake([[self.orderDict objectForKey:@"latitude"] doubleValue] , [[self.orderDict objectForKey:@"longitude"] doubleValue]);
    marker2.map=self.mapView;
    
    for (NSDictionary *routeDict in array){
        GMSMutablePath *path = [GMSMutablePath path];
        [path addCoordinate:CLLocationCoordinate2DMake(@([[[routeDict objectForKey:@"start_location"]objectForKey:@"lat"]floatValue]).doubleValue,@([[[routeDict objectForKey:@"start_location"]objectForKey:@"lng"]floatValue]).doubleValue)];
        [path addCoordinate:CLLocationCoordinate2DMake(@([[[routeDict objectForKey:@"end_location"]objectForKey:@"lat"]floatValue]).doubleValue,@([[[routeDict objectForKey:@"end_location"]objectForKey:@"lng"]floatValue]).doubleValue)];
        
        GMSPolyline *rectangle = [GMSPolyline polylineWithPath:path];
        rectangle.strokeWidth = 3.f;
        
        rectangle.strokeColor = [UIColor greenColor];
        
        rectangle.map = _mapView;
        
    }
    
    [API snapPathToRoad:array
                success:^(GMSMutablePath *pathToDraw){
                    
                    //Draw polyline with path
                    GMSPolyline *polyline = [GMSPolyline polylineWithPath:pathToDraw];
                    polyline.map = self.mapView;
                    polyline.strokeColor = [UIColor redColor];
                    polyline.strokeWidth = 6;
                    
                } failure:^(NSString *message) {
                    NSLog(@"Fail");
                }];
}



- (IBAction)submitOrderButtonPressed:(id)sender {
    if ([timeToArrive isEqualToString:@""]){
        [self startUpdating];
        return;
    }
    
    //self.textBoxConstraint.constant = 10;
    //[self mapRoute:self.routeArray];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"sellerId"]==nil || [[defaults objectForKey:@"sellerId"] isEqualToString:@""]){
        return;
    }
    
    NSMutableArray *bidders= [[NSMutableArray alloc]initWithArray:[self.orderDict objectForKey:@"bidders"] ];
    [bidders addObject:[defaults objectForKey:@"sellerId"]];
    
    NSString *key = [[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"sales"] childByAutoId].key;
    
    [bidders addObject:@{[defaults objectForKey:@"sellerId"]: key}];
    
    [API updateSalesOrderBidders:[self.orderDict objectForKey:@"orderId"] withSellerArray:bidders success:^{
        
    } failure:^(NSString *message) {
        NSLog(@"Fail");
    }];
    
    [API getBuyerDetails:[self.orderDict objectForKey:@"buyerId"]
               eventType:FIRDataEventTypeValue
                 success:^(NSDictionary *dict){
                     //sellerDict= [[NSMutableDictionary alloc]initWithDictionary:dict];
                     NSLog(@"%@",dict);
                 } failure:^(NSString *message) {
                     NSLog(@"Fail");
                 }];
    
    float totalPrice=0;
    for (NSDictionary*item in [self.orderDict objectForKey:@"orderItems"]){
        totalPrice = totalPrice+ ( [[item objectForKey:@"buyingPrice"] floatValue]*[[item objectForKey:@"quantity"] floatValue]);
    }
    [self.orderDict setObject:[NSString stringWithFormat:@"%.2f",totalPrice] forKey:@"totalPrice"];
    [self.orderDict setObject:[defaults objectForKey:@"sellerId"] forKey:@"sellerId"];
    [self.orderDict setObject:[defaults objectForKey:@"name"]  forKey:@"sellerName"];
    
    if ([defaults objectForKey:@"sellerRatings"]!=nil){
        [self.orderDict setObject:@"0" forKey:@"sellerRatings"];
    }else{
        [self.orderDict setObject:[defaults objectForKey:@"sellerRatings"]  forKey:@"sellerRatings"];
    }
    
    [self.orderDict setObject:self.commentTextView.text forKey:@"comments"];
    [self.orderDict setObject:@"Pending" forKey:@"status"];
    [self.orderDict setObject:timeToArrive forKey:@"ETA"];
    [self.orderDict removeObjectForKey:@"bidders"];
    [self.orderDict removeObjectForKey:@"buyer"];
    [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"sales"] child:key]
     setValue:self.orderDict];
    
    [self.navigationController popViewControllerAnimated:NO];
    [self.delegate proposalsSent:self.orderDict];
    
}
-(void)countDownTimer:(id)sender{
    [self.navigationController popViewControllerAnimated:NO];
    [self.delegate proposalsSent:self.orderDict];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"e_utos_mo_na_segue"]) {
        self.waitingViewController = [segue destinationViewController];
        self.waitingViewController.delegate=self;
        self.waitingViewController.productDict =sender;
        
    }
    else if ([segue.identifier isEqualToString:@"proceedOrderFromHomeSegue"]){
        //self.ordersMapViewController = [segue destinationViewController];
        //self.productViewController.productDict =sender;
        //self.productViewController.delegate=self;
    }
}




-(void)textViewDidBeginEditing:(UITextView *)textView{
    self.commentHeight.constant=190;
    if([textView.text isEqualToString:@"Note to seller (optional)"]){
        textView.textColor = [UIColor blackColor];
        textView.text=nil;
    }
    
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    self.commentHeight.constant=90;
    
    if([textView.text isEqual:@""]){
        textView.textColor = [UIColor lightGrayColor];
        [textView setText:@"Note to seller (optional)"];
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL shouldChangeText = YES;
    
    if ([text isEqualToString:@"\n"]) {
        // Find the next entry field
        //BOOL isLastField = YES;
        //        for (UIView *view in [self entryFields]) {
        //            if (view.tag == (textView.tag + 1)) {
        //                [view becomeFirstResponder];
        //                isLastField = NO;
        //                break;
        //            }
        //        }
        //        if (isLastField) {
        //            [textView resignFirstResponder];
        //        }
        [textView resignFirstResponder];
        shouldChangeText = NO;
    }
    
    return shouldChangeText;
}


@end

