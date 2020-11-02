//
//  ProfileTableViewCell.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 17/01/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *fullName;
@property (strong, nonatomic) IBOutlet UILabel *location;
@property (strong, nonatomic) IBOutlet UILabel *credits;

@end
