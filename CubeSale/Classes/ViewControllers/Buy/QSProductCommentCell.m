//
//  QSProductCommentCell.m
//  CubeSale
//
//  Created by Ankit Jain on 05/05/14.
//  Copyright (c) 2014 None. All rights reserved.
//

#import "QSProductCommentCell.h"
#import "QSUtil.h"

@interface QSProductCommentCell ()
{
    IBOutlet UIImageView *cImage;
    IBOutlet UILabel *commentLabel;
}

@property(nonatomic,strong)IBOutlet UILabel *nameLabel;
@property(nonatomic,strong)IBOutlet IBOutlet UILabel *timeLabel;

@end


@implementation QSProductCommentCell

@synthesize nameLabel,timeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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

-(void)setCommentsFromDictionary:(NSDictionary*)commentDict {
    
    NSString *userName = [commentDict objectForKey:@"username"];
    if(![QSUtil isEmptyString:userName]) {
        nameLabel.text = userName;
    } else {
        nameLabel.text = @"";
    }
    
    NSString *time = [commentDict objectForKey:@"mtime"];
    if(![QSUtil isEmptyString:time]) {
        timeLabel.text = [QSUtil fuzzyTime:time];
    } else {
        timeLabel.text = @"";
    }
    
    NSString *comment = [commentDict objectForKey:@"comment"];
    if(![QSUtil isEmptyString:comment]) {
        commentLabel.text = comment;
    } else {
        commentLabel.text = @"";
    }
}

-(void)setItemImage:(UIImage*)itemImage {
    if(itemImage){
        cImage.image = itemImage;
    }
    else {
        cImage.image = [UIImage imageNamed:@"listings_noimage"];;
    }
}
@end
