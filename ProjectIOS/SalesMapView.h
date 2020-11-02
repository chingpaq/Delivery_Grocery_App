//
//  SalesMapView.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 29/11/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Orders.h"
#import <FirebaseStorageUI/UIImageView+FirebaseStorage.h>
#import <CZPicker/CZPicker.h>
#import "UIColor+DBColors.h"
#import "CustomSalesMapViewTableViewCell.h"
#import "API.h"

@interface SalesMapView : UIView<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UILabel *mainLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tableViewArray;
@property (strong, nonatomic) NSString *totalPrice;

- (instancetype)initWithSales:(NSDictionary*)sales;
@end
