//
//  orders.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 14/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "Orders.h"

@implementation Orders


static Orders *manager = nil;

+ (Orders *)sharedManager;{
    if (manager == nil) {
        manager = [[self alloc] init];
    }
    
    return manager;
}

+ (Orders *)clearCurrentOrders{
    manager = [[self alloc] init];
    
    return manager;
}


- (id)init{
    self = [super init];
    
    if (self) {
        self.currentOrders = [[NSMutableArray alloc]init];
        self.sellersWithActiveOrders = [[NSMutableArray alloc] init];
        self.activeOrders = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
