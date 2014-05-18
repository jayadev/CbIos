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


@interface QSProductViewController () <QSHttpClientDelegate, UIScrollViewDelegate>
{
    IBOutlet UITableView *commentTable;
    IBOutlet UIActivityIndicatorView *commentActivity;
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
        self.comments = [NSMutableArray array];
        self.itemInfo = item;
        [self fetchCommentsList];
            //mtime
            //username
            //city
            //img_url
            //price
            //title
            //photo_url_small
            //photo_url
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
    [commentTable registerNib:[UINib nibWithNibName:@"QSProductCommentCell" bundle:nil] forCellReuseIdentifier:@"CommentCell"];
    _cellProductImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[itemInfo objectForKey:@"photo_url_small"]]]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        //commentTable.backgroundColor = [UIColor redColor];
    
        //commentTable.frame = CGRectMake(0,200,320,293);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    [commentActivity stopAnimating];
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
    return 60;
//	NSUInteger newLength = textField.text.length + string.length - range.length;
//	return (newLength > 100) ? NO : YES;
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
        
    }
        //cell.textLabel.text = @"421342121122e1";
    NSDictionary *commentdict = [comments objectAtIndex:indexPath.row];
    [cell setCommentsFromDictionary:commentdict];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}


//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    return cellFullImageView;
//}

@end
