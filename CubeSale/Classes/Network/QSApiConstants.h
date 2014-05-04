//
//  QSApiConstants.h
//  CubeSale
//
//  Created by Ankit Jain on 17/03/14.
//  Copyright (c) 2014 None. All rights reserved.
//

#ifndef CubeSale_QSApiConstants_h
#define CubeSale_QSApiConstants_h

#define QS_API_BASEPATH @"http://cubesales.com/api/v2"

#pragma mark USER API -
#define QS_API_REGISTERUSER @"/registerUser"

#pragma mark Listing API - 
#define QS_API_LISTINGS @"/getUserListings"

#pragma mark POST ITEM API -
#define QS_API_POST @"/postListing"

#pragma mark BUY ITEM API -
#define QS_API_BUY @"/getComments"

#pragma mark API Keys -
#define KAPI_USERID @"user_id"
#define KAPI_FILTERTYPE @"filter_type"
#define KAPI_RESPONSEDATA @"response_data"
#define KAPI_ITEM_IMAGE_URL @"photo_url"
#define KAPI_USER_IMAGE_URL @"img_url"
#define KAPI_POSTITEM_DESCRIPTION @"posting_description"
#define KAPI_POSTITEM_PRICE @"posting_price"
#define KAPI_POSTITEM_IMAGESIZE @"posting_photo_size"
#define KAPI_POSTITEM_STATUS @"posting_status"
#define KAPI_POSTITEM_IMAGE     @"posting_image"
#define KAPI_POSTITEM_PRODUCTID    @"prod_id"
#define KAPI_POSTITEM_ID    @"id"


#endif
