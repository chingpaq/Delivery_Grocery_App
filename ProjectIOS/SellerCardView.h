//
//  SellerCardView.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 17/05/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SellerCardView : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *cityStateLabel;
@property (strong, nonatomic) IBOutlet UILabel *creditsLabel;
@end
