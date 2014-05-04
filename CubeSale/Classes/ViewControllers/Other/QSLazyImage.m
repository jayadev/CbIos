//
//  QSLazyImage.m
//  CubeSale
//
//  Created by Sushant Kumar on 4/4/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "QSLazyImage.h"

static int s_lazyImageCount = 0;

@implementation QSLazyImage
{
    NSURL *_url;
        
    NSURLConnection *_connection;
    NSMutableData *_receivedData;
}

#pragma mark Properties

- (void)dealloc
{
	self.image = nil;
	[_connection cancel];
    
    NSLog(@"dealloc: QSLazyImage %d", --s_lazyImageCount);
}

- (void) willMoveToSuperview:(UIView *)newSuperview
{
    if(nil != newSuperview) {
        NSLog(@"alloc: QSLazyImage %d", ++s_lazyImageCount);
    }

    [super willMoveToSuperview:newSuperview];
}

- (void)setFadeIn
{
    self.alpha = 0.0;
}

- (void)loadFromUrl:(NSURL *)url
{
    _url = url;

    NSLog(@"image loading: %@", _url);
	if (_url)
	{
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:_url
                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                timeoutInterval:10.0];
        
        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self 
                                              startImmediately:NO];
        [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] 
                               forMode:NSRunLoopCommonModes];
        [_connection start];
	}	    
}

- (void)cancelLoading
{
	[_connection cancel];
    _connection = nil;
	_receivedData = nil;
}

#pragma mark NSURL Loading

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// every time we get an response it might be a forward, so we discard what data we have
	_receivedData = nil;
    
	// does not fire for local file URLs
	if ([response isKindOfClass:[NSHTTPURLResponse class]])
	{
		NSHTTPURLResponse *httpResponse = (id)response;
        
		if (![[httpResponse MIMEType] hasPrefix:@"image"])
		{
			[self cancelLoading];
		}
	}
    
	_receivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (_receivedData)
	{
		UIImage *image = [[UIImage alloc] initWithData:_receivedData];
        self.image = image;
        
        if(self.alpha < 1.0) {
            [UIView beginAnimations:@"fade in" context:nil];
            [UIView setAnimationDuration:0.5];
            self.alpha = 1.0;
            [UIView commitAnimations];
        }
		
		_receivedData = nil;
	}
    
    _connection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Failed to load image at %@, %@", _url, [error localizedDescription]);
    
    // TODO: set default image
    
	_connection = nil;
	_receivedData = nil;
}

@end
