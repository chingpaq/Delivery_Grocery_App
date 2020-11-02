//
//  API.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 27/09/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Products.h"
#import "ProductsDetail.h"
#import "Favorites.h"
#import "NSObject+FIRDatabaseSingleton.h"
#import "DataSingletons.h"
#import "Orders.h"
#import <PayMayaSDK/PayMayaSDK.h>
#import "PMDAPIManager.h"
#import "PMDCustomer.h"
#import "NSObject+KVCParsing.h"
#import "PMDCard.h"
#import "Seller.h"
#import "Buyer.h"
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "WRGMSMarker.h"
#import "Payments.h"
#import "Constants.h"


@import Firebase;
@import Realm;
@import AFNetworking;
@import Photos;
@protocol APIDelegate <NSObject>
@optional
-(void)paymentComplete:(id)sender;
-(void)paymentFailed:(id)sender;
-(void)customerInfo:(id)sender;
@end

@interface API : NSObject<PayMayaPaymentsDelegate>

+ (id)sharedManager;
- (id)init;

@property(nonatomic, strong) PMDAPIManager *apiManager;
@property(nonatomic, strong)id<APIDelegate>delegate;
+ (void)getGlobal:(void (^)(NSDictionary *dict))success
          failure:(void (^)(NSString *message))failure;
+ (void)getAds:(NSString*)active
     queryType:(FIRDataEventType)queryType
       success:(void (^)(NSArray *dict))success
       failure:(void (^)(NSString *message))failure;

+ (void)getNewProductsMaster:(int)lastUpdate
                     success:(void (^)(void))success
                     failure:(void (^)(NSString *message))failure;

+ (NSMutableArray*)productsArrayUsingSearch:(id)predicate;

+ (NSMutableArray*)productsDetailArrayUsingSearch:(id)predicate;

+ (void)createOrUpdateBuyer:(id)result
                    success:(void (^)(void))success
                    failure:(void (^)(NSString *message))failure;

+ (void)getAllSellers:(NSString*)status
              success:(void (^)(NSArray *array))success
              failure:(void (^)(NSString *message))failure;


+ (void)addSeller: (NSDictionary*)productDict;

+ (void)updateSeller:(id)result
             success:(void (^)(void))success
             failure:(void (^)(NSString *message))failure;

+ (Seller*)getSeller: (NSString*)sellerId;

+ (Buyer*)getBuyer: (NSString*)buyerId;

+ (void)getActiveSellers:(NSString*)postalCode
               eventType:(FIRDataEventType)eventType
                 success:(void (^)(NSArray *dict))success
                 failure:(void (^)(NSString *message))failure;
+ (void)activeSellerUpdated:(NSString*)postalCode
                  eventType:(FIRDataEventType)eventType
                    success:(void (^)(NSDictionary *dict))success
                    failure:(void (^)(NSString *message))failure;
+ (void)addRatingsToBuyer:(id)sellerDict
                   rating:(int)rating
                  success:(void (^)(void))success
                  failure:(void (^)(NSString *message))failure;
+ (void)deleteProposals:(NSString*)orderId
                success:(void (^)(NSDictionary *dict))success
                failure:(void (^)(NSString *message))failure;

+ (void)getSalesProposalWithID:(NSString*)orderId
                       success:(void (^)(NSArray *array))success
                       failure:(void (^)(NSString *message))failure;
+ (void)getProductById:(NSString*)productId
               success:(void (^)(NSDictionary *dict))success
               failure:(void (^)(NSString *message))failure;

+ (void)updateBuyer:(id)result
            success:(void (^)(void))success
            failure:(void (^)(NSString *message))failure;

+ (void)getNewProducts:(int)lastUpdate
               success:(void (^)(void))success
               failure:(void (^)(NSString *message))failure;

+ (void)getProduct:(NSString*)productName
           success:(void (^)(NSDictionary *dict))success
           failure:(void (^)(NSString *message))failure;

+ (void)addToFavorites: (NSDictionary*)productDict;

+ (void)getSellerDetails:(NSString*)sellerId
               eventType:(FIRDataEventType)eventType
                 success:(void (^)(NSDictionary *dict))success
                 failure:(void (^)(NSString *message))failure;

+ (void)getLatestPromos:(NSString*)active
                success:(void (^)(NSDictionary *dict))success
                failure:(void (^)(NSString *message))failure;

+ (void)monitorActiveOrders:(NSString*)buyerId
              queryType:(FIRDataEventType)queryType
                success:(void (^)(NSDictionary *dict))success
                failure:(void (^)(NSString *message))failure;

+ (void)getAllOrders:(NSString*)buyerId
           queryType:(FIRDataEventType)queryType
             success:(void (^)(NSArray *dict))success
             failure:(void (^)(NSString *message))failure;

+ (void)getAllActiveOrders:(NSString*)buyerId
                 queryType:(FIRDataEventType)queryType
                   success:(void (^)(id data))success
                   failure:(void (^)(NSString *message))failure;

+ (void)getOrdersByPostal:(NSString*)postalCode
                queryType:(FIRDataEventType)queryType
                  success:(void (^)(id data))success
                  failure:(void (^)(NSString *message))failure;

+ (void)monitorOrdersByPostal:(NSString*)postalCode
                   withHandle:(int) handle
                    queryType:(FIRDataEventType)queryType
                      success:(void (^)(id data))success
                      failure:(void (^)(NSString *message))failure;

+ (NSDictionary*)monitorOrdersByPostal:(NSString*)postalCode
                             queryType:(FIRDataEventType)queryType
                               success:(void (^)(id data))success
                               failure:(void (^)(NSString *message))failure;

+ (void)getSalesProposals:(NSString*)orderId
                  success:(void (^)(NSArray *dict))success
                  failure:(void (^)(NSString *message))failure;

+ (void)getSalesProposals:(NSString*)fetchType
                eventType:(FIRDataEventType)eventType
                  success:(void (^)(NSArray *array))success
                  failure:(void (^)(NSString *message))failure;

+ (void)updateSalesOrder:(NSString*)orderId
              withStatus:(NSString*)status
            withSellerId:(NSString*)sellerId
               withItems:(NSArray*) salesItems
                withDict:(NSDictionary*)orderDict
                 success:(void (^)(NSDictionary *dict))success
                 failure:(void (^)(NSString *message))failure;

+ (void)updateSalesOrderBidders:(NSString*)orderId
                withSellerArray:(NSArray*)sellerArray
                        success:(void (^)(void))success
                        failure:(void (^)(NSString *message))failure;

+ (void)updateProposal:(NSString*)proposalId
            orProposals:(NSArray*)proposalArray
             withStatus:(NSString*)status
                success:(void (^)(NSDictionary *dict))success
                failure:(void (^)(NSString *message))failure;

//+ (void)updateSalesOrder:(NSString*)orderId
//              withStatus:(NSString*)status
//            withSellerId:(NSString*)sellerId
//          withProposalId:(NSString*)proposalId
//               withItems:(NSArray*) salesItems
//                 success:(void (^)(NSDictionary *dict))success
//                 failure:(void (^)(NSString *message))failure;

+ (void)updateRatingSalesOrder:(NSString*)orderId
                   withRatings:(NSString*)ratings
                       success:(void (^)(NSDictionary *dict))success
                       failure:(void (^)(NSString *message))failure;

+ (NSMutableArray*)getFavorites:(id)predicate;

+ (void)addNewProducts:(NSDictionary*)dict;

+ (void)getNewProductsMaster:(int)lastUpdate
                   eventType:(FIRDataEventType)eventType
                     success:(void (^)(void))success
                     failure:(void (^)(NSString *message))failure;


+ (void)addBuyer: (NSDictionary*)buyerDict;
+ (void)getBuyerDetails:(NSString*)buyerId
              eventType:(FIRDataEventType)eventType
                success:(void (^)(NSDictionary *dict))success
                failure:(void (^)(NSString *message))failure;

-(BOOL)checkIfIncentivesFeesDone:(id)sender;

+ (void)registerLoad:(id)dict
            cardCode:(NSString*)cardCode
             cardPin:(NSString*)cardPin
             success:(void (^)(NSDictionary*dict))success
             failure:(void (^)(NSString *message))failure;

+ (void)getCredits:(NSString*)sellerId
         queryType:(FIRDataEventType)queryType
           success:(void (^)(NSArray *array))success
           failure:(void (^)(NSString *message))failure;

+ (void)addCredits:(id)result
           success:(void (^)(void))success
           failure:(void (^)(NSString *message))failure;

+ (void)addDebits:(id)result
          success:(void (^)(void))success
          failure:(void (^)(NSString *message))failure;

+ (void)getDebits:(NSString*)sellerId
        queryType:(FIRDataEventType)queryType
          success:(void (^)(NSArray *array))success
          failure:(void (^)(NSString *message))failure;

+ (void)getSingleCredit:(NSString*)sellerId
              queryType:(FIRDataEventType)queryType
                success:(void (^)(NSDictionary *dict))success
                failure:(void (^)(NSString *message))failure;

+ (void)getSingleDebit:(NSString*)sellerId
             queryType:(FIRDataEventType)queryType
               success:(void (^)(NSDictionary *dict))success
               failure:(void (^)(NSString *message))failure;

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
                     failure:(void (^)(NSString *message))failure;

-(void)getCreditCardToken:(void (^)(id))successBlock
             failureBlock:(void (^)(NSError *))failureBlock;

- (void)deletePaymentCustomerCard:(NSString*)cardID
                       customerID:(NSString*)customerID
                     successBlock:(void (^)(id))successBlock
                     failureBlock:(void (^)(NSError *))failureBlock;

-(void) createCheckoutPayment:(NSDictionary*)totalPayment
                 successBlock:(void (^)(id))successBlock
                 failureBlock:(void (^)(NSError *))failureBlock;

+(void) createPayMayaCheckoutPayment:(NSDictionary*)orderDict
                  withDelegateTarget:(id)delegate
                        successBlock:(void (^)(id))successBlock
                        failureBlock:(void (^)(NSError *))failureBlock;

#pragma mark - Map APIs
+(void)getRouteAndTimeToArriveWithCurrentLatitude:(float)lat andCurrentLongitude:(float)longi andUserLatitude:(float)userLat andUserLongitude:(float)userLong withTransportMode:(NSString*)mode success:(void (^)(NSMutableDictionary *routeDict))success failure:(void (^)(NSString *message))failure;

+(void)drawMapRoute:(NSMutableArray*)routeArray usingMap:(GMSMapView*)mapView withLatitude:(double)latitude andLongitude:(double)longitude withLineColor:(UIColor*)color andStrokeWidth:(float)strokeWidth withIcon:(NSString*) icon andStartDrawingAt:(int) drawAt;

+(void)snapPathToRoad:(NSMutableArray*)passedInArray
              success:(void (^)(GMSMutablePath *pathToDraw))success
              failure:(void (^)(NSString *message))failure;

+(void)snapPathToRoadv2:(NSMutableArray*)passedInArray
              success:(void (^)(id dict))success
              failure:(void (^)(NSString *message))failure;

+ (void)updateSellerRoute:(id)sellerRoute
                 ofSeller:(NSString*)seller
                      eta:(NSString*)eta
                  success:(void (^)(NSDictionary *dict))success
                  failure:(void (^)(NSString *message))failure;

+ (NSDictionary*)getSellerRoute:(NSString*)sellerId
             queryType:(FIRDataEventType)queryType
               success:(void (^)(NSDictionary *dict))success
               failure:(void (^)(NSString *message))failure;

+(int)distanceBetweenLocations:(CLLocation*)oldLocation andLocation:(CLLocation*)newLocation;

-(void)completeSales:(id)sender success:(void (^)(id result))success
             failure:(void (^)(NSString *message))failure;

+(void)createFirebaseImage:(NSDictionary*)imageDict urlString:(NSString*)urlString fileName:(NSString *)fileName imageData:(UIImage*)imageData
                   success:(void (^)(NSDictionary *dict))success
                   failure:(void (^)(NSString *message))failure;
@end
