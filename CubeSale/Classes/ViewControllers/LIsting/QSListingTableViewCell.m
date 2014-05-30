//
//  QSListingTableViewCell.m
//  CubeSale
//
//  Created by Ankit Jain on 29/04/14.
//  Copyright (c) 2014 None. All rights reserved.
//

#import "QSListingTableViewCell.h"
#import "QSUtil.h"
#import "QSApiConstants.h"


@implementation QSListingTableViewCellHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
            // Initialization code
        self.userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 7, 35, 35)];
        self.userImageView.image = [UIImage imageNamed:@"photo"];
        [self addSubview:self.userImageView];
        
        self.itempostTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, 170, 15)];
        self.itempostTimeLabel.font = [UIFont systemFontOfSize:12];
        self.itempostTimeLabel.textColor = [UIColor darkGrayColor];
        //self.itempostTimeLabel.backgroundColor = [UIColor yellowColor];
        [self addSubview:self.itempostTimeLabel];

        self.itempostUserNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 17, 170, 30)];
        //self.itempostUserNameLabel.backgroundColor = [UIColor redColor];
        [self addSubview:self.itempostUserNameLabel];

        self.itemPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 100, 15, 100, 20)];
        //self.itemPriceLabel.backgroundColor = [UIColor redColor];
        [self addSubview:self.itemPriceLabel];

        self.itemPriceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 55, 10, 28, 28)];
        //self.itemPriceImageView.backgroundColor = [UIColor redColor];
        //self.itemPriceImageView.image = [UIImage imageNamed:@"tag_free"];
        [self addSubview:self.itemPriceImageView];
    }
    return self;
}

@end

@implementation QSListingTableViewCellCenterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
            // Initialization code
        self.contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, self.frame.size.width-30,
                                                                              self.frame.size.height)];
        //self.contentImageView.backgroundColor = [UIColor greenColor];
        self.contentImageView.image = [UIImage imageNamed:@"listings_noimage"];
        //self.contentImageView.clipsToBounds = YES;
        [self addSubview:self.contentImageView];

        self.itemStatusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 85, 85)];
        //self.itemStatusImageView.image = [UIImage imageNamed:@"sold"];
        [self addSubview:self.itemStatusImageView];

        self.itemDescriptionBgView = [[UIView alloc] initWithFrame:CGRectMake(5, self.frame.size.height-85, self.frame.size.width-30, 85)];
        //NSLog(@":%@ :%@",NSStringFromCGRect(self.frame),NSStringFromCGRect(self.contenView.frame));
        self.itemDescriptionBgView.backgroundColor = [UIColor blackColor];
        self.itemDescriptionBgView.alpha = 0.8;
        [self addSubview:self.itemDescriptionBgView];

        self.itemDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, self.frame.size.height-80,
                                                                              self.frame.size.width-30, 75)];
        self.itemDescriptionLabel.textColor = [UIColor whiteColor];
        //self.itemDescriptionLabel.textAlignment = NSTextAlignmentLeft;
        self.itemDescriptionLabel.numberOfLines = 0;
        //[self.itemDescriptionLabel sizeToFit];
        //self.itemDescriptionLabel.backgroundColor = [UIColor greenColor];
        [self addSubview:self.itemDescriptionLabel];
    }
    return self;
}

@end

@implementation QSListingTableViewCellFooterView

-(id)initWithFrame:(CGRect)frame withTarget:(id)target
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //self.shareBtn.backgroundColor = [UIColor redColor];
        [self.shareBtn setTitle:@"Share" forState:UIControlStateNormal];
        [self.shareBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.shareBtn.frame = CGRectMake(10, 2, 50, 44);
        [self addSubview:self.shareBtn];

        self.askBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //self.askBtn.backgroundColor = [UIColor redColor];
        [self.askBtn setTitle:@"Ask for it" forState:UIControlStateNormal];
        [self.askBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.askBtn.frame = CGRectMake(self.frame.size.width - 120, 2, 100, 44);
        [self addSubview:self.askBtn];
    }
    return self;
}


@end

@implementation QSListingTableViewCell

@synthesize  headerView, centerView, footerView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.headerView = [[QSListingTableViewCellHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 52)];
        [self addSubview:self.headerView];

        self.centerView = [[QSListingTableViewCellCenterView alloc] initWithFrame:CGRectMake(0, 52, self.frame.size.width, 272)];
        [self.contentView addSubview:self.centerView];

        self.footerView = [[QSListingTableViewCellFooterView alloc] initWithFrame:CGRectMake(0, 324, self.frame.size.width, 44)];
        [self.contentView addSubview:self.footerView];

    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {

        self.headerView = [[QSListingTableViewCellHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 52)];
        self.headerView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.headerView];

        self.centerView = [[QSListingTableViewCellCenterView alloc] initWithFrame:CGRectMake(0, 52, self.frame.size.width, 272)];
        self.centerView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.centerView];

        self.footerView = [[QSListingTableViewCellFooterView alloc] initWithFrame:CGRectMake(0, 324, self.frame.size.width, 44)];
        self.footerView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.footerView];

    }
    return self;
}

-(void)awakeFromNib
{
    self.headerView = [[QSListingTableViewCellHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 52)];
    NSLog(@"W:%@",NSStringFromCGRect(self.headerView.frame));
    //self.headerView.backgroundColor = [UIColor greenColor];
    [self.contentView addSubview:self.headerView];

    self.centerView = [[QSListingTableViewCellCenterView alloc] initWithFrame:CGRectMake(0, 52, self.frame.size.width, 272)];
    //self.centerView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:self.centerView];

    self.footerView = [[QSListingTableViewCellFooterView alloc] initWithFrame:CGRectMake(0, 324, self.frame.size.width, 44) withTarget:nil];
    //self.footerView.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:self.footerView];

}

-(void)setValuesFromDictionary:(NSDictionary*)dictionary {

    NSString *uName = [dictionary objectForKey:@"username"];
    if(![self isEmptyStr:uName]){
        self.headerView.itempostUserNameLabel.text = uName;
    } else {
        self.headerView.itempostUserNameLabel.text = @"";
    }
    NSString *time = [dictionary objectForKey:@"mtime"];
    if(![self isEmptyStr:time]) {
        self.headerView.itempostTimeLabel.text = [QSUtil fuzzyTime:time];
    } else {
        self.headerView.itempostTimeLabel.text = @"";
    }
    NSString *price = [dictionary valueForKey:@"price"];
    if(![self isEmptyStr:price]) {
        if([price isEqualToString:@"free"]) {
            headerView.itemPriceImageView.hidden = NO;
            headerView.itemPriceLabel.hidden = NO;
            headerView.itemPriceImageView.image = [UIImage imageNamed:@"tag_free.png"];
            headerView.itemPriceLabel.frame = CGRectMake(self.frame.size.width - 95, 15, 100, 20);
        }
        else if([price isEqualToString:@"coffee"]) {
            headerView.itemPriceImageView.hidden = NO;
            headerView.itemPriceLabel.hidden = NO;
            headerView.itemPriceImageView.image = [UIImage imageNamed:@"tag_coffee.png"];
            headerView.itemPriceLabel.text = [NSString stringWithFormat:@"Buy for"];
            headerView.itemPriceLabel.frame = CGRectMake(self.frame.size.width - 95, 15, 100, 20);
        }
        else if([price isEqualToString:@"lunch"]) {
            headerView.itemPriceImageView.hidden = NO;
            headerView.itemPriceLabel.hidden = NO;
            headerView.itemPriceImageView.image = [UIImage imageNamed:@"tag_lunch.png"];
            headerView.itemPriceLabel.frame = CGRectMake(self.frame.size.width - 95, 15, 100, 20);
        }
        else {
            headerView.itemPriceImageView.hidden = YES;
            headerView.itemPriceLabel.hidden = NO;
            headerView.itemPriceLabel.text = [NSString stringWithFormat:@"Buy for $%@",price];
            CGSize size = [self getStringSize:headerView.itemPriceLabel.text withSizeConstraint:headerView.itemPriceLabel.frame.size withFont:headerView.itemPriceLabel.font];

            headerView.itemPriceLabel.frame = CGRectMake(self.frame.size.width - (size.width+3),
                                                         headerView.itemPriceLabel.frame.origin.y,
                                                         size.width,
                                                         headerView.itemPriceLabel.frame.size.height);
        }

    }

    NSString *des = [dictionary objectForKey:@"description"];
    if(![self isEmptyStr:des]) {
        //calculate height of description string
        CGRect labelRect = CGRectMake(5, centerView.frame.size.height-80, centerView.frame.size.width-30, 75);
        CGSize desStrSize = [self getStringSize:des withSizeConstraint:labelRect.size withFont:self.centerView.itemDescriptionLabel.font];

        ////////////update frame for bgview////////////
        CGRect rect =  centerView.itemDescriptionBgView.frame;
        float itemDescriptionHeight = desStrSize.height+20;
        centerView.itemDescriptionBgView.frame = CGRectMake(rect.origin.x,
                                                            centerView.frame.size.height-itemDescriptionHeight,
                                                            rect.size.width,
                                                            itemDescriptionHeight);
        /////////////label//////////////
        rect = centerView.itemDescriptionLabel.frame;
        centerView.itemDescriptionLabel.frame = CGRectMake(rect.origin.x,
                                                           centerView.frame.size.height-itemDescriptionHeight,
                                                           rect.size.width,
                                                           itemDescriptionHeight);
        self.centerView.itemDescriptionLabel.text = des;
    }
    else {
        CGRect rect = centerView.itemDescriptionBgView.frame;
        centerView.itemDescriptionBgView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 0);

        rect = centerView.itemDescriptionLabel.frame;
        centerView.itemDescriptionLabel.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 0);
        centerView.itemDescriptionLabel.text = @"";
    }

    NSNumber *itemSoldStatus = [dictionary objectForKey:@"posting_status"];
    if([itemSoldStatus boolValue]) {
        self.centerView.itemStatusImageView.hidden = NO;
        self.centerView.itemStatusImageView.image = [UIImage imageNamed:@"sold"];
    }
    else {
        self.centerView.itemStatusImageView.hidden = YES;
        self.centerView.itemStatusImageView.image = nil;
    }

}

-(void)setItemImage:(UIImage*)itemImage {
    if(itemImage){
        self.centerView.contentImageView.image = itemImage;
    }
    else {
        self.centerView.contentImageView.image = [UIImage imageNamed:@"listings_noimage"];;
    }
}

-(void)setUserImage:(UIImage*)userImage {
    if(userImage) {
        self.headerView.userImageView.image = userImage;
    }
    else {
        self.headerView.userImageView.image = [UIImage imageNamed:@"photo"];
    }
}
-(void)setBtnTarget:(id)target withSel:(SEL)selector withTagIndex:(NSInteger)index{
    [footerView.askBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    footerView.askBtn.tag = index;
    [footerView.shareBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    footerView.shareBtn.tag = index;
}

-(CGSize)getStringSize:(NSString*)str withSizeConstraint:(CGSize)size withFont:(UIFont*)font{
    CGSize theStringSize = [str sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByClipping];
    return theStringSize;
}
-(BOOL)isEmptyStr:(NSString*)string {
    if (!string || ![string isKindOfClass:[NSString class]]) return YES;
    NSString *_string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return (![_string length] || [_string isEqualToString:@"null"]);
}


@end



