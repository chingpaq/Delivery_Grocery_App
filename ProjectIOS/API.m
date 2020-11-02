//
//  API.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 27/09/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "API.h"

@implementation API

static API *manager = nil;

+ (API *)sharedManager;{
    if (manager == nil) {
        manager = [[self alloc] init];
    }
    
    return manager;
}

- (id)init{
    self = [super init];
    
    if (self) {
        //self.apiManager = [[PMDAPIManager alloc] initWithBaseUrl:@"http://13.229.99.182:1337" accessToken:@"XQFQeOngOKxxISokWt3fYP+LfgCW/eNUy1mNBxa8L2Zn/VBVx0p21Sh5BG3dy7oa"];
        
        // Setting up Paymaya
        // setup https://github.com/PayMaya/PayMaya-Payments-Skeleton-Backend
        // put your Secret API Key to the config/env/development.js file, run node app.js
        // browse for http://localhost:1337/register
        // register and get access access token put it in apiManager
        
        
    }
    return self;
}

#pragma mark - Paymaya API

-(void)createPayMayaCustomer:(NSString*)firstName
                  middleName:(NSString*)middleName
                    lastName:(NSString*)lastName
                    birthday:(NSString*)birthday
                         sex:(NSString*)sex
                       phone:(NSString*)phone
                       email:(NSString*)email
                 streetline1:(NSString*)line1
                       line2:(NSString*)line2
                        city:(NSString*)city
                       state:(NSString*)state
                     zipCode:(NSString*)zipCode
                 countryCode:(NSString*)countryCode
                     success:(void (^)(id data))success
                     failure:(void (^)(NSString *message))failure {
    // Get customer ID - temporary
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"paymayaId"]){
        //if ([[NSUserDefaults standardUserDefaults] objectForKey:@"PayMayaSDKCustomer"]) {
        NSDictionary *customer=@{};
        
        if (firstName.length==0 || middleName.length==0 || lastName.length==0 || birthday.length==0 || sex.length==0 || phone.length==0 ||email.length==0||line2.length==0||city.length==0||state.length==0||zipCode.length==0||countryCode.length==0){
            if (firstName.length>0 && lastName.length>0 && email.length>0 ){
                customer = @{
                             @"firstName": firstName,
                             @"lastName": lastName,
                             @"contact": @{
                                     @"email": email
                                     }
                             };
            }
        }
        else{
            customer = @{
                         @"firstName": firstName,
                         @"middleName": middleName,
                         @"lastName": lastName,
                         @"birthday": birthday,
                         @"sex": sex,
                         @"contact": @{
                                 @"phone": phone,
                                 @"email": email
                                 },
                         @"billingAddress": @{
                                 @"line1": line1,
                                 @"line2": line2,
                                 @"city": city,
                                 @"state": state,
                                 @"zipCode": zipCode,
                                 @"countryCode": countryCode
                                 },
                         @"metadata": @{}
                         };
        }
        
        
        
        [self.apiManager createCustomerWithInfo:customer successBlock:^(id response) {
            PMDCustomer *customer = [[PMDCustomer alloc] init];
            customer.identifier = response[@"id"];
            [customer parseValuesForKeysWithDictionary:response];
            
            NSData *customerData = [NSKeyedArchiver archivedDataWithRootObject:customer];
            [[NSUserDefaults standardUserDefaults] setObject:customerData forKey:@"PayMayaSDKCustomer"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSString *tableName;
            if ([[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] isEqualToString:@"Main"]){
                tableName=@"buyers";
            }else{
                tableName=@"sellers";
            }
            [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:tableName] child:[FIRAuth auth].currentUser.uid]
             updateChildValues:@{@"pid": customer.identifier}withCompletionBlock:^(NSError* _Nullable error, FIRDatabaseReference * _Nonnull ref){
                 if (error==nil){
                     //[self.delegate customerInfo:customer];
                     success(customer);
                 }else{
                     
                 }
             }];
            //[self.delegate customerInfo:customer];
            
        } failureBlock:^(NSError *error) {
            NSLog(@"Error: %@", error);
            failure(error.description);
        }];
    }else{
        success(@"");
    }
}

-(void)getCreditCardToken:(void (^)(id))successBlock
             failureBlock:(void (^)(NSError *))failureBlock{
    
    NSData *customerData = [[NSUserDefaults standardUserDefaults] objectForKey:@"PayMayaSDKCustomer"];
    PMDCustomer *customer = [NSKeyedUnarchiver unarchiveObjectWithData:customerData];
    //if ([[NSUserDefaults standardUserDefaults] objectForKey:@"paymayaId"]){
    //if (customer!=nil){
    
    //[self.apiManager getCardListWithCustomerID:customer.identifier
    [self.apiManager getCardListWithCustomerID:[[NSUserDefaults standardUserDefaults] objectForKey:@"paymayaId"] successBlock:^(NSDictionary *response) {
        
        for (NSDictionary *cardInfo in response) {
            
            PMDCard *card = [[PMDCard alloc] init];
            card.tokenIdentifier = cardInfo[@"cardTokenId"];
            card.type = cardInfo[@"cardType"];
            if ([cardInfo[@"state"] isEqualToString:@"VERIFIED"]) {
                card.maskedPan = cardInfo[@"maskedPan"];
            }else{
                card.maskedPan = [NSString stringWithFormat:@"%@ (Unverified)",cardInfo[@"maskedPan"]];
            }
            card.state = cardInfo[@"state"];
            
            NSData *customerData = [NSKeyedArchiver archivedDataWithRootObject:card];
            [[NSUserDefaults standardUserDefaults] setObject:customerData forKey:@"PayMayaCustomerCard"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            successBlock(card);
            break;
            
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Error: %@", error);
        failureBlock(error);
    }];
    //}
}

- (void)deletePaymentCustomerCard:(NSString*)cardID
                       customerID:(NSString*)customerID
                     successBlock:(void (^)(id))successBlock
                     failureBlock:(void (^)(NSError *))failureBlock{
    
    [self.apiManager deletePayMayaCustomerCard:cardID customerID:customerID
                                  successBlock:^(id response){
                                      successBlock(response);
                                  }failureBlock:^(NSError *error) {
                                      failureBlock(error);
                                  }];
}

-(void) createCheckoutPayment:(NSDictionary*)totalPayment
                 successBlock:(void (^)(id))successBlock
                 failureBlock:(void (^)(NSError *))failureBlock{
    
    [self getCreditCardToken:^(id response) {
        PMDCard *card = response;
        [self.apiManager executePaymentWithCustomerID:[[NSUserDefaults standardUserDefaults] objectForKey:@"paymayaId"] cardID:card.tokenIdentifier totalAmount:totalPayment successBlock:^(id response) {
            NSLog(@"%@",response);
            successBlock(response);
            [self.delegate paymentComplete:response];
        } failureBlock:^(NSError *error) {
            NSLog(@"Error: %@", error);
            failureBlock(error);
            [self.delegate paymentFailed:response];
        }];
        
        
    } failureBlock:^(NSError *error) {
        failureBlock(error);
        NSLog(@"Error: %@", error);
    }];
    
    
    
}

+(void) createPayMayaCheckoutPayment:(NSDictionary*)orderDict
                  withDelegateTarget:(id)delegate
                 successBlock:(void (^)(id))successBlock
                 failureBlock:(void (^)(NSError *))failureBlock{
    
    NSDictionary *totalAmount = @{
                                  @"currency" : [[orderDict objectForKey:@"currency"] uppercaseString],
                                  @"value" : [orderDict objectForKey:@"totalPrice"],
                                  @"details" : @{
                                          @"tax" : @"0.00",
                                          @"subtotal" : [orderDict objectForKey:@"totalPrice"]
                                          }
                                  };
    
    NSDictionary *address = @{
                              @"line1" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_STREET],
                              @"line2" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_STREET],
                              @"city" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_CITY],
                              @"state" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_STATE],
                              @"zipCode" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_ZIP_CODE],
                              @"countryCode" : @"PH"
                              };
    
    NSDictionary *buyer = @{
                            @"firstName" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_FIRST_NAME],
                            @"middleName" : @"-",
                            @"lastName" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_LAST_NAME],
                            @"contact" : @{
                                    @"phone" : [[NSUserDefaults standardUserDefaults] objectForKey:USER_MOBILE],
                                    @"email" : [[[FIRAuth auth] currentUser] email]
                                    },
                            @"shippingAddress" : address,
                            @"billingAddress" : address
                            };
    float servicefee = [[[NSUserDefaults standardUserDefaults] objectForKey:SERVICEFEE] floatValue];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSDictionary *productInfo in [orderDict objectForKey:@"salesItem"]) {

        NSDictionary *productDetail= [[API productsDetailArrayUsingSearch:[NSString stringWithFormat:@"productId contains '%@'", [productInfo objectForKey:@"productId"]]] firstObject];
        NSDictionary *item;
        if ([[productInfo objectForKey:@"productId"] isEqualToString:@"CFEE"]){
            item = @{
                     @"name" : @"Service Fee",
                     @"code" : @"CFEE",
                     @"description" : @"Service Fee",
                     @"quantity" : @"1",
                     @"amount" : @{
                             @"value" : [NSString stringWithFormat:@"%.2f",servicefee]
                             },
                     @"totalAmount" : @{
                             @"value" : [NSString stringWithFormat:@"%.2f",servicefee]
                             }
                     };
        }else{
            item = @{
                     @"name" : [productDetail objectForKey:@"productName"],
                     @"code" : [productInfo objectForKey:@"productId"],
                     @"description" : [productDetail objectForKey:@"description"],
                     @"quantity" : [NSString stringWithFormat:@"%i",[[productInfo objectForKey:@"quantity"] integerValue]],
                     @"amount" : @{
                             @"value" : [NSString stringWithFormat:@"%.2f",[[productInfo objectForKey:@"buyingPrice"] floatValue]]
                             },
                     @"totalAmount" : @{
                             @"value" : [NSString stringWithFormat:@"%.2f",([[productInfo objectForKey:@"buyingPrice"] floatValue]*[[productInfo objectForKey:@"quantity"] integerValue])]
                             }
                     };
        }
        [items addObject:item];
    }
    
    NSDictionary *checkoutDictionary = @{
                                         @"totalAmount" : totalAmount,
                                         @"buyer" : buyer,
                                         @"items" : items,
                                         @"requestReferenceNumber" : [orderDict objectForKey:@"orderId"],
                                         @"redirectUrl": @{
                                             @"success": @"http://www.success_paymaya.com",
                                             @"failure": @"http://www.askthemaya.com/failure?id=6319921",
                                             @"cancel": @"http://www.askthemaya.com/cancel?id=6319921"
                                         }};
    
    PMSDKCheckoutInformation *checkoutInformation = [[PMSDKCheckoutInformation alloc] initWithDictionary:checkoutDictionary];
    
//    PMSDKCheckoutInformation *checkoutInformation ;
    
    
    if (delegate!=nil){
        [[PayMayaSDK sharedInstance] checkout:checkoutInformation delegate:delegate];
    
        return;
    }else{
        [[PayMayaSDK sharedInstance] checkout:checkoutInformation result:^(PMSDKCheckoutResult* result, NSError *error) {
            if (error) {
                // handle error
                failureBlock(error);
            }
            else {
                //successBlock(checkoutDictionary);
                if (result.status == PMSDKCheckoutStatusUnknown) {
                    failureBlock(error);
                }
                else if (result.status == PMSDKCheckoutStatusCanceled) {
                    failureBlock(error);
                }
                else if (result.status == PMSDKCheckoutStatusFailed) {
                    failureBlock(error);
                }
                else if (result.status == PMSDKCheckoutStatusSuccess) {
                    successBlock(checkoutDictionary);
                }
            }
        }];
    }
}


#pragma mark - PayMayaPaymentsDelegate
- (void)createPaymentTokenDidFinishWithResult:(PMSDKPaymentTokenResult *)result
{
    [self executePaymentWithPaymentToken:result.paymentToken];
}

- (void)executePaymentWithPaymentToken:(PMSDKPaymentToken *)paymentToken
{
    
    NSLog(@"executePaymentWithPaymentToken:%@",paymentToken);
    
    [self.apiManager executePaymentWithPaymentToken:paymentToken.identifier
                                 paymentInformation:nil
                                       successBlock:^(id response) {
                                           NSLog(@"%@",response);
                                       } failureBlock:^(NSError *error) {
                                           NSLog(@"Error: %@", error);
                                       }];
}

- (void)createPaymentTokenDidFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

#pragma mark - Firebase APIs

#pragma mark *master data
+ (void)getGlobal:(void (^)(NSDictionary *dict))success
          failure:(void (^)(NSString *message))failure {
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[mainFirebaseReference child:@"global"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableDictionary *dict = snapshot.value;
        //[dict setObject:snapshot.key forKey:@"productId"];
        success(dict);
    }];
}
+ (void)getLatestPromos:(NSString*)active
                success:(void (^)(NSDictionary *dict))success
                failure:(void (^)(NSString *message))failure {
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[[[mainFirebaseReference child:@"products"]queryOrderedByChild:@"promo"]queryEqualToValue:active] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableDictionary *dict = snapshot.value;
        [dict setObject:snapshot.key forKey:@"productId"];
        success(dict);
    }];
}

+ (void)getAds:(NSString*)active
     queryType:(FIRDataEventType)queryType
       success:(void (^)(NSArray *dict))success
       failure:(void (^)(NSString *message))failure {
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[[[mainFirebaseReference child:@"ads"]queryOrderedByChild:@"status"]queryEqualToValue:@"Active"] observeEventType:queryType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSEnumerator *children = [snapshot children];
        FIRDataSnapshot *child;
        NSMutableArray *arraym = [[NSMutableArray alloc]init];
        while (child = [children nextObject]) {
            NSMutableDictionary *dict = child.value;
            [arraym addObject:dict];
        }
        success(arraym);
        
        
    }];
}

+ (void)getProduct:(NSString*)productName
           success:(void (^)(NSDictionary *dict))success
           failure:(void (^)(NSString *message))failure {
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[[[mainFirebaseReference child:@"products"]queryOrderedByChild:@"productName"]queryEqualToValue:productName] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableDictionary *dict = snapshot.value;
        [dict setObject:snapshot.key forKey:@"productId"];
        [API addNewProducts:dict];
        success(dict);
    }];
}

+ (void)getProductById:(NSString*)productId
               success:(void (^)(NSDictionary *dict))success
               failure:(void (^)(NSString *message))failure {
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[[mainFirebaseReference child:@"products"]child:productId] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        
        NSMutableDictionary *dict = snapshot.value;
        
        if (dict != (NSDictionary*) [NSNull null]){
            [dict setObject:snapshot.key forKey:@"productId"];
            [API addNewProducts:dict];
            success(dict);
        }
    }];
}


#pragma mark *transactions
+ (void)monitorActiveOrders:(NSString*)buyerId
                  queryType:(FIRDataEventType)queryType
                    success:(void (^)(NSDictionary *dict))success
                    failure:(void (^)(NSString *message))failure {
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[[[mainFirebaseReference child:@"orders"]queryOrderedByChild:@"buyerId"]queryEqualToValue:buyerId] observeEventType:queryType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableDictionary *dict = snapshot.value;
        [dict setObject:snapshot.key forKey:@"orderId"];
        success(dict);
    }];
}

+ (void)getAllActiveOrders:(NSString*)buyerId
                 queryType:(FIRDataEventType)queryType
                   success:(void (^)(id data))success
                   failure:(void (^)(NSString *message))failure {
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[[[mainFirebaseReference child:@"orders"]queryOrderedByChild:@"buyerId"]queryEqualToValue:buyerId] observeSingleEventOfType:queryType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (queryType==FIRDataEventTypeChildChanged){
            NSMutableDictionary *data = snapshot.value;
            [data setObject:snapshot.key forKey:@"orderId"];
            success(data);
        }else if (queryType==FIRDataEventTypeValue){
            NSEnumerator *children = [snapshot children];
            FIRDataSnapshot *child;
            NSMutableArray *arraym = [[NSMutableArray alloc]init];
            while (child = [children nextObject]) {
                NSMutableDictionary *dict = child.value;
                [dict setObject:child.key forKey:@"orderId"];
                NSLog(@"%@", dict);
                [arraym addObject:dict];
            }
            success(arraym);
        }
    }];
}
+ (void)getOrdersByPostal:(NSString*)postalCode
                queryType:(FIRDataEventType)queryType
                  success:(void (^)(id data))success
                  failure:(void (^)(NSString *message))failure {
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    
    [[[[mainFirebaseReference child:@"orders"]queryOrderedByChild:@"psid"]queryEqualToValue:postalCode] observeSingleEventOfType:queryType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (queryType==FIRDataEventTypeValue){
            NSEnumerator *children = [snapshot children];
            FIRDataSnapshot *child;
            NSMutableArray *arraym = [[NSMutableArray alloc]init];
            while (child = [children nextObject]) {
                NSMutableDictionary *dict = child.value;
                [dict setObject:child.key forKey:@"orderId"];
                NSLog(@"%@", dict);
                [arraym addObject:dict];
            }
            success(arraym);
        }else{
            NSMutableDictionary *data = snapshot.value;
            [data setObject:snapshot.key forKey:@"orderId"];
            success(data);
        }
    }];
}


+ (NSDictionary*)monitorOrdersByPostal:(NSString*)postalCode
                             queryType:(FIRDataEventType)queryType
                               success:(void (^)(id data))success
                               failure:(void (^)(NSString *message))failure {
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabaseSingleton sharedManager] mainFirebaseReference];
    FIRDatabaseReference *reference = [mainFirebaseReference child:@"orders"];
    FIRDatabaseHandle fbhandle =[[[reference queryOrderedByChild:@"psid"]queryEqualToValue:postalCode] observeEventType:queryType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (queryType==FIRDataEventTypeValue){
            NSEnumerator *children = [snapshot children];
            FIRDataSnapshot *child;
            NSMutableArray *arraym = [[NSMutableArray alloc]init];
            while (child = [children nextObject]) {
                NSMutableDictionary *dict = child.value;
                [dict setObject:child.key forKey:@"orderId"];
                NSLog(@"%@", dict);
                [arraym addObject:dict];
            }
            success(arraym);
        }else{
            NSMutableDictionary *data = snapshot.value;
            [data setObject:snapshot.key forKey:@"orderId"];
            success(data);
        }
    }];
    
    return @{@"handle" : [NSNumber numberWithLong:fbhandle],
             @"reference": reference
             };
    
}


#pragma mark *transactions
+ (void)getAllOrders:(NSString*)buyerId
           queryType:(FIRDataEventType)queryType
             success:(void (^)(NSArray *dict))success
             failure:(void (^)(NSString *message))failure {
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[[[mainFirebaseReference child:@"orders"]queryOrderedByChild:@"buyerId"]queryEqualToValue:buyerId] observeSingleEventOfType:queryType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // Loop over children
        NSEnumerator *children = [snapshot children];
        FIRDataSnapshot *child;
        NSMutableArray *arraym = [[NSMutableArray alloc]init];
        while (child = [children nextObject]) {
            NSMutableDictionary *dict = child.value;
            [dict setObject:child.key forKey:@"orderId"];
            [arraym addObject:dict];
        }
        
        success(arraym);
    }];
    
    
}

+ (void)getSalesProposals:(NSString*)orderId
                  success:(void (^)(NSArray *array))success
                  failure:(void (^)(NSString *message))failure {
    
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[[[mainFirebaseReference child:@"sales"]queryOrderedByChild:@"buyerId"]queryEqualToValue:[FIRAuth auth].currentUser.uid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // Loop over children
        NSEnumerator *children = [snapshot children];
        FIRDataSnapshot *child;
        NSMutableArray *arraym = [[NSMutableArray alloc]init];
        while (child = [children nextObject]) {
            NSMutableDictionary *dict = child.value;
            [dict setObject:child.key forKey:@"proposalId"];
            [arraym addObject:dict];
        }
        
        success(arraym);
    }];
}

+ (void)getSalesProposalWithID:(NSString*)orderId
                       success:(void (^)(NSArray *array))success
                       failure:(void (^)(NSString *message))failure {
    
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[[[mainFirebaseReference child:@"sales"]queryOrderedByChild:@"orderId"]queryEqualToValue:orderId] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // Loop over children
        NSEnumerator *children = [snapshot children];
        FIRDataSnapshot *child;
        NSMutableArray *arraym = [[NSMutableArray alloc]init];
        while (child = [children nextObject]) {
            NSMutableDictionary *dict = child.value;
            [dict setObject:child.key forKey:@"proposalId"];
            [arraym addObject:dict];
        }
        
        success(arraym);
    }];
}
+ (void)getSalesProposals:(NSString*)fetchType
                eventType:(FIRDataEventType)eventType
                  success:(void (^)(NSArray *array))success
                  failure:(void (^)(NSString *message))failure {
    
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    
    if ([fetchType isEqualToString:@"Single"]){
        [[[[mainFirebaseReference child:@"sales"]queryOrderedByChild:@"buyerId"]queryEqualToValue:[FIRAuth auth].currentUser.uid] observeEventType:eventType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSMutableArray *arraym = [[NSMutableArray alloc]init];
            if (eventType==FIRDataEventTypeValue){
                // Loop over children
                NSEnumerator *children = [snapshot children];
                FIRDataSnapshot *child;
                
                while (child = [children nextObject]) {
                    NSMutableDictionary *dict = child.value;
                    [dict setObject:child.key forKey:@"proposalId"];
                    [arraym addObject:dict];
                }
            }else{
                NSMutableDictionary *dict = snapshot.value;
                [dict setObject:snapshot.key forKey:@"proposalId"];
                [arraym addObject:dict];
            }
            success(arraym);
        }];
    }else if ([fetchType isEqualToString:@"Multiple-Single"]){
        [[[[mainFirebaseReference child:@"sales"]queryOrderedByChild:@"buyerId"]queryEqualToValue:[FIRAuth auth].currentUser.uid] observeSingleEventOfType:eventType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSMutableArray *arraym = [[NSMutableArray alloc]init];
            
            if (eventType==FIRDataEventTypeValue){
                // Loop over children
                NSEnumerator *children = [snapshot children];
                FIRDataSnapshot *child;
                
                while (child = [children nextObject]) {
                    NSMutableDictionary *dict = child.value;
                    [dict setObject:child.key forKey:@"proposalId"];
                    [arraym addObject:dict];
                }
            }else{
                NSMutableDictionary *dict = snapshot.value;
                [dict setObject:snapshot.key forKey:@"proposalId"];
                [arraym addObject:dict];
            }
            success(arraym);
        }];
    }else{
        [[[[mainFirebaseReference child:@"sales"]queryOrderedByChild:@"buyerId"]queryEqualToValue:[FIRAuth auth].currentUser.uid] observeEventType:eventType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSMutableArray *arraym = [[NSMutableArray alloc]init];
            
            if (eventType==FIRDataEventTypeValue){
                // Loop over children
                NSEnumerator *children = [snapshot children];
                FIRDataSnapshot *child;
                
                while (child = [children nextObject]) {
                    NSMutableDictionary *dict = child.value;
                    [dict setObject:child.key forKey:@"proposalId"];
                    [arraym addObject:dict];
                }
            }else{
                NSMutableDictionary *dict = snapshot.value;
                [dict setObject:snapshot.key forKey:@"proposalId"];
                [arraym addObject:dict];
            }
            success(arraym);
        }];
    }
}

+ (void)updateSalesOrder:(NSString*)orderId
              withStatus:(NSString*)status
            withSellerId:(NSString*)sellerId
               withItems:(NSArray*) salesItems
                withDict:(NSDictionary*)orderDict
                 success:(void (^)(NSDictionary *dict))success
                 failure:(void (^)(NSString *message))failure {
    
    
    float totalPrice=0;
    for (NSDictionary*item in salesItems){
        totalPrice = totalPrice+ ( [[item objectForKey:@"buyingPrice"] floatValue]*[[item objectForKey:@"quantity"] floatValue]);
    }
    if ([status isEqualToString:@"Completed"]){
        
        [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"orders"] child:orderId]
         updateChildValues:@{@"paymentMode":[orderDict objectForKey:@"paymentMode"],@"status": status,@"sellerId":sellerId,@"completionDate":[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]]}withCompletionBlock:^(NSError* _Nullable error, FIRDatabaseReference * _Nonnull ref){
             if (error==nil){
                 success(nil);
             }else{
                 failure(error.description);
             }
         }];
        
    }else if (salesItems.count==0){
        [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"orders"] child:orderId]
         updateChildValues:@{@"paymentMode":[orderDict objectForKey:@"paymentMode"],@"status": status,@"sellerId":sellerId} withCompletionBlock:^(NSError* _Nullable error, FIRDatabaseReference * _Nonnull ref){
             if (error==nil){
                 success(nil);
             }else{
                 failure(error.description);
             }
         }];
    }else{
        
        //    NSMutableDictionary * dict = [@{@"status": status,@"sellerId":sellerId,@"proposalId":proposalId,@"totalPrice":[NSString stringWithFormat:@"%.2f",totalPrice],@"salesItem": salesItems} mutableCopy];
        
        NSMutableDictionary * dict = [@{@"paymentMode":[orderDict objectForKey:@"paymentMode"],@"status": status,@"sellerId":sellerId,@"totalPrice":[NSString stringWithFormat:@"%.2f",totalPrice],@"salesItem": salesItems} mutableCopy];
        
        if ([orderDict objectForKey:@"proposalId"]){
            [dict setObject:[orderDict objectForKey:@"proposalId"] forKey:@"proposalId"];
        }
        
        if ([status isEqualToString:@"Accepted"]){
            //NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
            
            [dict setObject:[NSString stringWithFormat:@"%@%@",[orderDict objectForKey:@"psid"],sellerId] forKey:@"psid"];
            
            [dict setObject:sellerId forKey:@"psid"];
            
            
            
        }else if ([status isEqualToString:@"Expired"]){
            [dict setObject:@"-" forKey:@"psid"];
            [dict setObject:@"-" forKey:@"postalCode"];
        }else if ([status isEqualToString:@"On The Way"]){
            //[dict setObject:[orderDict objectForKey:@"sellerRoute"] forKey:@"sellerRoute"];
        }
        
        [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"orders"] child:orderId]
         updateChildValues:dict withCompletionBlock:^(NSError* _Nullable error, FIRDatabaseReference * _Nonnull ref){
             if (error==nil){
                 [dict setObject:orderId forKey:@"orderId"];
                 success(dict);
             }else{
                 failure(error.description);
             }
         }];
        
    }
}


+ (void)updateSalesOrderBidders:(NSString*)orderId
                withSellerArray:(NSArray*)sellerArray
                        success:(void (^)(void))success
                        failure:(void (^)(NSString *message))failure {
    
    [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"orders"] child:orderId]
     updateChildValues:@{@"bidders":sellerArray} withCompletionBlock:^(NSError* _Nullable error, FIRDatabaseReference * _Nonnull ref){
         
     }];
    
}
+ (void)updateRatingSalesOrder:(NSString*)orderId
                   withRatings:(NSString*)ratings
                       success:(void (^)(NSDictionary *dict))success
                       failure:(void (^)(NSString *message))failure {
    [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"orders"] child:orderId]
     updateChildValues:@{@"status": @"Closed",@"sellerRating":ratings, @"sellerRoute": @"-"} withCompletionBlock:^(NSError* _Nullable error, FIRDatabaseReference * _Nonnull ref){
         if (error==nil){
             success(nil);
         }else{
             failure(error.description);
         }
     }];
    
}

+ (void)updateProposal:(NSString*)proposalId
           orProposals:(NSArray*)proposalArray
            withStatus:(NSString*)status
               success:(void (^)(NSDictionary *dict))success
               failure:(void (^)(NSString *message))failure {
    
    if (proposalId == nil && proposalArray.count==0){
        failure(@"No values");
    }else{
        if (proposalId!=nil){
            [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"sales"] child:proposalId]
             updateChildValues:@{@"status": status}withCompletionBlock:^(NSError* _Nullable error, FIRDatabaseReference * _Nonnull ref){
                 if (error==nil){
                     success(nil);
                 }else{
                     failure(error.description);
                 }
             }];
            
        }else{
            for (NSString *_proposalId in proposalArray){
                [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"sales"] child:_proposalId]
                 updateChildValues:@{@"status": status}withCompletionBlock:^(NSError* _Nullable error, FIRDatabaseReference * _Nonnull ref){
                     if (error==nil){
                         success(nil);
                     }else{
                         failure(error.description);
                     }
                 }];
            }
        }
    }
}


+ (void)deleteProposals:(NSString*)orderId
                success:(void (^)(NSDictionary *dict))success
                failure:(void (^)(NSString *message))failure {
    
    
    [[[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference]
        child:@"sales"]queryOrderedByChild:@"orderId"]queryEqualToValue:orderId] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        
        // Loop over children
        NSEnumerator *children = [snapshot children];
        FIRDataSnapshot *child;
        
        while (child = [children nextObject]) {
            [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"sales"] child:child.key]
             removeValue];
        }
        success(nil);
    }];
    
    
    
}

#pragma mark *users
+ (void)getAllSellers:(NSString*)status
              success:(void (^)(NSArray *array))success
              failure:(void (^)(NSString *message))failure {
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[mainFirebaseReference child:@"sellers"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSEnumerator *children = [snapshot children];
        FIRDataSnapshot *child;
        NSMutableArray *arraym = [[NSMutableArray alloc]init];
        while (child = [children nextObject]) {
            NSMutableDictionary *dict = child.value;
            [dict setObject:child.key forKey:@"sellerId"];
            [arraym addObject:dict];
        }
        success(arraym);
        
        
        //        NSMutableDictionary *dict = snapshot.value;
        //        //[dict setObject:snapshot.key forKey:@"productId"];
        //        success(dict);
    }];
}
+ (void)getActiveSellers:(NSString*)postalCode
               eventType:(FIRDataEventType)eventType
                 success:(void (^)(NSArray *dict))success
                 failure:(void (^)(NSString *message))failure {
    
    [[[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"sellers"]queryOrderedByChild:@"postalCode"]queryEqualToValue:postalCode] observeSingleEventOfType:eventType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (eventType==FIRDataEventTypeChildChanged){
            NSMutableDictionary *data = snapshot.value;
            [data setObject:snapshot.key forKey:@"sellerId"];
            //success(data);
        }else if (eventType==FIRDataEventTypeValue){
            NSEnumerator *children = [snapshot children];
            FIRDataSnapshot *child;
            NSMutableArray *arraym = [[NSMutableArray alloc]init];
            while (child = [children nextObject]) {
                NSMutableDictionary *dict = child.value;
                [dict setObject:child.key forKey:@"sellerId"];
                
                NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:[[dict objectForKey:@"lastUpdate"] integerValue]];
                
                if ([date timeIntervalSinceNow]>-120){
                    if ([[dict objectForKey:@"active"] isEqualToString:@"Yes"])
                    {
                        [arraym addObject:dict];
                    }
                }
                
            }
            success(arraym);
        }
    }];
}
+ (void)activeSellerUpdated:(NSString*)postalCode
                  eventType:(FIRDataEventType)eventType
                    success:(void (^)(NSDictionary *dict))success
                    failure:(void (^)(NSString *message))failure {
    
    [[[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"sellers"]queryOrderedByChild:@"postalCode"]queryEqualToValue:postalCode] observeEventType:eventType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (eventType==FIRDataEventTypeChildChanged){
            NSMutableDictionary *data = snapshot.value;
            [data setObject:snapshot.key forKey:@"sellerId"];
            success(data);
        }else if (eventType==FIRDataEventTypeChildAdded){
            //            NSEnumerator *children = [snapshot children];
            //            FIRDataSnapshot *child;
            //            NSMutableArray *arraym = [[NSMutableArray alloc]init];
            //            while (child = [children nextObject]) {
            //                NSMutableDictionary *dict = child.value;
            //                [dict setObject:child.key forKey:@"sellerId"];
            //                if ([[dict objectForKey:@"active"] isEqualToString:@"Yes"])
            //                {
            //                    [arraym addObject:dict];
            //                }
            //            }
            //            success(arraym);
        }
    }];
}

+ (void)getSellerDetails:(NSString*)sellerId
               eventType:(FIRDataEventType)eventType
                 success:(void (^)(NSDictionary *dict))success
                 failure:(void (^)(NSString *message))failure {
    
    if (eventType==FIRDataEventTypeValue){
        
        [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"sellers"]child:sellerId] observeSingleEventOfType:eventType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if ([snapshot.key isEqualToString:@"-"]){
                failure(@"-");
            }else{
                NSMutableDictionary *dict = snapshot.value;
                if (![dict isKindOfClass:[NSNull class]]){
                    [dict setObject:snapshot.key forKey:@"sellerId"];
                    [API addSeller:dict];
                }
                success(dict);
            }
        }];
    }else{
        [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"sellers"]queryEqualToValue:sellerId] observeEventType:eventType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if ([snapshot.key isEqualToString:@"-"]){
                failure(@"-");
            }else{
                NSMutableDictionary *dict = snapshot.value;
                //if (![dict isKindOfClass:[NSNull class]]){
                [dict setObject:snapshot.key forKey:@"sellerId"];
                [API addSeller:dict];
                //}
                success(dict);
            }
        }];
    }
}
+ (void)getBuyerDetails:(NSString*)buyerId
              eventType:(FIRDataEventType)eventType
                success:(void (^)(NSDictionary *dict))success
                failure:(void (^)(NSString *message))failure {
    if (buyerId==nil){
        failure(@"no buyer id");
        return;
    }
    [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"buyers"]child:buyerId] observeSingleEventOfType:eventType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if ([snapshot.key isEqualToString:@"-"]){
            failure(@"-");
        }else{
            NSMutableDictionary *dict = snapshot.value;
            if (![dict isKindOfClass:[NSNull class]]){
                [dict setObject:snapshot.key forKey:@"buyerId"];
                [API addBuyer:dict];
                success(dict);
            }else{
                failure(@"buyer info not available");
            }
        }
    }];
}

+ (void)createOrUpdateBuyer:(id)result
                    success:(void (^)(void))success
                    failure:(void (^)(NSString *message))failure {
    if ([FIRAuth auth].currentUser.uid==nil){
        failure(@"Logged out");
        return;
    }
    [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"buyers"]  child:[FIRAuth auth].currentUser.uid]
     observeEventType:FIRDataEventTypeValue
     withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         if (![snapshot exists]) {
             CLLocation * location = [[DataSingletons sharedManager] userLocation];
             // create buyer profile using facebook profile
             
             if (result!=nil){
                 [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"buyers"] child:[FIRAuth auth].currentUser.uid]
                  setValue:@{@"name": result[@"name"],
                             @"firstName" : result[@"first_name"],
                             @"lastName" : result[@"last_name"],
                             @"mobileNumber" : @"-",
                             @"longitude": [NSNumber numberWithFloat:location.coordinate.longitude],
                             @"latitude" : [NSNumber numberWithFloat:location.coordinate.latitude],
                             @"lastUpdate" : [NSNumber numberWithInteger:0]
                             }];
             }
             
         } else {
             if ([FIRAuth auth].currentUser.uid==nil){
                 failure(@"Logged out");
                 return;
             }
             CLLocation * location = [[DataSingletons sharedManager] userLocation];
             [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"buyers"] child:[FIRAuth auth].currentUser.uid]
              updateChildValues:@{@"longitude": [NSNumber numberWithFloat:location.coordinate.longitude],
                                  @"latitude" : [NSNumber numberWithFloat:location.coordinate.latitude],
                                  @"lastUpdate": [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]]}withCompletionBlock:^(NSError* _Nullable error, FIRDatabaseReference * _Nonnull ref){
                                      if (error==nil){
                                          success();
                                      }else{
                                          failure(error.description);
                                      }
                                  }];
         }
     }];
    
    success();
}

+ (void)updateBuyer:(id)result
            success:(void (^)(void))success
            failure:(void (^)(NSString *message))failure {
    
    [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"buyers"]  child:[FIRAuth auth].currentUser.uid]
     observeEventType:FIRDataEventTypeValue
     withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         if ([snapshot exists]) {
             
             CLLocation * location = [[DataSingletons sharedManager] userLocation];
             
             NSMutableDictionary *dict = [@{@"longitude": [NSNumber numberWithFloat:location.coordinate.longitude],
                                            @"latitude" : [NSNumber numberWithFloat:location.coordinate.latitude],
                                            @"lastUpdate": [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]]} mutableCopy];
             
             [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"buyers"] child:[FIRAuth auth].currentUser.uid]
              updateChildValues:dict withCompletionBlock:^(NSError* _Nullable error, FIRDatabaseReference * _Nonnull ref){
                  if (error==nil){
                      success();
                  }else{
                      failure(error.description);
                  }
              }];
         }
     }];
    
    //success();
}
+ (void)updateSeller:(id)result
             success:(void (^)(void))success
             failure:(void (^)(NSString *message))failure {
    if ([FIRAuth auth].currentUser.uid==nil){
        return;
    }
    [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"sellers"]  child:[FIRAuth auth].currentUser.uid]
     observeEventType:FIRDataEventTypeValue
     withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         if ([snapshot exists]) {
             
             CLLocation * location = [[DataSingletons sharedManager] userLocation];
             
             NSMutableDictionary *dict = [@{@"longitude": [NSNumber numberWithFloat:location.coordinate.longitude],
                                            @"latitude" : [NSNumber numberWithFloat:location.coordinate.latitude],
                                            @"active" : [[NSUserDefaults standardUserDefaults] objectForKey:@"active"],
                                            @"lastUpdate": [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]]} mutableCopy];
             
             if ([FIRAuth auth].currentUser.uid==nil)
             {
                 return;
             }
             [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"sellers"] child:[FIRAuth auth].currentUser.uid]
              updateChildValues:dict withCompletionBlock:^(NSError* _Nullable error, FIRDatabaseReference * _Nonnull ref){
                  if (error==nil){
                      success();
                  }else{
                      failure(error.description);
                  }
              }];
         }
     }];
    
    //success();
}
+ (void)addDebits:(id)result
          success:(void (^)(void))success
          failure:(void (^)(NSString *message))failure {
    if ([FIRAuth auth].currentUser.uid==nil){
        failure(@"Logged out");
        return;
    }
    
    if (result!=nil){
        
        NSString *key = [[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"debit"] childByAutoId].key;
        [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"debit"] child:key]
         setValue:@{@"amount": [result objectForKey:@"amount"],
                    @"code" : [result objectForKey:@"code"],
                    @"paymentMethod" : [result objectForKey:@"paymentMethod"],
                    @"paidBy" : [result objectForKey:@"paidBy"],
                    @"orderDate" : [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]],
                    @"type": [result objectForKey:@"type"]
                    }];
        success();
    }
}
+ (void)getDebits:(NSString*)sellerId
        queryType:(FIRDataEventType)queryType
          success:(void (^)(NSArray *array))success
          failure:(void (^)(NSString *message))failure {
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[[[mainFirebaseReference child:@"debit"]queryOrderedByChild:@"paidBy"]queryEqualToValue:[FIRAuth auth].currentUser.uid] observeEventType:queryType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableDictionary *dict = snapshot.value;
        if (![dict isKindOfClass:[NSNull class] ]){
            
            success([dict allValues]);
            
        }else{
            success (nil);
        }
    }];
}

+ (void)getSingleDebit:(NSString*)sellerId
             queryType:(FIRDataEventType)queryType
               success:(void (^)(NSDictionary *dict))success
               failure:(void (^)(NSString *message))failure {
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[[[mainFirebaseReference child:@"debit"]queryOrderedByChild:@"paidBy"]queryEqualToValue:[FIRAuth auth].currentUser.uid] observeEventType:queryType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableDictionary *dict = snapshot.value;
        if (![dict isKindOfClass:[NSNull class] ]){
            
            success(dict);
            
        }else{
            success (nil);
        }
    }];
}
+ (void)registerLoad:(id)dict
            cardCode:(NSString*)cardCode
             cardPin:(NSString*)cardPin
           success:(void (^)(NSDictionary*dict))success
           failure:(void (^)(NSString *message))failure {
    if ([FIRAuth auth].currentUser.uid==nil){
        failure(@"Logged out");
        return;
    }
    
    [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"credits"]  child:cardCode]
     observeSingleEventOfType:FIRDataEventTypeValue
     withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         if ([snapshot exists]) {
             NSMutableDictionary *dict = snapshot.value;
             if (![dict isKindOfClass:[NSNull class] ]){
                 if (![[[dict objectForKey:@"code"]stringValue] isEqualToString:cardPin]){
                     failure(@"Wrong Pin");
                     return;
                 }
             }
             
             if ([FIRAuth auth].currentUser.uid==nil)
             {
                 failure(@"no user");
             }
             dict = [@{
                                            @"paidBy" : [FIRAuth auth].currentUser.uid,
                                            @"orderDate" : [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]],
                                            } mutableCopy];
             
             [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"credits"] child:cardCode]
              updateChildValues:dict withCompletionBlock:^(NSError* _Nullable error, FIRDatabaseReference * _Nonnull ref){
                  if (error==nil){
                      success(dict);
                  }else{
                      failure(error.description);
                  }
              }];
         }else{
             failure(@"Invalid Code");
         }
     }];
}

+ (void)addCredits:(id)result
           success:(void (^)(void))success
           failure:(void (^)(NSString *message))failure {
    if ([FIRAuth auth].currentUser.uid==nil){
        failure(@"Logged out");
        return;
    }
    
    NSString *key = [[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"credits"] childByAutoId].key;
    [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"credits"] child:key]
     setValue:@{@"amount": [result objectForKey:@"amount"],
                @"code" : [result objectForKey:@"code"],
                @"paymentMethod" : [result objectForKey:@"paymentMethod"],
                @"paidBy" : [result objectForKey:@"paidBy"],
                @"orderDate" : [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]],
                @"type": [result objectForKey:@"type"]
                }];
    success();
}
+ (void)updateCredits:(id)result
              success:(void (^)(void))success
              failure:(void (^)(NSString *message))failure {
    if ([FIRAuth auth].currentUser.uid==nil){
        failure(@"Logged out");
        return;
    }
    
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[[[mainFirebaseReference child:@"credits"]queryOrderedByChild:@"paidBy"]queryEqualToValue:[FIRAuth auth].currentUser.uid] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (![snapshot exists]) {
            if (result!=nil){
                NSString *key = [[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"credits"] childByAutoId].key;
                [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"credits"] child:key]
                 setValue:@{@"amount": @"1000.00",
                            @"code" : @"1",
                            @"paymentMethod" : @"Cash",
                            @"paidBy" : [FIRAuth auth].currentUser.uid,
                            @"orderDate" : [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]]
                            }];
            }
            success();
        } else {
            if ([FIRAuth auth].currentUser.uid==nil){
                failure(@"Logged out");
                return;
            }else{
                if (result!=nil){
                    [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"credits"] child:[FIRAuth auth].currentUser.uid]
                     setValue:@{@"amount": @"1000.00",
                                @"code" : @"123456789",
                                @"paymentMethod" : @"Cash",
                                @"paidBy" : [FIRAuth auth].currentUser.uid,
                                @"orderDate" : [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]]
                                }];
                }
            }
        }
    }];
}

+ (void)getCredits:(NSString*)sellerId
         queryType:(FIRDataEventType)queryType
           success:(void (^)(NSArray *array))success
           failure:(void (^)(NSString *message))failure {
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[[[mainFirebaseReference child:@"credits"]queryOrderedByChild:@"paidBy"]queryEqualToValue:[FIRAuth auth].currentUser.uid] observeSingleEventOfType:queryType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableDictionary *dict = snapshot.value;
        //[dict setObject:snapshot.key forKey:@"creditId"];
        if ([dict isKindOfClass:[NSNull class]]){
            failure(@"No credits");
        }else{
            success([dict allValues]);
        }
    }];
}

+ (void)getSingleCredit:(NSString*)sellerId
              queryType:(FIRDataEventType)queryType
                success:(void (^)(NSDictionary *dict))success
                failure:(void (^)(NSString *message))failure {
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[[[mainFirebaseReference child:@"credits"]queryOrderedByChild:@"paidBy"]queryEqualToValue:[FIRAuth auth].currentUser.uid] observeEventType:queryType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableDictionary *dict = snapshot.value;
        if ([dict isKindOfClass:[NSNull class]]){
            failure(@"No credits");
        }else{
            success(dict);
        }
    }];
}


+ (void)addRatingsToBuyer:(id)sellerDict
                   rating:(int)rating
                  success:(void (^)(void))success
                  failure:(void (^)(NSString *message))failure {
    
    int rate = (([[sellerDict objectForKey:@"ratings"] intValue])+rating)/2;
    
    NSDictionary *dict = [@{@"ratings": [NSNumber numberWithInt:rate],
                            
                            @"lastUpdate": [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]]} mutableCopy];
    [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"sellers"] child:[sellerDict objectForKey:@"sellerId"]]
     updateChildValues:dict withCompletionBlock:^(NSError* _Nullable error, FIRDatabaseReference * _Nonnull ref){
         if (error==nil){
             success();
         }else{
             failure(error.description);
         }
     }];
    
}

+(void)createFirebaseImage:(NSDictionary*)imageDict urlString:(NSString*)urlString fileName:(NSString *)fileName imageData:(UIImage*)imageData
                   success:(void (^)(NSDictionary *dict))success
                   failure:(void (^)(NSString *message))failure {
    NSURL *referenceUrl = imageDict[UIImagePickerControllerReferenceURL];
    // if it's a photo from the library, not an image from the camera
    if (referenceUrl) {
        PHFetchResult* assets = [PHAsset fetchAssetsWithALAssetURLs:@[referenceUrl] options:nil];
        PHAsset *asset = assets.firstObject;
        [asset requestContentEditingInputWithOptions:nil
                                   completionHandler:^(PHContentEditingInput *contentEditingInput,
                                                       NSDictionary *info) {
                                       NSURL *imageFile = contentEditingInput.fullSizeImageURL;
                                       
                                       NSString *filePath =
                                       [NSString stringWithFormat:@"%@/%@/%@",
                                        urlString,fileName,
                                        imageFile.lastPathComponent];
                                       
                                       [[[[FIRDatabaseSingleton sharedManager] storageRef] child:filePath]
                                        putFile:imageFile metadata:nil
                                        completion:^(FIRStorageMetadata *metadata, NSError *error) {
                                            if (error) {
                                                failure(error.description);
                                            }
                                            success(nil);
                                        }];
                                       // [END uploadimage]
                                   }];
        
    } else if (imageData!=nil){
        NSData *data = UIImageJPEGRepresentation(imageData,0.5);
        NSString *filePath =
        [NSString stringWithFormat:@"%@/%@.jpg",
         urlString,fileName];
        FIRStorageMetadata *metadata = [FIRStorageMetadata new];
        metadata.contentType = @"image/jpeg";
        [[[[FIRDatabaseSingleton sharedManager] storageRef] child:filePath]
         putData:data metadata:metadata
         completion:^(FIRStorageMetadata *metadata, NSError *error) {
             if (error) {
                 failure(error.description);
             }
             success(nil);
         }];
    }else {
        UIImage *image = imageDict[UIImagePickerControllerOriginalImage];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
        NSString *imagePath =
        [NSString stringWithFormat:@"%@/%@.jpg",urlString,fileName];
        FIRStorageMetadata *metadata = [FIRStorageMetadata new];
        metadata.contentType = @"image/jpeg";
        [[[[FIRDatabaseSingleton sharedManager] storageRef] child:imagePath] putData:imageData metadata:metadata
                                                                          completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                                                                              if (error) {
                                                                                  NSLog(@"Error uploading: %@", error);
                                                                                  failure(error.description);
                                                                              }
                                                                              success(nil);
                                                                          }];
        
    }
}

#pragma mark - Realm APIs
+ (void)getNewProductsMaster:(int)lastUpdate
                     success:(void (^)(void))success
                     failure:(void (^)(NSString *message))failure {
    
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[[[mainFirebaseReference child:@"products-master"]queryOrderedByValue]queryStartingAtValue:[NSNumber numberWithInteger:lastUpdate]] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        RLMResults *array =[Products objectsWhere:[NSString stringWithFormat:@"productName contains '%@'",snapshot.key]];
        
        if (array.count==0){
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            Products *information = [[Products alloc] init];
            information.productName=snapshot.key;
            information.lastUpdate=[snapshot.value stringValue];
            [realm addObject:information];
            [realm commitWriteTransaction];
            success();
        }
    }];
}

+ (void)getNewProductsMaster:(int)lastUpdate
                   eventType:(FIRDataEventType)eventType
                     success:(void (^)(void))success
                     failure:(void (^)(NSString *message))failure {
    
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[[[mainFirebaseReference child:@"products-master"]queryOrderedByValue]queryStartingAtValue:[NSNumber numberWithInteger:lastUpdate]] observeEventType:eventType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (eventType==FIRDataEventTypeChildAdded){
            RLMResults *array =[Products objectsWhere:[NSString stringWithFormat:@"productName contains '%@'",snapshot.key]];
            
            if (array.count==0){
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                Products *information = [[Products alloc] init];
                information.productName=snapshot.key;
                information.lastUpdate=[snapshot.value stringValue];
                [realm addObject:information];
                [realm commitWriteTransaction];
            }
            success();
        }else if (eventType==FIRDataEventTypeValue){
            NSEnumerator *children = [snapshot children];
            FIRDataSnapshot *child;
            NSMutableArray *arraym = [[NSMutableArray alloc]init];
            while (child = [children nextObject]) {
                NSMutableDictionary *dict = child.value;
                [arraym addObject:dict];
            }
        }
    }];
    
    
}

+ (void)getNewProducts:(int)lastUpdate
               success:(void (^)(void))success
               failure:(void (^)(NSString *message))failure {
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    [[[[mainFirebaseReference child:@"products"]queryOrderedByValue]queryStartingAtValue:[NSNumber numberWithInteger:lastUpdate]] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        ProductsDetail *information = [[ProductsDetail alloc] init];
        information.productId=snapshot.key;
        
        NSDictionary *dict = snapshot.value;
        
        information.productName = [dict objectForKey:@"productName"];
        information.productDescription= [dict objectForKey:@"description"];
        information.uom= [dict objectForKey:@"uom"];
        information.srp= [dict objectForKey:@"srp"];
        information.lastUpdate =[[dict objectForKey:@"lastUpdate"] stringValue];
        [realm addObject:information];
        [realm commitWriteTransaction];
        success();
    }];
}

+ (void)addNewProducts:(NSDictionary*)dict{
    if (dict==nil){
        return;
    }
    
    RLMResults *array =[ProductsDetail objectsWhere:[NSString stringWithFormat:@"productName contains '%@'",[dict objectForKey:@"productName"]]];
    
    if (array.count==0){
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        ProductsDetail *information = [[ProductsDetail alloc] init];
        information.productId=[dict objectForKey:@"productId"];
        
        information.productName = [dict objectForKey:@"productName"];
        information.productDescription= [dict objectForKey:@"description"];
        information.uom= [dict objectForKey:@"uom"];
        information.srp= [dict objectForKey:@"srp"];
        information.lastUpdate =[[dict objectForKey:@"lastUpdate"] stringValue];
        information.currency=[dict objectForKey:@"currency"];
        [realm addObject:information];
        [realm commitWriteTransaction];
    }else{
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        
        
        ProductsDetail *information = [array firstObject];
        information.productId=[dict objectForKey:@"productId"];
        
        information.productName = [dict objectForKey:@"productName"];
        information.productDescription= [dict objectForKey:@"description"];
        information.uom= [dict objectForKey:@"uom"];
        information.srp= [dict objectForKey:@"srp"];
        information.lastUpdate =[[dict objectForKey:@"lastUpdate"] stringValue];
        information.currency=[dict objectForKey:@"currency"];
        
        [realm commitWriteTransaction];
    }
}

+ (void)addToFavorites: (NSDictionary*)productDict{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    Favorites *information = [[Favorites alloc] init];
    information.productId=[productDict objectForKey:@"productId"];
    information.productName = [productDict objectForKey:@"productName"];
    [realm addObject:information];
    [realm commitWriteTransaction];
}

+ (void)addSeller: (NSDictionary*)sellerDict{
    RLMResults *array =[Seller objectsWhere:[NSString stringWithFormat:@"sellerId contains '%@'",[sellerDict objectForKey:@"sellerId"]]];
    if (sellerDict==nil)
        return;
    if (array.count==0){
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        Seller *information = [[Seller alloc] init];
        information.sellerId=[sellerDict objectForKey:@"sellerId"];
        information.name=[NSString stringWithFormat:@"%@ %@",[sellerDict objectForKey:@"firstName"],[sellerDict objectForKey:@"lastName"]];
        information.firstName = [sellerDict objectForKey:@"firstName"];
        information.lastName = [sellerDict objectForKey:@"lastName"];
        information.ratings = [[sellerDict objectForKey:@"ratings"] stringValue];
        information.mobileNumber = [sellerDict objectForKey:@"mobileNumber"];
        information.postalCode = [sellerDict objectForKey:USER_ZIP_CODE];
        information.status = [sellerDict objectForKey:@"status"];
        
        [realm addObject:information];
        [realm commitWriteTransaction];
    }else{
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        
        
        Seller *information = [array firstObject];
        information.sellerId=[sellerDict objectForKey:@"sellerId"];
        information.name=[NSString stringWithFormat:@"%@ %@",[sellerDict objectForKey:@"firstName"],[sellerDict objectForKey:@"lastName"]];
        information.firstName = [sellerDict objectForKey:@"firstName"];
        information.lastName = [sellerDict objectForKey:@"lastName"];
        information.ratings = [[sellerDict objectForKey:@"ratings"] stringValue];
        information.mobileNumber = [sellerDict objectForKey:@"mobileNumber"];
        information.postalCode = [sellerDict objectForKey:USER_ZIP_CODE];
        information.status = [sellerDict objectForKey:@"status"];
        
        [realm commitWriteTransaction];
    }
}

+ (void)addBuyer: (NSDictionary*)buyerDict{
    RLMResults *array =[Buyer objectsWhere:[NSString stringWithFormat:@"buyerId contains '%@'",[buyerDict objectForKey:@"buyerId"]]];
    
    if (array.count==0){
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        Buyer *information = [[Buyer alloc] init];
        information.buyerId=[buyerDict objectForKey:@"buyerId"];
        information.name=[buyerDict objectForKey:@"name"];
        information.firstName = [buyerDict objectForKey:@"firstName"];
        information.lastName = [buyerDict objectForKey:@"lastName"];
        information.ratings = [[buyerDict objectForKey:@"ratings"] stringValue];
        information.mobileNumber = [buyerDict objectForKey:@"mobileNumber"];
        information.postalCode = [buyerDict objectForKey:USER_ZIP_CODE];
        [realm addObject:information];
        [realm commitWriteTransaction];
    }else{
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        
        
        Buyer *information = [array firstObject];
        information.buyerId=[buyerDict objectForKey:@"buyerId"];
        information.name=[NSString stringWithFormat:@"%@",[buyerDict objectForKey:@"name"]];
        information.firstName = [buyerDict objectForKey:@"firstName"];
        information.lastName = [buyerDict objectForKey:@"lastName"];
        information.ratings = [[buyerDict objectForKey:@"ratings"] stringValue];
        information.mobileNumber = [buyerDict objectForKey:@"mobileNumber"];
        information.postalCode = [buyerDict objectForKey:USER_ZIP_CODE];
        [realm commitWriteTransaction];
    }
}

+(void)updateSeller:(Seller*)seller{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    
    [realm commitWriteTransaction];
}
+ (Seller*)getSeller: (NSString*)sellerId{
    RLMResults *array =[Seller objectsWhere:[NSString stringWithFormat:@"sellerId contains '%@'",sellerId]];
    
    if (array.count>0){
        return [array firstObject];
    }
    return nil;
}
+ (Buyer*)getBuyer: (NSString*)buyerId{
    RLMResults *array =[Buyer objectsWhere:[NSString stringWithFormat:@"buyerId contains '%@'",buyerId]];
    
    if (array.count>0){
        return [array firstObject];
    }
    return nil;
}
- (BOOL)paymentDone:(NSDictionary*)paymentDict{
    
    if ([[Payments objectsWhere:[NSString stringWithFormat:@"code CONTAINS[c] '%@' && type CONTAINS[c] '%@'",[paymentDict objectForKey:@"code"],[paymentDict objectForKey:@"type"]]] count]>0){
        return YES;
    }
    
    return NO;
}

- (BOOL)addPayments: (NSDictionary*)paymentDict{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    Payments *information = [[Payments alloc] init];
    information.code=[paymentDict objectForKey:@"code"];
    information.amount = [paymentDict objectForKey:@"amount"];
    //information.orderDate = [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
    information.type = [paymentDict objectForKey:@"type"];
    [realm addObject:information];
    [realm commitWriteTransaction];
    
    return NO;
}

+ (NSMutableArray*)productsArrayUsingSearch:(id)predicate {
    NSMutableArray *productsArray=[[NSMutableArray alloc] init];
    RLMResults *tableDataArray;
    if (predicate==nil)
    {
        tableDataArray= [Products allObjects];
    }
    else
    {
        tableDataArray= [Products objectsWhere:[NSString stringWithFormat:@"productName CONTAINS[c] '%@'",predicate]];
    }
    
    for (Products *products in tableDataArray)
    {
        [productsArray addObject:@{@"productName": products.productName, @"lastUpdate": products.lastUpdate}];
    }
    
    return productsArray;
}

+ (NSMutableArray*)productsDetailArrayUsingSearch:(id)predicate {
    NSMutableArray *productsArray=[[NSMutableArray alloc] init];
    RLMResults *tableDataArray;
    if (predicate==nil)
    {
        tableDataArray= [ProductsDetail allObjects];
    }else{
        tableDataArray= [ProductsDetail objectsWhere:predicate];
    }
    
    for (ProductsDetail *products in tableDataArray)
    {
        if (products.productName==nil || products.productId==nil || products.srp==nil || products.uom==nil || products.currency==nil || products.productDescription==nil){
            return nil;
        }
        
        [productsArray addObject:@{@"productName": products.productName, @"productId": products.productId,@"srp": products.srp,@"uom": products.uom, @"currency": products.currency, @"description":products.productDescription}];
    }
    
    return productsArray;
}

+ (NSMutableArray*)getFavorites:(id)predicate {
    NSMutableArray *productsArray=[[NSMutableArray alloc] init];
    RLMResults *tableDataArray;
    if (predicate==nil)
    {
        tableDataArray= [Favorites allObjects];
    }
    else
    {
        tableDataArray= [Favorites objectsWhere:[NSString stringWithFormat:@"productName contains '%@'",predicate]];
    }
    
    for (Favorites *products in tableDataArray)
    {
        [productsArray addObject:products];
    }
    
    return productsArray;
}


#pragma mark - Google Map API
/*
 
 */


+(void)getRouteAndTimeToArriveWithCurrentLatitude:(float)lat andCurrentLongitude:(float)longi andUserLatitude:(float)userLat andUserLongitude:(float)userLong withTransportMode:(NSString*)mode success:(void (^)(NSMutableDictionary *routeDict))success
                                          failure:(void (^)(NSString *message))failure {
    
    NSMutableArray *directionsArray = [[NSMutableArray alloc]init];
    __block BOOL hold = NO;
    __block float longitude=longi, latitude=lat;
    NSMutableDictionary *durationDict = [[NSMutableDictionary alloc]init];
    
    [self getDirections:latitude andCurrentLongitude:longitude andUserLatitude:userLat andUserLongitude:userLong withTransportMode:[[NSUserDefaults standardUserDefaults] objectForKey:MAP_ROUTING_TYPE] success:^(NSDictionary *dictleg){
        
        [durationDict setObject:[dictleg objectForKey:@"duration"] forKey:@"duration"];
        
        [durationDict setObject:[dictleg objectForKey:@"steps"] forKey:@"steps"];
        success(durationDict);
        
        
        
    } failure:^(NSString *message) {
        failure(@"failure in directions");
    }];
    
}

+(void)getDirections:(float)lat andCurrentLongitude:(float)longi andUserLatitude:(float)userLat andUserLongitude:(float)userLong withTransportMode:(NSString*)mode success:(void (^)(NSMutableDictionary *routeDict))success
             failure:(void (^)(NSString *message))failure {
    
    NSString *strUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&mode=%@&alternatives=true&key=%@", lat,  longi, userLat,  userLong, mode, GOOGLE_API_KEY];
    
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:strUrl
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSMutableArray *arrDistance=[responseObject objectForKey:@"routes"];
             if ([arrDistance count]>0) {
                 
                 NSMutableArray *arrLeg=[[arrDistance objectAtIndex:0]objectForKey:@"legs"];
                 NSMutableDictionary *dictleg=[arrLeg objectAtIndex:0];
                 success(dictleg);
             }else{
                 failure(@"None");
             }
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
             if (response.statusCode == 404) {
                 
             } else {
                 failure(@"Error");
             }
         }];
}



+(void)drawMapRoute:(NSMutableArray*)routeArray usingMap:(GMSMapView*)mapView withLatitude:(double)latitude andLongitude:(double)longitude withLineColor:(UIColor*)color andStrokeWidth:(float)strokeWidth withIcon:(NSString*) icon andStartDrawingAt:(int) drawAt{
    
    int cnt=0;
    for (NSDictionary *routeDict in routeArray){
        
        if (drawAt>cnt){
        }else{
            GMSMutablePath *path = [GMSMutablePath path];
            [path addCoordinate:CLLocationCoordinate2DMake(@([[[routeDict objectForKey:@"start_location"]objectForKey:@"lat"]floatValue]).doubleValue,@([[[routeDict objectForKey:@"start_location"]objectForKey:@"lng"]floatValue]).doubleValue)];
            [path addCoordinate:CLLocationCoordinate2DMake(@([[[routeDict objectForKey:@"end_location"]objectForKey:@"lat"]floatValue]).doubleValue,@([[[routeDict objectForKey:@"end_location"]objectForKey:@"lng"]floatValue]).doubleValue)];
            
            GMSPolyline *rectangle = [GMSPolyline polylineWithPath:path];
            rectangle.strokeWidth = strokeWidth;
            
            rectangle.strokeColor = color;
            rectangle.map = mapView;
        }
        
        cnt++;
        
    }
}

+(void)snapPathToRoadv2:(NSMutableArray*)passedInArray
              success:(void (^)(id dict))success
              failure:(void (^)(NSString *message))failure {
    //Create string to store coordinates in for the URL
    
    if (passedInArray==nil || passedInArray.count==0){
        return;
    }
    NSString *tempcoordinatesForURL = @"";
    
    //Append tempcoordinatesForURL string by the coordinates in the right format
    NSString *endCoordinatesString;
    
    for(int i = 0;i<[passedInArray count];i++){
        
        //CLLocationCoordinate2D coordinates = [[passedInArray objectAtIndex:i] coordinate];
        NSDictionary *routeDict =[passedInArray objectAtIndex:i];
        
        
        NSString *coordinatesString = [NSString stringWithFormat:@"|%.7f,%.7f",[[[routeDict objectForKey:@"start_location"]objectForKey:@"lat"]floatValue],[[[routeDict objectForKey:@"start_location"]objectForKey:@"lng"]floatValue]];
        coordinatesString = [NSString stringWithFormat:@"|%@,%@",[[routeDict objectForKey:@"start_location"]objectForKey:@"lat"],[[routeDict objectForKey:@"start_location"]objectForKey:@"lng"]];
        
        endCoordinatesString = [NSString stringWithFormat:@"|%.7f,%.7f",[[[routeDict objectForKey:@"end_location"]objectForKey:@"lat"]floatValue],[[[routeDict objectForKey:@"end_location"]objectForKey:@"lng"]floatValue]];
        
        tempcoordinatesForURL = [tempcoordinatesForURL stringByAppendingString:coordinatesString];
        //tempcoordinatesForURL = [tempcoordinatesForURL stringByAppendingString:endCoordinatesString];
    }
    tempcoordinatesForURL = [tempcoordinatesForURL stringByAppendingString:endCoordinatesString];
    
    //Remove unnecessary charchters from tempcoordinatesForURL
    NSString *coordinatesForURL = [[tempcoordinatesForURL substringToIndex:[tempcoordinatesForURL length]-1] stringByReplacingOccurrencesOfString:@"||" withString:@"|"];
    
    //Create url by removing last charachter from coordinatesForURL string
    NSString *urlPath = [NSString stringWithFormat:@"https://roads.googleapis.com/v1/snapToRoads?path=%@&interpolate=true&key=%@",[coordinatesForURL substringFromIndex:1],GOOGLE_API_KEY];
    
    //Remove unsupproted charchters from urlPath and create an NSURL
    NSString *escapedUrlPath = [urlPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:escapedUrlPath
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSArray *snappedPoints = [responseObject objectForKey:@"snappedPoints"];
             GMSMutablePath *pathToDraw = [[GMSMutablePath alloc]init];
             for (NSDictionary *dict in snappedPoints){
                 NSDictionary *location = [dict objectForKey:@"location"];
                 double latitude = [[location objectForKey:@"latitude"] doubleValue];
                 double longitude = [[location objectForKey:@"longitude"] doubleValue];
                 [pathToDraw addCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
             }
             success(@{@"snappedPoints":snappedPoints, @"pathToDraw": pathToDraw});
             //success(pathToDraw);
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
             if (response.statusCode == 404) {
                 //success([[NSArray alloc] init]);
             } else {
                 failure(response.description);
             }
         }];
    
    
    
    
}

+(void)snapPathToRoad:(NSMutableArray*)passedInArray
              success:(void (^)(GMSMutablePath *pathToDraw))success
              failure:(void (^)(NSString *message))failure {
    //Create string to store coordinates in for the URL
    
    if (passedInArray==nil || passedInArray.count==0){
        return;
    }
    NSString *tempcoordinatesForURL = @"";
    
    //Append tempcoordinatesForURL string by the coordinates in the right format
    NSString *endCoordinatesString;
    
    for(int i = 0;i<[passedInArray count];i++){
        
        //CLLocationCoordinate2D coordinates = [[passedInArray objectAtIndex:i] coordinate];
        NSDictionary *routeDict =[passedInArray objectAtIndex:i];
        
        
        NSString *coordinatesString = [NSString stringWithFormat:@"|%.7f,%.7f",[[[routeDict objectForKey:@"start_location"]objectForKey:@"lat"]floatValue],[[[routeDict objectForKey:@"start_location"]objectForKey:@"lng"]floatValue]];
        coordinatesString = [NSString stringWithFormat:@"|%@,%@",[[routeDict objectForKey:@"start_location"]objectForKey:@"lat"],[[routeDict objectForKey:@"start_location"]objectForKey:@"lng"]];
        
        endCoordinatesString = [NSString stringWithFormat:@"|%.7f,%.7f",[[[routeDict objectForKey:@"end_location"]objectForKey:@"lat"]floatValue],[[[routeDict objectForKey:@"end_location"]objectForKey:@"lng"]floatValue]];
        
        tempcoordinatesForURL = [tempcoordinatesForURL stringByAppendingString:coordinatesString];
        //tempcoordinatesForURL = [tempcoordinatesForURL stringByAppendingString:endCoordinatesString];
    }
    tempcoordinatesForURL = [tempcoordinatesForURL stringByAppendingString:endCoordinatesString];
    
    //Remove unnecessary charchters from tempcoordinatesForURL
    NSString *coordinatesForURL = [[tempcoordinatesForURL substringToIndex:[tempcoordinatesForURL length]-1] stringByReplacingOccurrencesOfString:@"||" withString:@"|"];
    
    //Create url by removing last charachter from coordinatesForURL string
    NSString *urlPath = [NSString stringWithFormat:@"https://roads.googleapis.com/v1/snapToRoads?path=%@&interpolate=true&key=%@",[coordinatesForURL substringFromIndex:1],GOOGLE_API_KEY];
    
    
    //urlPath = [NSString stringWithFormat:@"https://roads.googleapis.com/v1/nearestRoads?points=%@&key=%@",[coordinatesForURL substringFromIndex:1],GOOGLE_API_KEY];
    
    //Remove unsupproted charchters from urlPath and create an NSURL
    NSString *escapedUrlPath = [urlPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:escapedUrlPath
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSArray *snappedPoints = [responseObject objectForKey:@"snappedPoints"];
             GMSMutablePath *pathToDraw = [[GMSMutablePath alloc]init];
             //Loop through the snapped points array and add each coordinate to the path
             //             for (int i = 0; i<[snappedPoints count]; i++) {
             //                 NSDictionary *location = [[snappedPoints objectAtIndex:i] objectForKey:@"location"];
             for (NSDictionary *dict in snappedPoints){
                 NSDictionary *location = [dict objectForKey:@"location"];
                 double latitude = [[location objectForKey:@"latitude"] doubleValue];
                 double longitude = [[location objectForKey:@"longitude"] doubleValue];
                 [pathToDraw addCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
             }
             //@{@"snappedPoints":snappedPoints, @"pathToDraw": pathToDraw}
             success(pathToDraw);
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
             if (response.statusCode == 404) {
                 //success([[NSArray alloc] init]);
             } else {
                 failure(response.description);
             }
         }];
    
    
    
    
}

+ (void)updateSellerRoute:(id)sellerRoute
                 ofSeller:(NSString*)seller
                      eta:(NSString*)eta
                  success:(void (^)(NSDictionary *dict))success
                  failure:(void (^)(NSString *message))failure {
    if ([FIRAuth auth].currentUser.uid==nil){
        failure(@"Logged out");
        return;
    }
    CLLocation * location = [[DataSingletons sharedManager] userLocation];
    
    if (sellerRoute==nil){
        [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"sellerRoute"] child:seller]
         updateChildValues:@{
                             @"postalCode" : [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_LOC_CODE],
                             @"course" : [NSNumber numberWithFloat:location.course],
                             @"longitude": [NSNumber numberWithFloat:location.coordinate.longitude],
                             @"latitude" : [NSNumber numberWithFloat:location.coordinate.latitude],
                             @"lastUpdate" : [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]]
                             }];
    }else{
        [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"sellerRoute"] child:seller]
         updateChildValues:@{@"sellerRoute": [sellerRoute objectForKey:@"sellerRoute"],
                             @"sellerRouteV2": [sellerRoute objectForKey:@"sellerRouteV2"],
                             @"eta" :eta,
                             @"postalCode" : [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_LOC_CODE],
                             @"course" : [NSNumber numberWithFloat:location.course],
                             @"longitude": [NSNumber numberWithFloat:location.coordinate.longitude],
                             @"latitude" : [NSNumber numberWithFloat:location.coordinate.latitude],
                             @"lastUpdate" : [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]]
                             }];
    }
    success(nil);
}

+ (NSDictionary*)getSellerRoute:(NSString*)sellerId
             queryType:(FIRDataEventType)queryType
               success:(void (^)(NSDictionary *dict))success
               failure:(void (^)(NSString *message))failure {
    FIRDatabaseReference* mainFirebaseReference=[[FIRDatabase database] reference];
    FIRDatabaseReference *reference = [mainFirebaseReference child:@"sellerRoute"];
    FIRDatabaseHandle fbhandle=[[reference child:sellerId] observeEventType:queryType withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableDictionary *dict = snapshot.value;
        [dict setObject:snapshot.key forKey:@"sellerId"];
        success(dict);
    }];
    
    return @{@"handle" : [NSNumber numberWithLong:fbhandle],
             @"reference": reference
             };
}

+(int)distanceBetweenLocations:(CLLocation*)oldLocation andLocation:(CLLocation*)newLocation{
    
    int  totalDistance =0;
    CLLocationDistance meters = [newLocation distanceFromLocation:oldLocation];
    
    
    totalDistance = totalDistance + (meters / 1000);
    return meters;
    return totalDistance;
}
#pragma mark - Sales Order APIs
-(void)completeSales:(id)sender success:(void (^)(id result))success
             failure:(void (^)(NSString *message))failure{
    
    
    NSDictionary *dictProposal =sender;
    
    float cut = [[[NSUserDefaults standardUserDefaults] objectForKey:SERVICEFEE] floatValue]-[[[NSUserDefaults standardUserDefaults] objectForKey:INCENTIVE] floatValue];
    
    NSMutableDictionary *debitcreditDict= [[NSMutableDictionary alloc]initWithDictionary:
                                           @{@"paidBy": [dictProposal objectForKey:@"sellerId"],
                                             @"amount" : [NSString stringWithFormat:@"%.2f", cut],
                                             @"code" : [dictProposal objectForKey:@"orderId"],
                                             @"paymentMethod" : @"Cash",
                                             @"type" : @"Cut"
                                             }];
    // check if this transaction should provide incentive(credit card) or deduct from load
    if ([[dictProposal objectForKey:@"paymentMode"] isEqualToString:@"Cash"]){
        if ([self paymentDone:debitcreditDict]==NO){
            [API addDebits:debitcreditDict
                   success:^(){
                       [self addPayments:debitcreditDict];
                   } failure:^(NSString *message) {
                       NSLog(@"Fail");
                   }];
        }
    }else{
        [debitcreditDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:INCENTIVE] forKey:@"amount"];
        [debitcreditDict setObject:@"Paymaya" forKey:@"paymentMethod"];
        [debitcreditDict setObject:@"Incentive" forKey:@"type"];
        if ([self paymentDone:debitcreditDict]==NO){
            [API addCredits:debitcreditDict
                    success:^(){
                        [self addPayments:debitcreditDict];
                    } failure:^(NSString *message) {
                        NSLog(@"Fail");
                    }];
        }
    }
    
    if ([[dictProposal objectForKey:@"paymentMode"] isEqualToString:@"Credit"]){
        debitcreditDict= [[NSMutableDictionary alloc]initWithDictionary:
                          @{@"amount" : [dictProposal objectForKey:@"totalPrice"],
                            @"code" : [dictProposal objectForKey:@"orderId"],
                            @"paymentMethod" : @"Paymaya",
                            @"type" : @"Paymaya"
                            }];
        if ([self paymentDone:debitcreditDict]==NO){
            [API createPayMayaCheckoutPayment:dictProposal
             withDelegateTarget:nil
                           successBlock:^(id response){
                               [self addPayments:debitcreditDict];
                               if (![[dictProposal objectForKey:@"status"] isEqualToString:@"Completed"] ){
                                   [API updateSalesOrder:[dictProposal objectForKey:@"orderId"] withStatus:@"Completed" withSellerId:[dictProposal objectForKey:@"sellerId"] withItems:nil withDict:dictProposal
                                                 success:^(NSDictionary *dict){
                                                     NSLog(@"update salesorder Sucess");
                                                     
                                                     [API deleteProposals:[dictProposal objectForKey:@"orderId"]
                                                                  success:^(NSDictionary *dict){
                                                                      NSLog(@"delete proposal Sucess");
                                                                      success(nil);
                                                                  } failure:^(NSString *message) {
                                                                      NSLog(@"Fail");
                                                                  }];
                                                 } failure:^(NSString *message) {
                                                     failure(message.description);
                                                 }];
                               }else{
                                   success(nil);
                               }
                           }failureBlock:^(NSError *error) {
                               
                           }];
            /*
             //payment using Paymaya Vault
            [self createCheckoutPayment:  @{@"amount" : [dictProposal objectForKey:@"totalPrice"],@"currency" : [[dictProposal objectForKey:@"currency"] uppercaseString]}
                           successBlock:^(id response){
                               [self addPayments:debitcreditDict];
                           }failureBlock:^(NSError *error) {
             
                           }];
             */
        }else{
            if (![[dictProposal objectForKey:@"status"] isEqualToString:@"Completed"] ){
                [API updateSalesOrder:[dictProposal objectForKey:@"orderId"] withStatus:@"Completed" withSellerId:[dictProposal objectForKey:@"sellerId"] withItems:nil withDict:dictProposal
                              success:^(NSDictionary *dict){
                                  NSLog(@"update salesorder Sucess");
                                  
                                  [API deleteProposals:[dictProposal objectForKey:@"orderId"]
                                               success:^(NSDictionary *dict){
                                                   NSLog(@"delete proposal Sucess");
                                                   success(nil);
                                               } failure:^(NSString *message) {
                                                   NSLog(@"Fail");
                                               }];
                              } failure:^(NSString *message) {
                                  failure(message.description);
                              }];
            }else{
                success(nil);
            }
        }
    }else{
        
    
        if (![[dictProposal objectForKey:@"status"] isEqualToString:@"Completed"] ){
            [API deleteProposals:[dictProposal objectForKey:@"orderId"]
                         success:^(NSDictionary *dict){
                             NSLog(@"delete proposal Sucess");
                             [API updateSalesOrder:[dictProposal objectForKey:@"orderId"] withStatus:@"Completed" withSellerId:[dictProposal objectForKey:@"sellerId"] withItems:nil withDict:dictProposal
                                           success:^(NSDictionary *dict){
                                               NSLog(@"update salesorder Sucess");
                                               success(@"completed");
                                               
                                           } failure:^(NSString *message) {
                                               failure(message.description);
                                           }];
                         } failure:^(NSString *message) {
                             NSLog(@"Fail 6696");
                         }];
            
            
        }else{
            success(nil);
        }
    }
    
    //clean seller routes data
//    [API updateSellerRoute:@{@"sellerRoute":@"-",@"sellerRouteV2":@"-"} ofSeller:[dictProposal objectForKey:@"sellerId"] eta: @"-"
//                   success:^(NSDictionary *dict){}
//                   failure:^(NSString *message) {}];
    
}

-(BOOL)checkIfIncentivesFeesDone:(id)sender{
    
    
    NSDictionary *dictProposal =sender;
    
    float cut = [[[NSUserDefaults standardUserDefaults] objectForKey:SERVICEFEE] floatValue]-[[[NSUserDefaults standardUserDefaults] objectForKey:INCENTIVE] floatValue];
    
    NSMutableDictionary *debitcreditDict= [[NSMutableDictionary alloc]initWithDictionary:
                                           @{@"paidBy": [dictProposal objectForKey:@"sellerId"],
                                             @"amount" : [NSString stringWithFormat:@"%.2f", cut],
                                             @"code" : [dictProposal objectForKey:@"orderId"],
                                             @"paymentMethod" : @"Cash",
                                             @"type" : @"Cut"
                                             }];
    // check if this transaction should provide incentive(credit card) or deduct from load
    if ([[dictProposal objectForKey:@"paymentMode"] isEqualToString:@"Cash"]){
        if ([self paymentDone:debitcreditDict]==YES){
            return YES;
        }
    }else{
        [debitcreditDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:INCENTIVE] forKey:@"amount"];
        [debitcreditDict setObject:@"Paymaya" forKey:@"paymentMethod"];
        [debitcreditDict setObject:@"Incentive" forKey:@"type"];
        if ([self paymentDone:debitcreditDict]==YES){
            return YES;
        }
    }

    return NO;
}

+(void)displayAlertView:(id)target withDetails:(id)details success:(void (^)(id result))success{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Logout" message:[details objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        success(nil);
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [alert addAction:ok];
    [target presentViewController:alert animated:YES completion:nil];
}
@end






