//
//  OrdersTableViewCell.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 15/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "OrdersTableViewCell.h"

@implementation OrdersTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.quantity addSubview:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"down-button-full"]]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    UITouch *touch=[[event allTouches] anyObject];
//    if([touch view]== self.quantity)
//    {
//        NSLog(@"2");
//    }
//    else
//        NSLog(@"1");
//    [self.delegate cellpressed:nil];
//    
//}

@end
