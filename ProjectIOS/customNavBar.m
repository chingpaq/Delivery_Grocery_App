//
//  customNavBar.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 22/02/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import "customNavBar.h"

@implementation customNavBar
static char const *const kHeight = "Height";


- (void)setHeight:(CGFloat)height{
    objc_setAssociatedObject(self, kHeight, @(height), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)height{
    return objc_getAssociatedObject(self, kHeight);
}

-(CGSize)sizeThatFits:(CGSize)size{
    CGSize sizeThatFits = [super sizeThatFits:size];
    sizeThatFits.height = 100;
    return sizeThatFits;
}
@end
