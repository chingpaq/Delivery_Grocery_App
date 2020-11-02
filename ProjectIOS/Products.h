//
//  products.h
//  
//
//  Created by Manuel B Parungao Jr on 27/09/2017.
//

#import <Foundation/Foundation.h>
@import Realm;

@interface Products : RLMObject
@property NSString *productName;
@property NSString *lastUpdate;
@end
