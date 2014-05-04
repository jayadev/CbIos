//
//  QSImagePreviewController.h
//  CubeSale
//
//  Created by Sushant Kumar on 1/13/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QSPostController.h"

@interface QSImagePreviewController : UIViewController

@property (nonatomic, strong) UIImage *selectedImage;
- (QSPostController *) getController;
- (void) setController:(QSPostController *)controller;

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
- (IBAction) btnDontUse:(id) sender;
- (IBAction) btnUse:(id) sender;

@end
