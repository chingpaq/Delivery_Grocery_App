//
//  Created by Jhaybie Basco on 2/28/17.
//

#import "NewProductsViewController.h"

@interface NewProductsViewController ()<UITextFieldDelegate,UIImagePickerControllerDelegate, UITextViewDelegate>

@property (strong, nonatomic) UIBarButtonItem *keyboardDoneButton;
@property (strong, nonatomic) UIBarButtonItem *keyboardSkipButton;

@property (strong, nonatomic) UIToolbar *keyboardToolbar;

@end

@implementation NewProductsViewController

#pragma mark - Override Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Done button on keyboard
    self.keyboardToolbar = [[UIToolbar alloc] init];
    [self.keyboardToolbar sizeToFit];
    self.keyboardDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(saveButtonTapped:)];
    self.keyboardDoneButton.enabled = false;
    
    
    UIImage *image = [[UIImage imageNamed:@"camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(takePicture:)];
    
    UIBarButtonItem *flexibleSpace =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:self
                                                                                   action:nil];
    
    self.keyboardSkipButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(closeButtonTapped:)];
    
    [self.keyboardToolbar setItems:[NSArray arrayWithObjects:self.keyboardDoneButton, flexibleSpace,cameraButton,flexibleSpace, self.keyboardSkipButton, nil]];
    
    self.ProductTextField.inputAccessoryView= self.keyboardToolbar;
    self.UOMTextField.inputAccessoryView=self.keyboardToolbar;
    self.SRPTextField.inputAccessoryView=self.keyboardToolbar;
    self.DescriptionTextView.inputAccessoryView=self.keyboardToolbar;
    self.CurrencyTextField.inputAccessoryView=self.keyboardToolbar;
    
    
    self.DescriptionTextView.delegate=self;
    
    [self.ProductTextField addTarget:self
                              action:@selector(textFieldDidChange:)
                    forControlEvents:UIControlEventEditingChanged];
    [self.UOMTextField addTarget:self
                              action:@selector(textFieldDidChange:)
                    forControlEvents:UIControlEventEditingChanged];
    [self.SRPTextField addTarget:self
                              action:@selector(textFieldDidChange:)
                    forControlEvents:UIControlEventEditingChanged];

    [self.CurrencyTextField addTarget:self
                          action:@selector(textFieldDidChange:)
                forControlEvents:UIControlEventEditingChanged];
    
    [self.ProductTextField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    [self.ProductTextField becomeFirstResponder];
    
    
    
}
-(void)closeButtonTapped:(id)sender
{
    [self.delegate didDismissViewController:self];
}

-(void)saveButtonTapped:(id)sender
{
    
    if (self.UIImageView.image==nil)
    {
        return;
    }
    
    [SVProgressHUD show];
    
    NSString *key = [[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"products"] childByAutoId].key;
    NSDictionary *post = @{@"productName": self.ProductTextField.text,
                           @"uom": self.UOMTextField.text,
                           @"srp": self.SRPTextField.text,
                           @"currency": self.CurrencyTextField.text,
                           @"description": self.DescriptionTextView.text,
                           @"lastUpdate": [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]]
                           };
    
    
    [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"products"] child:key]
     setValue:post];
    
    [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"products-master"]
      child:self.ProductTextField.text]setValue:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]]];

    [API addToFavorites:@{@"productId": key, @"productName": self.ProductTextField.text}];
    
    
    
    
    NSURL *referenceUrl = self.imageDict[UIImagePickerControllerReferenceURL];
    // if it's a photo from the library, not an image from the camera
    if (referenceUrl) {
        PHFetchResult* assets = [PHAsset fetchAssetsWithALAssetURLs:@[referenceUrl] options:nil];
        PHAsset *asset = assets.firstObject;
        [asset requestContentEditingInputWithOptions:nil
                                   completionHandler:^(PHContentEditingInput *contentEditingInput,
                                                       NSDictionary *info) {
                                       NSURL *imageFile = contentEditingInput.fullSizeImageURL;
//                                       NSString *filePath =
//                                       [NSString stringWithFormat:@"%@/%lld/%@",
//                                        [FIRAuth auth].currentUser.uid,
//                                        (long long)([NSDate date].timeIntervalSince1970 * 1000.0),
//                                        imageFile.lastPathComponent];
                                       NSString *filePath =
                                       [NSString stringWithFormat:@"products/%@/%@",
                                        key,
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
                [NSString stringWithFormat:@"products/%@.jpg",
                 key];
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
#pragma mark - UITextField Delegate Methods

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    return true;
//    if (range.length + range.location > textField.text.length) {
//        return false;
//    }
//    
//    NSUInteger newLength = [textField.text length] + [string length] - range.length;
//    return newLength <= 2;
//}

- (void)textFieldDidChange:(DBDarkTextField *)textField {
    BOOL enabled = false;
    if (self.ProductTextField.text.length > 0
        && self.SRPTextField.text.length > 0
        && self.UOMTextField.text.length >0
        && self.DescriptionTextView.text.length>0
        && self.CurrencyTextField.text.length>0
        ) {
        
        enabled = true;
    }

    for (UIBarButtonItem *item in self.keyboardToolbar.items) {
        if (item == self.keyboardDoneButton) {
            item.enabled = enabled;
        }
    }
}

-(void)textViewDidChange:(UITextView *)textView{
    BOOL enabled = false;
    if (self.ProductTextField.text.length > 0
        && self.SRPTextField.text.length > 0
        && self.UOMTextField.text.length >0
        && self.DescriptionTextView.text.length>0
        && self.CurrencyTextField.text.length>0
        ) {
        
        enabled = true;
    }
    
    for (UIBarButtonItem *item in self.keyboardToolbar.items) {
        if (item == self.keyboardDoneButton) {
            item.enabled = enabled;
        }
    }
}
@end
