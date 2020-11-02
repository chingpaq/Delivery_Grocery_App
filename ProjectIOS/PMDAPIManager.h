//
//  PMDAPIManager.h
//  PayMayaSDK
//
//  Created by Elijah Cayabyab on 26/02/2016.
//  Copyright © 2016 PayMaya Philippines, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMDAPIManager : NSObject

@property (nonatomic, strong, readonly) NSString *baseUrl;

- (instancetype)initWithBaseUrl:(NSString *)baseUrl accessToken:(NSString *)accessToken;

- (void)getCustomerSuccessBlock:(void (^)(id))successBlock
                   failureBlock:(void (^)(NSError *))failureBlock;

- (void)createCustomerWithInfo:(NSDictionary*)customerDict
                  successBlock:(void (^)(id))successBlock
                  failureBlock:(void (^)(NSError *))failureBlock;

- (void)deletePayMayaCustomer:(NSString*)customerID
                  successBlock:(void (^)(id))successBlock
                  failureBlock:(void (^)(NSError *))failureBlock;

- (void)getCardListWithCustomerID:(NSString *)customerID
                     successBlock:(void (^)(id))successBlock
                     failureBlock:(void (^)(NSError *))failureBlock;

- (void)vaultCardWithPaymentTokenID:(NSString *)paymentTokenID
                         customerID:(NSString *)customerID
                       successBlock:(void (^)(id))successBlock
                       failureBlock:(void (^)(NSError *))failureBlock;

- (void)deletePayMayaCustomerCard:(NSString*)cardID
                            customerID:(NSString*)customerID
                          successBlock:(void (^)(id))successBlock
                          failureBlock:(void (^)(NSError *))failureBlock;


- (void)executePaymentWithCustomerID:(NSString *)customerID
                              cardID:(NSString *)cardID
                         totalAmount:(NSDictionary *)totalAmount
                        successBlock:(void (^)(id))successBlock
                        failureBlock:(void (^)(NSError *))failureBlock;

- (void)executePaymentWithPaymentToken:(NSString *)paymentToken
                    paymentInformation:(NSDictionary *)paymentInformation
                          successBlock:(void (^)(id))successBlock
                          failureBlock:(void (^)(NSError *))failureBlock;

@end
