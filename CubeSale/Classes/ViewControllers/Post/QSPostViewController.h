//
//  QSPostViewController.h
//  CubeSale
//
//  Created by Sushant Kumar on 1/15/12.
//  Copyright (c) 2012 None. All rights reserved.
//



#import "QSHttpClient.h"

@protocol QSPostViewControllerDelegate;

@interface QSPostViewController : UIViewController<UITextFieldDelegate, QSHttpClientDelegate>

@property(nonatomic,assign)id<QSPostViewControllerDelegate> delegate;

@end


@protocol QSPostViewControllerDelegate <NSObject>

-(void)itemPostedSuccessfully;

@end