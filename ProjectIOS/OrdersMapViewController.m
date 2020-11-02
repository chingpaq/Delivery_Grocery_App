//
//  OrdersMapViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 16/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "OrdersMapViewController.h"


@interface OrdersMapViewController ()

@end

@implementation OrdersMapViewController
BOOL userAddressExist;
NSMutableArray *ppickerData;
CLLocationManager *locationManagers;
GMSMarker*markers;
NSString *postalCode;
NSString * cardname;
#pragma mark - Override Methods

- (void)dealloc {
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.commentTextView.delegate=self;
    [self.commentTextView setText:@"Note to seller (optional)"];
    self.commentTextView.textColor = [UIColor lightGrayColor];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIImageView *imageBorder = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"description-box"]];
    imageBorder.frame = CGRectMake(0, 0, self.commentTextView.frame.size.width, self.commentTextView.frame.size.height);
    //[self.commentTextView addSubview:imageBorder];
    
    [self initializeMapView];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"PayMayaCustomerCard"]) {
        NSData *customerData = [[NSUserDefaults standardUserDefaults] objectForKey:@"PayMayaCustomerCard"];
        self.card = [NSKeyedUnarchiver unarchiveObjectWithData:customerData];
    }else{
        self.card= nil;
    }
    if(![[[NSUserDefaults standardUserDefaults]objectForKey:@"CashDefault"] isEqualToString:@"Yes"]){
        self.paymentModeTextBox.text = @"Credit";

    }else{
        self.paymentModeTextBox.text = @"Cash";

    }
    
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
    self.mapView.myLocationEnabled = true;
    float zoom = 15;

    UIImageView *mapscope = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"marker"]];
    mapscope.frame=CGRectMake(0, 0, 60, 60);
    mapscope.frame=CGRectMake(0, 0, 60, 60);
    //mapscope.bounds = self.mapView.bounds;
    mapscope.center= self.mapView.center;

    //self.addressTextView=[[UITextView alloc]init];
    //self.addressTextView.frame= CGRectMake(self.view.frame.size.width/2-100, self.view.frame.size.height-200,200,100);

    [self.addressTextView setNeedsDisplay];
    [mapscope setNeedsDisplay];
    mapscope.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:mapscope];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:14.652427
                                                            longitude:121.0103733
                                                                 zoom:zoom];
    self.mapView.camera = camera;
    self.mapView.settings.myLocationButton=YES;
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
    
    locationManagers = [[CLLocationManager alloc]init];
    locationManagers.delegate = self;
    locationManagers.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManagers.distanceFilter = kCLDistanceFilterNone;


    [locationManagers requestAlwaysAuthorization];
    markers= [[GMSMarker alloc]init];
    [self startUpdating];
}
-(void)startUpdating{
    [locationManagers startUpdatingLocation];
}

-(void) stopUpdating{
    [locationManagers stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:
(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{


}

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:markers.position.latitude longitude:markers.position.longitude];
    self.submitOrdersButton.userInteractionEnabled=NO;
    [ceo reverseGeocodeLocation: loc completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         CLPlacemark *placemark = [placemarks objectAtIndex:0];

         NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];

         
         NSLog(@"location %@",placemark.location);
         //Print the location to console
         NSLog(@"I am currently at %@",locatedAt);
         self.submitOrdersButton.userInteractionEnabled=YES;
         self.addressTextView.text = locatedAt;
         postalCode = placemark.postalCode;
     }];

}
-(void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    [self.mapView clear];
    CLLocationCoordinate2D center=self.mapView.camera.target;
    
    markers.position = center;
    //marker.map=self.mapView;

}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for(int i=0;i<locations.count;i++){
        CLLocation * newLocation = [locations objectAtIndex:i];
        self.mapView.camera = [GMSCameraPosition cameraWithLatitude:newLocation.coordinate.latitude
                                                          longitude:newLocation.coordinate.longitude
                                                               zoom:15];
    }

    [self stopUpdating];

}

- (IBAction)submitOrderButtonPressed:(id)sender {
    NSString *key = [[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"orders"] childByAutoId].key;
    
    
    NSMutableDictionary*cfee= [[NSMutableDictionary alloc]init];
    [cfee setObject:[[NSUserDefaults standardUserDefaults] objectForKey:SERVICEFEE] forKey:@"buyingPrice"];
    [cfee setObject:@"CFEE" forKey:@"productId"];
    [cfee setObject:@"1" forKey:@"quantity"];
    [cfee setObject:[[NSUserDefaults standardUserDefaults] objectForKey:SERVICEFEECURRENCY] forKey:@"currency"];
    [cfee setObject:@"unit" forKey:@"buyingUOM"];
    [cfee setObject:@"Convenience Fee" forKey:@"productName"];
    [cfee setObject:[[NSUserDefaults standardUserDefaults] objectForKey:SERVICEFEE] forKey:@"srp"];
    [[[Orders sharedManager] currentOrders] addObject:cfee];
    
    NSMutableArray *ordersArray = [[NSMutableArray alloc]init];

    // retain only relevant data for saving in Firebase
    float total=0;
    NSString *currency;
    for (NSDictionary *dict in [[Orders sharedManager] currentOrders]){
        [ordersArray addObject:
        @{@"productId":[dict objectForKey:@"productId"],
          @"quantity": [dict objectForKey:@"quantity"],
          @"buyingPrice": [dict objectForKey:@"buyingPrice"],
          @"buyingUOM" : [dict objectForKey:@"buyingUOM"],
          @"currency" : [dict objectForKey:@"currency"]
          }
         ];
        currency = [dict objectForKey:@"currency"];
        total = total + ([[dict objectForKey:@"quantity"] intValue]*[[dict objectForKey:@"buyingPrice"] floatValue]);
    }
    
    NSString *mode = @"Credit";

    if ([self.paymentModeTextBox.text isEqualToString:@"Cash"]){
        mode = @"Cash";
    }
    if (postalCode==nil){
        postalCode=@"Not available";
    }
    
    if ([self.commentTextView.text isEqualToString:@"Note to seller (optional)"]){
        self.commentTextView.text = @"None";
    }
    NSMutableDictionary *post = [@{@"buyerId": [FIRAuth auth].currentUser.uid,
                           @"sellerId": @"-",
                           @"latitude":[NSNumber numberWithDouble:markers.position.latitude],
                           @"longitude": [NSNumber numberWithDouble:markers.position.longitude],
                           @"totalPrice": [NSString stringWithFormat:@"%.2f",total],
                           @"currency": currency,
                           @"address": self.addressTextView.text,
                                   @"buyerComment": self.commentTextView.text,
                           @"orderDate": [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]],
                           @"orderItems" : ordersArray,
                           @"status": @"Open",
                           @"postalCode": postalCode,
                                   @"psid": postalCode,
                                   @"paymentMode": mode
                           } mutableCopy];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTab" object:sender userInfo:@{@"tab" : [NSNumber numberWithInt:3]}];// show proposals
    
    [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"orders"] child:key] setValue:post];
    [post setObject:key forKey:@"orderId"];
    
        // new implementation
    post = [@{                     @"status": @"Open",
                                   @"lastUpdate": [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]],
                                   @"buyerId": [FIRAuth auth].currentUser.uid,
                                   @"psid": postalCode
                                   } mutableCopy];
    [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"ordersMaster"] child:key] setValue:post];
    
    
    [post setObject:key forKey:@"orderId"];

    
    
    [[[Orders sharedManager]currentOrders] removeAllObjects];
        [self.navigationController popViewControllerAnimated:NO];
    [self.delegate proposalsReceived:post];
    
    
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

-(void)showCommentBox{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.tintTopCircle = NO;
    alert.iconTintColor = [UIColor colorWithHexString:@"#1F80AA"];
    alert.useLargerIcon = NO;
    alert.cornerRadius = 13.0f;
    
    SCLTextView *textField = [alert addTextField:@"Add comments"];
    
    
    [alert addButton:@"Add" actionBlock:^(void) {
        self.commentTextView.text =[NSString stringWithFormat:@"   Note to seller (optional)\r\n%@", textField.text];
        [alert performSelectorOnMainThread:@selector(hideView) withObject:nil waitUntilDone:YES];
    }];
    
    [alert addButton:@"Close" actionBlock:^(void) {
        [alert performSelectorOnMainThread:@selector(hideView) withObject:nil waitUntilDone:YES];
    }];
    [alert showCustom:self image:[UIImage imageNamed:@"icon-password"] color:[UIColor colorWithHexString:@"#1F80AA"] title:nil subTitle:@"Addtional order details or instructions to the Seller" closeButtonTitle:nil duration:0.0f];
}
-(void)showChangePaymentModePicker{
    self.pickerView = [[CZPickerView alloc] initWithHeaderTitle:@"Select Payment Type" cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm"];
    self.pickerView.headerTitleFont = [UIFont systemFontOfSize: 12];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.needFooterView = NO;
    self.pickerView.frame = CGRectMake(self.pickerView.frame.origin.x, self.pickerView.frame.origin.y, self.pickerView.frame.size.width, self.pickerView.frame.size.height);
    
    ppickerData = [[NSMutableArray alloc]initWithObjects:cardname,@"Cash", nil];
    ppickerData = [[NSMutableArray alloc]initWithObjects:@"Credit",@"Cash", nil];
    //if (cardname!=nil){
    [self.pickerView show];
    //}
    
    
}
- (IBAction)commentButtonPressed:(id)sender {
    [self showCommentBox];
}
- (IBAction)changePaymentOptionButtonPressed:(id)sender {
    [self showChangePaymentModePicker];
}


#pragma mark - Picker View Delegate

- (NSAttributedString *)czpickerView:(CZPickerView *)pickerView
               attributedTitleForRow:(NSInteger)row{
    
    NSAttributedString *att = [[NSAttributedString alloc]
                               initWithString:ppickerData[row]
                               attributes:@{
                                            NSFontAttributeName:[UIFont fontWithName:@"Avenir-Light" size:18.0]
                                            }];
    return att;
}

- (NSString *)czpickerView:(CZPickerView *)pickerView
               titleForRow:(NSInteger)row{
    return ppickerData[row];
}

- (UIImage *)czpickerView:(CZPickerView *)pickerView imageForRow:(NSInteger)row {
    //    if([pickerView isEqual:self.pickerWithImage]) {
    //        return pickerData[row];
    //    }
    return nil;
}

- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView {
    return ppickerData.count;
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row {
    if (row==0){
        self.paymentModeTextBox.text = cardname;
        self.paymentModeTextBox.text = @"Credit Card";
    }else if (row==1){
        self.paymentModeTextBox.text = @"Cash";
    }
    
    
//    NSMutableDictionary*dict = [[[Orders sharedManager] currentOrders] objectAtIndex:selectedIndex];
//    [dict setObject:pickerData[row] forKey:@"quantity"];
//    [self.navigationController setNavigationBarHidden:YES];
//    [self.tableView reloadData];
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemsAtRows:(NSArray *)rows {
    for (NSNumber *n in rows) {
        NSInteger row = [n integerValue];
        NSLog(@"%@ is chosen!", ppickerData[row]);
    }
}

- (void)czpickerViewDidClickCancelButton:(CZPickerView *)pickerView {
    //[self.navigationController setNavigationBarHidden:YES];
    NSLog(@"Canceled.");
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
        BOOL isLastField = YES;
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
