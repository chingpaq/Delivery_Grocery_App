//
//  CustomSalesMapViewTableViewCell.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 01/03/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import "CustomSalesMapViewTableViewCell.h"

@implementation CustomSalesMapViewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.quantity addSubview:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"textbox_small"]]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
