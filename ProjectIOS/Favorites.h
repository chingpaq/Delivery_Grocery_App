//
//  Favorites.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 17/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Realm;

@interface Favorites : RLMObject
@property (strong, nonatomic)NSString *productName;
@property (strong, nonatomic)NSString *productId;
@end
