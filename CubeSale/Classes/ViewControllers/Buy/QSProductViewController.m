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


@interface QSProductViewController () <QSHttpClientDelegate, UIScrollViewDelegate>
{
    IBOutlet UITableView *commentTable;
}


@property(nonatomic,strong)NSMutableArray *comments;
@property(nonatomic,strong)NSDictionary *itemInfo;
@property(nonatomic,strong)QSHttpClient *httpClient;

@end

NSString *escapeString(NSString *str);

@implementation QSProductViewController

@synthesize itemInfo, comments;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withProductInfo:(NSDictionary*)item
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.itemInfo = item;
        [self fetchCommentsList];
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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

-(void)fetchCommentsList {

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

#pragma mark QHHttpClient Delegate -
- (void) connectionDidFinishWithData:(NSDictionary *)response withError:(NSError*)error {
    NSLog(@"RESPONSE:%@",response);

    if((response) && (!error)) {
        BOOL status = [[response objectForKey:@"status"] boolValue];
        if(status){
            [comments removeAllObjects];
            [comments addObjectsFromArray:[response objectForKey:@"response_data"]];
            [commentTable reloadData];
        }
    }
}



- (IBAction) btnFullScreen:(id) sender
{
    //cellFullImageView.image = cellProductImage.image;
//    cellFullView.zoomScale = 1.0;
//    cellFullView.alpha = 0.0;
//    cellFullView.hidden = NO;
//    cellFullExit.hidden = NO;
//    
//    [UIView beginAnimations:@"fade in" context:nil];
//    [UIView setAnimationDuration:0.5];
//    cellFullView.alpha = 1.0;
//    [UIView commitAnimations];
}

- (IBAction) btnFullScreenExit:(id) sender
{
//    cellFullExit.hidden = YES;
//    cellFullView.hidden = YES;
}


-(IBAction) btnDone:(id) sender
{
//    if(_httpComments) {
//        [_httpComments cancelRequest];
//        _httpComments = nil;
//    }
//    if(_httpNewComment) {
//        [_httpNewComment cancelRequest];
//        _httpNewComment = nil;
//    }

   // [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) btnCancelComment:(id) sender
{
    NSLog(@"Post cancelled");
    //[commentField resignFirstResponder];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Post comment: %@", textField.text);
    [textField resignFirstResponder];    
    
    if([textField.text isEqualToString:@""]) return YES;
    
    // create request
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];                                    
//    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
//    [request setHTTPShouldHandleCookies:NO];
//    [request setTimeoutInterval:30];
//    [request setHTTPMethod:@"POST"];
//    
//    NSString *userId = [QSLoginController getUserId];
//    NSString *sbody = [NSString stringWithFormat:
//                     @"user_id=%@&prod_id=%@&comment=%@", 
//                     escapeString(userId), escapeString(_pid),
//                     escapeString(textField.text)];
//    NSLog(@"comment body: %@", sbody);
//
//    NSData *body = [sbody dataUsingEncoding:NSUTF8StringEncoding];
//    [request setHTTPBody:body];
//    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
//    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    
//    NSString *apiBase = [QSUtil getApiBase];
//    NSString *url = [NSString stringWithFormat:@"%@/addComment", apiBase];
//    
//    _httpNewComment = [[QSHttpClient alloc] init];
//    _httpNewComment.disableUI = true;
//    [_httpNewComment submitRequest:request :url :self :self :@"" :@"add"];
//    
//    [commentActivity startAnimating]; 

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
	NSUInteger newLength = textField.text.length + string.length - range.length;
	return (newLength > 100) ? NO : YES;
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return comments.count;
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
    NSDictionary *comment = [comments objectAtIndex:row];

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

}


//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    return cellFullImageView;
//}

@end
