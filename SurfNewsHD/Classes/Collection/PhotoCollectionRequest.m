//
//  PhotoCollectionRequest.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-7-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhotoCollectionRequest.h"
#import "PhotoCollectionData.h"



// 请求图片集合列表请求
@implementation PhotoCollectionChannelListRequest
- (id)init{
    if (self = [super init]) {
        CGRect rect_screen = [[UIScreen mainScreen] bounds];
        int scale_screen = [UIScreen mainScreen].scale;
        int width = CGRectGetWidth(rect_screen) * scale_screen;
        int height = CGRectGetHeight(rect_screen) * scale_screen;        
        _dm = [NSString stringWithFormat:@"%d*%d", width, height];
        _rt = width;
    }
    return self;
}
@end



@implementation PhotoCollectionListRequest

-(id)initWithCoid:(u_long)coid {
    if (self = [super init]) {
        _count = 20;
        _page = 1;
        _coid = coid;
    }
    return self;
}
- (id)initWithChannelId:(long)channelId
              newsCount:(NSInteger)newsCount
                   page:(NSInteger)page{
    if (self = [super init]) {
        self.coid = channelId;
        self.count = newsCount;
        self.page = page;
    }
    return self;
}

-(void)setPage:(NSUInteger)page{
    if (page < 1) 
        page = 1;
    _page = page;
}
@end


@implementation PhotoCollectionContentRequest

@synthesize pcId = __KEY_NAME_id;

- (id)initWithPhotoCollection:(PhotoCollection*)pc
{
    if (self = [super init]) {
        _type = 2;
        _coid = pc.coid;
        __KEY_NAME_id = pc.pcId;
        CGRect rect_screen = [[UIScreen mainScreen] bounds];
        int scale_screen = [UIScreen mainScreen].scale;
        int width = CGRectGetWidth(rect_screen) * scale_screen;
        int height = CGRectGetHeight(rect_screen) * scale_screen;
        _dm = [NSString stringWithFormat:@"%d*%d", width, height];
    }
    return self;
}

@end
