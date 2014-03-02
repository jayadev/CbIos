//
//  QSPostViewController.m
//  CubeSale
//
//  Created by Sushant Kumar on 1/15/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "SBJson.h"
#import "QSUtil.h"
#import "AudioToolBox/AudioServices.h"

#import "QSLoginController.h"
#import "QSPostViewController.h"
#import "QSProductViewController.h"
#import "QSShareViewController.h"

@interface QSPostViewController () <UIScrollViewDelegate>
{
}
@end

@implementation QSPostViewController
{
    UIDeviceOrientation _curOrientation;
    
    __unsafe_unretained QSPostController *_controller;
    
    BOOL _editing;
    BOOL _sharing;
    NSDictionary *_item;
    NSString *_audio;

    QSHttpClient *_http;
    NSMutableData *_postResponse;
    
    AVAudioRecorder *_recorder;
    NSString *_recordingPath;
    AVAudioPlayer *_player;
    
    NSTimer *_playTimer;
    NSTimer *_recordTimer;
    
    enum PriceType {
        FREE = 0,
        LUNCH = 1,
        COFFEE = 2,
        MONEY = 3
    } _priceType;
    
    bool _postIn;
    
    ACAccountStore *_accountStore;
    
    QSShareViewController *_share;
}

@synthesize recordButton;
@synthesize stopRecordButton;
@synthesize pauseButton;
@synthesize playButton;
@synthesize audioOverlayView;
@synthesize playProgress;
@synthesize recordProgress;

@synthesize cellFullView;
@synthesize cellFullImageView;
@synthesize cellFullExit;

@synthesize payByLabel;
@synthesize coffeeButton;
@synthesize lunchButton;
@synthesize freeButton;

@synthesize productImage;
@synthesize priceText;
@synthesize descText;

@synthesize linkedinButton;
@synthesize linkedinView;
@synthesize linkedinImage;

@synthesize soldImage;
@synthesize soldButton;

@synthesize deleteButton;

- (QSPostController *) getController
{
    return _controller;
}

- (void) setController:(QSPostController *)controller :(BOOL)editing :(NSDictionary *)item
{
    _controller = controller;
    _editing = editing;
    _item = item;
    NSObject *audioUrl = [item valueForKey:@"audio_url"];
    if(audioUrl && ([NSNull null] != audioUrl) && (((NSString *)audioUrl).length > 0)) {
        _audio = (NSString *)audioUrl;
    } else {
        _audio = @"";
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _sharing = false;

        // Custom initialization
        _curOrientation = UIDeviceOrientationUnknown;
        _recorder = NULL;
        _recordingPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/qs_tmp.caf"];
        _priceType = COFFEE;
        
        _playTimer = nil;
        _recordTimer = nil;
        
        _postIn = true;
        
        _accountStore = [[ACAccountStore alloc] init];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    [_controller onPostViewAppeared];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(!_editing && _sharing) {
        [_controller onPostSubmit];
    }
    
    _sharing = false;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    playProgress.hidden = YES;
    recordProgress.hidden = YES;
    
    cellFullView.contentSize = cellFullImageView.frame.size;
    
    descText.borderStyle = UITextBorderStyleRoundedRect;
    
    if(_editing) {
        recordButton.hidden = NO;
        stopRecordButton.hidden = YES;
        pauseButton.hidden = YES;
        if([_audio isEqualToString:@""]) {
            playButton.hidden = YES;
        } else {
            playButton.hidden = NO;
        }

        [QSUtil updateProductFullImageCell:_item :productImage];
        NSString *price = [_item valueForKey:@"price"];
        if([price isEqualToString:@"free"]) {
            [self btnPayFree:nil];
        }
        else if([price isEqualToString:@"coffee"]) {
            [self btnPayCoffee:nil];
        }
        else if([price isEqualToString:@"lunch"]) {
            [self btnPayLunch:nil];
        }
        else {
            _priceType = MONEY;
            priceText.text = price;
        }
        NSObject *desc = [_item valueForKey:@"description"];
        if(desc && ([NSNull null] != desc)) descText.text = (NSString *)desc;
        
        NSObject *sold = [_item valueForKey:@"posting_sold"];
        if(sold && ([NSNull null] != sold)) { 
            NSString *ssold = (NSString *)sold;
            int isold = [ssold intValue];
            if(1 == isold) {
                // soldImage.hidden = FALSE;
            } else {
                soldButton.hidden = FALSE;    
            }
        } else {
            soldButton.hidden = FALSE;
        }
        
        linkedinView.hidden = YES;
        _postIn = false;
    } else {
        recordButton.hidden = NO;
        stopRecordButton.hidden = YES;
        pauseButton.hidden = YES;
        playButton.hidden = YES; 
        
        deleteButton.hidden = YES;
        
        _priceType = COFFEE;
        [self btnPayCoffee:nil];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(cellFullView.hidden) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }

    cellFullExit.hidden = (interfaceOrientation != UIInterfaceOrientationPortrait);
    
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait) ||
    (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
    (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (IBAction) btnEditImage:(id)sender
{
    [_controller onPostEditImage:NO];
}

- (IBAction) btnCancel:(id) sender
{
    [_controller onPostCancel];    
}

- (IBAction) btnSubmit:(id) sender
{
    NSLog(@"Submitting post");
    
    int kMaxResolution = 640;
    int kMinResolution = 640;
    
    NSString *userId = [QSLoginController getUserId];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];                                    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *boundary = @"qsnewpost";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    NSString *price = priceText.text;
    if(_priceType == FREE) price = @"free";
    else if(_priceType == LUNCH) price = @"lunch";
    else if(_priceType == COFFEE) price = @"coffee";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
                            userId, @"user_id",
                            descText.text, @"posting_description",
                            price, @"posting_price", 
                            [NSString stringWithFormat:@"%d", kMaxResolution], @"posting_photo_size",
                            @"0", @"posting_status",
                            (_postIn ? @"1" : @"0"), @"consent_facebook",
                            nil];
    if(nil != _item) {
        [params setValue:[_item valueForKey:@"id"] forKey:@"prod_id"];
    }
    
    // add params (all params are strings)
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [self addMediaForPost:body :boundary :kMaxResolution :kMinResolution];
    
    // final boundary
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    NSString *apiBase = [QSUtil getApiBase];
    NSString *url = [NSString stringWithFormat:@"%@/postListing", apiBase];
    
    _http = [[QSHttpClient alloc] init];
    _http.disableUI = true;
    [_http submitRequest:request :url :self :self :@"" :(id)nil];
}

- (void) addMediaForPost:(NSMutableData *)body :(NSString *)boundary :(int)kMaxResolution :(int)kMinResolution
{
    // add image data
    // UIImage *scaledImage = [QSUtil scaleImage:productImage.image :kMaxResolution];
    // images should already by scaled
    NSData *imageData = UIImageJPEGRepresentation(productImage.image, 0.8);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", @"posting_image"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    UIImage *smallImage = productImage.image;
    if(kMaxResolution != kMinResolution) {
        smallImage = [QSUtil scaleImage:productImage.image :kMinResolution];
    }
    NSData *smallImageData = UIImageJPEGRepresentation(smallImage, 0.8);
    if (smallImageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image_small.jpg\"\r\n", @"posting_image_small"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:smallImageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add audio data
    if(_recorder) {
        NSFileManager *filemgr = [NSFileManager defaultManager];
        if ([filemgr fileExistsAtPath:_recordingPath]) {
            NSData *audioData = [filemgr contentsAtPath:_recordingPath];
            
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"audio.caf\"\r\n", @"posting_audio"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: audio/x-caf\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:audioData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            
        }
    }

}

- (IBAction) btnSold:(id) sender
{
    NSLog(@"Submitting sold");
        
    NSString *userId = [QSLoginController getUserId];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];                                    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *boundary = @"qsnewpost";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
                                   userId, @"user_id",
                                   @"1", @"posting_status",
                                   nil];
    [params setValue:[_item valueForKey:@"id"] forKey:@"prod_id"];
    
    // add params (all params are strings)
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    NSString *apiBase = [QSUtil getApiBase];
    NSString *url = [NSString stringWithFormat:@"%@/postListing", apiBase];
    
    _http = [[QSHttpClient alloc] init];
    _http.disableUI = true;
    [_http submitRequest:request :url :self :self :@"The posting is sold. Go to \"My Listings\" to view the updated status." :(id)nil];

}

- (IBAction) btnDelete:(id)sender
{
    NSLog(@"Submitting delete");
    
    NSString *userId = [QSLoginController getUserId];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];                                    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *boundary = @"qsnewpost";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
                                   userId, @"user_id",
                                   @"2", @"posting_status",
                                   nil];
    [params setValue:[_item valueForKey:@"id"] forKey:@"prod_id"];
    
    // add params (all params are strings)
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    NSString *apiBase = [QSUtil getApiBase];
    NSString *url = [NSString stringWithFormat:@"%@/postListing", apiBase];
    
    _http = [[QSHttpClient alloc] init];
    _http.disableUI = true;
    [_http submitRequest:request :url :self :self :@"Posting has been deleted." :(id)nil];
    
}

- (void) processResponse:(BOOL)success :(NSDictionary *)response :(id)userData
{
    _http = nil;

    if(_editing || !success) {
        [_controller onPostSubmit];
    } else {
        [_controller onPostSubmit];
        // [self btnShare:NULL];
    }
}

- (IBAction) btnRecordDesc:(id) sender
{
    stopRecordButton.hidden = NO;
    recordButton.hidden = YES;
    playButton.hidden = YES;

    audioOverlayView.hidden = NO;
    recordProgress.hidden = NO;
    recordProgress.progress = 0;
    
    if(NULL == _recorder)
    {
        NSLog(@"Recording path %@", _recordingPath);
        
        NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:16000.0], AVSampleRateKey,
                                  [NSNumber numberWithInt: kAudioFormatAppleIMA4], AVFormatIDKey,
                                  [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                  [NSNumber numberWithInt: AVAudioQualityMin], AVEncoderAudioQualityKey,
                                  nil];
        
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:_recordingPath] settings:settings error:NULL];
        
        _recorder.delegate = self;
    }
    
    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updateRecordProgress) userInfo:nil repeats:YES];

    [_recorder recordForDuration:45];   
    NSLog(@"Started recording");
}

- (IBAction) btnStopRecordDesc:(id) sender
{
    stopRecordButton.hidden = YES;
    recordButton.hidden = NO;
    playButton.hidden = NO;
    
    audioOverlayView.hidden = YES;
    recordProgress.hidden = YES;
    
    if(_recorder && _recorder.recording) {
        [_recorder stop];
    }
    
    if(_recordTimer) {
        [_recordTimer invalidate];
        _recordTimer = nil;
    }
}

- (IBAction) btnPlayDesc:(id) sender
{
    if(NULL == _recorder) {
        NSLog(@"Loading audio: %@", _audio);
        NSURL *audioUrl = [[NSURL alloc] initWithString:_audio];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:audioUrl
                                                      cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                  timeoutInterval:10.0];
        NSURLResponse *response = nil;
        NSData *audioData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];

        // NSData *audioData = [NSData dataWithContentsOfURL:audioUrl];
        if(nil == audioData) {
            [QSUtil showAlert:@"Failed to load audio data" :nil];            
        } else {
            NSError *error;
            _player = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
            if (nil == _player) {
                NSLog(@"Audio error: %@", error);
                [QSUtil showAlert:@"Failed to play audio" :nil];
            } else {
                _player.delegate = self;
            }   
        }
    } else {
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:_recordingPath] error:NULL];
        _player.delegate = self;        
    }
    
    if(_player) {
        pauseButton.hidden = NO;
        playButton.hidden = YES;
        recordButton.hidden = YES;

        audioOverlayView.hidden = NO;
        playProgress.hidden = NO;
        playProgress.progress = 0;

        UInt32 doChangeDefaultRoute = 1;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                                sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);

        _playTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updatePlayProgress) userInfo:nil repeats:YES];

        NSLog(@"Playing");
        _player.currentTime = 0;
        _player.volume = 1.0;
        [_player play];
    }    
}

- (IBAction) btnPauseDesc:(id) sender
{
    pauseButton.hidden = YES;
    playButton.hidden = NO;
    recordButton.hidden = NO;

    audioOverlayView.hidden = YES;
    playProgress.hidden = YES;
    
    if(_player && _player.playing) {
        [_player stop];
    }
    
    if(_playTimer) {
        [_playTimer invalidate];
        _playTimer = nil;
    }
}

- (void) updatePlayProgress
{
    playProgress.progress = (float)_player.currentTime / _player.duration;
}
- (void) updateRecordProgress
{
    recordProgress.progress = (float)_recorder.currentTime / 45;
}

- (IBAction) btnFullScreen:(id) sender
{
    cellFullImageView.image = productImage.image;
    cellFullView.zoomScale = 1.0;
    cellFullView.alpha = 0;
    cellFullView.hidden = NO;
    cellFullExit.hidden = NO;
    
    [UIView beginAnimations:@"fade in" context:nil];
    [UIView setAnimationDuration:0.5];
    cellFullView.alpha = 1.0;
    [UIView commitAnimations];
}

- (IBAction) btnFullScreenExit:(id) sender
{
    cellFullView.hidden = YES;
    cellFullExit.hidden = YES;
}

- (void) clearPay
{
    [coffeeButton setImage:[UIImage imageNamed:@"coffee1.png"] forState:UIControlStateNormal];
    [lunchButton setImage:[UIImage imageNamed:@"lunch1.png"] forState:UIControlStateNormal];
    [freeButton setImage:[UIImage imageNamed:@"free1.png"] forState:UIControlStateNormal];
    
    priceText.text = @"";
    payByLabel.text = @"";
}

- (IBAction) btnPayFree:(id) sender
{
    [self clearPay];
    _priceType = FREE;
    payByLabel.text = @"It's free";
    [freeButton setImage:[UIImage imageNamed:@"free2.png"] forState:UIControlStateNormal];
}
- (IBAction) btnPayLunch:(id) sender
{
    [self clearPay];
    _priceType = LUNCH;
    payByLabel.text = @"Buy me a lunch";
    [lunchButton setImage:[UIImage imageNamed:@"lunch2.png"] forState:UIControlStateNormal];
}
- (IBAction) btnPayCoffee:(id) sender
{
    [self clearPay];
    _priceType = COFFEE;
    payByLabel.text = @"Buy me a coffee";
    [coffeeButton setImage:[UIImage imageNamed:@"coffee2.png"] forState:UIControlStateNormal];
}

- (IBAction) btnLinkedin:(id) sender
{
    _postIn = !_postIn;
    [linkedinImage setImage:_postIn ? [UIImage imageNamed:@"fb_active.png"] : [UIImage imageNamed:@"fb_inactive.png"]];
    [linkedinButton setTitle:(_postIn ? @"       Share it on Facebook" : @"       Don't share it on Facebook") forState:UIControlStateNormal];
}

- (IBAction) btnShare:(id) sender
{
    _sharing = true;
    _share = [[QSShareViewController alloc] init];
    [_share setItem:_item];
    [self.navigationController pushViewController:_share animated:YES];
}

- (IBAction) btnShareTwitter:(id) sender
{
    ACAccountType *twitterType =
    [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    SLRequestHandler requestHandler =
    ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSString *errorMessage = NULL;
        if (responseData) {
            NSInteger statusCode = urlResponse.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
                NSDictionary *postResponseData =
                [NSJSONSerialization JSONObjectWithData:responseData
                                                options:NSJSONReadingMutableContainers
                                                  error:NULL];
                NSLog(@"[SUCCESS!] Created Tweet with ID: %@", postResponseData[@"id_str"]);
            }
            else {
                errorMessage = [NSString stringWithFormat:@"[ERROR] Server responded: status code %d %@", statusCode,
                      [NSHTTPURLResponse localizedStringForStatusCode:statusCode]];
            }
        }
        else {
            errorMessage = [NSString stringWithFormat:@"[ERROR] An error occurred while posting: %@", [error localizedDescription]];
        }
        
        if(errorMessage) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMessage
                                    message:nil
                                    delegate:nil
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil];
            [alert show];
        }
                            
    };
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreHandler =
    ^(BOOL granted, NSError *error) {
        if (!granted) {
            NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",
                  [error localizedDescription]);
            return;
        }
        
        NSArray *accounts = [_accountStore accountsWithAccountType:twitterType];
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                      @"/1.1/statuses/update_with_media.json"];
        NSString *postUrl = [NSString stringWithFormat:@"url/%@", @"id"];
        NSString *status = [NSString stringWithFormat:@"Checkout my listing on Cubesale: %@", postUrl];
        NSDictionary *params = @{@"status" : status};
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                            requestMethod:SLRequestMethodPOST
                            URL:url
                            parameters:params];

        UIImage *smallImage = [QSUtil scaleImage:productImage.image :250];
        NSData *smallImageData = UIImageJPEGRepresentation(smallImage, 0.8);
        [request addMultipartData:smallImageData
                             withName:@"media[]"
                                 type:@"image/jpeg"
                             filename:@"cubesale.jpg"];
        [request setAccount:[accounts lastObject]];
        [request performRequestWithHandler:requestHandler];
    };
    
    [_accountStore requestAccessToAccountsWithType:twitterType
                                               options:NULL
                                            completion:accountStoreHandler];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"Finished recording");
    
    [self btnPauseDesc:NULL];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"Finished playing");
    
    [self btnPauseDesc:NULL];    
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];    
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField 
{
    [QSUtil animateView:self.view :175 up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField 
{
    if(textField == priceText) {
        if([priceText.text isEqualToString:@""]) {
            if(_priceType == MONEY) {
                [self btnPayFree:nil];
            }
        } else {
            NSString *price = priceText.text;
            [self clearPay];
            _priceType = MONEY;
            priceText.text = price;
        }
    }
    
    [QSUtil animateView:self.view :175 up:NO];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = textField.text.length + string.length - range.length;
    
    if(textField == priceText) {
        return newLength > 8 ? NO : YES;
    }

    if(newLength > 100) {
        [QSUtil showAlert:@"Please restrict your post description to 100 characters" :nil];
        return NO;
    }
    
	return YES;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return cellFullImageView;
}

@end
