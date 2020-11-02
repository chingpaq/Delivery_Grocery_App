//
//  CALayer+Xib.m
//  
//
//  Created by Manuel B Parungao Jr on 25/10/2017.
//

#import "CALayer+Xib.h"

@implementation CALayer(Xib)
-(void)setBorderUIColor:(UIColor*)color
{
    self.borderColor = color.CGColor;
}

-(UIColor*)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}
@end
