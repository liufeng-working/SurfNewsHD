//
//  PhoneNewsListRequest.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneNewsListRequest.h"

@implementation PhoneNewsReq

- (id)init{
    if (self = [super init]) {
        _from = 0;
        _number = 10;
    }
    return self;
}
@end


@implementation PhoneNewsListRequest


- (id)initWithUid:(NSString*)uid page:(NSInteger)page{    
    if (self = [super init]) {
        _req = [PhoneNewsReq new];
        [_req setUid:uid];
        [_req setPage:page];
    }
    return self;
}
- (void)setListCount:(NSUInteger)count{
    [_req setNumber:count];
}
@end




@implementation CancelFacData

- (id)init{
    if (self = [super init]) {
        _from = 0;  // 固定值，不能修改
        _type = 1;  // 固定值，不能修改
    }
    return self;
}

@end

@implementation PhoneNewsCancelFavsRequest

- (id)initWithUid:(NSString*)uid hashcode:(NSString*)hash{
    if (self = [super init]) {
        _req = [CancelFacData new];
        [_req setUid:uid];
        [_req setHashcode:hash];
    }
    return self;
}

@end
