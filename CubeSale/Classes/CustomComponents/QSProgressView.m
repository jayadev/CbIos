//
//  QSProgressView.m
//  CubeSale
//
//  Copyright (c) 2014 None. All rights reserved.
//

#import "QSProgressView.h"

@interface QSProgressView ()
@property(nonatomic,strong)UIActivityIndicatorView *activityIndicator;

@end


@implementation QSProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor lightGrayColor];
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.frame = CGRectMake((self.frame.size.width-44)/2,
                                                  (self.frame.size.height-44)/2-50,
                                                  44, 44);
        self.activityIndicator.hidesWhenStopped = YES;
        [self addSubview:self.activityIndicator];

    }
    return self;
}

-(void)start {
    [self.activityIndicator startAnimating];
}

-(void)stop {
    [self.activityIndicator stopAnimating];
}
@end
