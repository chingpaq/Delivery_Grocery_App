//
//  Payments.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 07/06/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Realm;

@interface Payments : RLMObject
@property NSString *code;
@property NSString *amount;
@property NSString *type;
//@property NSNumber *orderDate;
@end
