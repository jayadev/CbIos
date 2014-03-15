//
//  QSPostController.m
//  CubeSale
//
//  Created by Sushant Kumar on 1/13/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "QSUtil.h"
#import "QSPostController.h"
#import "QSPostViewController.h"
#import "QSImagePickerController.h"

@implementation QSPostController
{
    bool _editing;
    __unsafe_unretained UINavigationController *_parentView;
    
    QSImagePickerController *_picker;
    UIImage *_previewImage;
    
    QSPostViewController *_product;
}

@synthesize pickerStatus;
@synthesize postStatus;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.pickerStatus = false;
        self.postStatus = WORKING;

        _picker = NULL;
        _previewImage = NULL;
    }
    return self;
}

- (void) dealloc
{
    NSLog(@"dealloc: QSPostController");
}

- (void) start:(UINavigationController *)parentView :(bool)editing :(NSDictionary *)item
{
    _parentView = parentView;
    _editing = editing;

    _product = [[QSPostViewController alloc] initWithNibName:@"QSPostViewController" bundle:nil];
    [_product setController:self :editing :item];

    // starting from main post view
    _editing = true;
    
    if(_editing) {
        [_parentView pushViewController:_product animated:YES];
    } else {
        [self onPostEditImage:NO];
    }
}

- (void) onPostViewAppeared
{
    if(pickerStatus) {
        _product.productImage.image = _previewImage;        
    }
}

- (void) onShowLibrary
{
    [_parentView dismissModalViewControllerAnimated:NO];
    [self onPostEditImage:YES];
}

- (void) onPickerUse
{
    pickerStatus = true;
    _picker = nil;
    
    if(_editing) {
        // dismiss picker
        [_parentView dismissModalViewControllerAnimated:YES];
    } else {
        _editing = TRUE;
        
        // dismiss picker and go to edit
        [_parentView dismissModalViewControllerAnimated:NO];
        [_parentView pushViewController:_product animated:YES];
    }    
}

- (void) onPickerCancel
{
    pickerStatus = false;
    _picker = nil;

    if(_editing) {  
        // go back to product edit
        [_parentView dismissModalViewControllerAnimated:YES]; // picker
    } else {
        postStatus = CANCELLED;
        [_parentView dismissModalViewControllerAnimated:YES]; // picker
    }
}

- (void) onPostCancel
{
    NSLog(@"Post cancelled");
    postStatus = CANCELLED;
    
    if(_editing) {
        [_parentView popViewControllerAnimated:YES];
    } else {
    }
}

- (void) onPostSubmit
{
    postStatus = POSTED;

    if(_editing) {
        [_parentView popViewControllerAnimated:YES];
    } else {
    }
}

- (void) onPostEditImage:(BOOL)useLibrary
{
    _picker = [[QSImagePickerController alloc] initWithNibName:@"QSImagePickerController" bundle:nil];
    [_picker setController:self];
    [_picker setupImagePicker:useLibrary];
    [_parentView presentModalViewController:_picker.imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{    
    NSLog(@"Picked an image");
    
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    if(nil == image) image = [info valueForKey:UIImagePickerControllerOriginalImage];    

    UIImage *scaledImage = [QSUtil scaleImage:image :960];
    
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        int ycrop = (scaledImage.size.height - 640) / 2;
        CGRect bounds = CGRectMake(0, ycrop, scaledImage.size.width, scaledImage.size.width);
        CGImageRef cgRectImage = CGImageCreateWithImageInRect([scaledImage CGImage], bounds);
        _previewImage = [[UIImage alloc] initWithCGImage:cgRectImage];
        CGImageRelease(cgRectImage);
    } else {
        _previewImage = scaledImage;
    }

    [self onPickerUse];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Cancelled image picker");

    [self onPickerCancel];
}

@end
