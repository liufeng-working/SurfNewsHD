//
//  PhotoCollectionData.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-7-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

// 图片信息
//{"id":35021,"cover_id":34945,"coid":15003,"img_id":"1","title":"王智黑白写真",
//"img_path":"http://192.168.10.54/images/15003/20130814/34945/320/34945_1.jpg",
//"source_path":"http://img.3g.cn/ent/2013/8/13/1128467255v_416_723.jpg",
//    "time":1376466688500,"webp_flag":1}
@interface PhotoData : NSObject

@property(nonatomic) u_long pId;        // 图片id
@property(nonatomic) u_long cover_id;   // 图集id(需要保存到文件中)
@property(nonatomic) u_long coid;       // 图集频道id(需要保存到文件中)
@property(nonatomic) u_long img_id;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *img_path;
@property(nonatomic,strong) NSString *source_path;
@property(nonatomic)double time;    // 服务器时间
@property(nonatomic) int webp_flag;

// 本地的临时数据
@property(nonatomic) BOOL isCacheData;      // 缓存数据(主要说明此数据不会保存到文件夹中，只在缓存中。因业务需要，图集列表加载更多是不保存到文件中的)
@property(nonatomic) BOOL isLoadingImage;   // 是否正在加载图片
@end


// 图集信息
//{
//    "id":33555,"title":"AKB48成员花球遮乳翘臀性感","desc":"356877","time":1375258860000,"source":"写真",
//    "imgUrl":"http://192.168.10.54:80/images/15003/20130731/33555/600/33555.webp",
//    "newsUrl":"http://img.3g.cn/ent/2013/7/31/153161574v.jpg",
//    "isTop":0,"type":4,"coid":15003,"isTopOrderby":0,"webp_flag":"1","open_type":0,"imgc":13
//},
@interface PhotoCollection : NSObject

//@property(nonatomic) u_long pc_id;
//@property(nonatomic,strong) NSString *coll_t;
//@property(nonatomic,strong) NSString *cover_img;
//@property(nonatomic,strong) NSArray *imgs;


@property(nonatomic) u_long pcId;   // 图集ID
@property(nonatomic) BOOL isTop;    // 是否热门
@property(nonatomic) u_long coid;   // 图集频道id
@property(nonatomic) BOOL webp_flag;
@property(nonatomic) u_int imgc;    // 姜俊说是图集里的图片数
@property(nonatomic) double time;  // 服务器时间

@property(nonatomic,strong) NSString *title;    // 标题
@property(nonatomic,strong) NSString *desc;     // 描述
@property(nonatomic,strong) NSString *source;   // 来源
@property(nonatomic,strong) NSString *imgUrl;   // 姜俊要我使用这个
@property(nonatomic,strong) NSString *newsUrl;  // 姜俊要我不要管

// 本地数据
@property(nonatomic)BOOL isTempData;    // 用来标记是否是加载更多获取到的数据


@end


// 图集频道信息
// {"id":15003,"name":"写真","type":2,"index":17341,"parent_id":14923,
// "content_url":"http://ent.3g.cn/api/surferphotoapplist.ashx?cid\u003d206\u0026part\u003d1\u0026num\u003d15"}
@interface PhotoCollectionChannel : NSObject

@property(nonatomic) u_long cid;    //图集频道id
@property(nonatomic) NSString *name;//图集频道名称
@property(nonatomic) int type;
@property(nonatomic) u_long index;
@property(nonatomic) u_long parent_id;
@property(nonatomic) NSString *content_url;

@property(nonatomic) double time;


@property(nonatomic) float listScrollOffsetY; // 本地临时数据，不需要保持


@end

// 图集频道的本地信息
@interface PCCLocalInfo : NSObject


// 本地属性
@property(nonatomic) u_long cid;                    //图集频道id
@property(nonatomic) double refreshTimeInterval;    // 刷新时间，需要保存到文件中(Since1970)
@property(nonatomic) double getMoreTimeInterval;    // 获取更多时间，需要保存到文件中(Since1970)

- (id)initWithPCChannel:(PhotoCollectionChannel*)pcc;
- (void)saveToFile;
- (void)loadDateFromFile;
@end


