//
//  CustomAdCell.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 02/12/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "CustomAdCell.h"

@implementation CustomAdCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.scrollView.delegate=self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    
    
    self.pageControl.currentPage = (int)scrollView.contentOffset.x / (int)pageWidth;
    
}

@end
