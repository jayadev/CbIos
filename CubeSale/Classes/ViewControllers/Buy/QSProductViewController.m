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
#import "QSApiConstants.h"
#import "QSUserSession.h"
#import "QSProductCommentCell.h"
#import "QSImageDownloader.h"

@interface QSProductViewController () <QSHttpClientDelegate, UIScrollViewDelegate, QSImageDownloaderDelegate>
{
    IBOutlet UITableView *commentTable;
    IBOutlet UIActivityIndicatorView *commentActivity;
    IBOutlet UIImageView *cellProductImage;
    IBOutlet UIImageView *cellProfileImage;
    IBOutlet UILabel *cellPrice;
    IBOutlet UIImageView *cellPriceImage;
    IBOutlet UILabel *cellTime;
    IBOutlet UILabel *cellName;
    IBOutlet UILabel *cellLocation;
    
    IBOutlet UITextField *commentField;
    
    IBOutlet UIButton *exitFullScreenBtn;
    UIScrollView *cellFullView;
    UIImageView *cellFullImageView;
    
    BOOL isCommentFetchRequest;
}

@property(nonatomic,strong) NSMutableDictionary *imageDownloadsInProgress;
@property(nonatomic,strong) NSMutableDictionary *downloadImages;
@property(nonatomic,strong)NSMutableArray *comments;
@property(nonatomic,strong)NSDictionary *itemInfo;
@property(nonatomic,strong)QSHttpClient *httpClient;

@end

NSString *escapeString(NSString *str);

@implementation QSProductViewController

@synthesize itemInfo, comments, downloadImages, imageDownloadsInProgress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withProductInfo:(NSDictionary*)item
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.comments = [NSMutableArray array];
        self.itemInfo = item;
        self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
        self.downloadImages = [NSMutableDictionary dictionary];
        [self fetchCommentsList];
        
        cellFullView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        cellFullView.delegate = self;
        cellFullImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        cellFullImageView.backgroundColor = [UIColor darkGrayColor];
        [self performSelectorInBackground:@selector(loadFullScrennProductImage) withObject:nil];
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
- (void)viewDidLoad
{
    [super viewDidLoad];
        // Do any additional setup after loading the view from its nib.
    self.title = @"Ask to Buy";
    exitFullScreenBtn.hidden = YES;
    
    [self updateUIFromItemDictionary];
    
    [self performSelectorInBackground:@selector(loadProductImage) withObject:nil];
    [self performSelectorInBackground:@selector(loadProfileImage) withObject:nil];
    
    
    [commentTable registerNib:[UINib nibWithNibName:@"QSProductCommentCell" bundle:nil] forCellReuseIdentifier:@"CommentCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(self.httpClient){
        [self.httpClient cancelRequest];
        self.httpClient.delegate = self;
        self.httpClient = nil;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)updateUIFromItemDictionary {
    cellName.text = [self getValidItemValue:[self.itemInfo objectForKey:@"username"]];
    cellPrice.text = [self getValidItemValue:[self.itemInfo objectForKey:@"price"]];
    cellTime.text = [QSUtil fuzzyTime:[self.itemInfo objectForKey:@"mtime"]];
    cellLocation.text = [self getValidItemValue:[self.itemInfo objectForKey:@"city"]];
}

-(NSString*)getValidItemValue:(NSString*)info {
    if(![QSUtil isEmptyString:info]) {
        return info;
    } else {
        return @"";
    }
}
-(void)loadFullScrennProductImage {
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[itemInfo objectForKey:@"photo_url"]]]];
    [self performSelectorOnMainThread:@selector(setFullScreenProductImage:) withObject:image waitUntilDone:NO];
}
-(void)setFullScreenProductImage:(UIImage*)image {
    cellFullImageView.image = image;
}
-(void)loadProductImage {
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[itemInfo objectForKey:@"photo_url_small"]]]];
    [self performSelectorOnMainThread:@selector(setProductImage:) withObject:image waitUntilDone:NO];
}
-(void)setProductImage:(UIImage*)image {
    cellProductImage.image = image;
}

-(void)loadProfileImage {
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[itemInfo objectForKey:@"img_url"]]]];
    
    [self performSelectorOnMainThread:@selector(setProfileImage:) withObject:image waitUntilDone:NO];
}
-(void)setProfileImage:(UIImage*)image {
    cellProfileImage.image = image;
}

-(void)fetchCommentsList {
    isCommentFetchRequest = TRUE;
    
    if(!self.httpClient){
        self.httpClient = [[QSHttpClient alloc] init];
        self.httpClient.delegate = self;
    }

    QSUserSession *session = [[QSUserSession alloc] init];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[session getUserId] forKey:KAPI_USERID];
    NSString *productId = [itemInfo objectForKey:KAPI_POSTITEM_ID];
    [dict setObject:productId forKey:KAPI_POSTITEM_PRODUCTID];
    [self.httpClient executeNetworkRequest:RequestType_Get WithRelativeUrl:QS_API_BUY parameters:dict];
}
-(void)addComment:(NSString*)commentStr {
    isCommentFetchRequest = FALSE;
    
    if(!self.httpClient){
        self.httpClient = [[QSHttpClient alloc] init];
        self.httpClient.delegate = self;
    }
    
    QSUserSession *session = [[QSUserSession alloc] init];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[session getUserId] forKey:KAPI_USERID];
    
    NSString *productId = [itemInfo objectForKey:KAPI_POSTITEM_ID];
    [dict setObject:productId forKey:KAPI_POSTITEM_PRODUCTID];
    
    [dict setObject:commentStr forKey:KAPI_ITEM_ADDCOMMENT];
    
    [self.httpClient executeNetworkRequest:RequestType_Post WithRelativeUrl:QS_API_ADDCOMMENT parameters:dict];
    
    [commentActivity startAnimating];
}

#pragma mark QHHttpClient Delegate -
- (void) connectionDidFinishWithData:(NSDictionary *)response withError:(NSError*)error {
    NSLog(@"RESPONSE:%@",response);
    [commentActivity stopAnimating];
    
    if((response) && (!error)) {
        BOOL status = [[response objectForKey:@"status"] boolValue];
        if(isCommentFetchRequest) {
            if(status){
                [comments removeAllObjects];
                [comments addObjectsFromArray:[response objectForKey:@"response_data"]];
                [commentTable reloadData];
            }
        }
        else {
            if(status){
                [self fetchCommentsList];
            }
        }
        
        
    }
}



- (IBAction) btnFullScreen:(id) sender
{
    [self.view addSubview:cellFullView];
    [cellFullView addSubview:cellFullImageView];
    
    [self.view bringSubviewToFront:exitFullScreenBtn];
    exitFullScreenBtn.hidden = NO;
    
    cellFullView.zoomScale = 1.0;
    cellFullView.alpha = 0.0;
    [UIView setAnimationDuration:0.5];
    
    [UIView beginAnimations:@"fade in" context:nil];

    cellFullView.alpha = 1.0;
    [UIView commitAnimations];
}

- (IBAction) btnFullScreenExit:(id) sender
{
    [cellFullView removeFromSuperview];
    [cellFullImageView removeFromSuperview];
    
    exitFullScreenBtn.hidden = YES;
}


- (IBAction) btnCancelComment:(id) sender
{
    NSLog(@"Post cancelled");
    commentField.text = @"";
    [commentField resignFirstResponder];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Post comment: %@", textField.text);
    [textField resignFirstResponder];    
    
    if([textField.text isEqualToString:@""]) return YES;
    
    [self addComment:textField.text];
    commentField.text = @"";
    // create request

	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField 
{
    [QSUtil animateView:self.view :225 up:YES];
    _commentCancelButton.hidden = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField 
{
    [QSUtil animateView:self.view :225 up:NO];
    //commentCancelButton.hidden = YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return 60;
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"CommentCell";
    QSProductCommentCell *cell = (QSProductCommentCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        
        cell = [[QSProductCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }
    NSDictionary *commentdict = [comments objectAtIndex:indexPath.row];
    [cell setCommentsFromDictionary:commentdict];
        //NSLog(@"tableView cellForRowAtIndexPath");
    NSString *imageUrl = [commentdict objectForKey:KAPI_USER_IMAGE_URL];
    UIImage *itemImage = [downloadImages objectForKey:imageUrl];
    if(itemImage){
        [cell setItemImage:itemImage];
    }
    else {
        [cell setItemImage:nil];
        
        [self startIconDownloadWithUrl:imageUrl];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return cellFullImageView;
}

- (void)startIconDownloadWithUrl:(NSString*)imageDownloadUrl
{
    NSLog(@"startIconDownloadWithUrl:%@",imageDownloadUrl);
    if(![QSUtil isEmptyString:imageDownloadUrl]) {
        QSImageDownloader *imageDownloader = [self.imageDownloadsInProgress objectForKey:imageDownloadUrl];
        if (imageDownloader == nil)
        {
            imageDownloader = [[QSImageDownloader alloc] init];
            imageDownloader.imageDownloadUrl = imageDownloadUrl;
            imageDownloader.delegate = self;
            [self.imageDownloadsInProgress setObject:imageDownloader forKey:imageDownloadUrl];
            [imageDownloader startDownload];
        }
    }
}


#pragma mark - Table view delegate
-(void)imageDownload:(QSImageDownloader*)imageDownloader finishImageLoading:(UIImage *)image {
    NSLog(@"imageDownload---finishImageLoading");
    NSString *key = imageDownloader.imageDownloadUrl;
    [downloadImages setObject:image forKey:key];
    imageDownloader.delegate = nil;
    [self.imageDownloadsInProgress removeObjectForKey:key];
    [commentTable reloadData];
}

-(void)imageDownload:(QSImageDownloader*)imageDownloader failWithError:(NSError *)error {
    NSString *key = imageDownloader.imageDownloadUrl;
    imageDownloader.delegate = nil;
    [self.imageDownloadsInProgress removeObjectForKey:key];
}


@end
