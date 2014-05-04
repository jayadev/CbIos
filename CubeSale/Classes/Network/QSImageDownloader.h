//
//  QSImageDownloader.h
//  CubeSale
//
//  Created by Ankit Jain on 03/05/14.
//  Copyright (c) 2014 None. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QSImageDownloaderDelegate;

@interface QSImageDownloader : NSObject

@property(nonatomic,assign)id<QSImageDownloaderDelegate> delegate;
@property(nonatomic,strong)NSString *imageDownloadUrl;
- (void)startDownload;
- (void)cancelRequest;

@end



@protocol QSImageDownloaderDelegate <NSObject>

-(void)imageDownload:(QSImageDownloader*)inImageDownloader finishImageLoading:(UIImage*)image;

-(void)imageDownload:(QSImageDownloader*)inImageDownloader failWithError:(NSError *)error;

@end