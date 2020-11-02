//
//  orders.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 14/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Orders : NSObject
+ (id)sharedManager;
//+ (id)restartSharedManager;
+ (id)clearCurrentOrders;
- (id)init;

@property(nonatomic, strong) NSMutableArray *currentOrders;
@property(nonatomic, strong) NSMutableArray *sellersWithActiveOrders;
@property(nonatomic, strong) NSMutableArray *activeOrders;
@end
