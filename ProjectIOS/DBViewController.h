//
//  DBViewController.h
//  Dashboard
//
//  Created by Jhaybie Basco on 3/13/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "NewProductsViewController.h"
#import "DBToastView.h"

@interface DBViewController : UIViewController <DBToastViewDelegate,NewProductsViewControllerDelegate>


- (void)displayToastWithMessage:(NSString *)message backgroundColor:(UIColor *)backgroundColor;

@end
