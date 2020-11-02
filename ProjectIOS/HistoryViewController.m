//
//  HistoryViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 02/06/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
}
-(void)viewDidAppear:(BOOL)animated{
    self.historyArray = [[NSMutableArray alloc]initWithArray:[[DataSingletons sharedManager] paymentHistory] ];
    [API getAllOrders:[FIRAuth auth].currentUser.uid
            queryType:FIRDataEventTypeValue
              success:^(NSArray*array){
                  [self.historyArray addObjectsFromArray:array];
                  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderDate" ascending:FALSE];
                  [self.historyArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                  [self.tableView reloadData];
                  
              } failure:^(NSString *message) {}];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
    
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"CustomOffersMainCell";
    CustomOffersMainCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil){
        [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
    }
    

    

    NSDictionary *dict = [self.historyArray objectAtIndex:indexPath.row];
    
    if ([dict objectForKey:@"paidBy"]){
        if ([[dict objectForKey:@"type"] isEqualToString:@"Cut"]){
            cell.mainLabel.text = @"Fee";
            cell.detailLabel.text = [NSString stringWithFormat:@"%@ (%@)",@"PHP",[dict objectForKey:@"amount"]];
            
            cell.productImageView.image = [UIImage imageNamed:@"ant-approved"];
            
        }else if ([[dict objectForKey:@"type"] isEqualToString:@"Incentive"]){
            cell.mainLabel.text = @"Incentive";
            cell.detailLabel.text = [NSString stringWithFormat:@"%@ %@",@"PHP",[dict objectForKey:@"amount"]];
            cell.productImageView.image = [UIImage imageNamed:@"wallet"];
            
        }else if ([[dict objectForKey:@"type"] isEqualToString:@"Topup"]){
            cell.mainLabel.text = @"Reload";
            cell.detailLabel.text = [NSString stringWithFormat:@"%@ %@",@"PHP",[dict objectForKey:@"amount"]];
            cell.productImageView.image = [UIImage imageNamed:@"paper_money"];
            
        }else if ([[dict objectForKey:@"type"] isEqualToString:@"Withdrawal"]){
            cell.mainLabel.text = @"Withdrawal";
            cell.detailLabel.text = [NSString stringWithFormat:@"%@ (%@)",@"PHP",[dict objectForKey:@"amount"]];
            cell.productImageView.image = [UIImage imageNamed:@"money"];
            
        }else{
            cell.mainLabel.text = @"Topup";
            cell.detailLabel.text = [NSString stringWithFormat:@"%@ %@",@"PHP",[dict objectForKey:@"amount"]];
            cell.productImageView.image = [UIImage imageNamed:@"paper_money"];
            
            
        }
        
    }else if ([dict objectForKey:@"orderId"]){
        
        if ([[dict objectForKey:@"paymentMode"] isEqualToString:@"Cash"]){
            cell.mainLabel.text = @"Cash Order";
        }else{
            cell.mainLabel.text = @"Credit Card Order";
        }
        cell.detailLabel.text = [NSString stringWithFormat:@"%@ %@",[[dict objectForKey:@"currency"]uppercaseString],[dict objectForKey:@"totalPrice"]];
        
        
        NSDictionary* itemDict=[[dict objectForKey:@"orderItems"] firstObject];
        FIRStorageReference *storageRef = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"gs://e-utos.appspot.com/products/%@.jpg", [itemDict objectForKey:@"productId"]]];
        
        
        [cell.productImageView sd_setImageWithStorageReference:storageRef placeholderImage:[UIImage imageNamed:@"ant-seller"]];
        cell.productImageView.layer.cornerRadius=21;
        cell.productImageView.layer.masksToBounds=YES;
        
        
        
    }
    
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:[[dict objectForKey:@"orderDate"] integerValue]];
    cell.secondDetailLabel.text=[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    
    cell.statusLabel.text = [dict objectForKey:@"status"];
    
    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.historyArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}


@end



