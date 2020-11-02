//
//  Created by Jhaybie Basco on 2/28/17.
//


#import <UIKit/UIKit.h>
#import "DBDarkTextField.h"
#import "NSObject+FIRDatabaseSingleton.h"
#import "API.h"

@import Firebase;
@import Photos;
@import SVProgressHUD;
@protocol NewProductsViewControllerDelegate <NSObject>

- (void)didDismissViewController:(UIViewController *)viewController;

@end

@interface NewProductsViewController : UIViewController <UITextFieldDelegate,UIImagePickerControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *UIImageView;
@property (strong, nonatomic) IBOutlet DBDarkTextField *ProductTextField;
@property (strong, nonatomic) IBOutlet DBDarkTextField *UOMTextField;
@property (strong, nonatomic) IBOutlet DBDarkTextField *SRPTextField;
@property (strong, nonatomic) IBOutlet UITextView *DescriptionTextView;
@property (strong, nonatomic) IBOutlet DBDarkTextField *CurrencyTextField;
@property (strong, nonatomic) id<NewProductsViewControllerDelegate> delegate;
@property (strong, nonatomic) NSDictionary *imageDict;

@end
