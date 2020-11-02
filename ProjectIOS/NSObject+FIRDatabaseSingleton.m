//
//  NSObject+FIRDatabaseSingleton.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 16/09/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "NSObject+FIRDatabaseSingleton.h"



@interface FIRDatabaseSingleton()
@end

@implementation FIRDatabaseSingleton:NSObject
static FIRDatabaseSingleton *manager = nil;
static FIRDatabaseSingleton *managerSeller = nil;


+ (FIRDatabaseSingleton *)sharedManager
{
    if (manager == nil) {
        manager = [[self alloc] init];
    }
    
    return manager;
}
+ (FIRDatabaseSingleton *)sharedManagerSeller
{
    if (managerSeller == nil) {
        managerSeller = [[self alloc] initSeller];
    }
    
    return manager;
}
+ (FIRDatabaseSingleton *)restartSharedManager
{
    manager = [[self alloc] init];
    
    return manager;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        self.mainFirebaseReference=[[FIRDatabase database] reference];
        self.storageRef = [[FIRStorage storage] reference];
        
        if (![[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] isEqualToString:@"Main"]){
            return self;
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        int lastUpdate = [[defaults objectForKey:@"lastUpdate"] intValue];
        
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"CashDefault"]==nil){
            [defaults setObject:@"Yes" forKey:@"CashDefault"];
        }
        
        
        [API getGlobal:^(NSDictionary *dict){
            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            if (![version isEqualToString:[dict objectForKey:@"buyerVersion"]]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"incorrectVersion" object:nil userInfo:nil];
            }else{
                
                NSString *paymayaUrl = [dict objectForKey:GATEWAY];
                
                [defaults setObject:[dict objectForKey:GATEWAY] forKey:GATEWAY];
                [defaults setObject:[dict objectForKey:SERVICEFEE] forKey:SERVICEFEE];
                [defaults setObject:[dict objectForKey:SERVICEFEECURRENCY] forKey:SERVICEFEECURRENCY];
                [defaults setObject:[dict objectForKey:INCENTIVE] forKey:INCENTIVE];
                [defaults setObject:[dict objectForKey:INCENTIVECURRENCY] forKey:INCENTIVECURRENCY];
                
                [[API sharedManager] setApiManager:[[PMDAPIManager alloc] initWithBaseUrl:paymayaUrl accessToken:@"XQFQeOngOKxxISokWt3fYP+LfgCW/eNUy1mNBxa8L2Zn/VBVx0p21Sh5BG3dy7oa"]];
            }
        } failure:^(NSString *message) {
            NSLog(@"Fail");
        }];
        
        
        [API getNewProductsMaster:lastUpdate
                          success:^{
                              
                          } failure:^(NSString *message) {
                              NSLog(@"Fail Get New Products");
                          }];
        
        if ([FIRAuth auth].currentUser.uid==nil){
            return self;
        }
        
        [API getAllActiveOrders:[FIRAuth auth].currentUser.uid
                      queryType:FIRDataEventTypeValue
                        success:^(id data){
                            for (NSDictionary *dict in data){
                                
                                NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:[[dict objectForKey:@"orderDate"] integerValue]];
                                
                                BOOL addis = YES;
                                if ([date timeIntervalSinceNow]>-7200){
                                    [[[Orders sharedManager]activeOrders] addObject:dict];
                                }else{
                                    if ([[dict objectForKey:@"status"] isEqualToString:@"Completed"] || [[dict objectForKey:@"status"] isEqualToString:@"Closed"]){
                                        [[[Orders sharedManager]activeOrders] addObject:dict];
                                    }else{
                                        addis=NO;
                                        [API updateSalesOrder:[dict objectForKey:@"orderId"] withStatus:@"Expired" withSellerId:@"-" withItems:[dict objectForKey:@"orderItems"] withDict:dict
                                                      success:^(NSDictionary *dict){
                                                          [API deleteProposals:[dict objectForKey:@"orderId"]
                                                                       success:^(NSDictionary *dict){
                                                                           
                                                                           
                                                                       } failure:^(NSString *message) {
                                                                           NSLog(@"Fail");
                                                                       }];
                                                      } failure:^(NSString *message) {
                                                          NSLog(@"Fail");
                                                      }];
                                        
                                        
                                    }
                                }
                                
                                
                                NSLog(@"%@",dict);
                                if (addis==YES){
                                    if ([[dict objectForKey:@"status"] isEqualToString:@"Pending"] || [[dict objectForKey:@"status"] isEqualToString:@"Accepted"] || [[dict objectForKey:@"status"] isEqualToString:@"On The Way"]){
                                        if(![[[Orders sharedManager]sellersWithActiveOrders] containsObject:[dict objectForKey:@"sellerId"]]){
                                            [[[Orders sharedManager]sellersWithActiveOrders] addObject:[dict objectForKey:@"sellerId"]];
                                        }
                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTab" object:dict userInfo:@{@"tab" : [NSNumber numberWithInt:1]}];// show map
                                    }else if ([[dict objectForKey:@"status"] isEqualToString:@"Completed"]){
                                        
                                        if ([[dict objectForKey:@"paymentMode"] isEqualToString:@"Credit"]){
                                            
                                            //                                            [[API sharedManager] createCheckoutPayment:@{@"amount" : [dict objectForKey:@"totalPrice"],@"currency" : [[dict objectForKey:@"currency"] uppercaseString]}
                                            //                                                                          successBlock:^(id response){
                                            //                                                                          }failureBlock:^(NSError *error) {}];
                                        }
                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"CompletedOrder" object:dict];
                                    }else if (!([[dict objectForKey:@"status"] isEqualToString:@"Closed"] || [[dict objectForKey:@"status"] isEqualToString:@"Expired"])){
                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTab" object:dict userInfo:@{@"tab" : [NSNumber numberWithInt:3]}];// show proposals
                                    }
                                }
                            }
                            
                        } failure:^(NSString *message) {
                            NSLog(@"Fail Get Orders");
                        }];
    }
    return self;
}

- (id)initSeller
{
    self = [super init];
    
    if (self) {
        self.mainFirebaseReference=[[FIRDatabase database] reference];
        self.storageRef = [[FIRStorage storage] reference];
        
        if ([[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] isEqualToString:@"Main"]){
            return self;
        }
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if (![[defaults objectForKey:MAP_ROUTING_TYPE]isEqualToString:@"driving"]){
            [defaults setObject:@"walking" forKey:MAP_ROUTING_TYPE];
        }
        
        if (!([[defaults objectForKey:MAP_ROUTING_DIST]isEqualToString:@"500"] || [[defaults objectForKey:MAP_ROUTING_DIST]isEqualToString:@"100"] || [[defaults objectForKey:MAP_ROUTING_DIST]isEqualToString:@"50"])){
            [defaults setObject:@"100" forKey:MAP_ROUTING_DIST];
        }
        
        int lastUpdate = [[defaults objectForKey:@"lastUpdate"] intValue];
        [defaults setObject:[NSNumber numberWithFloat:0]  forKey:@"credits"];
        
        [API getGlobal:^(NSDictionary *dict){
            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            if (![version isEqualToString:[dict objectForKey:@"sellerVersion"]]){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"incorrectVersion" object:nil userInfo:nil];
            }else{
                
                
                NSString *paymayaUrl = [dict objectForKey:GATEWAY];
                
                [defaults setObject:[dict objectForKey:GATEWAY] forKey:GATEWAY];
                [defaults setObject:[dict objectForKey:SERVICEFEE] forKey:SERVICEFEE];
                [defaults setObject:[dict objectForKey:SERVICEFEECURRENCY] forKey:SERVICEFEECURRENCY];
                [defaults setObject:[dict objectForKey:INCENTIVE] forKey:INCENTIVE];
                [defaults setObject:[dict objectForKey:INCENTIVECURRENCY] forKey:INCENTIVECURRENCY];
                
                [[API sharedManager] setApiManager:[[PMDAPIManager alloc] initWithBaseUrl:paymayaUrl accessToken:@"XQFQeOngOKxxISokWt3fYP+LfgCW/eNUy1mNBxa8L2Zn/VBVx0p21Sh5BG3dy7oa"]];
            }
        } failure:^(NSString *message) {
            NSLog(@"Fail");
        }];
        
        
        [API getNewProductsMaster:lastUpdate
                          success:^{
                              
                          } failure:^(NSString *message) {
                              NSLog(@"Fail Get New Products");
                          }];
        if ([FIRAuth auth].currentUser.uid==nil){
            return self;
        }
        [API getSellerDetails:[FIRAuth auth].currentUser.uid
                    eventType:FIRDataEventTypeValue
                      success:^(NSDictionary *dict){
                          
                          if (![dict isKindOfClass:[NSNull class]]){
                              [defaults setObject:[dict objectForKey:@"postalCode"] forKey:USER_ZIP_CODE];
                              
                              if ([dict objectForKey:@"name"]){
                                  [defaults setObject:[dict objectForKey:@"name"] forKey:@"name"];
                              }else{
                                  [defaults setObject:[NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"firstName"],[dict objectForKey:@"lastName"]] forKey:@"name"];
                                  
                              }
                              [defaults setObject:[dict objectForKey:@"mobileNumber"] forKey:@"mobileNumber"];
                              [defaults setObject:[dict objectForKey:@"sellerId"] forKey:@"sellerId"];
                              [defaults setObject:[dict objectForKey:@"ratings"] forKey:@"sellerRatings"];
                              [defaults setObject:[dict objectForKey:@"pid"] forKey:@"paymayaId"];
                          }
                          
                          [API getSingleDebit:[FIRAuth auth].currentUser.uid
                                    queryType:FIRDataEventTypeChildAdded
                                      success:^(NSDictionary *dict){
                                          [[[DataSingletons sharedManager]paymentHistory] addObject:dict];
                                          float credit = [[defaults objectForKey:@"credits"] floatValue]- [[dict objectForKey:@"amount"] floatValue];
                                          [defaults setObject:[NSNumber numberWithFloat:credit]  forKey:@"credits"];
                                          
                                      } failure:^(NSString *message) {
                                          NSLog(@"Fail");
                                      }];
                          [API getSingleCredit:[FIRAuth auth].currentUser.uid
                                     queryType:FIRDataEventTypeChildAdded
                                       success:^(NSDictionary *dict2){
                                           [[[DataSingletons sharedManager]paymentHistory] addObject:dict2];
                                           
                                           float total = [[defaults objectForKey:@"credits"] floatValue]+ [[dict2 objectForKey:@"amount"] floatValue];
                                           [defaults setObject:[NSNumber numberWithFloat:total]  forKey:@"credits"];
                                           
                                       } failure:^(NSString *message) {
                                           NSLog(@"Fail");
                                       }];
                          
                          
                          
                      } failure:^(NSString *message) {
                          NSLog(@"Fail");
                      }];
        
        
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTab" object:nil userInfo:@{@"tab" : [NSNumber numberWithInt:2]}];
    
    
    
    
    return self;
}

-(void)stopSellerOrdersMonitor{
    
    [[[DataSingletons sharedManager]sellerOrdersReference] removeAllObservers];
    
    //    [[[DataSingletons sharedManager]sellerOrdersReference] removeObserverWithHandle:[[DataSingletons sharedManager]zipAddedhandle]];
    //    [[[DataSingletons sharedManager]sellerOrdersReference] removeObserverWithHandle:[[DataSingletons sharedManager]zipDeletedhandle]];
    //    [[[DataSingletons sharedManager]sellerOrdersReference] removeObserverWithHandle:[[DataSingletons sharedManager]zipCangedhandle]];
    //
    //    [[[DataSingletons sharedManager]sellerOrdersReference] removeObserverWithHandle:[[DataSingletons sharedManager]zipUserAddedhandle]];
    //    [[[DataSingletons sharedManager]sellerOrdersReference] removeObserverWithHandle:[[DataSingletons sharedManager]zipUserCangedhandle]];
    //    [[[DataSingletons sharedManager]sellerOrdersReference] removeObserverWithHandle:[[DataSingletons sharedManager]zipUserDeletedhandle]];
}

@end





