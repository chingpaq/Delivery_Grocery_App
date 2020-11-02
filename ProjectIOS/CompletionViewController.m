//
//  CompletionViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 28/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "CompletionViewController.h"

@interface CompletionViewController ()

@end
NSMutableDictionary *sellerDict;

@implementation CompletionViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sellerRatings = @"5";
    
    self.completionLabel.text = [NSString stringWithFormat:@"Order %@ has been completed",[[self.completedOrder objectForKey:@"orderId"] substringFromIndex: [[self.completedOrder objectForKey:@"orderId"] length] - 4]];//[self.completedOrder objectForKey:@"orderId"]];
    [API getSellerDetails:[self.completedOrder objectForKey:@"sellerId"]
                eventType:FIRDataEventTypeValue
                  success:^(NSDictionary *dict){
                      if (![dict isKindOfClass:[NSNull class]]){
                          sellerDict= [[NSMutableDictionary alloc]initWithDictionary:dict];
                      }
                      else{
                          sellerDict = nil;
                      }
                  } failure:^(NSString *message) {
                      NSLog(@"Fail");
                  }];
    
    
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [SVProgressHUD dismiss];
    self.navigationController.navigationBarHidden=YES;
    
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    [[API sharedManager] completeSales:self.completedOrder
                               success:^(id response){
                                   [[Orders sharedManager]setActiveOrders:[[NSMutableArray alloc]initWithArray:
                                                                           [[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(orderId CONTAINS[cd] %@)", [self.completedOrder objectForKey:@"orderId"]]]]];
                                   
                               }failure:^(NSString *error) {
                                   
                               }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)star1Pressed:(id)sender {
    [self ratings:1];
}

- (IBAction)star2Pressed:(id)sender {
    [self ratings:2];
}
- (IBAction)star3Pressed:(id)sender {
    [self ratings:3];
}
- (IBAction)star4Pressed:(id)sender {
    [self ratings:4];
}
- (IBAction)star5Pressed:(id)sender {
    [self ratings:5];
}

-(void)ratings:(int)ratings{
    [self.star1 setBackgroundImage:[UIImage imageNamed:@"star-orange"]  forState:UIControlStateNormal];
    [self.star2 setBackgroundImage:[UIImage imageNamed:@"star-orange"]  forState:UIControlStateNormal];
    [self.star3 setBackgroundImage:[UIImage imageNamed:@"star-orange"]  forState:UIControlStateNormal];
    [self.star4 setBackgroundImage:[UIImage imageNamed:@"star-orange"]  forState:UIControlStateNormal];
    [self.star5 setBackgroundImage:[UIImage imageNamed:@"star-orange"]  forState:UIControlStateNormal];
    
    switch (ratings) {
        case 1:{
            [self.star2 setBackgroundImage:[UIImage imageNamed:@"star-grey"]  forState:UIControlStateNormal];
            [self.star3 setBackgroundImage:[UIImage imageNamed:@"star-grey"]  forState:UIControlStateNormal];
            [self.star4 setBackgroundImage:[UIImage imageNamed:@"star-grey"]  forState:UIControlStateNormal];
            [self.star5 setBackgroundImage:[UIImage imageNamed:@"star-grey"]  forState:UIControlStateNormal];
        }
            break;
        case 2:{
            [self.star3 setBackgroundImage:[UIImage imageNamed:@"star-grey"]  forState:UIControlStateNormal];
            [self.star4 setBackgroundImage:[UIImage imageNamed:@"star-grey"]  forState:UIControlStateNormal];
            [self.star5 setBackgroundImage:[UIImage imageNamed:@"star-grey"]  forState:UIControlStateNormal];
        }
            break;
        case 3:{
            [self.star4 setBackgroundImage:[UIImage imageNamed:@"star-grey"]  forState:UIControlStateNormal];
            [self.star5 setBackgroundImage:[UIImage imageNamed:@"star-grey"]  forState:UIControlStateNormal];
        }
            break;
        case 4:{
            [self.star5 setBackgroundImage:[UIImage imageNamed:@"star-grey"]  forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
    
    self.sellerRatings = [NSString stringWithFormat:@"%i",ratings];
    
}


- (IBAction)completeRatingsPressed:(id)sender {
    
    
    
    if ([self.sellerRatings isEqualToString:@"0"]){
        
    }
    else if (self.completedOrder!=nil){
        [API updateRatingSalesOrder:[self.completedOrder objectForKey:@"orderId"] withRatings:self.sellerRatings
                            success:^(NSDictionary *dict){
                                
                            } failure:^(NSString *message) {
                                NSLog(@"Fail");
                            }];
        [API addRatingsToBuyer:sellerDict rating:[self.sellerRatings intValue]
                       success:^{
                           
                       } failure:^(NSString *message) {
                           NSLog(@"Fail");
                       }];
        
    }
    
    self.navigationController.navigationBarHidden=NO;
    [self.navigationController popViewControllerAnimated:NO];
}
#pragma mark - Buttons
@end

