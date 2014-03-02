//
//  QSLazyImage.h
//  CubeSale
//
//  Created by Sushant Kumar on 4/4/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QSLazyImage : UIImageView

- (void)setFadeIn;
- (void)loadFromUrl:(NSURL *)url;
- (void)cancelLoading;

@end
