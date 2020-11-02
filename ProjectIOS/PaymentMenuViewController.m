//
//  PaymentMenuViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 11/11/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "PaymentMenuViewController.h"


@interface PaymentMenuViewController ()

@end

@implementation PaymentMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    NSData *customerData = [[NSUserDefaults standardUserDefaults] objectForKey:@"PayMayaSDKCustomer"];
    PMDCustomer *customer = [NSKeyedUnarchiver unarchiveObjectWithData:customerData];
    self.customerID = customer.identifier;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"PayMayaCustomerCard"]) {
        NSData *customerData = [[NSUserDefaults standardUserDefaults] objectForKey:@"PayMayaCustomerCard"];
        self.card = [NSKeyedUnarchiver unarchiveObjectWithData:customerData];
    }else{
        self.card= nil;
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
}
-(void)viewDidAppear:(BOOL)animated{
    [self refreshCards];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

- (void)refreshCards
{
    [[API sharedManager] getCreditCardToken:^(id response) {
        self.card= response;
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    } failureBlock:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] isEqualToString:@"Main"]){
        return 1;
    }else{
        return 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"PaymentMethodsTableViewCell";
    PaymentMethodsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil){
        [self.tableView registerNib:[UINib nibWithNibName:@"PaymentMethodsTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    }
    

    cell.paymentImage.hidden=YES;
    cell.textLabel.font=[UIFont fontWithName:@"SEOptimistLight" size:15.0f];;
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Cash";
            cell.paymentImage.image =[UIImage imageNamed:@"money"];
            break;
        case 1:
        {
            
            if (self.card!=nil){
                cell.mainPaymentLabel.text = [NSString stringWithFormat:@"**** %@",self.card.maskedPan];
                cell.textLabel.text = @"";
                if ([self.card.type isEqualToString:@"master-card"]){
                    cell.paymentImage.image=[UIImage imageNamed:@"mastercard-logo"];
                }else{
                    cell.paymentImage.image=[UIImage imageNamed:@"visa-logo"];
                }
                cell.paymentImage.hidden=NO;
            }else{
                cell.textLabel.text = @"Credit Card";
                cell.hidden=YES;
            }
            cell.hidden=YES;
        }
            break;
        case 2:
            cell.textLabel.text = @"Add Payment Method";
            cell.textLabel.font=[UIFont fontWithName:@"SEOptimistLight" size:15.0f];;
            cell.paymentImage.hidden=YES;
            cell.hidden=YES;
            break;
        case 3:
            cell.textLabel.text = @"Buy Credits";
            cell.textLabel.font=[UIFont fontWithName:@"SEOptimistLight" size:15.0f];;
            cell.paymentImage.hidden=YES;
            break;
        case 4:
            cell.textLabel.text = @"My Earnings";
            cell.textLabel.font=[UIFont fontWithName:@"SEOptimistLight" size:15.0f];;
            cell.paymentImage.hidden=YES;
            break;
        default:
            cell.textLabel.text = @"Hello world";
            break;
    }
    
    
    
    return cell;
}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    static NSString *HeaderCellIdentifier = @"Header";
//
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HeaderCellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HeaderCellIdentifier];
//        cell.backgroundColor = [UIColor grayColor];
//        cell.backgroundColor=[UIColor colorWithRed:56.0/255 green:185.0/255 blue:158.0/255 alpha:1];
//        //cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
//        cell.textLabel.textColor = [UIColor whiteColor];
//    }
//
//    // Configure the cell title etc
//    //[self configureHeaderCell:cell inSection:section];
//
//    if (section==0)
//        cell.textLabel.text=@"Payment Methods";
//    else if (section==1){
//    }
//    else{
//    }
//
//    return cell;
//}
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ((self.card==nil && indexPath.row==1) || indexPath.row==1 || indexPath.row==2){
        return 0;
    }
    
    return 65;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==1){
        return 0;
    }else{
        return 0;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 3:
            [self performSegueWithIdentifier:@"createLoadSegue" sender:nil];

            break;
        case 0:
            [self performSegueWithIdentifier:@"showCashDetailsSegue" sender:[NSNumber numberWithInt:indexPath.row]];
            break;
            
        case 4:
            [self performSegueWithIdentifier:@"showWithdrawalSegue" sender:[NSNumber numberWithInt:indexPath.row]];
            break;
            
        default:
            [self performSegueWithIdentifier:@"showPaymentSelectionSegue" sender:[NSNumber numberWithInt:indexPath.row]];
            //
            break;
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPaymentSelectionSegue"]) {
        self.paymentSelectionController = [segue destinationViewController];
        self.paymentSelectionController.card=self.card;
        self.paymentSelectionController.type = [sender intValue];
        self.paymentSelectionController.apiManager = [[API sharedManager] apiManager];
        self.paymentSelectionController.customerID= self.customerID;
    }
    
}


@end
