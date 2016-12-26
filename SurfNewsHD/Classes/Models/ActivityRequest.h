//
//  ActivityRequest.h
//  SurfNewsHD
//
//  Created by xuxg on 14-4-29.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "SurfJsonRequestBase.h"


// 新闻类型中的type==3(活动) 需要生成新的新闻链接
//注：   http://192.168.10.170:8091/suferDeskInteFace/redirectService?jsonRequest={"activityId":"97894","uid":"faf50a122c70cd91","sdkv":"15","os":"android","cityId":"101190101","dm":"540*960","pm":"HTC Z715e","did":"314ee5f7-b5a5-36be-85d6-ef04cd1b3cba","vername":"3.4","imsi":"460020019644765","cid":"11","vercode":47}
@interface ActivityRequest : SurfJsonRequestBase

@property(nonatomic) long activityId;

-(instancetype)init:(long)acitityId;
@end
