//
//  SellerOrdersViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 20/03/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import "SellerOrdersViewController.h"

@interface SellerOrdersViewController ()

@end

@implementation SellerOrdersViewController
BOOL loaded;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    // Do any additional setup after loading the view.
    
    NSDictionary *normalAttributes = @{
                                       NSFontAttributeName:[UIFont fontWithName:@"Junegull-Regular" size:15.0f],
                                       NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                       };
    [[UISegmentedControl appearance] setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithHexString:@"00a54F"]];
    
    
    
    
    self.openOrdersArray = [[NSMutableArray alloc]init];
    self.completedArray = [[NSMutableArray alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startMonitorFromNotification:)
                                                 name:@"startSellerMonitors"
                                               object:nil];
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if ([defaults objectForKey:USER_ZIP_CODE]==nil){
//        loaded=NO;
//        return;
//    }
//    loaded=YES;
//    [self startMonitor];
    
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
//    if (loaded==NO && [[NSUserDefaults standardUserDefaults] objectForKey:USER_ZIP_CODE]!=nil){
//        loaded=YES;
//        [self startMonitor];
//        return;
//    }
    [SVProgressHUD dismiss];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)startMonitorFromNotification:(NSNotification*)dict{
    if ([[[dict userInfo] valueForKey:@"active"] boolValue]){
        
    }else{
        
    }
    [self.tableView reloadData];
    [self startMonitor];
}

-(void)startMonitor{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:USER_ZIP_CODE]==nil){
        return;
    }
    
    NSDictionary *dictionary =[API monitorOrdersByPostal:[defaults objectForKey:USER_ZIP_CODE] queryType:FIRDataEventTypeChildAdded
                                                 success:^(id dict){
                                                     
                                                     NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:[[dict objectForKey:@"orderDate"] integerValue]];
                                                     
                                                     if ([date timeIntervalSinceNow]>-7200){
                                                         
                                                     }else{
                                                         if ([[dict objectForKey:@"status"] isEqualToString:@"Completed"] || [[dict objectForKey:@"status"] isEqualToString:@"Closed"]){
                                                         }else{
                                                             [API updateSalesOrder:[dict objectForKey:@"orderId"] withStatus:@"Expired" withSellerId:@"-" withItems:[dict objectForKey:@"orderItems"]
                                                              withDict:dict
                                                                           success:^(NSDictionary *dict){
                                                                               [API deleteProposals:[dict objectForKey:@"orderId"]
                                                                                            success:^(NSDictionary *dict){
                                                                                                //
                                                                                                
                                                                                            } failure:^(NSString *message) {
                                                                                                NSLog(@"Fail");
                                                                                            }];
                                                                           } failure:^(NSString *message) {
                                                                               NSLog(@"Fail");
                                                                           }];
                                                             return;
                                                         }
                                                     }
                                                     
                                                     
                                                     
                                                     
                                                     NSLog(@"FIRDataEventTypeChildAdded 34342");
                                                     
                                                     NSDictionary *found =[[self.openOrdersArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId CONTAINS[cd]%@", [dict objectForKey:@"orderId"]]] firstObject];
                                                     if (found!=nil ){
                                                         [self.openOrdersArray removeObject:found];
                                                     }
                                                     if (!([[dict objectForKey:@"status"] isEqualToString:@"Closed"] || [[dict objectForKey:@"status"] isEqualToString:@"Completed"])){
                                                         [self.openOrdersArray addObject:dict];
                                                         if (self.segmentedControl.selectedSegmentIndex==0){
                                                             NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderDate" ascending:FALSE];
                                                             [self.openOrdersArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                                                             [self.tableView reloadData];
                                                         }
                                                         
                                                         if ([self.tabBarItem.badgeValue isEqualToString:@""]){
                                                             self.tabBarItem.badgeValue= @"1";
                                                             self.tabBarItem.badgeColor = [UIColor redColor];
                                                         }
                                                         
                                                     }else{
                                                         [self.completedArray addObject:dict];
                                                         if (self.segmentedControl.selectedSegmentIndex==1){
                                                             NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completionDate" ascending:FALSE];
                                                             [self.completedArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                                                             [self.tableView reloadData];
                                                         }
                                                     }
                                                     
                                                     
                                                 } failure:^(NSString *message) {}];
    
    
    [[DataSingletons sharedManager]setSellerOrdersReference:[dictionary objectForKey:@"reference"]];
    [[DataSingletons sharedManager]setZipAddedhandle:[[dictionary objectForKey:@"handle"] longValue]];
    
    
    dictionary=[API monitorOrdersByPostal:[defaults objectForKey:USER_ZIP_CODE] queryType:FIRDataEventTypeChildChanged
                                  success:^(id dict){
                                      NSLog(@"FIRDataEventTypeChildChanged 34535");
                                      
                                      NSDictionary *found =[[self.openOrdersArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId CONTAINS[cd]%@", [dict objectForKey:@"orderId"]]] firstObject];
                                      if (found!=nil ){
                                          [self.openOrdersArray removeObject:found];
                                      }
                                      [self.openOrdersArray addObject:dict];
                                      [self.tableView reloadData];
                                      
                                  } failure:^(NSString *message) {}];
    
    [[DataSingletons sharedManager]setZipCangedhandle:[[dictionary objectForKey:@"handle"] longValue]];
    
    
    dictionary=[API monitorOrdersByPostal:[defaults objectForKey:USER_ZIP_CODE] queryType:FIRDataEventTypeChildRemoved
                                  success:^(id dict){
                                      NSLog(@"FIRDataEventTypeChildRemoved");
                                      
                                      NSDictionary *found =[[self.openOrdersArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId CONTAINS[cd]%@", [dict objectForKey:@"orderId"]]] firstObject];
                                      if (found!=nil ){
                                          [self.openOrdersArray removeObject:found];
                                      }
                                      //[self.openOrdersArray addObject:dict];
                                      [self.tableView reloadData];
                                  } failure:^(NSString *message) {}];
    [[DataSingletons sharedManager]setZipDeletedhandle:[[dictionary objectForKey:@"handle"] longValue]];
    
    
    dictionary=[API monitorOrdersByPostal:[FIRAuth auth].currentUser.uid queryType:FIRDataEventTypeChildAdded
                                  success:^(id dict){
                                      NSLog(@"FIRDataEventTypeChildAdded");
                                      
                                      NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:[[dict objectForKey:@"orderDate"] integerValue]];
                                      
                                      if ([date timeIntervalSinceNow]>-7200){
                                          
                                      }else{
                                          if ([[dict objectForKey:@"status"] isEqualToString:@"Completed"] || [[dict objectForKey:@"status"] isEqualToString:@"Closed"]){
                                          }else{
                                              [API updateSalesOrder:[dict objectForKey:@"orderId"] withStatus:@"Expired" withSellerId:@"-" withItems:[dict objectForKey:@"orderItems"]
                                                           withDict:dict
                                                            success:^(NSDictionary *dict){
                                                                [API deleteProposals:[dict objectForKey:@"orderId"]
                                                                             success:^(NSDictionary *dict){
                                                                                 //
                                                                                 
                                                                             } failure:^(NSString *message) {
                                                                                 NSLog(@"Fail");
                                                                             }];
                                                            } failure:^(NSString *message) {
                                                                NSLog(@"Fail");
                                                            }];
                                              return;
                                          }
                                      }
                                      
                                      
                                      NSDictionary *found =[[self.openOrdersArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId CONTAINS[cd]%@", [dict objectForKey:@"orderId"]]] firstObject];
                                      if (found!=nil ){
                                          [self.openOrdersArray removeObject:found];
                                          [[[Orders sharedManager]activeOrders] removeObject:found];
                                      }
                                      if (!([[dict objectForKey:@"status"] isEqualToString:@"Closed"] || [[dict objectForKey:@"status"] isEqualToString:@"Completed"])){
                                          [self.openOrdersArray addObject:dict];
                                          [[[Orders sharedManager]activeOrders] addObject:dict];
                                          
                                          if ([[dict objectForKey:@"status"] isEqualToString:@"On The Way"]){
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTab" object:nil userInfo:@{@"tab" : [NSNumber numberWithInt:0]}];
                                              
                                          }
                                          else if (self.segmentedControl.selectedSegmentIndex==0){
                                              NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderDate" ascending:TRUE];
                                              [self.openOrdersArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                                              [self.tableView reloadData];
                                          }
                                          
                                          if ([[dict objectForKey:@"status"] isEqualToString:@"Accepted"]){
                                              [self performSegueWithIdentifier:@"orderPopOverSegue" sender:dict];
                                          }
                                          
                                      }else{
                                          NSDictionary *found =[[self.completedArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId CONTAINS[cd]%@", [dict objectForKey:@"orderId"]]] firstObject];
                                          if (found!=nil ){
                                              [self.completedArray removeObject:found];
                                              [self.openOrdersArray removeObject:found];
                                              [[[Orders sharedManager]activeOrders] removeObject:found];
                                          }
                                          
                                          [self.completedArray addObject:dict];
                                          if (self.segmentedControl.selectedSegmentIndex==1){
                                              NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completionDate" ascending:TRUE];
                                              [self.openOrdersArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                                              [self.tableView reloadData];
                                          }
                                      }
                                  } failure:^(NSString *message) {}];
    [[DataSingletons sharedManager]setZipUserAddedhandle:[[dictionary objectForKey:@"handle"] longValue]];
    
    dictionary=[API monitorOrdersByPostal:[FIRAuth auth].currentUser.uid queryType:FIRDataEventTypeChildChanged
                       success:^(id dict){
                           NSLog(@"FIRDataEventTypeChildChanged 34234234");
                           
                           NSDictionary *found =[[self.openOrdersArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId CONTAINS[cd]%@", [dict objectForKey:@"orderId"]]] firstObject];
                           if (found!=nil ){
                               [self.openOrdersArray removeObject:found];
                               [[[Orders sharedManager]activeOrders] removeObject:found];
                           }
                           if (([[dict objectForKey:@"status"] isEqualToString:@"Closed"] || [[dict objectForKey:@"status"] isEqualToString:@"Completed"])){
                               NSDictionary *found =[[self.completedArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId CONTAINS[cd]%@", [dict objectForKey:@"orderId"]]] firstObject];
                               if (found!=nil ){
                                   [self.completedArray removeObject:found];
                               }
                               [self.completedArray addObject:dict];
                               if (([[dict objectForKey:@"status"] isEqualToString:@"Completed"])){
                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMapViewController" object:nil userInfo:nil];
                               }else{
                                   [self performSegueWithIdentifier:@"orderPopOverSegue" sender:dict];
                               }
                           }else{
                               [self.openOrdersArray addObject:dict];
                               [[[Orders sharedManager]activeOrders] addObject:dict];
                           }
                           if ([[dict objectForKey:@"status"] isEqualToString:@"On The Way"]){
                               //[[NSNotificationCenter defaultCenter] postNotificationName:@"changeTab" object:nil userInfo:@{@"tab" : [NSNumber numberWithInt:0]}];
                               [self.tableView reloadData];
                           }else{
                               if ([[dict objectForKey:@"status"] isEqualToString:@"Accepted"]){
                                   [self performSegueWithIdentifier:@"orderPopOverSegue" sender:dict];
                               }
                               [self.tableView reloadData];
                           }
                       } failure:^(NSString *message) {}];
    [[DataSingletons sharedManager]setZipUserCangedhandle:[[dictionary objectForKey:@"handle"] longValue]];
    
    dictionary=[API monitorOrdersByPostal:[FIRAuth auth].currentUser.uid queryType:FIRDataEventTypeChildRemoved
                       success:^(id dict){
                           NSLog(@"FIRDataEventTypeChildRemoved");
                           
                           NSDictionary *found =[[self.openOrdersArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId CONTAINS[cd]%@", [dict objectForKey:@"orderId"]]] firstObject];
                           if (found!=nil ){
                               [self.openOrdersArray removeObject:found];
                               [[[Orders sharedManager]activeOrders] removeObject:found];
                           }
                           [self.tableView reloadData];
                       } failure:^(NSString *message) {}];
    [[DataSingletons sharedManager]setZipUserDeletedhandle:[[dictionary objectForKey:@"handle"] longValue]];
    
    [self startMonitorExternalPostal];
    
    
}


-(void)startMonitorExternalPostal{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:USER_ZIP_CODE]==nil){
        return;
    }
    
    if (![[defaults objectForKey:USER_ZIP_CODE]isEqualToString:[defaults objectForKey:CURRENT_LOC_CODE]] && [defaults objectForKey:CURRENT_LOC_CODE]!=nil){
        NSDictionary *dictionary =[API monitorOrdersByPostal:[defaults objectForKey:CURRENT_LOC_CODE] queryType:FIRDataEventTypeChildAdded
                                       success:^(id dict){
                                           NSLog(@"FIRDataEventTypeChildAdded34434");
                                           
                                           NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:[[dict objectForKey:@"orderDate"] integerValue]];
                                           
                                           if ([date timeIntervalSinceNow]>-7200){
                                           }else{
                                               if ([[dict objectForKey:@"status"] isEqualToString:@"Completed"] || [[dict objectForKey:@"status"] isEqualToString:@"Closed"]){
                                               }else{
                                                   [API updateSalesOrder:[dict objectForKey:@"orderId"] withStatus:@"Expired" withSellerId:@"-" withItems:[dict objectForKey:@"orderItems"]
                                                                withDict:dict
                                                                 success:^(NSDictionary *dict){
                                                                     [API deleteProposals:[dict objectForKey:@"orderId"]
                                                                                  success:^(NSDictionary *dict){
                                                                                      //
                                                                                      
                                                                                  } failure:^(NSString *message) {
                                                                                      NSLog(@"Fail");
                                                                                  }];
                                                                 } failure:^(NSString *message) {
                                                                     NSLog(@"Fail");
                                                                 }];
                                                   return;
                                               }
                                           }
                                           
                                           NSDictionary *found =[[self.openOrdersArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId CONTAINS[cd]%@", [dict objectForKey:@"orderId"]]] firstObject];
                                           if (found!=nil ){
                                               [self.openOrdersArray removeObject:found];
                                           }
                                           if (!([[dict objectForKey:@"status"] isEqualToString:@"Closed"] || [[dict objectForKey:@"status"] isEqualToString:@"Completed"])){
                                               [self.openOrdersArray addObject:dict];
                                               if (self.segmentedControl.selectedSegmentIndex==0){
                                                   NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderDate" ascending:TRUE];
                                                   [self.openOrdersArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                                                   [self.tableView reloadData];
                                               }
                                               
                                               if ([self.tabBarItem.badgeValue isEqualToString:@""]){
                                                   self.tabBarItem.badgeValue= @"1";
                                                   self.tabBarItem.badgeColor = [UIColor redColor];
                                               }
                                               
                                           }else{
                                               [self.completedArray addObject:dict];
                                               if (self.segmentedControl.selectedSegmentIndex==1){
                                                   NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completionDate" ascending:TRUE];
                                                   [self.openOrdersArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                                                   [self.tableView reloadData];
                                               }
                                           }
                                           
                                           
                                       } failure:^(NSString *message) {}];
        
        dictionary=[API monitorOrdersByPostal:[defaults objectForKey:CURRENT_LOC_CODE] queryType:FIRDataEventTypeChildChanged
                                      success:^(id dict){
                                          NSLog(@"FIRDataEventTypeChildChanged 4343543");
                                          
                                          NSDictionary *found =[[self.openOrdersArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId CONTAINS[cd]%@", [dict objectForKey:@"orderId"]]] firstObject];
                                          if (found!=nil ){
                                              [self.openOrdersArray removeObject:found];
                                          }
                                          [self.openOrdersArray addObject:dict];
                                          [self.tableView reloadData];
                                          
                                      } failure:^(NSString *message) {}];
        
        dictionary=[API monitorOrdersByPostal:[defaults objectForKey:CURRENT_LOC_CODE] queryType:FIRDataEventTypeChildRemoved
                                      success:^(id dict){
                                          NSLog(@"FIRDataEventTypeChildRemoved");
                                          
                                          NSDictionary *found =[[self.openOrdersArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId CONTAINS[cd]%@", [dict objectForKey:@"orderId"]]] firstObject];
                                          if (found!=nil ){
                                              [self.openOrdersArray removeObject:found];
                                          }
                                          
                                          [self.tableView reloadData];
                                      } failure:^(NSString *message) {}];
    
    }
    
}

- (IBAction)segmentValueChanged:(id)sender {
    
    [SVProgressHUD dismiss];
    
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [self getOpenOrders];
            break;
        case 1:
            [self getCompletedOrders];
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}



-(void)getCompletedOrders{
    [SVProgressHUD show];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completionDate" ascending:FALSE];
    [self.completedArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    
    [self.tableView reloadData];
}


-(void)getOpenOrders{
    self.openOrdersArray= [[NSMutableArray alloc]init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [API getOrdersByPostal:[defaults objectForKey:USER_ZIP_CODE] queryType:FIRDataEventTypeValue
                   success:^(NSArray *array){
                       
                       for (NSMutableIndexSet *dict in array){
                           if (![self.openOrdersArray containsObject:dict]){
                               [self.openOrdersArray addObject:dict];
                           }
                       }
                       [API getOrdersByPostal:[FIRAuth auth].currentUser.uid queryType:FIRDataEventTypeValue
                                      success:^(NSArray *array){
                                          for (NSMutableIndexSet *dict in array){
                                              if (![self.openOrdersArray containsObject:dict]){
                                                  [self.openOrdersArray addObject:dict];
                                              }
                                          }
                                          
                                          NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderDate" ascending:FALSE];
                                          [self.openOrdersArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                                          
                                          self.completedArray= [[NSMutableArray alloc]initWithArray:[self.openOrdersArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(status CONTAINS[cd] %@ || status CONTAINS[cd] %@)",@"Closed",@"Completed"]]];
                                          sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completionDate" ascending:FALSE];
                                          [self.completedArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                                          
                                          self.openOrdersArray= [[NSMutableArray alloc]initWithArray:[self.openOrdersArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(status CONTAINS[cd] %@ || status CONTAINS[cd] %@ )",@"Closed",@"Completed"]]];
                                          
                                          [self.tableView reloadData];
                                      } failure:^(NSString *message) {}];
                   } failure:^(NSString *message) {}];
    defaults = [NSUserDefaults standardUserDefaults];
    if (![[defaults objectForKey:USER_ZIP_CODE]isEqualToString:[defaults objectForKey:CURRENT_LOC_CODE]]){
        [API getOrdersByPostal:[defaults objectForKey:CURRENT_LOC_CODE] queryType:FIRDataEventTypeValue
                       success:^(NSArray *array){
                           for (NSMutableIndexSet *dict in array){
                               if (![self.openOrdersArray containsObject:dict]){
                                   [self.openOrdersArray addObject:dict];
                               }
                           }
                           
                                              NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderDate" ascending:TRUE];
                                              [self.openOrdersArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                                              
                                              self.completedArray= [[NSMutableArray alloc]initWithArray:[self.openOrdersArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(status CONTAINS[cd] %@ || status CONTAINS[cd] %@)",@"Closed",@"Completed"]]];
                                              sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completionDate" ascending:TRUE];
                                              [self.completedArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                                              
                                              self.openOrdersArray= [[NSMutableArray alloc]initWithArray:[self.openOrdersArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(status CONTAINS[cd] %@ || status CONTAINS[cd] %@ )",@"Closed",@"Completed"]]];
                                              
                                              
                                              [self.tableView reloadData];
                           
                           
                           
                       } failure:^(NSString *message) {}];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.segmentedControl.selectedSegmentIndex==0){
        NSArray *ar=[self.openOrdersArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(status CONTAINS[cd] %@) AND NOT(bidders CONTAINS[cd] %@)",@"Open",[[NSUserDefaults standardUserDefaults]objectForKey:@"sellerId"]]];
        
        
        //if ([[dict objectForKey:@"bidders"]containsObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"sellerId"]]){
        if (ar.count>0){
            self.tabBarItem.badgeValue= [NSString stringWithFormat:@"%lu",(unsigned long)ar.count];
            self.tabBarItem.badgeColor = [UIColor redColor];
        }else{
            self.tabBarItem.badgeValue= @"";
            self.tabBarItem.badgeColor = [UIColor clearColor];
        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([[defaults objectForKey:@"active"] isEqualToString:@"No"]){
            return 0;
        }else{
            if (self.openOrdersArray.count>10){
                //[SVProgressHUD show];
            }
            
            return self.openOrdersArray.count;
        }
    }
    else {
        if (self.completedArray.count>10){
            //[SVProgressHUD show];
        }
        return self.completedArray.count;
        
    }
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
            if (self.openOrdersArray.count-1==indexPath.row || indexPath.row==5){
                [SVProgressHUD dismiss];
            }
            
            NSDictionary *dict = [self.openOrdersArray objectAtIndex:indexPath.row];
            detailLabel=[NSString stringWithFormat:@"Buying at %@ %@ (%@)",[dict objectForKey:@"currency"],[dict objectForKey:@"totalPrice"],[dict objectForKey:@"paymentMode"]];
            itemDict=[[dict objectForKey:@"orderItems"] firstObject];
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
                                        //
                                    } failure:^(NSString *message) {
                                        NSLog(@"Fail");
                                    }];
                    }
                }
            }
            
            
            secondDetailLabel=[dict objectForKey:@"buyerComment"];
            secondDetailLabel=[secondDetailLabel substringWithRange:NSMakeRange(0, secondDetailLabel.length<30 ? secondDetailLabel.length:30)];
            
            status=[dict objectForKey:@"status"];
            
            if ([[dict objectForKey:@"bidders"]containsObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"sellerId"]]){
                if (!([status isEqualToString:@"Rejected"] || [status isEqualToString:@"Accepted"] || [status isEqualToString:@"On The Way"])){
                    if ([status isEqualToString:@"Completed"] ){
                        status = @"Waiting for Ratings";
                    }else status = @"Sent Offer";
                }
            }
            
        }
            break;
        case 1:{
            if (self.completedArray.count-1==indexPath.row || indexPath.row==5){
                [SVProgressHUD dismiss];
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
                                        //
                                    } failure:^(NSString *message) {
                                        NSLog(@"Fail");
                                    }];
                    }
                }
            }
            
            
            
            NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:[[dict objectForKey:@"completionDate"] integerValue]];
            
            
            secondDetailLabel=[NSString stringWithFormat:@"Delivered: %@", [NSDateFormatter localizedStringFromDate:date
                                                                                                          dateStyle:NSDateFormatterMediumStyle
                                                                                                          timeStyle:NSDateFormatterMediumStyle] ];
            status=[dict objectForKey:@"paymentMode"];
            status=@"";
        }
        default:
            break;
    }
    
    
    cell.mainLabel.text =[mainLabel substringWithRange:NSMakeRange(0, mainLabel.length<35 ? mainLabel.length:34)];
    cell.detailLabel.text=detailLabel;
    cell.secondDetailLabel.text =secondDetailLabel;
    cell.statusLabel.text = status;
    
    
    FIRStorageReference *storageRef = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"gs://e-utos.appspot.com/products/%@.jpg", [itemDict objectForKey:@"productId"]]];
    [cell.productImageView sd_setImageWithStorageReference:storageRef placeholderImage:[UIImage imageNamed:@"ant-approved"]];
    cell.productImageView.layer.cornerRadius=21;
    cell.productImageView.layer.masksToBounds=YES;
    cell.layer.borderColor = [[UIColor whiteColor] CGColor];
    cell.layer.borderWidth= 3;
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
                dict=[self.openOrdersArray objectAtIndex:indexPath.row];
                
                
                if ([[dict objectForKey:@"bidders"]containsObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"sellerId"]]){
                    if (!([[dict objectForKey:@"status"] isEqualToString:@"Accepted"] || [[dict objectForKey:@"status"] isEqualToString:@"On The Way"])){
                        
                        CustomOffersMainCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                        cell.userInteractionEnabled = NO;
                        
                        
                        [API getSalesProposalWithID:[dict objectForKey:@"orderId"]
                                            success:^(NSArray *array){
                                                cell.userInteractionEnabled=YES;
                                                NSDictionary *dict1=[[array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"sellerId CONTAINS[CD]%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"sellerId"]]] firstObject];
                                                
                                                [self performSegueWithIdentifier:@"SelectProposalSegue" sender:dict1];
                                                return;
                                            } failure:^(NSString *message) {}];
                    }else{
                        dict = [self.openOrdersArray objectAtIndex:indexPath.row];
                        [self performSegueWithIdentifier:@"SelectProposalSegue" sender:dict];
                    }
                }else{
                    dict = [self.openOrdersArray objectAtIndex:indexPath.row];
                    [self performSegueWithIdentifier:@"SelectProposalSegue" sender:dict];
                }
                
                
                
            }else{
                dict = [self.completedArray objectAtIndex:indexPath.row];
                [self performSegueWithIdentifier:@"SelectProposalSegue" sender:dict];
            }
            
        }
            break;
    }
    
}

#pragma mark - segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectProposalSegue"]) {
        self.proposalDetailsController = [segue destinationViewController];
        self.proposalDetailsController.delegate=self;
        self.proposalDetailsController.proposalDict = sender;
        [self.proposalDetailsController.tableView reloadData];
    }
    else if ([segue.identifier isEqualToString:@"orderPopOverSegue"]){
        
        self.orderPopoverController = [segue destinationViewController];
        self.orderPopoverController.userId = [sender objectForKey:@"buyerId"];
        self.orderPopoverController.delegate=self;
        self.orderPopoverController.orderDict= sender;
        
    }
    
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
    
    [API updateSalesOrder:[dictProposal objectForKey:@"orderId"] withStatus:@"Accepted" withSellerId:[dictProposal objectForKey:@"sellerId"] withItems:[dictProposal objectForKey:@"orderItems"]withDict:dictProposal
                  success:^(NSDictionary *dict){
                      
                      NSArray *proposalsForOnHold = [[[self.proposalsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"orderId == %@", [dictProposal objectForKey:@"orderId"]]] valueForKeyPath:@"@distinctUnionOfObjects.proposalId"]filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self != %@",[dictProposal objectForKey:@"proposalId"]]];
                      
                      [API updateProposal:[dictProposal objectForKey:@"proposalId"] orProposals:nil withStatus:@"Accepted"
                                  success:^(NSDictionary *dict){
                                      
                                      [API updateProposal:nil orProposals:proposalsForOnHold withStatus:@"On-Hold"
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

-(void)oTWProposal:(id)sender{
    if ([[self.openOrdersArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status CONTAINS[cd]%@",@"On The Way"]] count]>0){
        [AZNotification showNotificationWithTitle:@"You still have an ongoing transaction"  controller:self notificationType:AZNotificationTypeWarning shouldShowNotificationUnderNavigationBar:YES];
    }else{
        NSMutableDictionary *orderDict = sender;
        
        CLLocation * location = [[DataSingletons sharedManager] userLocation];
        
        [API getRouteAndTimeToArriveWithCurrentLatitude:location.coordinate.latitude andCurrentLongitude:location.coordinate.longitude andUserLatitude:[[sender objectForKey:@"latitude"]floatValue] andUserLongitude:[[sender objectForKey:@"longitude"]floatValue] withTransportMode:[[NSUserDefaults standardUserDefaults] objectForKey:MAP_ROUTING_TYPE] success:^(NSDictionary *dictleg){
            
            [API snapPathToRoadv2:[dictleg objectForKey:@"steps"]
                          success:^(id dict){
                              
                              [[DataSingletons sharedManager] setRouteArray:[[NSMutableArray alloc]initWithArray:[dict objectForKey:@"snappedPoints"]]];
                              
                              [API updateSellerRoute:@{@"sellerRoute":[dictleg objectForKey:@"steps"],
                                                       @"sellerRouteV2": [dict objectForKey:@"snappedPoints"]
                                                       } ofSeller:[sender objectForKey:@"sellerId"] eta: [[dictleg objectForKey:@"duration"]objectForKey:@"text"]
                                             success:^(NSDictionary *dict){}
                                             failure:^(NSString *message) {}];
                              
                          } failure:^(NSString *message) {
                              NSLog(@"Fail12345");
                          }];
            
//            [[DataSingletons sharedManager] setRouteArray:[[NSMutableArray alloc]initWithArray:[dictleg objectForKey:@"steps"]]];
//
//            for (NSDictionary *dict in [dictleg objectForKey:@"steps"]){
//                if ([[[dict objectForKey:@"distance"]objectForKey:@"value"] integerValue]>1000){
//                    //[[[DataSingletons sharedManager] routeArray] removeObject:dict];
//                }
//            }
//
//            [API updateSellerRoute:[dictleg objectForKey:@"steps"] ofSeller:[sender objectForKey:@"sellerId"] eta: [[dictleg objectForKey:@"duration"]objectForKey:@"text"]
//                           success:^(NSDictionary *dict){} failure:^(NSString *message) {}];
            
        } failure:^(NSString *message) {}];
        
        [API updateSalesOrder:[sender objectForKey:@"orderId"] withStatus:@"On The Way" withSellerId:[sender objectForKey:@"sellerId"] withItems:[sender objectForKey:@"salesItem"] withDict:orderDict
                      success:^(NSDictionary *dict){
                          [API updateProposal:[sender objectForKey:@"proposalId"] orProposals:nil withStatus:@"On The Way"
                                      success:^(NSDictionary *dict){
                                          
                                          
                                      } failure:^(NSString *message) {
                                          //NSLog(@"Fail");
                                      }];
                      } failure:^(NSString *message) {
                          NSLog(@"Fail");
                      }];
        
        
    }
}

#pragma mark - popup delegates
-(void)gotoMap{
   // [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTab" object:nil userInfo:@{@"tab" : [NSNumber numberWithInt:0]}];// show map
}
-(void)onTheWay:(id)orderDict{
    [self oTWProposal:orderDict];
}
@end

