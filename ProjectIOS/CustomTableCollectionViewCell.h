//
//  CustomTableCollectionViewCell.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 07/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionCellType1.h"

@interface CustomTableCollectionViewCell : UITableViewCell
@property (strong, nonatomic) NSMutableArray *productsArray;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;


@end
