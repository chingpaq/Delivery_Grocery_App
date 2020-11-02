//
//  CompletionViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 28/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"
@import SVProgressHUD;

@protocol CompletionViewControllerDelegate <NSObject>
@optional
-(void)closeCompletion;
@end


@interface CompletionViewController : UIViewController
@property (strong, nonatomic) id<CompletionViewControllerDelegate>delegate;
@property (strong, nonatomic)NSMutableDictionary *completedOrder;
@property (strong, nonatomic) IBOutlet UIButton *completeRatingButton;
@property (strong, nonatomic) IBOutlet UIButton *star1;
@property (strong, nonatomic) IBOutlet UIButton *star2;
@property (strong, nonatomic) IBOutlet UIButton *star3;
@property (strong, nonatomic) IBOutlet UIButton *star4;
@property (strong, nonatomic) IBOutlet UIButton *star5;
@property (strong, nonatomic) IBOutlet UILabel *completionLabel;

@property (strong, nonatomic) NSString *sellerRatings;
@end
