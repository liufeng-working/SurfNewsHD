//
//  SubsChannelsListRequest.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonRequestBase.h"
// 频道列表
@interface SubsChannelsListRequest : SurfJsonRequestBase

@property NSInteger page;
@property long cateId;


-(id) initWithCateId:(long)cateId page:(NSInteger)page;


@end

//游客默认订阅列表
@interface DefaultSubsChannelsListJson : SurfJsonRequestBase

@end

@interface DefaultSubsChannelsListRequest : NSObject

@property DefaultSubsChannelsListJson *req;

@end


//根据UserId获取订阅列表
@interface UserSubsChannelsListRequest : SurfJsonRequestBase
@property NSString* userId;

-(id)initWithUserId:(NSString*)userId;
@end
