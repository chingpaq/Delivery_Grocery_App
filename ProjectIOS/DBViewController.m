//
//  DBViewController.m
//  Dashboard
//
//  Created by Jhaybie Basco on 3/13/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import "DBViewController.h"
#import "UIColor+DBColors.h"

@interface DBViewController ()

@property (nonatomic, strong) DBToastView *toastView;

@end

@implementation DBViewController

#pragma mark - Override Methods
BOOL isAddressEntered;
BOOL isToastVisible = false;
NSTimer *timer;

#pragma mark - Override Methods

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup default behavior for nag view
    
    //[self enterAddressButtonTapped:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)dealloc {
}

#pragma mark - Private Methods



- (void)displayToastWithMessage:(NSString *)message backgroundColor:(UIColor *)backgroundColor {
    [self enterAddressButtonTapped:nil];
    return;
    
    CGRect startFrame = CGRectMake(0,80, [[UIScreen mainScreen] bounds].size.width, 80);
    CGRect endFrame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 80);
    
    [timer invalidate];
    timer = nil;
    
    if (!isToastVisible) {
        isToastVisible = true;

        self.toastView = [[DBToastView alloc] initWithMessage:message backgroundColor:backgroundColor];
        self.toastView.frame = startFrame;
        self.toastView.delegate = self;
        [self.view addSubview:self.toastView];

        [UIView animateWithDuration:0.5f animations:^{
            self.toastView.frame = endFrame;
        } completion:^(BOOL finished) {
            timer = [NSTimer scheduledTimerWithTimeInterval:10.0f
                                                     target:self
                                                   selector:@selector(toastCloseButtonTapped)
                                                   userInfo:nil
                                                    repeats:true];
        }];
    } else { // current toast notification exists
        
        CGRect endFrame = CGRectMake(0, -60, [[UIScreen mainScreen] bounds].size.width, 60);
        [UIView animateWithDuration:0.15f animations:^{
            self.toastView.frame = endFrame;
        } completion:^(BOOL finished) {
            isToastVisible = false;
            [self.toastView removeFromSuperview];
            
            [self displayToastWithMessage:message backgroundColor:backgroundColor];
        }];
    }
    
}

#pragma mark - AddressViewController Delegate Method

- (void)didDismissViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[NewProductsViewController class]]) {
        [self dismissViewControllerAnimated:false completion:nil];
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

#pragma mark - DBNagView Delegate Methods

- (void)enterAddressButtonTapped:(id)sender {
    [self.view endEditing:true];
    NewProductsViewController *avc = [[NewProductsViewController alloc] initWithNibName:@"NewProductsViewController" bundle:nil];
    avc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    
    avc.delegate = self;
    [self presentViewController:avc
                       animated:true
                     completion:nil];
}

#pragma mark - DBToastView Delegate Methods

- (void)toastCloseButtonTapped {
    CGRect endFrame = CGRectMake(0, -60, [[UIScreen mainScreen] bounds].size.width, 60);
    
    [UIView animateWithDuration:0.5f animations:^{
        self.toastView.frame = endFrame;
    } completion:^(BOOL finished) {
        isToastVisible = false;
        [self.toastView removeFromSuperview];
    }];
}

@end
