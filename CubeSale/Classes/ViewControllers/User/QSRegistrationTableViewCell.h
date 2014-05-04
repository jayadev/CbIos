//
//  QSRegistrationTableViewCell.h
//  CubeSale
//
//  Created by Ankit Jain on 05/04/14.
//  Copyright (c) 2014 None. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QSRegistrationTableViewCell : UITableViewCell

@end



@interface  QSRegistrationTitleCell: QSRegistrationTableViewCell

@property (nonatomic, strong) UIImageView *ivProfileImage;
@property (nonatomic, strong) UILabel *lbTitle;

@end

@interface  QSRegistrationWorkEmailCell: QSRegistrationTableViewCell

@property (nonatomic, strong) UITextField *tfWorkEmail;
@property (nonatomic, strong) UILabel *lbWorkEmail;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTarget:(id)target;

@end

@interface  QSRegistrationHobbiesCell: QSRegistrationTableViewCell

@property (nonatomic, strong) UITextView *tvHobbies;
@property (nonatomic, strong) UILabel *lbHobies;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTarget:(id)target;

@end


@interface  QSRegistrationWorkLocationCell: QSRegistrationTableViewCell 

@property (nonatomic, strong) UITextField *tfWorkLocation;
@property (nonatomic, strong) UILabel *lbWorkLocation;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTarget:(id)target;

@end


@interface  QSRegistrationPhoneNumberCell: QSRegistrationTableViewCell

@property (nonatomic, strong) UITextField *tfPhoneNUmber;
@property (nonatomic, strong) UILabel *lbPhoneNumber;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTarget:(id)target;

@end

@interface  QSRegistrationGettingStartedCell: QSRegistrationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withButtonTarget:(id)target;

-(void)showActivityView;
-(void)stopActivityView;

@property (nonatomic, strong) UIButton *btGettingStarted;

@end



