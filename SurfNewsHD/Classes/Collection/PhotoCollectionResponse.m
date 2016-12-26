//
//  PhotoCollectionResponse.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-7-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhotoCollectionResponse.h"

@implementation PhotoCollectionListResponse
@synthesize item = __ELE_TYPE_PhotoCollectionChannel;
@end



// 接受图集列表数据
@implementation PhotoCollectionResponse
@synthesize news = __ELE_TYPE_PhotoCollection;
@end



// 图集内容
@implementation PhotoCollectionContentResponse
@synthesize item = __ELE_TYPE_PhotoData;
@end