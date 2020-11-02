//
//  SalesMapView.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 29/11/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "SalesMapView.h"

@implementation SalesMapView

- (instancetype)initWithSales:(NSDictionary*)sales{
    
    CGRect frame = CGRectMake(0, 0, 250, 150);
    
    
    if ((self = [super initWithFrame:frame])) {
        
        
        self = [[[NSBundle mainBundle] loadNibNamed:@"SalesMapView"
                                                  owner:self
                                                options:nil] objectAtIndex:0];
        
        self.frame = frame;
        self.tableViewArray = [[NSMutableArray alloc]init];
        self.tableView.delegate=self;
        self.tableView.dataSource=self;
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
    
}- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //static NSString *cellIdentifier = @"Cell";
    static NSString *cellIdentifier = @"CustomSalesMapViewTableViewCell";
    CustomSalesMapViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil){
        [self.tableView registerNib:[UINib nibWithNibName:@"CustomSalesMapViewTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
    }
    
    
    NSDictionary*dict = [self.tableViewArray objectAtIndex:indexPath.row];
    
    NSDictionary *productDetail= [[API productsDetailArrayUsingSearch:[NSString stringWithFormat:@"productId contains '%@'", [dict objectForKey:@"productId"]]] firstObject];
    cell.productName.text =[NSString stringWithFormat:@"%@ %@",[productDetail objectForKey:@"productName"],[productDetail objectForKey:@"description"]];
    cell.quantity.text = [dict objectForKey:@"quantity"];
    cell.price.text = [NSString stringWithFormat:@"Total: %@%@",[dict objectForKey:@"currency"],self.totalPrice];
    //total = total + ([[dict objectForKey:@"quantity"] intValue]*[[dict objectForKey:@"buyingPrice"] floatValue]);
    FIRStorageReference *storageRef = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"gs://e-utos.appspot.com/products/%@.jpg", [dict objectForKey:@"productId"]]];
    [cell.productPhoto sd_setImageWithStorageReference:storageRef placeholderImage:[UIImage imageNamed:@"e_utos_ant"]];
    
    return cell;

}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 102;//30;
}



@end
