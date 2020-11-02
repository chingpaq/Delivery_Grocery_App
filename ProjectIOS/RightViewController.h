//
//  RightViewController.h
//  LGSideMenuControllerDemo
//

#import <UIKit/UIKit.h>
#import "Orders.h"
#import "OrdersTableViewCell.h"
#import <FirebaseStorageUI/UIImageView+FirebaseStorage.h>
#import <CZPicker/CZPicker.h>
#import "UIColor+DBColors.h"
#import "Constants.h"

//@protocol RightViewControllerDelegate <NSObject>
//
//- (void)proceedToCheckout;
//
//@end
@interface RightViewController :UIViewController<UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate, UIPickerViewDataSource,CZPickerViewDelegate,CZPickerViewDataSource>
@property (strong, nonatomic)UITableView *tableView;
//@property (strong, nonatomic)UIPickerView *pickerView;
@property (strong, nonatomic)CZPickerView *pickerView;
//@property (strong, nonatomic)id<RightViewControllerDelegate> delegate;
@end
