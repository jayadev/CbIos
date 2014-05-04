//
//  QSProductEditController.h
//  CubeSale
//
//  Created by Sushant Kumar on 1/15/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "AVFoundation/AVAudioRecorder.h"
#import "AVFoundation/AVAudioPlayer.h"
#import "CoreAudio/CoreAudioTypes.h"

#import "QSPostController.h"

@interface QSProductEditController : UIViewController<AVAudioPlayerDelegate, AVAudioRecorderDelegate, UITextFieldDelegate>

- (QSPostController *) getController;
- (void) setController:(QSPostController *)controller :(BOOL)editing;

@property (nonatomic, strong) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) IBOutlet UIButton *pauseButton;
@property (nonatomic, strong) IBOutlet UIButton *playButton;

@property (nonatomic, strong) IBOutlet UIButton *coffeeButton;
@property (nonatomic, strong) IBOutlet UIButton *lunchButton;
@property (nonatomic, strong) IBOutlet UIButton *freeButton;

@property (nonatomic, strong) IBOutlet UIImageView *productImage;
@property (nonatomic, strong) IBOutlet UITextField *priceText;
@property (nonatomic, strong) IBOutlet UITextField *descText;

- (IBAction) btnCancel:(id) sender;
- (IBAction) btnSubmit:(id) sender;
- (IBAction) btnEditImage:(id) sender;
- (IBAction) textFieldDoneEditing:(id) sender;

- (IBAction) btnRecordDesc:(id) sender;
- (IBAction) btnPlayDesc:(id) sender;
- (IBAction) btnPauseDesc:(id) sender;

- (IBAction) btnPayFree:(id) sender;
- (IBAction) btnPayLunch:(id) sender;
- (IBAction) btnPayCoffee:(id) sender;

- (void) clearPay;

@end
