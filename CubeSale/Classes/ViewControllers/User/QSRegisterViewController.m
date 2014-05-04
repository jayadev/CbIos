//
//  QSRegisterViewController.m
//  CubeSale
//
//  Created by Sushant Kumar on 1/21/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "QSRegisterViewController.h"
#import "QSUtil.h"
#import "QSLocationViewController.h"
#import "QSApiConstants.h"
#import "QSRegistrationTableViewCell.h"
#import "QSUserSession.h"
#import "QSDataStore.h"
#import "QSUserSession.h"


#define REGISTRATION_TITLE_CELLINDEX            0
#define REGISTRATION_WORKEMAIL_CELLINDEX        1
#define REGISTRATION_HOBBIES_CELLINDEX          2
#define REGISTRATION_WORKLOCATION_CELLINDEX     3
#define REGISTRATION_PHONENUMBER_CELLINDEX      4
#define REGISTRATION_GETTINGSTARTED_CELLINDEX   5

@interface QSRegisterViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    BOOL isRequestInProgess;
}
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UIButton *submitButton;

@property (nonatomic,strong)UITableViewController *regViewController;
@property (nonatomic,strong)QSHttpClient *httpClient;
@property (nonatomic,strong)UITextField *tf;
@property (nonatomic,strong)UITextView *tv;
@end

@implementation QSRegisterViewController

@synthesize submitButton, headerView, regViewController;

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
- (void)dealloc
{
    NSLog(@"QSRegisterViewController dealloc");
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.headerView.backgroundColor = [UIColor colorWithRed:42.0f/255.0f green:87.0f/255.0f blue:128.0f/255.0f alpha:1];
    CGRect headerViewFrame = headerView.frame;
    CGFloat registrationViewYPos =  (headerViewFrame.origin.y+headerViewFrame.size.height);
    CGRect registrationViewFrame = CGRectMake(0,
                                              registrationViewYPos,
                                              headerViewFrame.size.width,
                                              self.view.frame.size.height - registrationViewYPos);
    self.regViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    regViewController.tableView.delegate = self;
    regViewController.tableView.dataSource = self;
    regViewController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    regViewController.view.frame = registrationViewFrame;
    regViewController.view.backgroundColor = [UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:241.0f/255.0f alpha:1];
    [self.view addSubview:regViewController.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITextViewDelegate -

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.tv = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    if ( [text isEqualToString:@"\n"] ) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark UITextFieldDelegate -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{    
	[textField resignFirstResponder];
    
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField 
{
    self.tf = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField 
{

}

#pragma mark Buttom Action Handler -

- (void)btnGettingStarted:(id)sender
{
    if(!isRequestInProgess){
        isRequestInProgess = TRUE;
        self.view.userInteractionEnabled = NO;
        [self.tv resignFirstResponder];
        [self.tf resignFirstResponder];
        [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(register1:) userInfo:nil repeats:NO];
    }
}
-(void)register1:(id)sender {
    //
    QSRegistrationWorkEmailCell *cell1 = (QSRegistrationWorkEmailCell*)[self.regViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:REGISTRATION_WORKEMAIL_CELLINDEX inSection:0]];
    NSString *workEmail = cell1.tfWorkEmail.text;
    if(![QSUtil isValidEmailId:workEmail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter your email id"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    QSRegistrationWorkLocationCell *cell2 = (QSRegistrationWorkLocationCell*)[self.regViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:REGISTRATION_WORKLOCATION_CELLINDEX inSection:0]];
    NSString *workLocation =  cell2.tfWorkLocation.text;
    if([QSUtil isEmptyString:workLocation]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter your work location"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }


    QSRegistrationPhoneNumberCell *cell3 = (QSRegistrationPhoneNumberCell*)[self.regViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:REGISTRATION_PHONENUMBER_CELLINDEX inSection:0]];
    NSString *phoneNumber = cell3.tfPhoneNUmber.text;
    if(![QSUtil isValidEmailId:phoneNumber]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter your Phone Number"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
    }


    QSRegistrationGettingStartedCell *cell4 = (QSRegistrationGettingStartedCell*)[self.regViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:REGISTRATION_GETTINGSTARTED_CELLINDEX inSection:0]];
    [cell4 showActivityView];


    NSString *consentStr = @"1";

    @try {//KUSER_EMAIL
        //create post request data dict
        QSUserSession *userSession = [[QSUserSession alloc] init];
        NSMutableDictionary *postDict = [NSMutableDictionary dictionary];
        [postDict setObject:[userSession getUserId] forKey:@"user_id"];
        [postDict setObject:[userSession getUserEmail] forKey:@"email"];
        [postDict setObject:[userSession getUserFirstName] forKey:@"firstname"];
        [postDict setObject:[userSession getUserLastName] forKey:@"lastname"];
        [postDict setObject:[userSession getUserImageUrl] forKey:@"img_url"];
        //[postDict setObject:[userSession getUserProfileUrl] forKey:@"profile_url"];
        //[postDict setObject:nil forKey:@"hobby"];
        [postDict setObject:workEmail forKey:@"company_email"];
        //[postDict setObject:nil forKey:@"company_zip"];
        [postDict setObject:workLocation forKey:@"company_city"];
        //[postDict setObject:nil forKey:@"company_ccode"];
        //[postDict setObject:nil forKey:@"update"];
        [postDict setObject:consentStr forKey:@"consent"];
        NSLog(@"Post Data:%@",postDict);
        if(!self.httpClient){
            self.httpClient = [[QSHttpClient alloc] init];
            self.httpClient.delegate = self;
        }

        [self.httpClient executeNetworkRequest:RequestType_Post WithRelativeUrl:QS_API_REGISTERUSER parameters:postDict];
    }
    @catch (NSException *exception) {
        isRequestInProgess = FALSE;
        self.view.userInteractionEnabled = YES;
        QSRegistrationGettingStartedCell *cell4 = (QSRegistrationGettingStartedCell*)[self.regViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:REGISTRATION_GETTINGSTARTED_CELLINDEX inSection:0]];
        [cell4 stopActivityView];
        NSLog(@"Exception While Reistering User:%@",exception);
    }

}

#pragma mark alertview delegate -
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    isRequestInProgess = FALSE;
    self.view.userInteractionEnabled = YES;

    QSRegistrationGettingStartedCell *cell4 = (QSRegistrationGettingStartedCell*)[self.regViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:REGISTRATION_GETTINGSTARTED_CELLINDEX inSection:0]];
    [cell4 stopActivityView];
}


#pragma mark uitableview datasource / delegate handler -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 0;
    
    if(indexPath.row == REGISTRATION_TITLE_CELLINDEX) {
        cellHeight = 105;
    }
    else if(indexPath.row == REGISTRATION_WORKEMAIL_CELLINDEX) {
        cellHeight = 55;
    }
    else if(indexPath.row == REGISTRATION_HOBBIES_CELLINDEX) {
        cellHeight = 125;
    }
    else if( (indexPath.row == REGISTRATION_WORKLOCATION_CELLINDEX) || (indexPath.row == REGISTRATION_PHONENUMBER_CELLINDEX) ) {
        cellHeight = 40;
    }
    else if(indexPath.row == REGISTRATION_GETTINGSTARTED_CELLINDEX) {
        cellHeight = 100;
    }
    return cellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reusableIdentifier1 = @"registration_title_cell";
    static NSString *reusableIdentifier2 = @"registration_workemail_cell";
    static NSString *reusableIdentifier3 = @"registration_hobbies_cell";
    static NSString *reusableIdentifier4 = @"registration_worklocation";
    static NSString *reusableIdentifier5 = @"registration_phonenumber_cell";
    static NSString *reusableIdentifier6 = @"registration_gettingstarted_cell";
    
    UITableViewCell *cell = NULL;
    if(indexPath.row == REGISTRATION_TITLE_CELLINDEX){
        cell = (QSRegistrationTitleCell*)[tableView dequeueReusableCellWithIdentifier:reusableIdentifier1];
        if(!cell) {
            cell = [[QSRegistrationTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableIdentifier1];
        }
        QSUserSession *userSession = [[QSUserSession alloc] init];
        QSRegistrationTitleCell *cell1 = (QSRegistrationTitleCell*)cell;
        cell1.ivProfileImage.image = [UIImage imageWithContentsOfFile:[userSession getUserProfileUrl]];
        cell1.lbTitle.text = [NSString stringWithFormat:@"Welcome %@ %@",[userSession getUserFirstName],[userSession getUserLastName]];
    }
    if(indexPath.row == REGISTRATION_WORKEMAIL_CELLINDEX){
        cell = (QSRegistrationWorkEmailCell*)[tableView dequeueReusableCellWithIdentifier:reusableIdentifier2];
        if(!cell) {
            cell = [[QSRegistrationWorkEmailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableIdentifier2 withTarget:self];
        }
    }
    if(indexPath.row == REGISTRATION_HOBBIES_CELLINDEX){
        cell = (QSRegistrationHobbiesCell*)[tableView dequeueReusableCellWithIdentifier:reusableIdentifier3];
        if(!cell) {
            cell = [[QSRegistrationHobbiesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableIdentifier3 withTarget:self];
        }
    }
    if(indexPath.row == REGISTRATION_WORKLOCATION_CELLINDEX){
        cell = (QSRegistrationWorkLocationCell*)[tableView dequeueReusableCellWithIdentifier:reusableIdentifier4];
        if(!cell) {
            cell = [[QSRegistrationWorkLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableIdentifier4 withTarget:self];
        }
    }
    if(indexPath.row == REGISTRATION_PHONENUMBER_CELLINDEX){
        cell = (QSRegistrationPhoneNumberCell*)[tableView dequeueReusableCellWithIdentifier:reusableIdentifier5];
        if(!cell) {
            cell = [[QSRegistrationPhoneNumberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableIdentifier5 withTarget:self];
        }
    }
    if(indexPath.row == REGISTRATION_GETTINGSTARTED_CELLINDEX){
        cell = (QSRegistrationGettingStartedCell*)[tableView dequeueReusableCellWithIdentifier:reusableIdentifier6];
        if(!cell) {
            cell = [[QSRegistrationGettingStartedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableIdentifier6 withButtonTarget:self];
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


#pragma mark QSHttpClient Delegate Handler -

- (void) connectionDidFinishWithData:(NSDictionary *)response withError:(NSError*)error {
    isRequestInProgess = FALSE;
    self.view.userInteractionEnabled = TRUE;
    if(!error) {
        BOOL status = [[response objectForKey:@"status"] boolValue];
        if(status) {
            [QSDataStore storeObject:[NSNumber numberWithBool:YES] forKey:KUSER_REGISTERED];
            [self.delegate registrationCompletedWithStatus:TRUE withError:nil];
        }
        else {
            
        }
    }
    else {
        
    }
}

@end
