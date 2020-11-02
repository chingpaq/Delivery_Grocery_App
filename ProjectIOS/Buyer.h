//
//  Buyer.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 02/04/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Realm;

@interface Buyer : RLMObject
@property NSString *buyerId;
@property NSString *firstName;
@property NSString *lastName;
@property NSString *mobileNumber;
@property NSString *name;
@property NSString *postalCode;
@property NSString *ratings;

@end
