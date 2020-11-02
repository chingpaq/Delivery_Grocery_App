//
//  PaymentCreateLoadViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 15/05/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import "PaymentCreateLoadViewController.h"

@interface PaymentCreateLoadViewController ()

@end

@implementation PaymentCreateLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    //self.sellerArray= [[NSMutableArray alloc]init];
    [API getAllSellers:@"All"
                  success:^(NSArray *array){
                      
                      self.sellerArray = [[NSMutableArray alloc]initWithArray:array];
                      [self.tableView reloadData];
                  } failure:^(NSString *message) {
                      NSLog(@"Fail");
                  }];
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
    
}- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        //cell.backgroundColor = [UIColor offWhite];
        cell.layer.borderColor = [[UIColor whiteColor] CGColor];
        cell.layer.borderWidth = 3;
        
        //cell.selectedBackgroundView = [[UIView alloc] init];
    }
    NSDictionary *dict = [self.sellerArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"firstName"],[dict objectForKey:@"lastName"]];
        cell.textLabel.font=[UIFont fontWithName:@"SEOptimistLight" size:15.0f];
        return cell;
        
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = [self.sellerArray objectAtIndex:indexPath.row];
    self.sellerTextBox.text = [NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"firstName"],[dict objectForKey:@"lastName"]];
    self.sellerDict= [dict mutableCopy];
    
//    switch (indexPath.row) {
//        default:
//        {
//
//        }
//            break;
//    }
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.sellerArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (IBAction)createLoadPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"e-Utos" message:@"Not part of specs. For test purposes only!" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    if ([self.amountTextBox.text floatValue]>0){
        [API addCredits:@{@"amount": self.amountTextBox.text,
                          @"code": @"-",
                          @"paymentMethod": @"Cash",
                          @"paidBy": [self.sellerDict objectForKey:@"sellerId"],
                          @"type" : @"Topup"
                          }
                success:^(){
                    [self.navigationController popViewControllerAnimated:NO];
                } failure:^(NSString *message) {
                    NSLog(@"Fail");
                }];

    }else{
        
    }
    
}
- (IBAction)registerLoadPressed:(id)sender {
    if ([self.cardPinNumberTextField.text isEqualToString:@""] || [self.cardLoadNumberTextField.text isEqualToString:@""]){
        return;
    }
    
    [API registerLoad:nil cardCode:self.cardLoadNumberTextField.text cardPin:self.cardPinNumberTextField.text
              success:^(NSDictionary *dict){
                  [AZNotification showNotificationWithTitle:[NSString stringWithFormat:@"You have successfully loaded %@", @"PHP 500.00"] controller:self notificationType:AZNotificationTypeSuccess shouldShowNotificationUnderNavigationBar:NO];
                  self.cardPinNumberTextField.text =@"";
                  self.cardLoadNumberTextField.text=@"";
              } failure:^(NSString *message) {
                  NSLog(@"5785646476");
                  [AZNotification showNotificationWithTitle:message controller:self notificationType:AZNotificationTypeError shouldShowNotificationUnderNavigationBar:NO];
              }];
}


-(void)temp{
    
}



#pragma mark - segue
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"sellerOfferSegue"]) {
//
//
//        self.productViewController = [segue destinationViewController];
//        NSDictionary *productDetail= [[API productsDetailArrayUsingSearch:[NSString stringWithFormat:@"productName contains '%@'", [sender objectForKey:@"productName"]]] firstObject];
//
//        if (productDetail!=nil){
//            self.productViewController.productDict = [productDetail mutableCopy];
//        }else{
//            self.productViewController.productDict =sender;
//        }
//        self.productViewController.delegate=self;
//
//
//    }
//}

@end
