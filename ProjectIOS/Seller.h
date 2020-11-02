//
//  Seller.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 13/12/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Realm;

@interface Seller : RLMObject
@property NSString *sellerId;
@property NSString *firstName;
@property NSString *lastName;
@property NSString *mobileNumber;
@property NSString *name;
@property NSString *postalCode;
@property NSString *ratings;
@property NSString *status;
@end
