//
//  OrderPopoverViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 10/06/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import "OrderPopoverViewController.h"

@implementation OrderPopoverViewController

-(void)viewDidLoad{
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    FIRStorageReference *storageRef = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"gs://e-utos.appspot.com/profile/%@.jpg",self.userId]];
    [self.profileImageView sd_setImageWithStorageReference:storageRef placeholderImage:[UIImage imageNamed:@"profileImage"]];
    self.profileImageView.layer.cornerRadius=30;
    self.profileImageView.layer.masksToBounds=YES;
    self.profileImageView.layer.borderWidth = 3.0f;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImageView.hidden=NO;
    
    if ([[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] isEqualToString:@"Main"]){
        Seller *seller=[API getSeller:[self.orderDict objectForKey:@"sellerId"]];
        self.userLabel.text =[NSString stringWithFormat:@"Seller %@",seller.name];
        self.contactDetail.text = seller.mobileNumber;

    }else{
        Buyer *buyer =[API getBuyer:[self.orderDict objectForKey:@"buyerId"]];
        self.userLabel.text =[NSString stringWithFormat:@"Buyer %@",buyer.name];
        self.contactDetail.text = buyer.mobileNumber;
    }
    self.statusLabel.text=[self.orderDict objectForKey:@"status"];
    if ([[self.orderDict objectForKey:@"status"] isEqualToString:@"On The Way"]){
        self.statusLabel.text=@"Seller En Route";
    }else {
        
    }
        
    
    self.amountLabel.text=[NSString stringWithFormat:@"Amount: %@ %@",[self.orderDict objectForKey:@"currency"],[self.orderDict objectForKey:@"totalPrice"]];
    self.ordersLabel.text=@"";
    for (NSDictionary*prod in [self.orderDict objectForKey:@"salesItem"]){
        NSDictionary *productDetail= [[API productsDetailArrayUsingSearch:[NSString stringWithFormat:@"productId contains '%@'", [prod objectForKey:@"productId"]]] firstObject];
        if (productDetail!=nil){
        self.ordersLabel.text = [NSString stringWithFormat:@"%@\r%@",self.ordersLabel.text,[productDetail objectForKey:@"productName"]];
        }
    }
    
}
-(void)viewDidAppear:(BOOL)animated{
    //self.profileImageLeft.constant=(self.popupView.frame.size.width/2)-30;
    self.profileImageView.hidden=NO;
    if ([[self.orderDict objectForKey:@"status"] isEqualToString:@"Accepted"]){
        //self.showButton.titleLabel.text = @"Ok";
    }
}

- (IBAction)showButtonPressed:(id)sender {
    if ([self.showButton.titleLabel.text isEqualToString:@"Ok"]){
        [self.delegate onTheWay:self.orderDict];
    }else{
        [self.delegate gotoMap];
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
