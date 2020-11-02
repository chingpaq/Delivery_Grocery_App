//
//  OrdersTableViewCell.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 15/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@protocol OrdersTableViewCellDelegate  <NSObject>
@optional
-(void)cellpressed:(id)sender;
@end


@interface OrdersTableViewCell : UITableViewCell
@property (strong, nonatomic) id<OrdersTableViewCellDelegate>delegate;
@property (strong, nonatomic) IBOutlet UIImageView *productPhoto;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UITextField *quantity;

@end
