//
//  QSPostViewController.h
//  CubeSale
//
//  Created by Sushant Kumar on 1/15/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "AVFoundation/AVAudioRecorder.h"
#import "AVFoundation/AVAudioPlayer.h"
#import "CoreAudio/CoreAudioTypes.h"

#import "QSPostController.h"
#import "QSHttpClient.h"
#import "QSLazyImage.h"

@interface QSPostViewController : UIViewController<AVAudioPlayerDelegate, AVAudioRecorderDelegate, UITextFieldDelegate, QSHttpClientDelegate>

- (QSPostController *) getController;
- (void) setController:(QSPostController *)controller :(BOOL)editing :(NSDictionary *)item;

@property (nonatomic, strong) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) IBOutlet UIButton *stopRecordButton;
@property (nonatomic, strong) IBOutlet UIButton *pauseButton;
@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIView *audioOverlayView;
@property (nonatomic, strong) IBOutlet UIProgressView *playProgress;
@property (nonatomic, strong) IBOutlet UIProgressView *recordProgress;

@property (nonatomic, strong) IBOutlet UIScrollView *cellFullView;
@property (nonatomic, strong) IBOutlet UIImageView *cellFullImageView;
@property (nonatomic, strong) IBOutlet UIButton *cellFullExit;

@property (nonatomic, strong) IBOutlet UILabel *payByLabel;
@property (nonatomic, strong) IBOutlet UIButton *coffeeButton;
@property (nonatomic, strong) IBOutlet UIButton *lunchButton;
@property (nonatomic, strong) IBOutlet UIButton *freeButton;

@property (nonatomic, strong) IBOutlet QSLazyImage *productImage;
@property (nonatomic, strong) IBOutlet UITextField *priceText;
@property (nonatomic, strong) IBOutlet UITextField *descText;

@property (nonatomic, strong) IBOutlet UIView *linkedinView;
@property (nonatomic, strong) IBOutlet UIButton *linkedinButton;
@property (nonatomic, strong) IBOutlet UIImageView *linkedinImage;

@property (nonatomic, strong) IBOutlet UIImageView *soldImage;
@property (nonatomic, strong) IBOutlet UIButton *soldButton;

@property (nonatomic, strong) IBOutlet UIButton *deleteButton;

- (IBAction) btnCancel:(id) sender;
- (IBAction) btnSubmit:(id) sender;
- (IBAction) btnSold:(id) sender;
- (IBAction) btnDelete:(id) sender;
- (IBAction) btnEditImage:(id) sender;

- (IBAction) btnRecordDesc:(id) sender;
- (IBAction) btnStopRecordDesc:(id) sender;
- (IBAction) btnPlayDesc:(id) sender;
- (IBAction) btnPauseDesc:(id) sender;
- (IBAction) btnFullScreen:(id) sender;
- (IBAction) btnFullScreenExit:(id) sender;

- (IBAction) btnPayFree:(id) sender;
- (IBAction) btnPayLunch:(id) sender;
- (IBAction) btnPayCoffee:(id) sender;

- (IBAction) btnShare:(id) sender;

- (IBAction) btnLinkedin:(id) sender;
- (IBAction) btnShareTwitter:(id) sender;

- (void) clearPay;

@end
