//
//  QSProductViewController.m
//  CubeSale
//
//  Created by Sushant Kumar on 1/11/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "Foundation/NSDateFormatter.h"
#import "AudioToolBox/AudioServices.h"

#import "QSUtil.h"
#import "QSHttpClient.h"
#import "QSProductViewController.h"
#import "QSInMailViewController.h"
#import "QSLoginController.h"
#import "QSPostController.h"
//#import "OAuthLoginView.h"

@interface QSProductViewController () <QSHttpClientDelegate, UIScrollViewDelegate>
{    
}
    
@end


@implementation QSProductViewController
{
    UIDeviceOrientation _curOrientation;

    NSDictionary *_item;
    BOOL _myItem;
    NSString *_pid;
    NSString *_audio;
 
    AVAudioPlayer *_player;
    NSTimer *_playTimer;
 
    QSHttpClient *_httpComments;
    QSHttpClient *_httpNewComment;
    
    NSMutableArray *_comments;
    
    BOOL _watch;
    
    QSPostController *_postController;    
    QSInMailViewController *_inmail;
}

@synthesize reloadGrid;
@synthesize refetchGrid;

@synthesize headerView;

@synthesize editButton;

@synthesize cellProductImage;
@synthesize cellProfileImage;
@synthesize cellPrice;
@synthesize cellPriceImage;
@synthesize cellTime;
@synthesize cellName;
@synthesize cellLocation;
@synthesize cellWatch;
@synthesize cellFullView;
@synthesize cellFullImageView;
@synthesize cellDescription;
@synthesize cellBubble;
@synthesize cellFullExit;

@synthesize commentTable;
@synthesize commentCell;

@synthesize playButton;
@synthesize pauseButton;
@synthesize playProgress;

@synthesize commentProfileImage;
@synthesize commentField;
@synthesize commentCancelButton;
@synthesize commentActivity;

@synthesize descView;
@synthesize profileView;

- (void) setItem:(NSDictionary *)item
{
    _item = item;
    _pid = [item valueForKey:@"id"];
    NSString *userId = NULL;//[QSLoginController getUserId];
    NSString *iuserId = [_item valueForKey:@"user_id"];
    if([userId isEqualToString:iuserId]) {
        _myItem = YES;
    }
    
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
        // Custom initialization
        self.reloadGrid = false;
        self.refetchGrid = false;

        _curOrientation =  UIDeviceOrientationUnknown;
        _myItem = NO;
        _player = nil;
        _playTimer = nil;
        _comments = [[NSMutableArray alloc] init];
        _watch = true;
        _postController = nil;
    }
    return self;
}

- (void) dealloc
{
    NSLog(@"dealloc: QSProductViewController");
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
    
    if(_postController) {
        self.refetchGrid = (POSTED == _postController.postStatus);
        _postController = nil;

        if(self.refetchGrid) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }

    editButton.hidden = !_myItem;
    cellWatch.hidden = _myItem;

    if(_audio.length > 0) {
        playButton.hidden = NO;
        pauseButton.hidden = YES;
    } else {
        playButton.hidden = YES;
        pauseButton.hidden = YES;        
    }
    
    playProgress.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if(_playTimer) {
        [_playTimer invalidate];
        _playTimer = nil;
    }
    if(_player && _player.isPlaying) {
        [_player stop];
    };
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    cellFullView.contentSize = cellFullImageView.frame.size;
    
    [QSUtil updateItemCell:_item :cellProductImage :cellProfileImage :cellName :cellPrice :cellPriceImage :cellLocation :nil :cellTime :nil :nil :nil];
    [QSUtil updateProductFullImageCell:_item :cellFullImageView];
    NSObject *desc = [_item valueForKey:@"description"];
    if(desc && ([NSNull null] != desc) && !([(NSString *)desc isEqualToString:@""])) {
        cellDescription.text = (NSString *)desc;
    } else {
        descView.hidden = YES;
        /*profileView.frame = CGRectOffset(profileView.frame, 0, -73);
        CGRect frame = headerView.frame;
        frame.size.height -= 73;
        headerView.frame = frame;*/
    }

    // commentTable.tableHeaderView = headerView;

    NSString *commentProfileUrl = NULL;//[QSLoginController getUserProfilerImage];
    if(![commentProfileUrl isEqualToString:@""]) {
        [commentProfileImage loadFromUrl:[NSURL URLWithString:commentProfileUrl]];
    }
//    if([QSLoginController isInUserWatch:_pid]) {
//        [self btnWatch:cellWatch];
//    }
    
    NSString *apiBase = NULL;//[QSUtil getApiBase];
    NSString *url = NULL;//[NSString stringWithFormat:@"%@/getComments?user_id=%@&prod_id=%@", apiBase, [QSLoginController getUserId], _pid];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    _httpComments = [[QSHttpClient alloc] init];
        // [_httpComments submitRequest:request :url :self :self :@"" :@"get"];
}

- (void) processResponse:(BOOL)success :(NSDictionary *)response :(id)userData
{
    _httpComments = nil;
    _httpNewComment = nil;

    [commentActivity stopAnimating]; 
    if(!success) return;
    
    if([(NSString *)userData isEqualToString:@"add"]) {
//        NSDictionary *newItem = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                 @"", @"mtime", 
//                                 [QSLoginController getUserId], @"user_id", 
//                                 [QSLoginController getUserName], @"username", 
//                                 [QSLoginController getUserProfilerImage], @"img_url", 
//                                 commentField.text, @"comment", 
//                                 nil];
//        [_comments insertObject:newItem atIndex:0];
        commentField.text = @"";
    } else {
        NSArray *comments = (NSArray *)[response valueForKey:@"response_data"];
    
        /*NSObject *desc = [_item valueForKey:@"description"];
        if(desc && ([NSNull null] != desc) && !([(NSString *)desc isEqualToString:@""])) {
            NSString *userId = [QSLoginController getUserId];
            NSString *iuserId = [_item valueForKey:@"user_id"];
        
            NSDictionary *descItem = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      [_item valueForKey:@"mtime"], @"mtime", 
                                      [_item valueForKey:@"username"], @"username", 
                                      [_item valueForKey:@"img_url"], @"img_url", 
                                      desc, @"comment", 
                                      nil];
        
            if([userId isEqualToString:iuserId]) {
                [_comments addObjectsFromArray:comments];
                [_comments addObject:descItem];
            } else {
                [_comments addObject:descItem];
                [_comments addObjectsFromArray:comments];
            }
        } else {
            [_comments addObjectsFromArray:comments];
        }*/
        [_comments addObjectsFromArray:comments];
    }
    
    [commentTable reloadData];
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
    //    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    
    //cellFullExit.hidden = (interfaceOrientation != UIInterfaceOrientationPortrait);

    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait) ||
    (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
    (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (IBAction) btnPosterProfile:(id) sender
{
    NSString *userId = [_item valueForKey:@"user_id"];
    /*NSString *profileUrl = [NSString stringWithFormat:@"http://www.linkedin.com/x/profile/%@/%@", [OAuthLoginView getApiKey], userId];
    NSLog(@"Loading profile: %@", profileUrl);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:profileUrl]];*/
}

- (IBAction) btnWatch:(id) sender
{
    self.reloadGrid = true;

//    if(_watch) {
//        [cellWatch setImage:[UIImage imageNamed:@"starorange.png"] forState:UIControlStateNormal];
//        [QSLoginController addUserWatch:_item];
//    } else {
//        [cellWatch setImage:[UIImage imageNamed:@"stargray.png"] forState:UIControlStateNormal];
//        [QSLoginController removeUserWatch:_pid];
//    }
    _watch = !_watch;
}

- (IBAction) btnFullScreen:(id) sender
{
    //cellFullImageView.image = cellProductImage.image;
    cellFullView.zoomScale = 1.0;
    cellFullView.alpha = 0.0;
    cellFullView.hidden = NO;
    cellFullExit.hidden = NO;
    
    [UIView beginAnimations:@"fade in" context:nil];
    [UIView setAnimationDuration:0.5];
    cellFullView.alpha = 1.0;
    [UIView commitAnimations];
}

- (IBAction) btnFullScreenExit:(id) sender
{
    cellFullExit.hidden = YES;
    cellFullView.hidden = YES;
}

- (IBAction) btnPlay:(id) sender
{
    if(nil == _player) {
        NSLog(@"Loading audio: %@", _audio);
        NSURL *audioUrl = [[NSURL alloc] initWithString:_audio];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:audioUrl
                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                timeoutInterval:10.0];
        NSURLResponse *response = nil;
        NSData *audioData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
        
        //NSData *audioData = [NSData dataWithContentsOfURL:audioUrl];
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
    }
 
    if(nil != _player) {
        UInt32 doChangeDefaultRoute = 1;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                                sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);

        playButton.hidden = YES;
        pauseButton.hidden = NO;
        playProgress.hidden = NO;
        playProgress.progress = 0.0;
        
        _playTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updatePlayProgress) userInfo:nil repeats:YES];
        
        _player.volume = 1.0;
        _player.currentTime = 0;
        [_player play];
    }
}

- (IBAction) btnPause:(id) sender
{
    playButton.hidden = NO;
    pauseButton.hidden = YES;
    playProgress.hidden = YES;

    [_playTimer invalidate];
    _playTimer = nil;
    [_player stop];
}

- (void) updatePlayProgress
{
    playProgress.progress = (float)_player.currentTime / _player.duration;
}

- (IBAction) btnEdit:(id) sender
{
    _postController = [[QSPostController alloc] init];
    [_postController start:self.navigationController :YES :_item];
}

-(IBAction) btnDone:(id) sender
{
    if(_httpComments) {
        [_httpComments cancelRequest];
        _httpComments = nil;
    }
    if(_httpNewComment) {
        [_httpNewComment cancelRequest];
        _httpNewComment = nil;
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) btnCancelComment:(id) sender
{
    NSLog(@"Post cancelled");
    [commentField resignFirstResponder];    
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Post comment: %@", textField.text);
    [textField resignFirstResponder];    
    
    if([textField.text isEqualToString:@""]) return YES;
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];                                    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    
    NSString *userId = NULL;//[QSLoginController getUserId];
    NSString *sbody;
//    NSString *sbody = [NSString stringWithFormat:
//                     @"user_id=%@&prod_id=%@&comment=%@", 
//                     escapeString(userId), escapeString(_pid),
//                     escapeString(textField.text)];
    NSLog(@"comment body: %@", sbody);

    NSData *body = [sbody dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    NSString *apiBase = NULL;//[QSUtil getApiBase];
    NSString *url = [NSString stringWithFormat:@"%@/addComment", apiBase];
    
    _httpNewComment = [[QSHttpClient alloc] init];
//    _httpNewComment.disableUI = true;
//    [_httpNewComment submitRequest:request :url :self :self :@"" :@"add"];
    
    [commentActivity startAnimating]; 
    
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField 
{
    [QSUtil animateView:self.view :225 up:YES];
    commentCancelButton.hidden = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField 
{
    [QSUtil animateView:self.view :225 up:NO];
    commentCancelButton.hidden = YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSUInteger newLength = textField.text.length + string.length - range.length;
	return (newLength > 100) ? NO : YES;
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"CommentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"QSProductCommentCell" owner:self options:nil];        
        cell = self.commentCell;
    }
    
    self.commentCell = nil;
    
    NSUInteger row = [indexPath row];
    NSDictionary *comment = [_comments objectAtIndex:row];

    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    nameLabel.text = [comment valueForKey:@"username"];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:2];
    [QSUtil updateProductTimeCell:comment :timeLabel];
    QSLazyImage *cImage = (QSLazyImage *)[cell viewWithTag:3];
    cImage.image = [UIImage imageNamed:@"photo.png"];
    [QSUtil updateProfileImageCell:comment :cImage];
    UILabel *commentLabel = (UILabel *)[cell viewWithTag:4];
    NSObject *commentString = [comment valueForKey:@"comment"];
    if(commentString && ([NSNull null] != commentString)) {
        commentLabel.text = (NSString *)commentString;
    } else {
        commentLabel.text = @"";    
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:FALSE];
    
    NSUInteger row = [indexPath row];
    NSDictionary *comment = [_comments objectAtIndex:row];
    
    /*NSString *userId = (NSString *)[comment valueForKey:@"user_id"];
    NSString *profileUrl = [NSString stringWithFormat:@"http://www.linkedin.com/x/profile/%@/%@", [OAuthLoginView getApiKey], userId];
    NSLog(@"Loading profile: %@", profileUrl);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:profileUrl]];*/

    /*NSString *userId = [QSLoginController getUserId];
    if(!iuserid || ([userId isEqualToString:iuserid])) {
        return;
    }

    _inmail = [[QSInMailViewController alloc] init];
    [_inmail setItem:comment];
    [self.navigationController pushViewController:_inmail animated:YES];*/
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"Finished playing");
    
    [self btnPause:NULL];    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return cellFullImageView;
}

@end
