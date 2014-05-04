//
//  QSListingTableViewCell.h
//  CubeSale
//
//  Created by Ankit Jain on 29/04/14.
//  Copyright (c) 2014 None. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QSListingTableViewCellHeaderView : UIView

@property(nonatomic,strong)UIImageView *userImageView;
@property(nonatomic,strong)UILabel *itempostTimeLabel;
@property(nonatomic,strong)UILabel *itempostUserNameLabel;
@property(nonatomic,strong)UIImageView *itemPriceImageView;
@property(nonatomic,strong)UILabel *itemPriceLabel;
//@property(nonatomic,strong)UILabel *itempostUserLocation;
//@property(nonatomic,strong)UILabel *itempostBuyDescriptionLabel;


@end

@interface QSListingTableViewCellCenterView : UIView

@property(nonatomic,strong)UIImageView *contentImageView;
@property(nonatomic,strong)UIImageView *itemStatusImageView;
@property(nonatomic,strong)UIView *itemDescriptionBgView;
@property(nonatomic,strong)UILabel *itemDescriptionLabel;

@end

@interface QSListingTableViewCellFooterView : UIView

-(id)initWithFrame:(CGRect)frame withTarget:(id)target;

@property(nonatomic,strong)UIButton *shareBtn;
@property(nonatomic,strong)UIButton *askBtn;


@end


@interface QSListingTableViewCell : UICollectionViewCell

@property(nonatomic,strong)QSListingTableViewCellHeaderView *headerView;
@property(nonatomic,strong)QSListingTableViewCellCenterView *centerView;
@property(nonatomic,strong)QSListingTableViewCellFooterView *footerView;

-(void)setValuesFromDictionary:(NSDictionary*)dictionary;
-(void)setItemImage:(UIImage*)itemImage;
-(void)setUserImage:(UIImage*)itemImage;
-(void)setBtnTarget:(id)target withSel:(SEL)selector withTagIndex:(NSInteger)index;
@end
