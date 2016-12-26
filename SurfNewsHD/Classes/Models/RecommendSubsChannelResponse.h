//
//  RecommendSubsChannelResponse.h
//  SurfNewsHD
//
//  Created by SYZ on 13-8-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"
#import "SubsChannelsListResponse.h"




@interface RecommendSubsChannelResponse : SurfJsonResponseBase

@property NSString *apicPass; // URL图片前缀
@property NSArray *item;

@end
