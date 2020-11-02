//
//  LeftViewController.m
//  LGSideMenuControllerDemo
//

#import "LeftViewController.h"
#import "MainViewController.h"
#import "UIViewController+LGSideMenuController.h"

@interface LeftViewController ()

@property (strong, nonatomic) NSArray *titlesArray;

@end

@implementation LeftViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        
        self.titlesArray = @[@"",
                             @"Payments",
                             @"History",
                             @"Profile",
                             @"Settings",
                             @"About",
                             @"Logout"];
        
        self.view.backgroundColor = [UIColor clearColor];
        
        self.tableView.contentInset = UIEdgeInsetsMake(44.0-20, 0.0, 44.0-20, 0.0);
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.backgroundColor = [UIColor clearColor];
        
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.opaque = NO;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.bounces = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateProfilePicture)
                                                     name:@"updateProfilePicture"
                                                   object:nil];
        
        
    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated{
    //[self.tableView reloadData];
}
- (BOOL)prefersStatusBarHidden {
    
    return YES;
}
-(void)updateProfilePicture{
    //[self.tableView reloadData];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titlesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil || indexPath.row==0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.textLabel.textColor = [UIColor blackColor];
        
        //cell.layer.borderWidth= 3;
        if (indexPath.row==0){
            static NSString *cellIdentifier = @"ProfileTableViewCell";
            ProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            if (cell==nil){
                [self.tableView registerNib:[UINib nibWithNibName:@"ProfileTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
                cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                if ([defaults objectForKey:USER_IMAGE_URL]==nil){
                    
                    FIRStorageReference *storageRef = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"gs://e-utos.appspot.com/profile/%@.jpg",[FIRAuth auth].currentUser.uid]];
                    [cell.profileImage sd_setImageWithStorageReference:storageRef placeholderImage:[UIImage imageNamed:@"camera-1"]];
                    cell.profileImage.layer.cornerRadius=30;
                    cell.profileImage.layer.masksToBounds=YES;
                    cell.profileImage.layer.borderWidth = 1.0f;
                    cell.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
                    
                }else{
                    [cell.profileImage sd_setImageWithURL:[defaults objectForKey:USER_IMAGE_URL] placeholderImage:[UIImage imageNamed:@"placeholder-user-icon"]];
                }
            }
            
            
            //cell.userInteractionEnabled=NO;
            
            if ([defaults objectForKey:USER_FULL_NAME]==nil){
                if ([defaults objectForKey:USER_ZIP_CODE]){
                    cell.fullName.text = [defaults objectForKey:@"name"];
                    if([[defaults objectForKey:USER_ZIP_CODE] isEqualToString:[defaults objectForKey:CURRENT_LOC_CODE]] || [defaults objectForKey:CURRENT_LOC_CODE]==nil )
                        cell.location.text =[NSString stringWithFormat:@" Postal: %@",[defaults objectForKey:USER_ZIP_CODE]];
                    else{
                        cell.location.text =[NSString stringWithFormat:@" Postal: %@/%@",[defaults objectForKey:USER_ZIP_CODE],[defaults objectForKey:CURRENT_LOC_CODE]];
                    }
                    cell.credits.text=[NSString stringWithFormat:@" Credits: %0.2f Ratings: %@",[[defaults objectForKey:@"credits"]floatValue],[defaults objectForKey:@"sellerRatings"]];
                    
                    
                }else{
                    cell.profileImage.image = [UIImage imageNamed:@"camera-1"];
                }
            }else{
                cell.fullName.text =[defaults objectForKey:USER_FULL_NAME];
                cell.location.text =[defaults objectForKey:USER_LOCATION];
                cell.credits.hidden=YES;
            }
        
            return cell;
            
        }
        
        
        
    }
    cell.textLabel.text = self.titlesArray[indexPath.row];
    cell.textLabel.font=[UIFont fontWithName:@"SEOptimistLight" size:15.0f];
    cell.imageView.image = [UIImage imageNamed:self.titlesArray[indexPath.row]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row==0){
        return 100;
    }else{
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
            if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_IMAGE_URL]==nil){
                [self takePicture:nil];
            }
            
            break;
        }
        case 1:{
            [self.delegate paymentsMenuPressed];
        }
            break;
        case 2:{
            [self.delegate ordersMenuPressed];
        }
            break;
        case 3:{
            [self.delegate showAddressView];
        }
            break;
        case 4:{
            [self.delegate settingsMenuPressed];
        }
            break;
        case 5:{
            [self.delegate aboutPressed];
        }
            break;
        case 6:{
            //
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Logout" message:@"Do you want to logout from e-Utos?" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
                                     [self.delegate logoutPressed];
                                 }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancel];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
            break;
        default:
            
            break;
    }
    
}

#pragma mark - Private Methods
-(void)takePicture:(id)sender
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = (id)self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:picker animated:YES completion:NULL];
}
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    self.imageDict = info;
    
    UIImage *image = self.imageDict[UIImagePickerControllerOriginalImage];
    
    
    self.UIImageView.image =image;
    
    [API createFirebaseImage:self.imageDict urlString:@"profile" fileName:[FIRAuth auth].currentUser.uid imageData:nil success:^(NSDictionary *dict2){
        NSLog(@"Success Picture ");
    } failure:^(NSString *message) {
        NSLog(@"Fail Picture");
    }];
    
}
@end

