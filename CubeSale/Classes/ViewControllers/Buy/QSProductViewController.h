//
//  QSProductViewController.h
//  CubeSale
//
//  Created by Sushant Kumar on 1/11/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "QSLazyImage.h"

@interface QSProductViewController : UIViewController<AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource> {
    
}


@property (nonatomic, strong) IBOutlet QSLazyImage *commentProfileImage;

@property (nonatomic, strong) IBOutlet UIButton *commentCancelButton;


@property (nonatomic, strong) IBOutlet UIView *descView;
@property (nonatomic, strong) IBOutlet UIView *profileView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withProductInfo:(NSDictionary*)item;

- (IBAction) btnFullScreen:(id) sender;
- (IBAction) btnFullScreenExit:(id) sender;
- (IBAction) btnDone:(id) sender;

- (IBAction) btnCancelComment:(id) sender;

@end
