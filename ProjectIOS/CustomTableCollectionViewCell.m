//
//  CustomTableCollectionViewCell.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 07/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "CustomTableCollectionViewCell.h"

@implementation CustomTableCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    
    [self.collectionView registerClass:[CollectionCellType1 class] forCellWithReuseIdentifier:@"CollectionCellType1"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionCellType1" bundle:nil] forCellWithReuseIdentifier:@"CollectionCellType1"];
}


@end
