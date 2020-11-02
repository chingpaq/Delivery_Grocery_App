//
//  SearchDetailViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 13/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FirebaseStorageUI/UIImageView+FirebaseStorage.h>
#import "API.h"
#import "AZNotification.h"
#import "SellerOffersViewController.h"

@protocol ProductViewControllerDelegate  <NSObject>
@optional
-(void)addCartPressed:(id)sender;
-(void)changeCartDetails:(id)sender;
@end


@interface ProductViewController : UIViewController<SellerOffersViewControllerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIButton *addCartButton;
@property (strong, nonatomic) id<ProductViewControllerDelegate>delegate;
@property (strong, nonatomic) SellerOffersViewController *sellerOffersVC;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UITextField *qty;
@property (strong, nonatomic) IBOutlet UITextField *buyingPrice;
@property (strong, nonatomic) UIBarButtonItem *keyboardDoneButton;
@property (strong, nonatomic) UIBarButtonItem *offerButton;
@property (strong, nonatomic) IBOutlet UIButton *addItemsToFavorites;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *currencyLabel;

@property (strong, nonatomic) UIToolbar *keyboardToolbar;
@property (strong, nonatomic) NSMutableDictionary *productDict;

-(void)setCartDetails:(NSMutableDictionary*)itemDict;
@end
