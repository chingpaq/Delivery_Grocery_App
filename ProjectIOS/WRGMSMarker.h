//
//  WRGMSMarker.h
//  Dashboard
//
//  Created by Jhaybie Basco on 5/17/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>


@interface WRGMSMarker : GMSMarker

@property (nonatomic, strong) NSDictionary *sellerInfo;
@property (nonatomic, strong) NSString *sellerId;
@property (nonatomic, strong) NSString *orderId;
@end
