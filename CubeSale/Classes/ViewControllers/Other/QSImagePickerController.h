//
//  QSImagePickerController.h
//  CubeSale
//
//  Created by Sushant Kumar on 4/10/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QSImagePickerController : UIViewController
{
    
}

@property (nonatomic, retain) UIImagePickerController *imagePicker;

- (QSPostController *) getController;
- (void) setController:(QSPostController *)controller;

- (void)setupImagePicker:(BOOL)useLibrary;

- (IBAction) btnClick:(id) sender;
- (IBAction) btnCancel:(id) sender;
- (IBAction) btnLibrary:(id) sender;

@end
