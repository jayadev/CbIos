//
//  QSHttpClient.m
//  CubeSale
//
//  Created by Sushant Kumar on 4/4/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "SBJson.h"
#import "QSHttpClient.h"
#import "QSLoginController.h"
#import "QSBusyView.h"

NSString *escapeString(NSString *str);

@implementation QSHttpClient
{
    NSURLConnection *_connection;

    BOOL _result;
    NSMutableData *_postResponse;
    NSString *_successMessage;
    id _userData;
    
    __unsafe_unretained id <QSHttpClientDelegate> _delegate;
    NSDictionary *_response;
    
    QSBusyView *_busy;
}

@synthesize disableUI;

- (id) init
{
    self = [super init];
    if(self) {
        disableUI = false;
        _connection = nil;
    }
    return self;
}

- (void) dealloc
{
    NSLog(@"dealloc: QSHttpClient");
}

- (void) submitRequest:(NSMutableURLRequest *)request :(NSString *)url :(UIViewController *)parent :(id <QSHttpClientDelegate>) delegate :(NSString *)successMessage :(id)userData
{
    NSString *reqUrl = nil;

    NSString *token = [QSLoginController getToken];
    if(token) {
        NSRange range = [url rangeOfString:@"?"];
        if(NSNotFound == range.location) {
            reqUrl = [NSString stringWithFormat:@"%@?_token=%@", url, escapeString(token)];
        } else {
            reqUrl = [NSString stringWithFormat:@"%@&_token=%@", url, escapeString(token)];            
        }
    } else {
        reqUrl = url;
    }
    
    [request setURL:[NSURL URLWithString:reqUrl]];
    NSLog(@"http: %@", request.URL);

    _result = FALSE;
    _delegate = delegate;
    _successMessage = successMessage;
    _userData = userData;
    _response = nil;
    
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if(_connection) {
        _postResponse = [NSMutableData data];
    } else {
        disableUI = false;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection failed!"
														message:nil
													   delegate:self
                                              cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
        return;
    }
    
    if(disableUI) {
        _busy = [[QSBusyView alloc] initWithNibName:@"QSBusyView" bundle:nil];
        [parent presentModalViewController:_busy animated:FALSE];
    }
}

- (void)cancelRequest
{
    _delegate = nil;
    
    if(_connection) {
        [_connection cancel];
        _connection = nil;
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(disableUI) {
        [_busy dismissModalViewControllerAnimated:FALSE];
    }

    if(_delegate) {
        [_delegate processResponse:_result :_response :_userData];
        // _delegate = nil;
    }
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
    
    if(disableUI) {
        // inform the user
        NSString *errorMessage = [NSString stringWithFormat:@"Connection failed! Error - %@",
                                  [error localizedDescription]];
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorMessage
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
        [alert show];
    } else if(_delegate) {
        [_delegate processResponse:_result :_response :_userData];
        // _delegate = nil;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSString *response = [[NSString alloc] initWithData:_postResponse encoding:NSUTF8StringEncoding];
    //NSLog(@"response: %@", response);
    
    UIAlertView *alert = nil;
    NSDictionary *responseJson = [_postResponse JSONValue];
    int status = 0;
    NSString *errorMsg = nil;
    if(nil != responseJson) {
        status = [[responseJson valueForKey:@"status"] intValue];
        errorMsg = [responseJson valueForKey:@"error_desc"];
    }
    
    if((nil == responseJson) || (status != 1)) {
        NSString *response = [[NSString alloc] initWithData:_postResponse encoding:NSUTF8StringEncoding];
        NSLog(@"response: %@", response);
        
        alert = [[UIAlertView alloc] initWithTitle:@"Error processing request"
                                           message:errorMsg
                                          delegate:self
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];        
    } else {
        NSLog(@"%@", responseJson);
        
        _result = TRUE;
        _response = responseJson;

        if([_successMessage isEqualToString:@""]) {
            if(disableUI) {
                [_busy dismissModalViewControllerAnimated:FALSE];
            }
            
            if(_delegate) {
                [_delegate processResponse:_result :_response :_userData];
                // _delegate = nil;
            }
            return;
        } else {
            alert = [[UIAlertView alloc] initWithTitle:_successMessage
                                           message:nil
                                          delegate:self
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        }
    }
    
    [alert show];    
}

@end
