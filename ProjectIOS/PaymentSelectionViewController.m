//
//  PaymentSelectionViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 11/11/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "PaymentSelectionViewController.h"

@interface PaymentSelectionViewController ()

@end

@implementation PaymentSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.keyboardToolbar = [[UIToolbar alloc] init];
    [self.keyboardToolbar sizeToFit];
    self.keyboardSaveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(saveButtonTapped:)];
    self.keyboardAddButton = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(saveButtonTapped:)];
    UIBarButtonItem *flexibleSpace =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    if (self.type==2){
        [self.keyboardToolbar setItems:[NSArray arrayWithObjects:flexibleSpace,self.keyboardAddButton,flexibleSpace, nil]];
    }else{
        self.mainLabel.text = @"Edit Card Details";
        [self.keyboardToolbar setItems:[NSArray arrayWithObjects:flexibleSpace,self.keyboardSaveButton,flexibleSpace, nil]];
    }
    self.cardNumberTextField.inputAccessoryView= self.keyboardToolbar;
    [self.cardNumberTextField becomeFirstResponder];
    
    
    
    self.createCreditCardView.hidden=YES;
}

-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"Token: %@",self.card.tokenIdentifier);
    NSLog(@"Card: %@",self.card.maskedPan);
    UIBarButtonItem *flexibleSpace =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    switch (self.type) {
        case 0:
        {
            [self.cardNumberTextField resignFirstResponder];
            self.createCreditCardView.hidden=YES;
        }
            break;
        case 1:
            self.createCreditCardView.hidden=NO;
            self.mainLabel.text = @"Edit Card Details";
            [self.keyboardToolbar setItems:[NSArray arrayWithObjects:flexibleSpace,self.keyboardSaveButton,flexibleSpace, nil]];
            
            self.cardNumberTextField.text = [NSString stringWithFormat:@"**********%@",self.card.maskedPan];// mastercard
            
            
            break;
        case 2:
            self.createCreditCardView.hidden=NO;
            self.mainLabel.text = @"Add Payments";
            [self.keyboardToolbar setItems:[NSArray arrayWithObjects:flexibleSpace,self.keyboardAddButton,flexibleSpace, nil]];
            self.cardNumberTextField.text = @"4123450131001522";    //@"5123456789012346"; mastercard
            self.expiryTextField.text = @"2019/05";//@"12";
            self.ccvTextField.text = @"123";
            self.countryTextField.text = @"Philippines";
            break;
        default:
            break;
    }
//    [self.apiManager deletePayMayaCustomer:self.customerID successBlock:^(id response){
//        NSLog(@"Success: %@", response);
//    }failureBlock:^(NSError *error) {
//        NSLog(@"Fail: %@", error);
//    }];
//
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)saveButtonTapped:(id)sender{
    [[API sharedManager] createPayMayaCustomer:@"Kimi1" middleName:nil lastName:@"Tyler" birthday:nil sex:nil phone:nil email:[FIRAuth auth].currentUser.email streetline1:nil line2:nil city:nil state:nil zipCode:nil countryCode:nil
                                        success:^(id data){

//                                            NSData *customerData = [[NSUserDefaults standardUserDefaults] objectForKey:@"PayMayaSDKCustomer"];
//                                            PMDCustomer *customer = [NSKeyedUnarchiver unarchiveObjectWithData:customerData];
//                                            self.customerID = customer.identifier;
//
                                            //if (self.customerID!=nil){
                                                if (self.card!=nil){
                                                    [[API sharedManager] deletePaymentCustomerCard:self.card.tokenIdentifier customerID:[[NSUserDefaults standardUserDefaults] objectForKey:@"paymayaId"]
                                                                                      successBlock:^(id response){
                                                                                          [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PayMayaCustomerCard"];
                                                                                          [self performSelectorOnMainThread:@selector(createCard) withObject:nil waitUntilDone:YES];
                                                                                      }failureBlock:^(NSError *error) {
                                                                                          [self performSelectorOnMainThread:@selector(createCard) withObject:nil waitUntilDone:YES];
                                                                                          
                                                                                      }];
                                                }else
                                                    
                                                    [self createCard];
                                            //}
                                            
                                            
                                        } failure:^(NSString *message) {
                                            NSLog(@"Fail Get Orders");
                                        }];


    
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - PayMayaPaymentsDelegate
-(void)createCard{
    // temporary
    self.type=2;
    
    if (self.type==2){
        PMSDKCard *card = [[PMSDKCard alloc] init];
        card.number = self.cardNumberTextField.text;
        card.expiryMonth = @"05";//@"12";
        card.expiryYear = @"2019";
        card.cvc = self.ccvTextField.text;
        [SVProgressHUD show];
        [[PayMayaSDK sharedInstance] createPaymentTokenFromCard:card delegate:self];
    }
}
- (void)createPaymentTokenDidFinishWithResult:(PMSDKPaymentTokenResult *)result
{
    NSString *paymentTokenStatus;
    
    if (result.status == PMSDKPaymentTokenStatusCreated) {
        paymentTokenStatus = @"Created";
    }
    [self vaultCardWithPaymentToken:result.paymentToken];
    
//    if (self.state == PMDCardInputViewControllerStatePayments) {
//        [self executePaymentWithPaymentToken:result.paymentToken];
//    }
//    else if (self.state == PMDCardInputViewControllerStateCardVault) {
//        [self vaultCardWithPaymentToken:result.paymentToken];
//    }
}

- (void)executePaymentWithPaymentToken:(PMSDKPaymentToken *)paymentToken
{
    
    NSLog(@"executePaymentWithPaymentToken:%@",paymentToken);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.paymentTokenTextField.text = paymentToken.identifier;
//        self.paymentTokenLabel.hidden = NO;
//        self.paymentTokenTextField.hidden = NO;
//        self.duplicateTokenButton.hidden = NO;
//    });
//
//    [self.apiManager executePaymentWithPaymentToken:paymentToken.identifier
//                                 paymentInformation:self.paymentInformation
//                                       successBlock:^(id response) {
//                                           dispatch_async(dispatch_get_main_queue(), ^{
//                                               self.navigationItem.hidesBackButton = NO;
//                                               self.generateTokenButton.enabled = YES;
//                                               self.activityIndicatorView.alpha = 0.0f;
//
//                                               UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Payment Successful"
//                                                                                                              message:nil
//                                                                                                       preferredStyle:UIAlertControllerStyleAlert];
//                                               UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                                                                                     handler:^(UIAlertAction * action) {}];
//                                               [alert addAction:defaultAction];
//                                               [self presentViewController:alert animated:YES completion:nil];
//                                           });
//                                       } failureBlock:^(NSError *error) {
//                                           NSLog(@"Error: %@", error);
//                                           dispatch_async(dispatch_get_main_queue(), ^{
//                                               UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Payment Error"
//                                                                                                              message:error.userInfo[NSLocalizedDescriptionKey]
//                                                                                                       preferredStyle:UIAlertControllerStyleAlert];
//                                               UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                                                                                     handler:^(UIAlertAction * action) {}];
//                                               [alert addAction:defaultAction];
//                                               [self presentViewController:alert animated:YES completion:nil];
//
//                                               self.navigationItem.hidesBackButton = NO;
//                                               self.generateTokenButton.enabled = YES;
//                                               self.activityIndicatorView.alpha = 0.0f;
//                                           });
//                                       }];
}

- (void)vaultCardWithPaymentToken:(PMSDKPaymentToken *)paymentToken
{
    NSLog(@"vaultCardWithPaymentToken: %@",paymentToken);
    __weak typeof(self)weakSelf = self;
    
    
    [self.apiManager vaultCardWithPaymentTokenID:paymentToken.identifier
                                      customerID:self.customerID
                                    successBlock:^(NSDictionary *response) {
                                        __strong typeof(weakSelf)strongSelf = weakSelf;
                                        NSString *key = [NSString stringWithFormat:@"%@_VERIFICATION_URL", response[@"cardTokenId"]];
                                        [[NSUserDefaults standardUserDefaults] setObject:response[@"verificationUrl"] forKey:key];
                                        [[NSUserDefaults standardUserDefaults] synchronize];

                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            
                                            [SVProgressHUD dismiss];
                                            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Card Vault Successful"
                                                                                                           message:@"Card is successfully vaulted. Please verify card use it for payment."
                                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                PMDVerifyCardViewController *verifyCardViewController = [[PMDVerifyCardViewController alloc] initWithCheckoutURL:response[@"verificationUrl"] redirectUrl:self.apiManager.baseUrl];
                                                verifyCardViewController.title = @"Verify Card";
                                                verifyCardViewController.delegate = self;
                                                UINavigationController *verifyCardNavigationController = [[UINavigationController alloc] initWithRootViewController:verifyCardViewController];
                                                [strongSelf presentViewController:verifyCardNavigationController animated:YES completion:nil];
                                            }];
                                            [alert addAction:defaultAction];
                                            [strongSelf presentViewController:alert animated:YES completion:nil];
                                            
                                        });
                                    } failureBlock:^(NSError *error) {
                                        NSLog(@"Error: %@", error);
                                        __strong typeof(weakSelf)strongSelf = weakSelf;
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Card Vault Error"
                                                                                                           message:error.userInfo[NSLocalizedDescriptionKey]
                                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                                                  handler:^(UIAlertAction * action) {}];
                                            [alert addAction:defaultAction];
                                            [strongSelf presentViewController:alert animated:YES completion:nil];

                                        });
                                    }];
}

- (void)createPaymentTokenDidFailWithError:(NSError *)error
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.navigationItem.hidesBackButton = NO;
//        self.generateTokenButton.enabled = YES;
//        self.activityIndicatorView.alpha = 0.0f;
        NSLog(@"Error: %@", error);
//    });
}
#pragma mark - PMDVerifyCardViewControllerDelegate

- (void)verifyCardViewControllerDidFinishCardVerification:(PMDVerifyCardViewController *)verifyCardViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
