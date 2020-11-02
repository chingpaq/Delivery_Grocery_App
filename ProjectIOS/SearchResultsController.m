//
//  SearchResultsController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 12/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "SearchResultsController.h"

@interface SearchResultsController ()

@end

@implementation SearchResultsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        //cell.backgroundColor = [UIColor clearColor];
        //cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        //cell.textLabel.textColor = [UIColor whiteColor];
        //cell.textLabel.highlightedTextColor = [UIColor blueColor];
        //cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    NSDictionary *dict = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"productName"];
    //cell.imageView.image = [UIImage imageNamed:self.titlesArray[indexPath.row]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        default:
        {
            [self.delegate didSelectableCell:indexPath withSearch:nil];
        }
            break;
    }
    
}


@end
