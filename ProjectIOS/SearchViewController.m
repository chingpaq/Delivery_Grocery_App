//
//  SearchViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 12/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    
    self.dataArray = [API productsArrayUsingSearch:nil];
    [self.tableView reloadData];
    
    
    self.searchResultsController = [[SearchResultsController alloc]initWithNibName:@"SearchResultsController" bundle:nil ];
    self.searchResultsController.delegate=self;
    
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate=self;
    self.searchController.view.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 10);
    
    
    
    self.searchController.searchBar.barTintColor =[UIColor clearColor];
    self.searchController.searchBar.barTintColor =[UIColor colorWithRed:56.0/255 green:185.0/255 blue:158.0/255 alpha:1];
    self.searchController.searchBar.barTintColor =[UIColor whiteColor];
    self.tableView.tableHeaderView=self.searchController.searchBar;
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
        
    }
    
    NSDictionary *dict = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"productName"];
    cell.backgroundColor = [UIColor offWhite];
    cell.layer.borderWidth=3;
    cell.layer.borderColor = [[UIColor whiteColor]CGColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        default:
        {
            NSDictionary *dict= [self.dataArray objectAtIndex:indexPath.row];
            [self performSegueWithIdentifier:@"showSearchItemDetail" sender:dict];

        }
            break;
    }
    
}




#pragma mark - SearchResultsController delegates
-(void)didSelectableCell:(NSIndexPath *)index withSearch:(NSString *)searchString{
    NSDictionary *dict= [self.searchResultsController.dataArray objectAtIndex:index.row];
    
    [self performSegueWithIdentifier:@"showSearchItemDetail" sender:dict];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSearchItemDetail"]) {
        
        self.productViewController = [segue destinationViewController];
        
        NSDictionary *productDetail= [[API productsDetailArrayUsingSearch:[NSString stringWithFormat:@"productName contains '%@'", [sender objectForKey:@"productName"]]] firstObject];
        
        
        if (productDetail!=nil){
            self.productViewController.productDict = [productDetail mutableCopy];
        }else{
            self.productViewController.productDict =sender;
        }
            self.productViewController.delegate=self;
    }
}
// When the user types in the search bar, this method gets called.
- (void)updateSearchResultsForSearchController:(UISearchController *)aSearchController {
    NSLog(@"updateSearchResultsForSearchController");
    
    NSString *searchString = aSearchController.searchBar.text;
    NSLog(@"searchString=%@", searchString);
    
    // Check if the user cancelled or deleted the search term so we can display the full list instead.
    if (![searchString isEqualToString:@""]) {
        self.searchResultsController.dataArray=[API productsArrayUsingSearch:searchString];
        [self.searchResultsController.tableView reloadData];
        
    }
    else {
        //        self.displayedItems = self.allItems;
    }
    [self.tableView reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"clicked");
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - ProductViewController delegate
-(void)addCartPressed:(id)sender
{
    [[[Orders sharedManager] currentOrders] addObject:sender];
}
@end
