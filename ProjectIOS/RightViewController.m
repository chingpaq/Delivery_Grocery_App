//
//  RightViewController.m
//  LGSideMenuControllerDemo
//

#import "RightViewController.h"
#import "MainViewController.h"
#import "UIViewController+LGSideMenuController.h"

@interface RightViewController ()


@end

@implementation RightViewController
NSMutableArray *pickerData;
int selectedIndex;
int currentSection;
float total=0;
//NSMutableDictionary *cfee;

//- (id)init {
//    self = [super initWithStyle:UITableViewStylePlain];
//    if (self) {
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    
    self.tableView.contentInset = UIEdgeInsetsMake(44.0, 0.0, 44.0, 0.0);
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

//
    [self.view addSubview:self.tableView];
    UIButton *proceedButton;
    
    proceedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [proceedButton addTarget:self action:@selector(proceedButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [proceedButton setFrame:CGRectMake(0, self.view.frame.size.height-85, 300, 80)];
    [proceedButton setBackgroundColor:[UIColor colorWithHexString:@"00a54F"]];
    [proceedButton setTitle:@"PROCEED" forState:UIControlStateNormal];
    [proceedButton.titleLabel setFont:[UIFont fontWithName:@"Junegull-Regular" size:18.0f]];
    [self.view addSubview:proceedButton];
    
    pickerData = [[NSMutableArray alloc]init];
    for (int i=1; i<100; i++){
        [pickerData addObject:[NSString stringWithFormat:@"%i",i]];
    }
    
    self.pickerView = [[CZPickerView alloc] initWithHeaderTitle:@"Quantity" cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm"];
    self.pickerView.headerTitleFont = [UIFont fontWithName:@"Junegull-Regular" size:18.0];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.needFooterView = NO;
    self.pickerView.frame = CGRectMake(self.pickerView.frame.origin.x, self.pickerView.frame.origin.y, self.pickerView.frame.size.width, self.pickerView.frame.size.height*.5);
    self.pickerView.headerBackgroundColor=[UIColor colorWithHexString:@"#F78320"];
    

    
    
}

-(void)doneClicked{
    self.pickerView.hidden=YES;
}
-(void)proceedButtonClicked:(id)sender
{
    //[[[Orders sharedManager] currentOrders] addObject:cfee];
    [self hideRightViewAnimated:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"proceedToCheckout" object:nil];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    //[self.tableView reloadData];
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //[[[Orders sharedManager] currentOrders] removeObject:cfee];
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0){
        total =30;//[[cfee objectForKey:@"buyingPrice"] floatValue];
        return [[[Orders sharedManager] currentOrders] count];
        
    }else if (section==1){
        return 1;
    }else{
        return 0;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0){
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            [[[Orders sharedManager] currentOrders] removeObjectAtIndex:indexPath.row];
            [self.tableView reloadData];
        }
        else if (editingStyle == UITableViewCellEditingStyleInsert)
        {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForSwipeAccessoryButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0){
        return @"Add";
    }else return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0){
        static NSString *cellIdentifier = @"OrderTableViewCell";
        OrdersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil){
            [self.tableView registerNib:[UINib nibWithNibName:@"OrdersTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
            cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
        }
        
        
        NSDictionary*dict = [[[Orders sharedManager] currentOrders] objectAtIndex:indexPath.row];
        cell.productName.text =[NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"productName"],[dict objectForKey:@"description"]];
        cell.quantity.text = [dict objectForKey:@"quantity"];
        cell.price.text = [NSString stringWithFormat:@"Price: %@%@",[dict objectForKey:@"currency"],[dict objectForKey:@"buyingPrice"]];
        total = total + ([[dict objectForKey:@"quantity"] intValue]*[[dict objectForKey:@"buyingPrice"] floatValue]);
        FIRStorageReference *storageRef = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"gs://e-utos.appspot.com/products/%@.jpg", [dict objectForKey:@"productId"]]];
        [cell.productPhoto sd_setImageWithStorageReference:storageRef placeholderImage:[UIImage imageNamed:@"e_utos_ant"]];
        
        return cell;
    
    }
    else{
        static NSString *cellIdentifier = @"OrderTableViewCell";
        OrdersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil){
            [self.tableView registerNib:[UINib nibWithNibName:@"OrdersTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
            cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        }
        
        cell.productName.text =@"Convenience Fee";
        cell.quantity.text = @"1";
        
        
        cell.price.text = [NSString stringWithFormat:@"Price: %@ %@",[[NSUserDefaults standardUserDefaults] objectForKey:SERVICEFEECURRENCY],[[NSUserDefaults standardUserDefaults] objectForKey:SERVICEFEE]];
        cell.productPhoto.image = [UIImage imageNamed:@"ant-approved"];
        
        
        return cell;
    }
        
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *HeaderCellIdentifier = @"Header";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HeaderCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HeaderCellIdentifier];
        
    }
    
    // Configure the cell title etc
    //[self configureHeaderCell:cell inSection:section];
    cell.textLabel.font=[UIFont fontWithName:@"Junegull-Regular" size:15.0f];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"00a54F"];
    if (section==0){
        cell.textLabel.text=@"MY ORDERS";
        //cell.textLabel.textColor = [UIColor colorWithHexString:@"00a54F"];
    }else if (section==1){
        //cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.text = @"SERVICES";
    }
    else{
        cell.textLabel.text=[NSString stringWithFormat:@"TOTAL: %@ %.2f",[[NSUserDefaults standardUserDefaults] objectForKey:SERVICEFEECURRENCY],total];
        cell.textLabel.font=[UIFont fontWithName:@"SEOptimistLight" size:15.0f];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    
    return cell;
}
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 102;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==1){
        return 50;
    }else{
        return 50;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section==0){
        NSDictionary*dict = [[[Orders sharedManager] currentOrders] objectAtIndex:indexPath.row];
        NSNumber *quantity = [NSNumber numberWithInteger:[[dict objectForKey:@"quantity"]intValue]-1];
        
        self.pickerView.selectedRows = [[NSArray alloc]initWithObjects:quantity, nil];
        [self.pickerView show];
        
        selectedIndex= indexPath.row;
    }
}
#pragma mark - Picker View Delegate
// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return pickerData[row];
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    NSMutableDictionary*dict = [[[Orders sharedManager] currentOrders] objectAtIndex:selectedIndex];
    [dict setObject:pickerData[row] forKey:@"quantity"];
    [self.tableView reloadData];
    
}

- (NSAttributedString *)czpickerView:(CZPickerView *)pickerView
               attributedTitleForRow:(NSInteger)row{
    
    NSAttributedString *att = [[NSAttributedString alloc]
                               initWithString:pickerData[row]
                               attributes:@{
                                            NSFontAttributeName:[UIFont fontWithName:@"Avenir-Light" size:18.0]
                                            }];
    return att;
}

- (NSString *)czpickerView:(CZPickerView *)pickerView
               titleForRow:(NSInteger)row{
    return pickerData[row];
}

- (UIImage *)czpickerView:(CZPickerView *)pickerView imageForRow:(NSInteger)row {
//    if([pickerView isEqual:self.pickerWithImage]) {
//        return pickerData[row];
//    }
    return nil;
}

- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView {
    return pickerData.count;
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row {
    NSMutableDictionary*dict = [[[Orders sharedManager] currentOrders] objectAtIndex:selectedIndex];
    [dict setObject:pickerData[row] forKey:@"quantity"];
    [self.navigationController setNavigationBarHidden:YES];
    [self.tableView reloadData];
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemsAtRows:(NSArray *)rows {
    for (NSNumber *n in rows) {
        NSInteger row = [n integerValue];
        NSLog(@"%@ is chosen!", pickerData[row]);
    }
}

- (void)czpickerViewDidClickCancelButton:(CZPickerView *)pickerView {
    [self.navigationController setNavigationBarHidden:YES];
    NSLog(@"Canceled.");
}


@end
