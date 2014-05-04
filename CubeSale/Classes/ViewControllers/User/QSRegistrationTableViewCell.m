//
//  QSRegistrationTableViewCell.m
//  CubeSale
//
//  Created by Ankit Jain on 05/04/14.
//  Copyright (c) 2014 None. All rights reserved.
//

#import "QSRegistrationTableViewCell.h"

@implementation QSRegistrationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end


@implementation QSRegistrationTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.contentView.frame.size.width, 85)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bgView];
        self.ivProfileImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 60, 60)] ;
        self.ivProfileImage.backgroundColor = [UIColor darkGrayColor];
        [bgView addSubview:self.ivProfileImage];
        
        self.lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(80, 25, 200, 30)];
        self.lbTitle.backgroundColor = [UIColor clearColor];
        [bgView addSubview:self.lbTitle];
    }
    return self;
}


@end

@implementation QSRegistrationWorkEmailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTarget:(id)target
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 45)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bgView];
        
        self.lbWorkEmail = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 90, 30)];
        self.lbWorkEmail.backgroundColor = [UIColor clearColor];
        self.lbWorkEmail.text = @"Work Email";
        [bgView addSubview:self.lbWorkEmail];
        
        self.tfWorkEmail = [[UITextField alloc] initWithFrame:CGRectMake(110, 0, 180, 44)];
        self.tfWorkEmail.placeholder = @"pinky promise we don't spam";
        self.tfWorkEmail.delegate = target;
        [bgView addSubview:self.tfWorkEmail];
    }
    return self;
}

@end


@implementation QSRegistrationHobbiesCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTarget:(id)target
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 115)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bgView];
        
        self.lbHobies = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 300, 30)];
        self.lbHobies.backgroundColor = [UIColor clearColor];
        self.lbHobies.text = @"Tag your skills or hobbies";
        [bgView addSubview:self.lbHobies];
        
        self.tvHobbies = [[UITextView alloc] initWithFrame:CGRectMake(5, 40, 300, 60)];
        self.tvHobbies.backgroundColor = [UIColor clearColor];
        self.tvHobbies.delegate = target;
        [bgView addSubview:self.tvHobbies];
    }
    return self;
}

@end


@implementation QSRegistrationWorkLocationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTarget:(id)target
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 40)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bgView];
        
        self.lbWorkLocation = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 120, 30)];
        self.lbWorkLocation.backgroundColor = [UIColor clearColor];
        self.lbWorkLocation.text = @"Work Location";
        [self.contentView addSubview:self.lbWorkLocation];
        
        self.tfWorkLocation = [[UITextField alloc] initWithFrame:CGRectMake(140, 0, 150, 44)];
        self.tfWorkLocation.delegate = target;
        [self.contentView addSubview:self.tfWorkLocation];
    }
    return self;
}

@end


@implementation QSRegistrationPhoneNumberCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTarget:(id)target
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 40)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bgView];
        
        self.lbPhoneNumber = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 120, 30)];
        self.lbPhoneNumber.backgroundColor = [UIColor clearColor];
        self.lbPhoneNumber.text = @"Phone Number";
        [self.contentView addSubview:self.lbPhoneNumber];
        
        self.tfPhoneNUmber = [[UITextField alloc] initWithFrame:CGRectMake(140, 0, 150, 44)];
        self.tfPhoneNUmber.delegate = target;
        [self.contentView addSubview:self.tfPhoneNUmber];
    }
    return self;
}

@end


@implementation QSRegistrationGettingStartedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withButtonTarget:(id)target
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:241.0f/255.0f alpha:1];
        self.btGettingStarted = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btGettingStarted.frame = CGRectMake((self.frame.size.width - 200)/2, 30, 200, 44);
        self.btGettingStarted.backgroundColor = [UIColor colorWithRed:42.0f/255.0f green:87.0f/255.0f blue:128.0f/255.0f alpha:1];
        [self.btGettingStarted addTarget:target action:@selector(btnGettingStarted:) forControlEvents:UIControlEventTouchUpInside];
        [self.btGettingStarted setTitle:@"Get Started" forState:UIControlStateNormal];
        [self.contentView addSubview:self.btGettingStarted];

        //
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.tag = 10001;
        activityView.frame = CGRectMake(self.btGettingStarted.frame.origin.x+90, 30, 44, 44);
        activityView.hidesWhenStopped = TRUE;
        [self.contentView addSubview:activityView];

    }
    return self;
}

-(void)showActivityView {

    UIActivityIndicatorView *activityView = (UIActivityIndicatorView*)[self.contentView viewWithTag:10001];
    [activityView startAnimating];
}
-(void)stopActivityView {
    UIActivityIndicatorView *activityView = (UIActivityIndicatorView*)[self.contentView viewWithTag:10001];
    [activityView stopAnimating];
}

@end

