//
//  Constants.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 28/11/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#pragma mark - NSUSERDEFAULT KEYS

#define IS_SESSION_ACTIVE   @"IsSessionActive"
#define USER_IMAGE_URL      @"UserImageURL"
#define USER_FULL_NAME      @"UserFullName"
#define USER_LOCATION       @"UserLocation"
#define USER_STREET         @"UserStreet"
#define USER_CITY           @"UserCity"
#define USER_STATE          @"UserState"
#define USER_ZIP_CODE       @"UserZipCode"
#define USER_MOBILE         @"UserMobile"
#define CURRENT_LOC_CODE    @"CurrentZipCode"
#define USER_ADDRESS_EXISTS @"UserAddressExists"
#define CONTACTS_IMPORTED   @"ContactsImported"
#define ALL_CONTACTS        @"AllContacts"
#define USERNAME            @"Username"
#define PASSWORD            @"Password"
#define AUTH_TOKEN          @"AuthToken"
#define REFRESH_TOKEN       @"RefreshToken"
#define USER_FIRST_NAME     @"first_name"
#define USER_LAST_NAME     @"last_name"
#define SMS_COUNTER         @"sms_counter"
#define EMAIL_COUNTER       @"email_counter"
#define CALL_COUNTER        @"call_counter"
#define CFEE                @{@"buyingPrice":@"30.00",@"productId": @"CFEE",@"quantity":@"1",@"currency":@"Php",@"buyingUOM":@"unit",@"productName":@"Convenience Fee",@"srp":"30.00"}
#define GATEWAY             @"gateway"
#define SERVICEFEE          @"sellerfee"
#define SERVICEFEECURRENCY  @"sellerfeecurrency"
#define INCENTIVE           @"sellerincentive"
#define INCENTIVECURRENCY   @"sellerincentivecurrency"

#define MAP_ROUTING_TYPE    @"routingType"
#define MAP_ROUTING_DIST    @"routingDistance"

#define FIREBASE_STORAGE_URL @"SUPPLY YOUR OWN"
#define GOOGLE_API_KEY      @"SUPPLY YOUR OWN"
@end
