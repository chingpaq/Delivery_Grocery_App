//
//  CustomTabBar.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 21/02/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import "CustomTabBar.h"

@implementation CustomTabBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(CGSize)sizeThatFits:(CGSize)size
{
    CGSize sizeThatFits = [super sizeThatFits:size];
    sizeThatFits.height = 100-10;
    
    return sizeThatFits;
    
}
@end
