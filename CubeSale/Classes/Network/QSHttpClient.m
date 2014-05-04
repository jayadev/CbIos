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
@property (nonatomic, strong) NSMutableData *responseData;

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

-(NSString*)getCompleteApiPathForRelativePath:(NSString*)apiRelativePath withQueryParams:(NSString*)queryParams {
    if(!apiRelativePath)
        NSParameterAssert("Invalid api path");
    QSUserSession *userSession = [[QSUserSession alloc] init];
        //NSURL *baseUrl = [NSURL URLWithString:QS_API_BASEPATH];
    NSString *token = [userSession getUserToken];
    if(token) {
        NSRange range = [apiRelativePath rangeOfString:@"?"];
        if(NSNotFound == range.location) {
            apiRelativePath = [NSString stringWithFormat:@"%@?_token=%@", apiRelativePath,[QSUtil getEscapeString:token]];
        } else {
            apiRelativePath = [NSString stringWithFormat:@"%@&_token=%@", apiRelativePath,[QSUtil getEscapeString:token]];
        }
    } else {
        apiRelativePath = apiRelativePath;
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",QS_API_BASEPATH,apiRelativePath];
    if(queryParams) {
        urlStr = [NSString stringWithFormat:@"%@&%@",urlStr,queryParams];
    }
    return urlStr;
}
-(NSMutableString*)getQueryParamString:(NSDictionary*)queryParamDict {
    if( (!queryParamDict) || (!queryParamDict.count) )
        NSParameterAssert("Invalid query param dict");
    
    NSMutableString *queryparams = [NSMutableString string];
    BOOL isEmpty = TRUE;
    for (NSString* key in queryParamDict) {
        NSString *query;
        if(isEmpty) {
            query =[NSString stringWithFormat:@"%@=%@",key,[queryParamDict objectForKey:key]];
            isEmpty = FALSE;
        }
        else {
            query =[NSString stringWithFormat:@"&%@=%@",key,[queryParamDict objectForKey:key]];
        }
        
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
-(NSMutableURLRequest*)createMultipartFormDataPostRequest:(NSString*)apiPath withParams:(NSDictionary*)params {
    NSURL *url = [NSURL URLWithString:apiPath];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setURL:url];

    // set Content-Type in HTTP header
    NSString *boundary = @"qsnewpost";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];

    NSMutableData *body = [NSMutableData data];

    for (NSString *param in params) {
        if(![param isEqualToString:KAPI_POSTITEM_IMAGE]) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }

    UIImage *productImage = [params objectForKey:KAPI_POSTITEM_IMAGE];
    NSData *imageData = UIImageJPEGRepresentation(productImage, 0.8);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", @"posting_image"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    UIImage *smallImage = [QSUtil scaleImage:productImage :250];

    NSData *smallImageData = UIImageJPEGRepresentation(smallImage, 0.8);
    if (smallImageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image_small.jpg\"\r\n", @"posting_image_small"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:smallImageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    // final boundary
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];

    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];

    return  request;
}

-(NSURLRequest*)createGetRequestWithUrl:(NSString*)urlString {
    NSLog(@"GET REQ URL:%@",urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:url];
    return request;
}
-(NSURLRequest*)createPostRequestWithUrl:(NSString*)apiPath withPostData:(NSData*)postData{
    NSURL *url = [NSURL URLWithString:apiPath];
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
-(void)executeNetworkRequest:(NetworkRequestType)requestType WithRelativeUrl:(NSString*)relativeUrlPath
                  parameters:(NSDictionary*)paramsDict {
    NSURLRequest *request;
    if(requestType == RequestType_Get){
        NSString *queryParams = [self getQueryParamString:paramsDict];
        NSString *urlString = [self getCompleteApiPathForRelativePath:relativeUrlPath withQueryParams:queryParams];
        NSLog(@"Get Url:%@",urlString);
        request = [self createGetRequestWithUrl:urlString];
    }
    else if(requestType == RequestType_Post) {
        NSString *postDataStr = [self getQueryParamString:paramsDict];
        NSLog(@"Post Str:%@",postDataStr);
        NSString *urlString = [self getCompleteApiPathForRelativePath:relativeUrlPath withQueryParams:nil];
        request = [self createPostRequestWithUrl:urlString
                                    withPostData:[postDataStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else if(requestType == RequestType_Post_Multipart) {
        NSString *urlString = [self getCompleteApiPathForRelativePath:relativeUrlPath withQueryParams:nil];
        request = [self createMultipartFormDataPostRequest:urlString withParams:paramsDict];
    }

    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if(self.connection) {
        self.responseData = [NSMutableData data];
    }
    else {
        assert("network connection object creation failed");
    }
}
-(void)executeNetworkRequestWithUrl:(NSString*)urlString {
    NSURLRequest *request = [self createGetRequestWithUrl:urlString];

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
        //[self.responseData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    @try {
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
    @catch (NSException *exception) {
        NSLog(@"Connection Exception:%@",exception);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.responseData = nil;
}

@end
