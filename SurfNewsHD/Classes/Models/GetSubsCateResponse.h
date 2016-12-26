//
//  GetSubsCateResponse.h
//  SurfNewsHD
//
//  Created by SYZ on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"


@interface CategoryItem : NSObject

@property long cateId;
@property NSString *imageUrl;
@property NSString *indexId;
@property NSString *name;

//========本地属性========
@property BOOL isHidden;
@property(nonatomic,strong) NSMutableArray* channels;  // 属于该分类的所有可订阅频道
@property NSInteger channelCurrentPage;         // 订阅频道显示第几页

@end

@interface GetSubsCateResponse : SurfJsonResponseBase

@property NSString *apicPass;
@property NSArray *item;

@end
