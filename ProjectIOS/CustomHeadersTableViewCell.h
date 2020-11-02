//
//  CustomHeadersTableViewCell.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 19/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomHeadersTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *sellerDetails;
@property (strong, nonatomic) IBOutlet UILabel *sellerBid;
@property (strong, nonatomic) IBOutlet UILabel *sellerETA;
@property (strong, nonatomic) IBOutlet UITextView *sellerCommets;

@end
