//
//  ProductsDetail.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 08/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Realm;
@interface ProductsDetail : RLMObject
@property NSString *productName;
@property NSString *productId;
@property NSString *productDescription;
@property NSString *uom;
@property NSString *srp;
@property NSString *lastUpdate;
@property NSString *currency;

@end
