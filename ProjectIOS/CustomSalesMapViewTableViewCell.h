//
//  CustomSalesMapViewTableViewCell.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 01/03/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSalesMapViewTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *productPhoto;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UITextField *quantity;

@end
