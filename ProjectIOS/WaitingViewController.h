//
//  WaitingViewController.h
//  
//
//  Created by Manuel B Parungao Jr on 18/10/2017.
//

#import <UIKit/UIKit.h>
#import "API.h"
#import "ProposalsViewController.h"
@protocol WaitingViewControllerDelegate <NSObject>
@optional
-(void)done;
-(void)proposalsReceived;
-(void)cancelThisOrder;
-(void)continueThisOrder;
@end


@interface WaitingViewController : UIViewController
@property (strong, nonatomic) id<WaitingViewControllerDelegate>delegate;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong,nonatomic)NSMutableDictionary *productDict;
@property (strong, nonatomic)ProposalsViewController *proposalsViewController;
@property (strong, nonatomic)NSMutableArray *proposalsArray;
@property (strong, nonatomic) NSTimer *waitTimer;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@end
