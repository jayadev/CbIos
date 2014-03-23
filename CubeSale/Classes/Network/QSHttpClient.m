//
//  QSHttpClient.m
//  CubeSale
//
//  Created by Sushant Kumar on 4/4/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "QSHttpClient.h"
#import "QSLoginController.h"
#import "QSApiConstants.h"
#import "QSUtil.h"
#import "QSUserSession.h"


@interface QSHttpClient ()

@property (nonatomic, weak) NSURLConnection *connection;
@property (nonatomic, weak) NSMutableData *responseData;

@end


@implementation QSHttpClient

- (id) init
{
    self = [super init];
    if(self) {

    }
    return self;
}
- (void) dealloc
{
    NSLog(@"dealloc: QSHttpClient");
}

#pragma mark Request Creation Methods -

-(NSURL*)getUrlForApiPath:(NSString*)apiRelativePath {
    if(!apiRelativePath)
        NSParameterAssert("Invalid api path");
    QSUserSession *userSession = [QSUtil getUsetSession];
    NSURL *baseUrl = [NSURL URLWithString:QS_API_BASEPATH];
    NSString *token = userSession.token;
    if(token) {
        NSRange range = [apiRelativePath rangeOfString:@"?"];
        if(NSNotFound == range.location) {
            apiRelativePath = [NSString stringWithFormat:@"%@?_token=%@", apiRelativePath,[QSUtil geteEscapeString:token]];
        } else {
            apiRelativePath = [NSString stringWithFormat:@"%@&_token=%@", apiRelativePath,[QSUtil geteEscapeString:token]];
        }
    } else {
        apiRelativePath = apiRelativePath;
    }
    NSURL *url = [[NSURL alloc] initWithString:apiRelativePath relativeToURL:baseUrl];
    return url;
}
-(NSMutableString*)getQueryParamString:(NSDictionary*)queryParamDict {
    if( (!queryParamDict) || (!queryParamDict.count) )
        NSParameterAssert("Invalid query param dict");
    
    NSMutableString *queryparams = [NSMutableString string];
    for (NSString* key in queryParamDict) {
        NSString *query =[NSString stringWithFormat:@"%@=%@",key,[queryParamDict objectForKey:key]];
        [queryparams appendString:query];
    }
    return queryparams;
}
-(NSData*)getPostBodyString:(NSDictionary*)postParamDict {
    if( (!postParamDict) || (!postParamDict.count) )
        NSParameterAssert("Invalid post param dict");
    NSError *postDataError = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postParamDict options:NSJSONWritingPrettyPrinted error:&postDataError];
    if(postDataError){
        assert("Invalid Post param dict");
    }
    return postData;
}
-(NSURLRequest*)createGetRequestWithUrl:(NSURL*)url queryParams:(NSString*)queryparams{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:url];
    return request;
}
-(NSURLRequest*)createPostRequestWithUrl:(NSURL*)url withPostData:(NSData*)postData{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //set post data
    [request setHTTPBody:postData];
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //set other post request params
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setURL:url];
    return request;
}
-(void)executeNetworkRequest:(NetworkRequestType)requesType WithRelativeUrl:(NSString*)relativeUrlPath
                  parameters:(NSDictionary*)paramsDict {
    NSURLRequest *request;
    if(requesType == RequestType_Get){
        request = [self createGetRequestWithUrl:[self getUrlForApiPath:relativeUrlPath]
                                    queryParams:[self getQueryParamString:paramsDict]];
    }
    else if(requesType == RequestType_Post) {
        request = [self createPostRequestWithUrl:[self getUrlForApiPath:relativeUrlPath]
                                    withPostData:[self getPostBodyString:paramsDict]];
    }
    
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
    [self.responseData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *jsonParseError = nil;
    id responseJson = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:&jsonParseError];
    //check for json parsing error
    if(jsonParseError){
        //call delegate with error object
        if(self.delegate){
            [self.delegate connectionDidFinishWithData:nil withError:jsonParseError];
        }
    }
    //check for response type : it should be of type dictionary
//    if([id class] ty]){
//        
//    }
    //call delegate with error=nil
    if(self.delegate){
        [self.delegate connectionDidFinishWithData:responseJson withError:nil];
    }
    
    
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.responseData = nil;
}

@end
