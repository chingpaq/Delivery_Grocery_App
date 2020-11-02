//
//  ProposalDetailsViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 18/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "ProposalDetailsViewController.h"

@interface ProposalDetailsViewController ()

@end

@implementation ProposalDetailsViewController
NSArray *orderItemsArray;
int selected;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.cancelButton.hidden=YES;
    self.tableViewHeight.constant=153;
    if ([[self.proposalDict objectForKey:@"status"] isEqualToString:@"Accepted"] || [[self.proposalDict objectForKey:@"status"] isEqualToString:@"Rejected"]){
        self.tableViewHeight.constant=0;
        self.acceptButton.hidden=YES;
        self.rejectButton.hidden=YES;
    }
    if ([[self.proposalDict objectForKey:@"status"] isEqualToString:@"Accepted"]){
        self.cancelButton.hidden=YES;
    }
    if ([[self.proposalDict objectForKey:@"status"] isEqualToString:@"Completed"] || [[self.proposalDict objectForKey:@"status"] isEqualToString:@"Closed"] || [[self.proposalDict objectForKey:@"status"] isEqualToString:@"Cancelled Buyer"]){
        self.tableViewHeight.constant=0;
        self.cancelButton.hidden=YES;
        self.acceptButton.hidden=YES;
        self.rejectButton.hidden=YES;
    }
    if ([[self.proposalDict objectForKey:@"status"] isEqualToString:@"On The Way"]){
        self.tableViewHeight.constant=0;
        self.cancelButton.hidden=YES;
        self.acceptButton.hidden=YES;
        self.rejectButton.hidden=YES;
    }
    if ([[self.proposalDict objectForKey:@"status"] isEqualToString:@"On-Hold"]){
        self.tableViewHeight.constant=0;
        self.cancelButton.hidden=YES;
        self.acceptButton.hidden=YES;
        self.rejectButton.hidden=YES;
    }
    
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    Seller *seller=[API getSeller:[self.proposalDict objectForKey:@"sellerId"]];
    
    if (seller==nil){
        [API getSellerDetails:[self.proposalDict objectForKey:@"sellerId"]
                    eventType:FIRDataEventTypeValue
                      success:^(NSDictionary *dict){
                          if (dict){
                              Seller *seller=[API getSeller:[self.proposalDict objectForKey:@"sellerId"]];
                              if (seller){
                                  [self.proposalDict setObject:seller forKey:@"seller"];
                                  [self.tableView reloadData];
                              }
                          }
                      } failure:^(NSString *message) {
                          NSLog(@"Fail");
                      }];
    }else{
        [self.proposalDict setObject:seller forKey:@"seller"];
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==4){
        if ([self.proposalDict objectForKey:@"salesItem"]){
            orderItemsArray = [self.proposalDict objectForKey:@"salesItem"];
        }else{
            orderItemsArray = [self.proposalDict objectForKey:@"orderItems"];
        }
        return orderItemsArray.count;
        //return orderItemsArray.count;
        
    }
    return 1;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==1){
        if ([[self.proposalDict objectForKey:@"status"] isEqualToString:@"Accepted"]||[[self.proposalDict objectForKey:@"status"] isEqualToString:@"On The Way"]||[[self.proposalDict objectForKey:@"status"] isEqualToString:@"Completed"]||[[self.proposalDict objectForKey:@"status"] isEqualToString:@"Closed"]){
            return 230;
        }
    }else if (indexPath.section==0){
        return 80;
    }
    return 60;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section==0 || section==4-1){
        return 1;
    }
    return 0;
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
        
        
        if ([[self.proposalDict objectForKey:@"status"] isEqualToString:@"Accepted"]||[[self.proposalDict objectForKey:@"status"] isEqualToString:@"On The Way"]||[[self.proposalDict objectForKey:@"status"] isEqualToString:@"Completed"]||[[self.proposalDict objectForKey:@"status"] isEqualToString:@"Closed"]){
            
            Seller *seller=[self.proposalDict objectForKey:@"seller"];
            if (seller){
            cell.textLabel.text =[NSString stringWithFormat:@"Seller %@ (%@)", seller.name,[self.proposalDict objectForKey:@"status"]];
            }else{
                cell.textLabel.text = @"Seller Info Unavailable";
            }
            if ([self.proposalDict objectForKey:@"sellerRatings"]!=nil){
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                seller.ratings = [NSString stringWithFormat:@"%@",[self.proposalDict objectForKey:@"sellerRatings"]];
                [realm commitWriteTransaction];
            }
            
            
        }else{
            cell.textLabel.text =[NSString stringWithFormat:@"Offer from a %@-star Seller", [self.proposalDict objectForKey:@"sellerRatings"]];
            
            
        }
        
        if ([[self.proposalDict objectForKey:@"status"] isEqualToString:@"Completed"]|| [[self.proposalDict objectForKey:@"status"] isEqualToString:@"Closed"]){
            NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:[[self.proposalDict objectForKey:@"completionDate"] integerValue]];
            cell.detailTextLabel.text=[NSString stringWithFormat:@"Delivered on: %@",[NSDateFormatter localizedStringFromDate:date
                                                                                                                    dateStyle:NSDateFormatterMediumStyle
                                                                                                                    timeStyle:NSDateFormatterMediumStyle]];
        }else{
            cell.detailTextLabel.text=[NSString stringWithFormat:@"Estimate time to deliver: %@",[self.proposalDict objectForKey:@"ETA"]];
        }
        
        return cell;
    }else if (indexPath.section==1){
        
        static NSString *cellIdentifier = @"CustomTableCellSellersTableViewCell";
        if ([[self.proposalDict objectForKey:@"status"] isEqualToString:@"Accepted"]||[[self.proposalDict objectForKey:@"status"] isEqualToString:@"On The Way"]||[[self.proposalDict objectForKey:@"status"] isEqualToString:@"Completed"]||[[self.proposalDict objectForKey:@"status"] isEqualToString:@"Closed"]){
            
            CustomTableCellSellersTableViewCell *scell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (scell == nil) {
                [self.tableView registerNib:[UINib nibWithNibName:@"CustomTableCellSellersTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
                scell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                
            }
            scell.userInteractionEnabled=NO;
            [scell setSingleLocation:self.proposalDict];
            return scell;
        }else{
            cellIdentifier = @"Cellother";
            UITableViewCell *cellother = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cellother == nil) {
                cellother = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
                cellother.textLabel.textColor = [UIColor blackColor];
                
                
            }
            
            cellother.textLabel.text = [self.proposalDict objectForKey:@"comments"];
            cellother.detailTextLabel.text = @"Seller Notes";
            
            cellother.textLabel.font=[UIFont fontWithName:@"SEOptimistLight" size:15.0f];
            return cellother;
        }
        
        
    }else if (indexPath.section==2){
        
        cell.textLabel.text = [self.proposalDict objectForKey:@"buyerComment"];
        cell.detailTextLabel.text = @"Your Notes";
        cell.textLabel.font=[UIFont fontWithName:@"SEOptimistLight" size:15.0f];
        return cell;
        
    }else if (indexPath.section==3){
        cell.textLabel.text = [NSString stringWithFormat:@"Amount %@%@", [self.proposalDict objectForKey:@"currency"],[self.proposalDict objectForKey:@"totalPrice"]];
        cell.detailTextLabel.text = @"Total Price";
        cell.textLabel.font=[UIFont fontWithName:@"SEOptimistLight" size:15.0f];
        return cell;
        
    }else if (indexPath.section==4){
        NSDictionary *dict = [orderItemsArray objectAtIndex:indexPath.row];
        
        cell.textLabel.font=[UIFont fontWithName:@"SEOptimistLight" size:15.0f];
        if ([[dict objectForKey:@"productId"] isEqualToString:@"CFEE"]){
            cell.textLabel.text= @"Convinience Fee";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Price: %@ %@",[dict objectForKey:@"currency"],[dict objectForKey:@"buyingPrice"]];
        }else{
            NSDictionary *productDetail= [[API productsDetailArrayUsingSearch:[NSString stringWithFormat:@"productId contains '%@'", [dict objectForKey:@"productId"]]] firstObject];
            cell.textLabel.text=[NSString stringWithFormat:@"%@",[productDetail objectForKey:@"productName"]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Price: %@ %@ Qty: %@",[dict objectForKey:@"currency"],[dict objectForKey:@"buyingPrice"],[dict objectForKey:@"quantity"]];
        }
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

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
    }
    
}

- (IBAction)acceptButtonPressed:(id)sender {
    [self.delegate acceptProposal:self.proposalDict];
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (IBAction)rejectButtonPressed:(id)sender {
    
    [self.delegate rejectProposal:self.proposalDict];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)cancelButtonPressed:(id)sender {
    [self.delegate cancelProposal:self.proposalDict];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)changeCartDetails:(id)sender{
    NSMutableDictionary *dict = [orderItemsArray objectAtIndex:selected];
    [dict setObject:[sender objectForKey:@"newQty"] forKey:@"quantity"];
    [dict setObject:[sender objectForKey:@"newBuyingPrice"] forKey:@"buyingPrice"];
    [self.tableView reloadData];
    
}
@end

