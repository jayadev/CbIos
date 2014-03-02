//
//  iPhone OAuth Starter Kit
//
//  Supported providers: LinkedIn (OAuth 1.0a)
//
//  Lee Whitney
//  http://whitneyland.com
//
#import <Foundation/NSNotificationQueue.h>
#import "OAuthLoginView.h"

//
// OAuth steps for version 1.0a:
//
//  1. Request a "request token"
//  2. Show the user a browser with the LinkedIn login page
//  3. LinkedIn redirects the browser to our callback URL
//  4  Request an "access token"
//
@implementation OAuthLoginView

@synthesize requestToken, accessToken, profile, consumer;

//
// OAuth step 1a:
//
// The first step in the the OAuth process to make a request for a "request token".
// Yes it's confusing that the work request is mentioned twice like that, but it is whats happening.
//
- (void)requestTokenFromProvider
{
    OAMutableURLRequest *request = 
            [[OAMutableURLRequest alloc] initWithURL:requestTokenURL
                                             consumer:consumer
                                                token:nil   
                                             callback:linkedInCallbackURL
                                    signatureProvider:nil];

    [request setHTTPMethod:@"POST"];   
    //OARequestParameter * scopeParameter=[OARequestParameter requestParameter:@"scope" value:@"r_basicprofile r_fullprofile r_emailaddress r_contactinfo r_network r_contactinfo rw_nus"];
    OARequestParameter * scopeParameter=[OARequestParameter requestParameter:@"scope" value:@"r_fullprofile r_emailaddress r_network rw_nus"];
    [request setParameters:[NSArray arrayWithObject:scopeParameter]];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenResult:didFinish:)
                  didFailSelector:@selector(requestTokenResult:didFail:)];    
}

//
// OAuth step 1b:
//
// When this method is called it means we have successfully received a request token.
// We then show a webView that sends the user to the LinkedIn login page.
// The request token is added as a parameter to the url of the login page.
// LinkedIn reads the token on their end to know which app the user is granting access to.
//
- (void)requestTokenResult:(OAServiceTicket *)ticket didFinish:(NSData *)data 
{
    NSLog(@"%@", [ticket request].parameters);
    NSLog(@"%@", [ticket response]);
    NSLog(@"%@", [ticket body]);
    if (ticket.didSucceed == NO) 
        return;
        
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    self.requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
    
    [self allowUserToLogin];
}

- (void)requestTokenResult:(OAServiceTicket *)ticket didFail:(NSData *)error 
{
    NSLog(@"%@",[error description]);
}

//
// OAuth step 2:
//
// Show the user a browser displaying the LinkedIn login page.
// They type username/password and this is how they permit us to access their data
// We use a UIWebView for this.
//
// Sending the token information is required, but in this one case OAuth requires us
// to send URL query parameters instead of putting the token in the HTTP Authorization
// header as we do in all other cases.
//
- (void)allowUserToLogin
{
    NSString *userLoginURLWithToken = [NSString stringWithFormat:@"%@?oauth_token=%@&auth_token_secret=%@", 
        userLoginURLString, self.requestToken.key, self.requestToken.secret];
    
    userLoginURL = [NSURL URLWithString:userLoginURLWithToken];
    NSURLRequest *request = [NSMutableURLRequest requestWithURL: userLoginURL];
    [webView loadRequest:request];     
}


//
// OAuth step 3:
//
// This method is called when our webView browser loads a URL, this happens 3 times:
//
//      a) Our own [webView loadRequest] message sends the user to the LinkedIn login page.
//
//      b) The user types in their username/password and presses 'OK', this will submit
//         their credentials to LinkedIn
//
//      c) LinkedIn responds to the submit request by redirecting the browser to our callback URL
//         If the user approves they also add two parameters to the callback URL: oauth_token and oauth_verifier.
//         If the user does not allow access the parameter user_refused is returned.
//
//      Example URLs for these three load events:
//          a) https://www.linkedin.com/uas/oauth/authorize?oauth_token=<token value>
//
//          b) https://www.linkedin.com/uas/oauth/authorize/submit   OR
//             https://www.linkedin.com/uas/oauth/authenticate?oauth_token=<token value>&trk=uas-continue
//
//          c) hdlinked://linkedin/oauth?oauth_token=<token value>&oauth_verifier=63600     OR
//             hdlinked://linkedin/oauth?user_refused
//             
//
//  We only need to handle case (c) to extract the oauth_verifier value
//
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType 
{
	NSURL *url = request.URL;
	NSString *urlString = url.absoluteString;
    
    addressBar.text = urlString;
    [activityIndicator startAnimating];
    
    BOOL requestForCallbackURL = ([urlString rangeOfString:linkedInCallbackURL].location != NSNotFound);
    if ( requestForCallbackURL )
    {
        BOOL userAllowedAccess = ([urlString rangeOfString:@"user_refused"].location == NSNotFound);
        if ( userAllowedAccess )
        {            
            [self.requestToken setVerifierWithUrl:url];
            [self accessTokenFromProvider];
        }
        else
        {
            // User refused to allow our app access
            // Notify parent and close this view
            [[NSNotificationCenter defaultCenter] 
                    postNotificationName:@"loginViewDidFinish"        
                                  object:self 
                                userInfo:nil];

            //[self dismissModalViewControllerAnimated:YES];
        }
    }
    else
    {
        // Case (a) or (b), so ignore it
    }
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityIndicator stopAnimating];
}

//
// OAuth step 4:
//
- (void)accessTokenFromProvider
{ 
    OAMutableURLRequest *request = 
            [[OAMutableURLRequest alloc] initWithURL:accessTokenURL
                                             consumer:consumer
                                                token:self.requestToken   
                                             callback:nil
                                    signatureProvider:nil];
    
    [request setHTTPMethod:@"POST"];
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(accessTokenResult:didFinish:)
                  didFailSelector:@selector(accessTokenResult:didFail:)];    
}

- (void)accessTokenResult:(OAServiceTicket *)ticket didFinish:(NSData *)data 
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    BOOL problem = ([responseBody rangeOfString:@"oauth_problem"].location != NSNotFound);
    if ( problem )
    {
        NSLog(@"Request access token failed.");
        NSLog(@"%@",responseBody);
    }
    else
    {
        self.accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        [self testApiCall];
    }
}

- (void)testApiCall
{
    // NSURL *url = [NSURL URLWithString:@"https://api.linkedin.com/v1/people/~"];
    NSURL *url = [NSURL URLWithString:@"https://api.linkedin.com/v1/people/~:(id,email-address,first-name,last-name,formatted-name,picture-url,headline,location:(name,country),positions:(is-current,company:(name,id)),three-current-positions:(is-current,company:(name,id)))"];
    OAMutableURLRequest *request = 
            [[OAMutableURLRequest alloc] initWithURL:url
                                            consumer:consumer
                                               token:self.accessToken
                                            callback:nil
                                    signatureProvider:nil];
    
    [request setValue:@"json" forHTTPHeaderField:@"x-li-format"];

    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(testApiCallResult:didFinish:)
                  didFailSelector:@selector(testApiCallResult:didFail:)];    
}

- (void)testApiCallResult:(OAServiceTicket *)ticket didFinish:(NSData *)data 
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    self.profile = [responseBody objectFromJSONString];
    
    // Notify parent and close this view
    [[NSNotificationCenter defaultCenter] 
            postNotificationName:@"loginViewDidFinish"        
                          object:self
                        userInfo:self.profile];

    //[self dismissModalViewControllerAnimated:YES];
}

- (void)testApiCallResult:(OAServiceTicket *)ticket didFail:(NSData *)error 
{
    NSLog(@"%@",[error description]);
}

+ (NSString *) getApiKey
{
    // return @"1w21k3mjxchi";
    return @"mqjqg1ussz60";
}

+ (NSString *) getSecretKey
{
    // return @"ZK0Vmg4TjKgdyUAh";
    return @"zSuMH324tMoAuxj8";
}

+ (OAConsumer *) getConsumer
{
    return [[OAConsumer alloc] initWithKey:[OAuthLoginView getApiKey]
                                secret:[OAuthLoginView getSecretKey]
                                realm:@"http://api.linkedin.com/"];
}

//
//  This api consumer data could move to a provider object
//  to allow easy switching between LinkedIn, Twitter, etc.
//
- (void)initLinkedInApi
{
    apikey = [OAuthLoginView getApiKey];
    secretkey = [OAuthLoginView getSecretKey];   

    consumer = [[OAConsumer alloc] initWithKey:apikey
                                        secret:secretkey
                                         realm:@"http://api.linkedin.com/"];

    requestTokenURLString = @"https://api.linkedin.com/uas/oauth/requestToken";
    accessTokenURLString = @"https://api.linkedin.com/uas/oauth/accessToken";
    userLoginURLString = @"https://www.linkedin.com/uas/oauth/authorize";    
    linkedInCallbackURL = @"hdlinked://linkedin/oauth";
    
    requestTokenURL = [NSURL URLWithString:requestTokenURLString];
    accessTokenURL = [NSURL URLWithString:accessTokenURLString];
    userLoginURL = [NSURL URLWithString:userLoginURLString];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initLinkedInApi];
    [addressBar setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    }

- (void)viewDidAppear:(BOOL)animated
{
    //if ([apikey length] < 64 || [secretkey length] < 64)
    if ([apikey length] < 1 || [secretkey length] < 1)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"OAuth Starter Kit"
                          message: @"You must add your apikey and secretkey.  See the project file readme.txt"
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
        [alert show];
        
        // Notify parent and close this view
        [[NSNotificationCenter defaultCenter] 
         postNotificationName:@"loginViewDidFinish"        
         object:self
         userInfo:self.profile];
        
        //[self dismissModalViewControllerAnimated:YES];
    }

    [self requestTokenFromProvider];
}
    
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)btnCancel:(UIButton *)sender
{
    // Notify parent and close this view
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:@"loginViewDidFinish"        
     object:self
     userInfo:nil];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
