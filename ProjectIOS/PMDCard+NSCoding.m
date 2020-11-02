//
//  PMDCard+NSCoding.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 13/11/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "PMDCard+NSCoding.h"

@implementation PMDCard (NSCoding)



- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    /*
     property (nonatomic, strong) NSString *tokenIdentifier;
     @property (nonatomic, strong) NSString *type;
     @property (nonatomic, strong) NSString *maskedPan;
     @property (nonatomic, strong) NSString *state;
     @property (nonatomic, strong) NSString *verificationURL;
     */
    self.tokenIdentifier = [decoder decodeObjectForKey:@"tokenIdentifier"];
    self.type = [decoder decodeObjectForKey:@"type"];
    self.maskedPan = [decoder decodeObjectForKey:@"maskedPan"];
    
    self.state = [decoder decodeObjectForKey:@"state"];
    self.verificationURL = [decoder decodeObjectForKey:@"verificationURL"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.tokenIdentifier forKey:@"tokenIdentifier"];
    [encoder encodeObject:self.type forKey:@"type"];
    [encoder encodeObject:self.maskedPan forKey:@"maskedPan"];
    [encoder encodeObject:self.state forKey:@"state"];
    [encoder encodeObject:self.verificationURL forKey:@"verificationURL"];
    
}
@end
