//
//  SettingsViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 14/07/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface SettingsViewController : UIViewController
@property (strong, nonatomic) IBOutlet UISegmentedControl *routeDIstanceInterval;
@property (strong, nonatomic) IBOutlet UISegmentedControl *generateRouteType;

@end
