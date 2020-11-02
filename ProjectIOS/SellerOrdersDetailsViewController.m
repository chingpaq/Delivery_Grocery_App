//
//  SellerOrdersDetailsViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 25/03/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import "SellerOrdersDetailsViewController.h"

@interface SellerOrdersDetailsViewController ()

@end

@implementation SellerOrdersDetailsViewController
NSArray *orderSItemsArray;
int selectedna;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.cancelButton.hidden=YES;
    
    
    
    self.tableviewConstraint.constant=70;
    if ([[self.proposalDict objectForKey:@"status"] isEqualToString:@"Rejected"]||[[self.proposalDict objectForKey:@"status"] isEqualToString:@"Closed"]||[[self.proposalDict objectForKey:@"bidders"]containsObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"sellerId"]]){
        self.tableviewConstraint.constant=0;
        self.cancelButton.hidden=YES;
        self.acceptButton.hidden=YES;
        self.oMWButton.hidden=YES;
    }else{
        self.cancelButton.hidden=YES;
        self.acceptButton.hidden=NO;
        self.oMWButton.hidden=YES;
    }
    if ([[self.proposalDict objectForKey:@"status"] isEqualToString:@"Pending"]){
        self.tableviewConstraint.constant=0;
        self.cancelButton.hidden=YES;
        self.acceptButton.hidden=YES;
        self.oMWButton.hidden=YES;
    }
    if ([[self.proposalDict objectForKey:@"status"] isEqualToString:@"Accepted"]){
        self.cancelButton.hidden=YES;
        self.acceptButton.hidden=YES;
        self.oMWButton.hidden=NO;
    }
    if ([[self.proposalDict objectForKey:@"status"] isEqualToString:@"On The Way"]){
        self.cancelButton.hidden=YES;
        self.acceptButton.hidden=YES;
        self.oMWButton.hidden=YES;
    }
    
    Buyer *buyerDetails=[API getBuyer:[self.proposalDict objectForKey:@"buyerId"]];
    if (buyerDetails==nil && self.proposalDict!=nil){
        [API getBuyerDetails:[self.proposalDict objectForKey:@"buyerId"]
                   eventType:FIRDataEventTypeValue
                     success:^(NSDictionary *dict){
                         Buyer *buyerDetails=[API getBuyer:[self.proposalDict objectForKey:@"buyerId"]];
                         [self.proposalDict setObject:@{@"name":buyerDetails.name, @"firstName":buyerDetails.firstName,@"lastName":buyerDetails.lastName,@"mobileNumber":buyerDetails.mobileNumber,@"buyerId":buyerDetails.buyerId} forKey:@"buyer"];
                         [self.tableView reloadData];
                         NSLog(@"%@",dict);
                     } failure:^(NSString *message) {
                         NSLog(@"Fail");
                     }];
    }else if (self.proposalDict!=nil){
        [self.proposalDict setObject:@{@"name":buyerDetails.name, @"firstName":buyerDetails.firstName,@"lastName":buyerDetails.lastName,@"mobileNumber":buyerDetails.mobileNumber,@"buyerId":buyerDetails.buyerId} forKey:@"buyer"];
        //[self.tableView reloadData];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    //[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -TableView Methods and Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==3){
        if ([self.proposalDict objectForKey:@"salesItem"]){
            orderSItemsArray = [self.proposalDict objectForKey:@"salesItem"];
        }else{
            orderSItemsArray = [self.proposalDict objectForKey:@"orderItems"];
        }
        return orderSItemsArray.count;
    }
    return 1;
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==1){
        return 230;
        
    }else if (indexPath.section==0){
        return 80;
    }
    //
    //    return 80;
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.textLabel.textColor = [UIColor blackColor];
        
    }
    
    if (indexPath.section==0){
        cell.textLabel.font=[UIFont fontWithName:@"Junegull-Regular" size:17.0f];
        cell.textLabel.textColor=[UIColor colorWithHexString:@"#F78320"];
        NSString *status =[self.proposalDict objectForKey:@"status"];
        if ([status isEqualToString:@"Pending"]){
            status = @"New bid";
        }
        
        NSDate *date;
        if ([self.proposalDict objectForKey:@"salesItem"]){
            NSDictionary *buyer = [self.proposalDict objectForKey:@"buyer"];
            date = [[NSDate alloc]initWithTimeIntervalSince1970:[[self.proposalDict objectForKey:@"completionDate"] integerValue]];
            cell.detailTextLabel.text=[NSString stringWithFormat:@"Delivery Date: %@",[NSDateFormatter localizedStringFromDate:date
                                                                                                                     dateStyle:NSDateFormatterMediumStyle
                                                                                                                     timeStyle:NSDateFormatterMediumStyle]];
            
            if ([[self.proposalDict objectForKey:@"status"] isEqualToString:@"Closed"]){
                cell.textLabel.text = [NSString stringWithFormat:@"Sold to %@ for %@ %@",[buyer objectForKey:@"name"],[self.proposalDict objectForKey:@"currency"],[self.proposalDict objectForKey:@"totalPrice"]];
            }else{
                cell.textLabel.text = [NSString stringWithFormat:@"Sell to %@ for %@ %@",[buyer objectForKey:@"name"],[self.proposalDict objectForKey:@"currency"],[self.proposalDict objectForKey:@"totalPrice"]];
                date = [[NSDate alloc]initWithTimeIntervalSince1970:[[self.proposalDict objectForKey:@"orderDate"] integerValue]];
                cell.detailTextLabel.text=[NSString stringWithFormat:@"Order Date: %@",[NSDateFormatter localizedStringFromDate:date
                                                                                                                         dateStyle:NSDateFormatterMediumStyle
                                                                                                                         timeStyle:NSDateFormatterMediumStyle]];
            }
        }else{
            date = [[NSDate alloc]initWithTimeIntervalSince1970:[[self.proposalDict objectForKey:@"orderDate"] integerValue]];
            cell.detailTextLabel.text=[NSString stringWithFormat:@"Order Date & Time: %@",[NSDateFormatter localizedStringFromDate:date
                                                                                                                         dateStyle:NSDateFormatterMediumStyle
                                                                                                                         timeStyle:NSDateFormatterMediumStyle]];
            float sum =0;
            for (NSDictionary *dict in orderSItemsArray){
                sum = sum + ([[dict objectForKey:@"buyingPrice"] floatValue]*[[dict objectForKey:@"quantity"]intValue]);
            }
            //float sum = [[orderSItemsArray valueForKeyPath: @"@sum.buyingPrice"] floatValue];
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@ - Your Offer %@ %.2f",status,[self.proposalDict objectForKey:@"currency"],sum];
        }
        
        
        
        return cell;
        
    }else if (indexPath.section==1){
        static NSString *cellIdentifier = @"CustomTableCellSellersTableViewCell";
        CustomTableCellSellersTableViewCell *scell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (scell == nil) {
            [self.tableView registerNib:[UINib nibWithNibName:@"CustomTableCellSellersTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
            scell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
        }
        scell.userInteractionEnabled=NO;
        [scell setSingleLocation:self.proposalDict];
        return scell;
        
        
        
    }else if (indexPath.section==2){
        cell.textLabel.text = [self.proposalDict objectForKey:@"buyerComment"];
        cell.detailTextLabel.text = @"Buyer Notes";
        cell.textLabel.font=[UIFont fontWithName:@"SEOptimistLight" size:15.0f];
        return cell;
    }else if (indexPath.section==3){
        
        NSDictionary *dict = [orderSItemsArray objectAtIndex:indexPath.row];
        cell.textLabel.font=[UIFont fontWithName:@"SEOptimistLight" size:15.0f];
        
        if ([[dict objectForKey:@"productId"] isEqualToString:@"CFEE"]){
            cell.textLabel.text = @"Convinience Fee";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Price: %@ %@",[dict objectForKey:@"currency"],[dict objectForKey:@"buyingPrice"]];
        }else{
            NSDictionary *productDetail= [[API productsDetailArrayUsingSearch:[NSString stringWithFormat:@"productId contains '%@'", [dict objectForKey:@"productId"]]] firstObject];
            cell.textLabel.text =[NSString stringWithFormat:@"%@",[productDetail objectForKey:@"productName"]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Price: %@ %@ Qty: %@",[dict objectForKey:@"currency"],[dict objectForKey:@"buyingPrice"],[dict objectForKey:@"quantity"]];
        }
        return cell;
    }
    return nil;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section==0 || section==3-1){
        return 1;
    }else if(section==2){
        return 10;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section!=3 )return;
    if ([[self.proposalDict objectForKey:@"bidders"]containsObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"sellerId"]] || [[self.proposalDict objectForKey:@"sellerId"] isEqualToString:[FIRAuth auth].currentUser.uid]   ){
        return;
    }
    
    switch (indexPath.row) {
        default:
        {
            //            NSDictionary *dict = [self.proposalsArray objectAtIndex:indexPath.row];
            NSDictionary *dict = [orderSItemsArray objectAtIndex:indexPath.row];
            if ([[dict objectForKey:@"productId"] isEqualToString:@"CFEE"]){
                return;
            }
            selectedna=indexPath.row;
            [self performSegueWithIdentifier:@"showProductDetailsSegue" sender:dict];
        }
            break;
    }
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showProductDetailsSegue"]) {
        
        NSMutableDictionary *productDetail= [[[API productsDetailArrayUsingSearch:[NSString stringWithFormat:@"productId contains '%@'", [sender objectForKey:@"productId"]]] firstObject] mutableCopy];
        self.productViewController = [segue destinationViewController];
        if (productDetail!=nil){
            [productDetail setObject:[sender objectForKey:@"buyingPrice"] forKey:@"buyingPrice"];
            [productDetail setObject:[sender objectForKey:@"currency"] forKey:@"currency"];
            [productDetail setObject:[sender objectForKey:@"quantity"] forKey:@"quantity"];
            self.productViewController.productDict = productDetail;
        }else{
            self.productViewController.productDict =sender;
        }
        self.productViewController.delegate=self;
        
        [self.productViewController setCartDetails:sender];
    }else if ([segue.identifier isEqualToString:@"SellerOrdersMapViewControllerSegue"]) {
        self.sellerOrdersMapViewController = [segue destinationViewController];
        self.sellerOrdersMapViewController.orderDict= sender;
        self.sellerOrdersMapViewController.delegate=self;
    }
    
}

- (IBAction)acceptButtonPressed:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults objectForKey:@"credits"] floatValue]>50){
        [self performSegueWithIdentifier:@"SellerOrdersMapViewControllerSegue" sender:self.proposalDict];
    }else{
        [AZNotification showNotificationWithTitle:@"Don't have enough credits.Reload"  controller:self notificationType:AZNotificationTypeWarning shouldShowNotificationUnderNavigationBar:YES];
    }
    
    
    
}
- (IBAction)otwButtonPressed:(id)sender {
    
    [self.delegate oTWProposal:self.proposalDict];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)cancelButtonPressed:(id)sender {
    [self.delegate cancelProposal:self.proposalDict];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)changeCartDetails:(id)sender{
    NSMutableDictionary *dict = [orderSItemsArray objectAtIndex:selectedna];
    [dict setObject:[sender objectForKey:@"newQty"] forKey:@"quantity"];
    [dict setObject:[sender objectForKey:@"newBuyingPrice"] forKey:@"buyingPrice"];
    [dict setObject:[sender objectForKey:@"productId"] forKey:@"productId"];
    [dict setObject:[sender objectForKey:@"currency"] forKey:@"currency"];
    [dict setObject:[sender objectForKey:@"uom"] forKey:@"buyingUOM"];
    [self.tableView reloadData];
    
}
#pragma mark - SellerOrdersMapView Delegate
-(void)proposalsSent:(id)sender{
    [self.navigationController popViewControllerAnimated:NO];
}
@end

