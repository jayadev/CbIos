//
//  QSProductEditController.m
//  CubeSale
//
//  Created by Sushant Kumar on 1/15/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "QSProductEditController.h"

UIImage *scaleImage(UIImage *image);

@implementation QSProductEditController
{
    QSPostController *_controller;
    BOOL _editing;
    
    AVAudioRecorder *_recorder;
    NSString *_recordingPath;
    AVAudioPlayer *_player;
    
    NSMutableData *_postResponse;

    enum PriceType {
        FREE = 0,
        LUNCH = 1,
        COFFEE = 2,
        MONEY = 3
    } _priceType;
}

@synthesize recordButton;
@synthesize pauseButton;
@synthesize playButton;

@synthesize coffeeButton;
@synthesize lunchButton;
@synthesize freeButton;

@synthesize productImage;
@synthesize priceText;
@synthesize descText;

- (QSPostController *) getController
{
    return _controller;
}

- (void) setController:(QSPostController *)controller :(BOOL)editing
{
    _controller = controller;
    _editing = editing;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _recorder = NULL;
        _recordingPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/qs_tmp.caf"];
        _priceType = MONEY;
    }
    return self;
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

    recordButton.hidden = NO;
    pauseButton.hidden = YES;
    playButton.hidden = YES; 
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_controller onPostViewAppeared];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) btnEditImage:(id)sender
{
    [_controller onPostEditImage];
}

- (IBAction) btnCancel:(id) sender
{
    [_controller onPostCancel];
}

- (IBAction) btnSubmit:(id) sender
{
    NSLog(@"Submitting post");

    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];                                    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *boundary = @"cubesalepost";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    NSString *price = priceText.text;
    if(_priceType == FREE) price = @"FREE";
    else if(_priceType == LUNCH) price = @"LUNCH";
    else if(_priceType == COFFEE) price = @"COFFEE";

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: 
                            descText.text, @"posting_description",
                            price, @"posting_price", nil];
    
    // add params (all params are strings)
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    UIImage *scaledImage = scaleImage(productImage.image);
    NSData *imageData = UIImageJPEGRepresentation(scaledImage, 0.6);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", @"posting_image"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    // add audio data
    if(_recorder) {
        NSFileManager *filemgr = [NSFileManager defaultManager];
        if ([filemgr fileExistsAtPath:_recordingPath]) {
            NSData *audioData = [filemgr contentsAtPath:_recordingPath];            
            
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"audio.caf\"\r\n", @"posting_audio"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:audioData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];

        }
    }

    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set URL
    //NSURL *requestURL = [NSURL URLWithString:@"http://localhost:8080/api/v1/postListingLog"];
    NSURL *requestURL = [NSURL URLWithString:@"http://50.19.98.62/api/v1/postListingLog"];
    [request setURL:requestURL];

    NSLog(@"Posting %@", body);
    NSURLConnection *theConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    if(theConnection) {
        _postResponse = [NSMutableData data];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to upload the post"
														message:nil
													   delegate:nil
                                              cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
    }
}

- (IBAction) btnRecordDesc:(id) sender
{
    pauseButton.hidden = NO;
    recordButton.hidden = YES;
    playButton.hidden = YES;
    
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
    
    [_recorder recordForDuration:60];   
    NSLog(@"Started recording");
}

- (IBAction) btnPlayDesc:(id) sender
{
    pauseButton.hidden = NO;
    recordButton.hidden = YES;
    playButton.hidden = YES;
    
    if(NULL == _player)
    {
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:_recordingPath] error:NULL];
        _player.delegate = self;
    }
    
    NSLog(@"Playing");
    [_player play];
}

- (IBAction) btnPauseDesc:(id) sender
{
    pauseButton.hidden = YES;
    recordButton.hidden = NO;
    playButton.hidden = NO;

    
    if(_recorder && _recorder.recording)
    {
        [_recorder stop];
    }
    
    if(_player && _player.playing)
    {
        [_player stop];
    }
}

- (void) clearPay
{
    [coffeeButton setImage:[UIImage imageNamed:@"coffee1.png"] forState:UIControlStateNormal];
    [lunchButton setImage:[UIImage imageNamed:@"lunch1.png"] forState:UIControlStateNormal];
    [freeButton setImage:[UIImage imageNamed:@"free1.png"] forState:UIControlStateNormal];
}

- (IBAction) btnPayFree:(id) sender
{
    _priceType = FREE;
    [self clearPay];
    [freeButton setImage:[UIImage imageNamed:@"free2.png"] forState:UIControlStateNormal];
}
- (IBAction) btnPayLunch:(id) sender
{
    _priceType = LUNCH;
    [self clearPay];
    [lunchButton setImage:[UIImage imageNamed:@"lunch2.png"] forState:UIControlStateNormal];
}
- (IBAction) btnPayCoffee:(id) sender
{
    _priceType = COFFEE;
    [self clearPay];
    [coffeeButton setImage:[UIImage imageNamed:@"coffee2.png"] forState:UIControlStateNormal];
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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_postResponse setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_postResponse appendData:data];    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _postResponse = NULL;
    
    // inform the user
    NSString *errorMessage = [NSString stringWithFormat:@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMessage
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"response: %@", _postResponse);

    NSString *successMessage = [NSString stringWithFormat:@"Post is live!"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:successMessage
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];    
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];    
	return YES;
}

- (IBAction) textFieldDoneEditing:(id) sender {
    [sender resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [_controller onPostSubmit];    
}

UIImage *scaleImage(UIImage *image) {
    int kMaxResolution = 480;
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    NSLog(@"image: %d %d or %d %d", (int)width, (int)height, (int)image.size.width, (int)image.size.height);
    //if(image.size.width < image.size.height)
    //      kMaxResolution = 640; // 940;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    CGFloat scaleRatio = bounds.size.width / width;
    //CGFloat scaleRatio = 1.0;
    
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

@end
