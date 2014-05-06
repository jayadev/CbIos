//
//  QSListingsViewController.m
//  CubeSale
//
//  Created by Sushant Kumar on 2/1/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "QSListingsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "QSPostController.h"
#import "QSProductViewController.h"
#import "QSProfileViewController.h"
#import "QSUtil.h"
#import "QSApiConstants.h"
#import "QSListingTableViewCell.h"
#import "QSProgressView.h"
#import "SWRevealViewController.h"
#import "QSUserSession.h"
#import "QSImageDownloader.h"
#import <MFMailComposeViewController.h>
#import "QSPostViewController.h"
#import "QSProductViewController.h"
#import <FacebookSDK/FacebookSDK.h>


//http://cubesales.com/api/v2/getUserListings?user_id=608151843&filter_type=mycmpl&_token=CAAHmj2KnaRsBAFwEjtPFfh9XXtsaq7w6QVkLx4Fe0nkFdZCUGZANUFTC9n85tltyZAZAO7aix5Skqhx6Fs5uNfSYgXrAZBrTuLEk72qHJxpzNbgMMvCldV0gfzFhVze3sH6BuNdLZBoWMM58cAZA8bnCGLZBmUihwfq0CQRsAjkZAP6ZAtoza7ZA3Q9qN05ZCInx0mXkUFtzjzbbUT4WZBaWgygQa


@interface QSListingsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate,
                                        QSHttpClientDelegate, QSImageDownloaderDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate, QSPostViewControllerDelegate>
{
    UICollectionView *listingCollectionView;
    QSProgressView *progressView;
    NSInteger btnActionIndex;

    BOOL isRequestInProgress;
    BOOL loadListing;
}

@property (nonatomic,strong)QSHttpClient *httpClient;
@property (nonatomic,strong)NSMutableArray *listings;
@property(nonatomic,strong) NSMutableDictionary *imageDownloadsInProgress;
@property(nonatomic,strong) NSMutableDictionary *downloadImages;

@end

@implementation QSListingsViewController

@synthesize listings,downloadImages;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.listings = [NSMutableArray array];
        self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
        self.downloadImages = [NSMutableDictionary dictionary];

        //add collection view
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        //[flowLayout setItemSize:CGSizeMake(150, 100)];
        [flowLayout setMinimumInteritemSpacing:10];
        [flowLayout setMinimumLineSpacing:10];
        [flowLayout setSectionInset:UIEdgeInsetsMake(10,10,10,10)];

        listingCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                 collectionViewLayout:flowLayout];
        [listingCollectionView setBackgroundColor:[UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1]];
        [listingCollectionView registerNib:[UINib nibWithNibName:@"View" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"Type1Cell"];
        listingCollectionView.showsVerticalScrollIndicator = YES;
        listingCollectionView.dataSource=self;
        listingCollectionView.delegate=self;
        [self.view addSubview:listingCollectionView];

        [self fetchListingWithProgressView:YES];
    }
    return self;
}

- (void) dealloc
{
    NSLog(@"dealloc: QSListingsViewController");
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
    NSLog(@"viewDidLoad: QSListingsViewController");

    //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    SWRevealViewController *revealController = [self revealViewController];


    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];

    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon"]
                                                                         style:UIBarButtonItemStyleDone target:revealController action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;

    UIBarButtonItem *rightRevealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus"]
                                                                             style:UIBarButtonItemStyleBordered target:self action:@selector(postItem:)];

    self.navigationItem.rightBarButtonItem = rightRevealButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    NSLog(@"viewDidUnload: QSListingsViewController");

}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    if(loadListing){
        [self fetchListingWithProgressView:NO];
    }
}

-(void)postItem:(id)sender {
    QSPostViewController *postViewCon = [[QSPostViewController alloc] initWithNibName:@"QSPostViewController" bundle:nil];
    postViewCon.delegate = self;
    [self.navigationController pushViewController:postViewCon animated:YES];
}

- (void)loadImagesForOnscreenRows
{
    if ([listings count] > 0)
    {
//        NSArray *visiblePaths = [listingTableView indexPathsForVisibleRows];
//        for (NSIndexPath *indexPath in visiblePaths)
//        {
//            NSMutableDictionary *dict = [self.listings objectAtIndex:indexPath.row];
//
//            if( dict && ([dict isKindOfClass:[NSMutableDictionary class]]) )
//            {
//                NSString *itemImageUrl = [dict objectForKey:KAPI_ITEM_IMAGE_URL];
//                if ( (![QSUtil isEmptyString:itemImageUrl]) && (![downloadImages objectForKey:KDOWNLOADED_ITEM_IMAGE]) ) {
//                    [self startIconDownloadWithUrl:itemImageUrl];
//                }
//                NSString *userImageUrl = [dict objectForKey:KAPI_USER_IMAGE_URL];
//                if((![QSUtil isEmptyString:userImageUrl]) && (![downloadImages objectForKey:KDOWNLOADED_USER_IMAGE]) ) {
//                    [self startIconDownloadWithUrl:userImageUrl];
//                }
//            }
//
//        }
    }
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

#pragma mark - data fetching methods / qshttp client delegate
#pragma mark -
-(void)fetchListingWithProgressView:(BOOL)progressViewStatus {
    if(!isRequestInProgress){
        isRequestInProgress = TRUE;
        if(progressViewStatus) {
            if(!progressView){
                progressView = [[QSProgressView alloc] initWithFrame:self.view.bounds];
            }
            [self.view addSubview:progressView];
            [progressView start];
        }

        if(!self.httpClient) {
            self.httpClient = [[QSHttpClient alloc] init];
            self.httpClient.delegate = self;
        }

        QSUserSession *userSession = [[QSUserSession alloc] init];
        NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
        [queryDict setObject:[userSession getUserId] forKey:KAPI_USERID];
        [queryDict setObject:@"mycmp" forKey:KAPI_FILTERTYPE];
        [self.httpClient executeNetworkRequest:RequestType_Get WithRelativeUrl:QS_API_LISTINGS parameters:queryDict];
    }

}
- (void) connectionDidFinishWithData:(NSDictionary *)response withError:(NSError*)error {
    isRequestInProgress = FALSE;
    loadListing = FALSE;
    [progressView stop];
    [progressView removeFromSuperview];

    NSLog(@"RESPONSE:%@ Error:%@",response,error);
    if((response) && (!error)) {

        [listings removeAllObjects];
        NSArray *listingData = [response objectForKey:KAPI_RESPONSEDATA];
        [listings addObjectsFromArray:listingData];
        [listingCollectionView reloadData];

        if(self.listings){
            NSDictionary *item = [self.listings objectAtIndex:0];
            self.title = [item objectForKey:@"company"];
        }

    }
    else {
        //error handling
    }
}

#pragma mark - QSPostViewControllerDelegate
-(void)itemPostedSuccessfully {
    loadListing = TRUE;
}

#pragma mark - collectionview datasource / delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return  [self.listings count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width-20, 368);
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reusableIdentifier1 = @"Type1Cell";
    QSListingTableViewCell *myCell = [collectionView
                                         dequeueReusableCellWithReuseIdentifier:reusableIdentifier1
                                         forIndexPath:indexPath];
    [myCell setBtnTarget:self withSel:@selector(btnAction:) withTagIndex:indexPath.row];
    myCell.layer.borderWidth = 0.5f;
    myCell.layer.borderColor = [UIColor lightGrayColor].CGColor;

    //set values
    NSDictionary *itemDict = [self.listings objectAtIndex:indexPath.row];
    [myCell setValuesFromDictionary:itemDict];

    //download images
    UIImage *itemImage = [downloadImages objectForKey:[itemDict objectForKey:KAPI_ITEM_IMAGE_URL]];
    if(itemImage){
        [myCell setItemImage:itemImage];
    }
    else {
        [myCell setItemImage:nil];
        //if (collectionView.dragging == NO && collectionView.decelerating == NO)
        {
            [self startIconDownloadWithUrl:[itemDict objectForKey:KAPI_ITEM_IMAGE_URL]];
        }
    }

    UIImage *userImage = [downloadImages objectForKey:[itemDict objectForKey:KAPI_USER_IMAGE_URL]];
    if(userImage){
        [myCell setUserImage:userImage];
    }
    else{
        [myCell setUserImage:nil];
        //if (collectionView.dragging == NO && collectionView.decelerating == NO)
        {
            [self startIconDownloadWithUrl:[itemDict objectForKey:KAPI_USER_IMAGE_URL]];
        }
    }

    return  myCell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Scroll view delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

#pragma mark - Table view delegate
-(void)imageDownload:(QSImageDownloader*)imageDownloader finishImageLoading:(UIImage *)image {
    NSString *key = imageDownloader.imageDownloadUrl;
    [downloadImages setObject:image forKey:key];
    imageDownloader.delegate = nil;
    [self.imageDownloadsInProgress removeObjectForKey:key];
    [listingCollectionView reloadData];
}

-(void)imageDownload:(QSImageDownloader*)imageDownloader failWithError:(NSError *)error {
    NSString *key = imageDownloader.imageDownloadUrl;
    imageDownloader.delegate = nil;
    [self.imageDownloadsInProgress removeObjectForKey:key];
}

#pragma mark - Btn action Methods
-(void)btnAction:(UIButton*)sender {

    btnActionIndex = sender.tag;
    NSString *btnTitle = sender.titleLabel.text;
    if([btnTitle isEqualToString:@"Share"]) {

        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share it on Facebook",@"Mail the Posting", nil];
        [sheet showInView:self.view];
    }
    else { //ask

        QSProductViewController *productVC = [[QSProductViewController alloc] initWithNibName:@"QSProductViewController" bundle:nil withProductInfo:[listings objectAtIndex:btnActionIndex]];
        [self.navigationController pushViewController:productVC animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if(buttonIndex == 0) {//Facebook
                          //NSURL* url = [NSURL URLWithString:@"https://developers.facebook.com/"];
        BOOL session = [FBSession activeSession];
        [FBDialogs presentOSIntegratedShareDialogModallyFrom:self
                                                 initialText:@"Test"
                                                       image:nil
                                                         url:nil
                                                     handler:^(FBOSIntegratedShareDialogResult result, NSError *error) {
                                                         
                                                         NSLog(@"error:%@",error);
                                      }];
    }
    else if(buttonIndex == 1) {
        NSDictionary *dict = [listings objectAtIndex:btnActionIndex];
        NSString *text = @"Checkout this item on CubeOut!";
        NSString *linkStr = [NSString stringWithFormat:@"%@\n%@?pid=%@",text, [QSUtil getFEProductLanding],[dict valueForKey:@"id"]];
        UIImage *image = [downloadImages objectForKey:[dict objectForKey:KAPI_ITEM_IMAGE_URL]];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.8);

        /////
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setMessageBody:linkStr isHTML:NO];

        // Determine the MIME type
        NSString *mimeType = @"image/jpeg";
        // Add attachment
        [mc addAttachmentData:imageData mimeType:mimeType fileName:@"product image"];

        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }

    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end


