//
//  QSPostController.h
//  CubeSale
//
//  Created by Sushant Kumar on 1/13/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <Foundation/Foundation.h>

enum QSPostStatus {
    WORKING = 0,
    POSTED = 1,
    CANCELLED = 2
};

@interface QSPostController : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property bool pickerStatus;
@property enum QSPostStatus postStatus;

- (void) start:(UINavigationController *)parentView :(bool)editing :(NSDictionary *)item;

- (void) onPostViewAppeared;
- (void) onShowLibrary;
- (void) onPickerUse;
- (void) onPickerCancel;
- (void) onPostEditImage:(BOOL)useLibrary;
- (void) onPostCancel;
- (void) onPostSubmit;

@end
