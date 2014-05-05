//
//  QSPostViewController.m
//  CubeSale
//
//  Created by Sushant Kumar on 1/15/12.
//  Copyright (c) 2012 None. All rights reserved.
//

//#import <Accounts/Accounts.h>
//#import <Social/Social.h>
#import "QSUtil.h"
#import "QSPostViewController.h"
#import "QSUserSession.h"
#import "QSImagePickerController.h"
#import "QSApiConstants.h"
#import "QSProgressView.h"

typedef enum {
    FREE = 0,
    LUNCH = 1,
    COFFEE = 2,
    MONEY = 3
}PriceType;

@interface QSPostViewController () <UIScrollViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,QSImagePickerControllerDelegate>
{
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *postImage;
    IBOutlet UILabel *setImageLabel;
    IBOutlet UIButton *btnCoffe;
    IBOutlet UIButton *btnLunch;
    IBOutlet UIButton *btnFree;
    IBOutlet UIButton *btnPost;
    IBOutlet UITextField *tfDescription;
    IBOutlet UITextField *tfPrice;
    IBOutlet UILabel *lbPayBy;

    PriceType priceType;
    QSProgressView *progressView;
}
@property(nonatomic,strong)UIImage *selectedImage;
@property(nonatomic,strong)UIImagePickerController *pickerForCamera;
@property(nonatomic,strong)UIImagePickerController *pickerForPhotoLibrary;
@property(nonatomic,strong)QSImagePickerController *imagePickerCon;
@property(nonatomic,strong)QSHttpClient *httpClient;
@end

@implementation QSPostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        priceType = COFFEE;
    }
    return self;
}
- (void) dealloc
{
    NSLog(@"dealloc: QSPostViewController");
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    scrollView.frame = self.view.bounds;
    NSLog(@"____1111:%@",NSStringFromCGRect(scrollView.frame));
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, 1100);
   // scrollView.scrollEnabled = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [btnPost setBackgroundColor:[UIColor colorWithRed:42.0f/255.0f green:87.0f/255.0f blue:128.0f/255.0f alpha:1]];
}

- (UIImagePickerController*)setupImagePicker:(BOOL)useLibrary
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if(!useLibrary && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.showsCameraControls = NO;
        if([[imagePicker.cameraOverlayView subviews] count] == 0) {
            self.imagePickerCon = [[QSImagePickerController alloc] initWithNibName:@"QSImagePickerController" bundle:nil];
            self.imagePickerCon.delegate = self;
            [imagePicker.cameraOverlayView addSubview:self.imagePickerCon.view];
        }
    }
    return imagePicker;
}

#pragma mark Button Action Methods -
-(IBAction)btnPayCoffeeAction:(UIButton*)sender {
    [self clearPay];
    priceType = COFFEE;
    lbPayBy.text = @"List it for: Coffee";
    [btnCoffe setImage:[UIImage imageNamed:@"coffee2.png"] forState:UIControlStateNormal];

}
-(IBAction)btnPayLunchAction:(UIButton*)sender {
    [self clearPay];
    priceType = LUNCH;
    lbPayBy.text = @"List it for: Lunch";
    [btnLunch setImage:[UIImage imageNamed:@"lunch2.png"] forState:UIControlStateNormal];

}
-(IBAction)btnFreeAction:(UIButton*)sender {
    [self clearPay];
    priceType = FREE;
    lbPayBy.text = @"List it for: Free";
    [btnFree setImage:[UIImage imageNamed:@"free2.png"] forState:UIControlStateNormal];
}
-(IBAction)btnPhotoAlbumAction:(UIButton*)sender {
    self.pickerForCamera = [self setupImagePicker:FALSE];
    [self presentViewController:self.pickerForCamera animated:YES completion:nil];
}
-(IBAction)cancelBtnAction {
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)postBtnAction {

    int kMaxResolution = 640;

    QSUserSession *userSession = [[QSUserSession alloc] init];
    NSString *userId = [userSession getUserId];

    NSString *price = tfPrice.text;
    if(priceType == FREE) price = @"free";
    else if(priceType == LUNCH) price = @"lunch";
    else if(priceType == COFFEE) price = @"coffee";

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:userId forKey:KAPI_USERID];
    [params setObject:price forKey:KAPI_POSTITEM_PRICE];
    [params setObject:[NSString stringWithFormat:@"%d", kMaxResolution] forKey:KAPI_POSTITEM_IMAGESIZE];
    [params setObject:@"0" forKey:KAPI_POSTITEM_STATUS];
    if(self.selectedImage){
        [params setObject:self.selectedImage forKey:KAPI_POSTITEM_IMAGE];
    }
    if(![QSUtil isEmptyString:tfDescription.text]) {
        [params setObject:tfDescription.text forKey:KAPI_POSTITEM_DESCRIPTION];
    }

    if(!self.httpClient){
        self.httpClient = [[QSHttpClient alloc] init];
        self.httpClient.delegate = self;
    }
    [self.httpClient executeNetworkRequest:RequestType_Post_Multipart WithRelativeUrl:QS_API_POST parameters:params];

    [tfDescription resignFirstResponder];
    [tfPrice resignFirstResponder];

    progressView = [[QSProgressView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:progressView];
    [progressView start];
}

- (void) clearPay
{
    [btnCoffe setImage:[UIImage imageNamed:@"coffee1.png"] forState:UIControlStateNormal];
    [btnLunch setImage:[UIImage imageNamed:@"lunch1.png"] forState:UIControlStateNormal];
    [btnFree setImage:[UIImage imageNamed:@"free1.png"] forState:UIControlStateNormal];

    tfPrice.text = @"";
    lbPayBy.text = @"";
}

#pragma mark UITextFieldDelegate -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];

	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [scrollView setContentOffset:CGPointMake(0, 200)];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [scrollView setContentOffset:CGPointMake(0, 0)];
    if(tfPrice == textField){
        NSString *price = textField.text;
        if(![QSUtil isEmptyString:price]) {
            [self clearPay];
            tfPrice.text = price;
            priceType = MONEY;
        }
        else {
            [self clearPay];
            priceType = COFFEE;
            lbPayBy.text = @"List it for: Coffee";
            [btnCoffe setImage:[UIImage imageNamed:@"coffee2.png"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark QHHttpClient Delegate -
- (void) connectionDidFinishWithData:(NSDictionary *)response withError:(NSError*)error {

    [progressView start];
    [progressView removeFromSuperview];

    if((response) && (!error)) {
        NSLog(@"RESPONSE:%@",response);
        BOOL status = [[response objectForKey:@"status"] boolValue];
        if(status){
            if(self.delegate) {
                [self.delegate itemPostedSuccessfully];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error in Posting" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else {
        //error handling
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error in Posting" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark UIImagePickerController Delegate -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    if(nil == image) image = [info valueForKey:UIImagePickerControllerOriginalImage];

    UIImage *scaledImage = [QSUtil scaleImage:image :960];

    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        int ycrop = (scaledImage.size.height - 640) / 2;
        CGRect bounds = CGRectMake(0, ycrop, scaledImage.size.width, scaledImage.size.width);
        CGImageRef cgRectImage = CGImageCreateWithImageInRect([scaledImage CGImage], bounds);
        self.selectedImage = [[UIImage alloc] initWithCGImage:cgRectImage];
        CGImageRelease(cgRectImage);
    } else {
        self.selectedImage = scaledImage;
    }

    postImage.image = self.selectedImage;
    setImageLabel.hidden = TRUE;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark QSImagePickerController Delegate -
-(void)dismissImagePickerController {
    [self.pickerForCamera dismissViewControllerAnimated:YES completion:nil];
}
-(void)showImagePickerWithPhotoAlbum {
    self.pickerForPhotoLibrary = [self setupImagePicker:YES];
    [self.pickerForCamera dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:self.pickerForPhotoLibrary animated:YES completion:nil];

}
-(void)takePicture {
    [self.pickerForCamera takePicture];
}

@end


