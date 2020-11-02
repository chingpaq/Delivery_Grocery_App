//
//  ProposalsViewController.m
//  
//
//  Created by Manuel B Parungao Jr on 18/10/2017.
//

#import "ProposalsViewController.h"

@interface ProposalsViewController ()

@end

@implementation ProposalsViewController
BOOL proposalsVCloaded;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    // Do any additional setup after loading the view.
    [self getSalesProposal];
    NSDictionary *normalAttributes = @{
                                       NSFontAttributeName:[UIFont fontWithName:@"Junegull-Regular" size:15.0f],
                                       NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                       };
    [[UISegmentedControl appearance] setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithHexString:@"00a54F"]];

    [self startMonitor];
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [self.tableView reloadData];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startMonitor{
    
    [API monitorActiveOrders:[FIRAuth auth].currentUser.uid
                   queryType:FIRDataEventTypeChildChanged
                     success:^(NSDictionary*dict){
                         NSLog(@"%@",dict);
                         NSDictionary *found =[[[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId CONTAINS[cd]%@", [dict objectForKey:@"orderId"]]] firstObject];
                         if (found!=nil ){
                             [[[Orders sharedManager]activeOrders] removeObject:found];
                         }
                         [[[Orders sharedManager]activeOrders] addObject:dict];
                         [[DataSingletons sharedManager]setReceivedOffer:YES];
                         if ([[dict objectForKey:@"status"] isEqualToString:@"Accepted"]){
                             
                             if(![[[Orders sharedManager]sellersWithActiveOrders] containsObject:[dict objectForKey:@"sellerId"]]){
                                 [[[Orders sharedManager]sellersWithActiveOrders] addObject:[dict objectForKey:@"sellerId"]];
                             }
                         }else if ([[dict objectForKey:@"status"] isEqualToString:@"Completed"]){
                             [[NSNotificationCenter defaultCenter] postNotificationName:@"CompletedOrder" object:dict];
                         }else if ([[dict objectForKey:@"status"] isEqualToString:@"On The Way"]){
                             [self performSegueWithIdentifier:@"orderPopOverSegue" sender:dict];
                         }
                         [self.tableView reloadData];
                     } failure:^(NSString *message) {
                         NSLog(@"Fail Get Orders");
                     }];
    
    [API monitorActiveOrders:[FIRAuth auth].currentUser.uid
                   queryType:FIRDataEventTypeChildRemoved
                     success:^(NSDictionary*dict){
                         NSLog(@"%@",dict);
                         NSDictionary *found =[[[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId CONTAINS[cd]%@", [dict objectForKey:@"orderId"]]] firstObject];
                         if (found!=nil ){
                             [[[Orders sharedManager]activeOrders] removeObject:found];
                         }
                         [self.tableView reloadData];
                     } failure:^(NSString *message) {
                         NSLog(@"Fail Get Orders");
                     }];
    
    
}
- (IBAction)segmentValueChanged:(id)sender {
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [self getSalesProposal];
            break;
        case 1:
            [self getCompletedOrders];
            break;
        default:
            break;
    }
    
}

-(void)getSalesProposal{
    self.proposalsArray= [[NSMutableArray alloc]init];
    [self.tableView reloadData];

    [API getSalesProposals:@"Multiple" eventType:FIRDataEventTypeChildAdded
                   success:^(NSArray *array){
                       for (NSMutableIndexSet *dict in array){
                           if (![self.proposalsArray containsObject:dict]){
                               NSDictionary *temp = (NSDictionary*)(dict);
                               NSDictionary *found =[[[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId CONTAINS[cd]%@", [temp objectForKey:@"orderId"]]] firstObject];
                               // condition here is to check if there are undeleted offers with closed orders
                               if (!found){
                                   //[self.proposalsArray addObject:dict];
                               }else{
                                   if (!([[found objectForKey:@"status"] isEqualToString:@"Closed"] || [[found objectForKey:@"status"] isEqualToString:@"Expired"])){
                                       [self.proposalsArray addObject:dict];
                                   }else{
                                       [API deleteProposals:[found objectForKey:@"orderId"]
                                                    success:^(NSDictionary *dict){
                                                        NSLog(@"delete proposal Sucess");
                                                        
                                                    } failure:^(NSString *message) {
                                                        NSLog(@"Fail");
                                                    }];
                                   }
                               }
                               
                               
                           }
                       }
                       
                       NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderDate" ascending:FALSE];
                       [self.proposalsArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                       
                       [self.tableView reloadData];
                   } failure:^(NSString *message) {}];
    [API getSalesProposals:@"Multiple" eventType:FIRDataEventTypeChildRemoved
                   success:^(NSArray *array){
                       NSDictionary *dict = [array firstObject];

                       self.proposalsArray = [[NSMutableArray alloc]initWithArray:[self.proposalsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(proposalId CONTAINS[cd] %@)",[dict objectForKey:@"proposalId"]]]];
                       
                       NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderDate" ascending:FALSE];
                       [self.proposalsArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                       
                       [self.tableView reloadData];
                   } failure:^(NSString *message) {}];
    [API getSalesProposals:@"Multiple" eventType:FIRDataEventTypeChildChanged
                   success:^(NSArray *array){
                       NSDictionary *dict = [array firstObject];

                       self.proposalsArray = [[NSMutableArray alloc]initWithArray:[self.proposalsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(proposalId CONTAINS[cd] %@)",[dict objectForKey:@"proposalId"]]]];

                       [self.proposalsArray addObject:dict];
                       
                       NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderDate" ascending:FALSE];
                       [self.proposalsArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                       
                       [self.tableView reloadData];
                   } failure:^(NSString *message) {}];
}

-(void)getCompletedOrders{
    self.completedArray= [[NSMutableArray alloc]initWithArray:[[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(status CONTAINS[cd] %@ || status CONTAINS[cd] %@)", @"Completed",@"Closed"]]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completionDate" ascending:FALSE];
    [self.completedArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.segmentedControl.selectedSegmentIndex==0){
        NSArray *ar=[self.proposalsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(status CONTAINS[cd] %@)",@"Pending"]];
        
        if (ar.count>0){
            self.tabBarItem.badgeValue= [NSString stringWithFormat:@"%lu",(unsigned long)ar.count];
            self.tabBarItem.badgeColor = [UIColor redColor];
        }else{
            self.tabBarItem.badgeValue= @"";
            self.tabBarItem.badgeColor = [UIColor clearColor];
        }
        
        if (self.proposalsArray.count>10){
            //[SVProgressHUD show];
        }
        
        return self.proposalsArray.count;
    }
    else {
        if (self.completedArray.count>10){
            //[SVProgressHUD show];
        }
        return self.completedArray.count;}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CustomOffersMainCell";
    CustomOffersMainCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil){
        [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
    }
    

    NSString *mainLabel;
    NSString *detailLabel;
    NSString *secondDetailLabel;
    NSString *status;
    NSDictionary*itemDict;
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:{
            if (self.proposalsArray.count-1==indexPath.row){
                //[SVProgressHUD dismiss];
            }
            
            NSDictionary *dict = [self.proposalsArray objectAtIndex:indexPath.row];
            detailLabel=[NSString stringWithFormat:@"Amount: %@ %@",[dict objectForKey:@"currency"],[dict objectForKey:@"totalPrice"]];
            itemDict=[[dict objectForKey:@"orderItems"] firstObject];
            
            
            status=[dict objectForKey:@"status"];
            if ([status isEqualToString:@"Accepted"] || [status isEqualToString:@"On The Way"]){
                Seller *seller=[API getSeller:[dict objectForKey:@"sellerId"]];
                mainLabel =[NSString stringWithFormat:@"Seller %@",seller.name];
            }
            if ([status isEqualToString:@"Pending"]){
                status = @"See Offer";
            }
            
            detailLabel=[NSString stringWithFormat:@"Offer: %@ %@ (%@)",[dict objectForKey:@"currency"],[dict objectForKey:@"totalPrice"],[dict objectForKey:@"paymentMode"]];
            secondDetailLabel=[NSString stringWithFormat:@"Delivery in %@", [dict objectForKey:@"ETA"] ];
            
            //cell.statusLabel.hidden=YES;
            if ([status isEqualToString:@"See Offer"]|| [status isEqualToString:@"Rejected"]|| [status isEqualToString:@"Cancelled By Buyer"]){
                for (NSDictionary *productDict in [dict objectForKey:@"orderItems"]){
                    NSDictionary *productDetail= [[API productsDetailArrayUsingSearch:[NSString stringWithFormat:@"productId contains '%@'", [productDict objectForKey:@"productId"]]] firstObject];
                    if (productDetail!=nil){
                        if (mainLabel==nil){
                            mainLabel = [NSString stringWithFormat:@"%@",[productDetail objectForKey:@"productName"]];
                        }else{
                            mainLabel = [NSString stringWithFormat:@"%@ %@",mainLabel, [productDetail objectForKey:@"productName"]];
                        }
                    }else{
                        if (![[productDict objectForKey:@"productId"] isEqualToString:@"CFEE"]){
                            mainLabel =@"Product info not available";
                            [API getProductById:[productDict objectForKey:@"productId"]
                                        success:^(NSDictionary*dict){
                                            
                                        } failure:^(NSString *message) {
                                            NSLog(@"Fail");
                                        }];
                        }
                    }
                }
            }
        }
            break;
        case 1:{
            if (self.completedArray.count-1==indexPath.row){
//                [SVProgressHUD dismiss];
            }
            NSDictionary *dict = [self.completedArray objectAtIndex:indexPath.row];
            detailLabel=[NSString stringWithFormat:@"Amount: %@ %@ (%@)",[dict objectForKey:@"currency"],[dict objectForKey:@"totalPrice"],[dict objectForKey:@"paymentMode"]];
            itemDict=[[dict objectForKey:@"orderItems"] firstObject];
            for (NSDictionary *productDict in [dict objectForKey:@"salesItem"]){
                NSDictionary *productDetail= [[API productsDetailArrayUsingSearch:[NSString stringWithFormat:@"productId contains '%@'", [productDict objectForKey:@"productId"]]] firstObject];
                if (productDetail!=nil){
                    if (mainLabel==nil){
                        mainLabel = [NSString stringWithFormat:@"%@",[productDetail objectForKey:@"productName"]];
                    }else{
                        mainLabel = [NSString stringWithFormat:@"%@ %@",mainLabel, [productDetail objectForKey:@"productName"]];
                    }
                }else{
                    if (![[productDict objectForKey:@"productId"] isEqualToString:@"CFEE"]){
                        mainLabel =@"Product info not available";
                        [API getProductById:[productDict objectForKey:@"productId"]
                         success:^(NSDictionary*dict){
                            
                        } failure:^(NSString *message) {
                            NSLog(@"Fail");
                        }];
                    }
                }
            }
            
            
            
            NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:[[dict objectForKey:@"completionDate"] integerValue]];
            
            
            secondDetailLabel=[NSString stringWithFormat:@"Delivered: %@", [NSDateFormatter localizedStringFromDate:date
                                                                                dateStyle:NSDateFormatterMediumStyle
                                                                                                          timeStyle:NSDateFormatterMediumStyle]];
            status=@"";//[dict objectForKey:@"sellerId"];
        }
        default:
            break;
    }
    
    cell.mainLabel.text =[mainLabel substringWithRange:NSMakeRange(0, mainLabel.length<35 ? mainLabel.length:34)];
    cell.detailLabel.text=detailLabel;
    cell.secondDetailLabel.text =secondDetailLabel;
    cell.statusLabel.text =status;
    
    
    FIRStorageReference *storageRef = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"gs://e-utos.appspot.com/products/%@.jpg", [itemDict objectForKey:@"productId"]]];
    [cell.productImageView sd_setImageWithStorageReference:storageRef placeholderImage:[UIImage imageNamed:@"ant-approved"]];
    cell.productImageView.layer.cornerRadius=21;
    cell.productImageView.layer.masksToBounds=YES;
    //cell.layer.borderColor = [[UIColor whiteColor] CGColor];
    //cell.layer.borderWidth= 3;
    //cell.userInteractionEnabled = YES;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        default:
        {
            NSDictionary *dict;
            if (self.segmentedControl.selectedSegmentIndex==0){
            dict = [self.proposalsArray objectAtIndex:indexPath.row];
            }else{
                dict = [self.completedArray objectAtIndex:indexPath.row];
            }
            [self performSegueWithIdentifier:@"SelectProposalSegue" sender:dict];
        }
            break;
    }
//    CustomOffersMainCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.userInteractionEnabled = NO;
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectProposalSegue"]) {
        self.proposalDetailsController = [segue destinationViewController];
        self.proposalDetailsController.delegate=self;
        self.proposalDetailsController.proposalDict = sender;
        [self.proposalDetailsController.tableView reloadData];
    }
    else if ([segue.identifier isEqualToString:@"orderPopOverSegue"]){
        self.orderPopoverController = [segue destinationViewController];
        self.orderPopoverController.userId = [sender objectForKey:@"sellerId"];
        self.orderPopoverController.delegate=self;
        self.orderPopoverController.orderDict= sender;
        
    }
    
}

-(void)gotoMap{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTab" object:nil userInfo:@{@"tab" : [NSNumber numberWithInt:1]}];// show map
}
#pragma mark Proposal Detail delegates
-(void)rejectProposal:(id)sender{
    NSDictionary *dictProposal =sender;
    
    [API updateProposal:[dictProposal objectForKey:@"proposalId"] orProposals:nil withStatus:@"Rejected"
                success:^(NSDictionary *dict){
                    
                    
                } failure:^(NSString *message) {
                    NSLog(@"Fail");
                }];
    }
-(void)acceptProposal:(id)sender{
    NSDictionary *dictProposal =sender;
    
    [[NSUserDefaults standardUserDefaults] setObject:[dictProposal objectForKey:@"postalCode"] forKey:CURRENT_LOC_CODE];
    
    [API updateSalesOrder:[dictProposal objectForKey:@"orderId"] withStatus:@"Accepted" withSellerId:[dictProposal objectForKey:@"sellerId"]  withItems:[dictProposal objectForKey:@"orderItems"] withDict:dictProposal
                  success:^(NSDictionary *dict){
                      NSArray *proposalsForOnHold = [[[self.proposalsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId == %@", [dictProposal objectForKey:@"orderId"]]] valueForKeyPath:@"@distinctUnionOfObjects.proposalId"]filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self != %@",[dictProposal objectForKey:@"proposalId"]]];
                      
                      [API updateProposal:[dictProposal objectForKey:@"proposalId"] orProposals:nil withStatus:@"Accepted"
                                  success:^(NSDictionary *dict){
                                      [API updateProposal:nil orProposals:proposalsForOnHold withStatus:@"On-Hold"
                                                  success:^(NSDictionary *dict){
                                                      NSLog(@"Sucess-update proposal");
                                                  } failure:^(NSString *message) {
                                                      NSLog(@"Fail 321311313");
                                                  }];
                                  } failure:^(NSString *message) {
                                      NSLog(@"Fail 2342342445");
                                  }];
                  } failure:^(NSString *message) {
                      NSLog(@"Fail 787099");
                  }];
    
    
    
}
-(void)cancelProposal:(id)sender{
    
    NSDictionary*dictProposal= sender;
    
    [API updateSalesOrder:[dictProposal objectForKey:@"orderId"] withStatus:@"Open" withSellerId:[dictProposal objectForKey:@"sellerId"] withItems:[dictProposal objectForKey:@"orderItems"]withDict:dictProposal
                  success:^(NSDictionary *dict){
                      
                      NSArray *proposalsForOnHold = [[[self.proposalsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId == %@", [dictProposal objectForKey:@"orderId"]]] valueForKeyPath:@"@distinctUnionOfObjects.proposalId"]filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self != %@",[dictProposal objectForKey:@"proposalId"]]];
                      
                      [API updateProposal:[dictProposal objectForKey:@"proposalId"] orProposals:nil withStatus:@"Cancelled By Buyer"
                                  success:^(NSDictionary *dict){
                                      
                                      [API updateProposal:nil orProposals:proposalsForOnHold withStatus:@"Pending"
                                                  success:^(NSDictionary *dict){
                                                      NSLog(@"Sucess-update proposal");
                                                  } failure:^(NSString *message) {
                                                      NSLog(@"Fail");
                                                  }];
                                  } failure:^(NSString *message) {
                                      NSLog(@"Fail");
                                  }];
                  } failure:^(NSString *message) {
                      NSLog(@"Fail");
                  }];
    
}
@end
