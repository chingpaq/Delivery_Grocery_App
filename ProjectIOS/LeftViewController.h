//
//  LeftViewController.h
//  LGSideMenuControllerDemo
//

#import <UIKit/UIKit.h>
#import "NSObject+reSideMenuSingleton.h"
#import "AppDelegate.h"
#import "API.h"
#import "Constants.h"
#import "ProfileTableViewCell.h"
#import "UIImageView+WebCache.h"

@import Firebase;
@import FirebaseStorageUI;


@protocol LeftViewControllerDelegate <NSObject>
@optional
- (void)paymentsMenuPressed;
- (void)ordersMenuPressed;
- (void)settingsMenuPressed;
- (void)logoutPressed;
- (void)aboutPressed;
- (void)showAddressView;

@end
@interface LeftViewController : UITableViewController<UIImagePickerControllerDelegate>
@property (strong, nonatomic)id<LeftViewControllerDelegate>delegate;
@property (strong, nonatomic) IBOutlet UIImageView *UIImageView;
@property (strong, nonatomic) NSDictionary *imageDict;

@end
