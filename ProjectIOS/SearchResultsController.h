//
//  SearchResultsController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 12/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchResultsControllerDelegate  <NSObject>
@optional
-(void)didSelectableCell:(NSIndexPath *)index withSearch:(NSString *)searchString;
@end

@interface SearchResultsController : UITableViewController
@property (strong, nonatomic) id<SearchResultsControllerDelegate>delegate;
@property (strong, nonatomic) NSMutableArray *dataArray;

@end
