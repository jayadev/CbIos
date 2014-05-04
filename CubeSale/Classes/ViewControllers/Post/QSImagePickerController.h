//
//  QSImagePickerController.h
//  CubeSale
//
//  Created by Sushant Kumar on 4/10/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QSImagePickerControllerDelegate;

@interface QSImagePickerController : UIViewController
{
    
}

@property(nonatomic,assign)id<QSImagePickerControllerDelegate>delegate;

@end

@protocol QSImagePickerControllerDelegate <NSObject>

-(void)dismissImagePickerController;
-(void)showImagePickerWithPhotoAlbum;
-(void)takePicture;
@end