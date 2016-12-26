//
//  PhotoCollectionResponse.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-7-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"


// 接受图集频道列表数据
@interface PhotoCollectionListResponse : SurfJsonResponseBase

@property(nonatomic)NSArray *item;
@end


//////////////////////////////////////////////////////////
// 接受图集列表数据
//////////////////////////////////////////////////////////
/*
{
    "countPage":1,
    "news":
    [
        {
            "id":33555,"title":"AKB48成员花球遮乳翘臀性感","desc":"356877","time":1375258860000,"source":"写真",
            "imgUrl":"http://192.168.10.54:80/images/15003/20130731/33555/600/33555.webp",
            "newsUrl":"http://img.3g.cn/ent/2013/7/31/153161574v.jpg",
            "isTop":0,"type":4,"coid":15003,"isTopOrderby":0,"webp_flag":"1","open_type":0,"imgc":13
        },
        {
            "id":33556,"title":"叶熙祺纯美写真穿白裙似女神","desc":"356871","time":1375258860000,"source":"写真",
            "imgUrl":"http://192.168.10.54:80/images/15003/20130731/33556/600/33556.webp",
            "newsUrl":"http://img.3g.cn/ent/2013/7/31/1510183875v.jpg","isTop":0,"type":4,"coid":15003,"isTopOrderby":0,"webp_flag":"1","open_type":0,"imgc":4
        },
        {
            "id":33557,"title":"周奇奇穿丝绸衣服成一代名媛","desc":"356868","time":1375258860000,"source":"写真",
            "imgUrl":"http://192.168.10.54:80/images/15003/20130731/33557/600/33557.webp",
            "newsUrl":"http://img.3g.cn/ent/2013/7/31/153545819v.jpg","isTop":0,"type":4,"coid":15003,"isTopOrderby":0,"webp_flag":"1","open_type":0,"imgc":5
        }
    ],
    "res":{"reCode":"1","resMessage":"Operation is successful"}
}
 */
@interface PhotoCollectionResponse : SurfJsonResponseBase
@property(nonatomic) uint countPage;    // 总页数
@property(nonatomic) NSArray *news;     // 图集数据
@end




// 图集内容
/*{
    "res":{
        "reCode":"1",
        "resMessage":
        "Operation is successful"
    },
    ”imgs”:[
    {“id”:”10001”,”title”:”第一张子图”,”imgUrl”:”第一张子图地址”},
    {“id”:”10002”,”title”:”第二张子图”,”imgUrl”:”第二张子图地址”}
            ]
}
*/
@interface PhotoCollectionContentResponse : SurfJsonResponseBase
@property(nonatomic) NSArray *item;     // 图集内容数组
@end

