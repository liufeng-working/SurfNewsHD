//
//  PhotoCollectionRequest.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-7-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonRequestBase.h"


// 请求图集频道列表
@interface PhotoCollectionChannelListRequest : SurfJsonRequestBase
@property(nonatomic) NSString *dm;
@property(nonatomic) long rt;
@end


// 使用图集频道id，请求图集列表。
//{"sdkv":"10","os":"android","count":20,"dm":"500*800","pm":"GT-I9000","did":"1b51b899-4d26-3e98-a6c5-c94603ab7c2a","vername":"2.2","cid":"4svHsswM","page":1,"coid":15003,"vercode":37,"rt":"600"}
@interface PhotoCollectionListRequest : PhotoCollectionChannelListRequest

@property(nonatomic) u_long coid;   // 图集频道ID
@property(nonatomic) NSInteger count;    // 一页的图集数 默认20
@property(nonatomic) NSUInteger page;     // 图集页数(从1开始)

-(id)initWithCoid:(u_long)coid;
- (id)initWithChannelId:(long)channelId
              newsCount:(NSInteger)newsCount
                   page:(NSInteger)page;
@end




// 图集请求
//method=getImgNewsListByCoverId&jsonRequest={"id":"45209","sdkv":"15","os":"android","coid":4061,"dm":"540*960","pm":"HTC","did":"ef901559-05e0-3321-aea0-c0d60e914ad9","vername":"2.2.1","type":"2","cid":"4svHsswM","vercode":35}
@interface PhotoCollectionContentRequest : SurfJsonRequestBase

@property(nonatomic) u_long pcId;   // 图集内容ID
@property(nonatomic) u_long coid;   // 图集频道ID
@property(nonatomic) uint type;     // 新闻类型（0为快讯维护，1为助手维护，2为图集）
@property(nonatomic) NSString *dm;

- (id)initWithPhotoCollection:(PhotoCollection*)pc;
@end
