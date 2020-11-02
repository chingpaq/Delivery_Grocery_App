//
//  CreateSellerViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 22/03/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import "CreateSellerViewController.h"

@interface CreateSellerViewController ()

@end

@implementation CreateSellerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBarHidden=NO;
    self.emailTextbox.delegate=self;
    self.firstnameTextbox.delegate=self;
    self.lastnameTextbox.delegate=self;
    self.passwordTextbox.delegate=self;
    self.confirmPasswordTextbox.delegate=self;
    self.mobileNumberTextBox.delegate=self;
    self.postalCodeTextBox.delegate=self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) {
        self.navigationController.navigationBarHidden=YES;
    }
}
- (IBAction)signupWasPressed:(id)sender {
    if (![self.emailTextbox.text isEqualToString:@""])
    {
        if ([self.passwordTextbox.text isEqualToString:@""] || [self.confirmPasswordTextbox.text isEqualToString:@""])
        {
            [self showMessagePrompt:@"Empty password"];
            
        }
        else
        {
            if ([self.passwordTextbox.text isEqualToString:self.confirmPasswordTextbox.text])
            {
                if (![self.postalCodeTextBox.text isEqualToString:@""]){
                    //[self showMessagePrompt:@"Profile Picture will be taken"];
                    [self takePicture:nil];
                }else{
                    [self showMessagePrompt:@"Postal Code is required"];
                }
            }
            else
            {
                [self showMessagePrompt:@"Passwords don't match"];
            }
        }
    }
    else
    {
        [self showMessagePrompt:@"Email is required"];
    }
}

-(void)createProfileUsingEmail
{
    [SVProgressHUD show];
    [[FIRAuth auth] createUserWithEmail:self.emailTextbox.text
                               password:self.passwordTextbox.text
                             completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                                 [SVProgressHUD dismiss];
                                 if (error) {
                                     [self showMessagePrompt: error.localizedDescription];
                                     return;
                                 }
                                 NSLog(@"%@ created", user.email);
                                 // create buyer profile
                                 [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"sellers"] child:[FIRAuth auth].currentUser.uid]
                                  setValue:@{@"name": [NSString stringWithFormat:@"%@ %@", self.firstnameTextbox.text,self.lastnameTextbox.text],
                                             @"firstName" : self.firstnameTextbox.text,
                                             @"lastName" : self.lastnameTextbox.text,
                                             @"mobileNumber" : self.mobileNumberTextBox.text,
                                             @"postalCode": self.postalCodeTextBox.text,
                                             @"ratings": [NSNumber numberWithInt:0],
                                             @"active": @"Yes"
                                             }];
                                 
                                 
                                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                 //[defaults setObject:@"True" forKey:USER_ADDRESS_EXISTS];
                                 //[defaults setObject:self.streetTextField.text forKey:USER_STREET];
                                 //[defaults setObject:self.cityTextField.text forKey:USER_CITY];
                                 //[defaults setObject:self.stateTextField.text forKey:USER_STATE];
                                 [defaults setObject:self.postalCodeTextBox.text forKey:USER_ZIP_CODE];
                                 [defaults setObject:self.mobileNumberTextBox.text forKey:USER_MOBILE];
                                 
                                 
                                 [self.navigationController popViewControllerAnimated:NO];
                                 //[self createProfilePicture];
                                 
                                 [API createFirebaseImage:self.imageDict urlString:@"profile" fileName:[FIRAuth auth].currentUser.uid imageData:nil success:^(NSDictionary *dict2){

                                 } failure:^(NSString *message) {
                                     NSLog(@"Fail");
                                 }];
                                 
                                 
                             }];
    
    [self updateFirstLastName];
    
    
    
}

-(void)updateFirstLastName
{
    if (![self.lastnameTextbox.text isEqualToString:@""] && ![self.firstnameTextbox.text isEqualToString:@""])
    {
        FIRUserProfileChangeRequest *changeRequest = [[FIRAuth auth].currentUser profileChangeRequest];
        changeRequest.displayName = [NSString stringWithFormat:@"%@ %@", self.firstnameTextbox.text, self.lastnameTextbox.text];
        [changeRequest commitChangesWithCompletion:^(NSError *_Nullable error) {
            //ok
        }];
    }
}

#pragma mark - Private Methods
-(void)createProfilePicture{
    NSURL *referenceUrl = self.imageDict[UIImagePickerControllerReferenceURL];
    // if it's a photo from the library, not an image from the camera
    if (referenceUrl) {
        PHFetchResult* assets = [PHAsset fetchAssetsWithALAssetURLs:@[referenceUrl] options:nil];
        PHAsset *asset = assets.firstObject;
        [asset requestContentEditingInputWithOptions:nil
                                   completionHandler:^(PHContentEditingInput *contentEditingInput,
                                                       NSDictionary *info) {
                                       NSURL *imageFile = contentEditingInput.fullSizeImageURL;
                                       
                                       NSString *filePath =
                                       [NSString stringWithFormat:@"profile/%@/%@",
                                        [FIRAuth auth].currentUser.uid,
                                        imageFile.lastPathComponent];
                                       
                                       [[[[FIRDatabaseSingleton sharedManager] storageRef] child:filePath]
                                        putFile:imageFile metadata:nil
                                        completion:^(FIRStorageMetadata *metadata, NSError *error) {
                                            if (error) {
                                                NSLog(@"Error uploading: %@", error);
                                                
                                                return;
                                            }
                                            [SVProgressHUD dismiss];
                                            [self.delegate didDismissViewController:self];
                                            //[self uploadSuccess:metadata storagePath:filePath];
                                        }];
                                       // [END uploadimage]
                                   }];
        
    } else {
        UIImage *image = self.imageDict[UIImagePickerControllerOriginalImage];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
        NSString *imagePath =
        [NSString stringWithFormat:@"profile/%@.jpg",
         [FIRAuth auth].currentUser.uid];
        FIRStorageMetadata *metadata = [FIRStorageMetadata new];
        metadata.contentType = @"image/jpeg";
        [[[[FIRDatabaseSingleton sharedManager] storageRef] child:imagePath] putData:imageData metadata:metadata
                                                                          completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
                                                                              if (error) {
                                                                                  NSLog(@"Error uploading: %@", error);
                                                                                  //_urlTextView.text = @"Upload Failed";
                                                                                  return;
                                                                              }
                                                                              //[self uploadSuccess:metadata storagePath:imagePath];
                                                                              [SVProgressHUD dismiss];
                                                                              [self.delegate didDismissViewController:self];
                                                                          }];
        
    }
}
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
    
    
    [self createProfileUsingEmail];
    
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

@end

