//
//  QSImageDownloader.m
//  CubeSale
//
//  Copyright (c) 2014 None. All rights reserved.
//

#import "QSImageDownloader.h"
#import "QSHttpClient.h"

@interface QSImageDownloader ()

@property (nonatomic, weak) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *responseData;

@end


@implementation QSImageDownloader

-(id)init {
    self = [super init];
    if(self) {

    }
    return self;
}

- (void)startDownload {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.imageDownloadUrl]];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if(self.connection) {
        self.responseData = [NSMutableData data];
    }
    else {
        assert("network connection object creation failed");
    }
}

- (void)cancelRequest
{
    self.delegate = nil;
    if(self.responseData){
        self.responseData = nil;
    }
    if(self.connection) {
        [self.connection cancel];
        self.connection = nil;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{

}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    @try {
        UIImage *image = [UIImage imageWithData:self.responseData];
        self.responseData = nil;
        if(self.delegate) {
            [self.delegate imageDownload:self finishImageLoading:image];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Connection Exception:%@",exception);
        self.responseData = nil;
        if(self.delegate) {
            [self.delegate imageDownload:self failWithError:nil];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.responseData = nil;
    if(self.delegate) {
        [self.delegate imageDownload:self failWithError:error];
    }
}



@end
