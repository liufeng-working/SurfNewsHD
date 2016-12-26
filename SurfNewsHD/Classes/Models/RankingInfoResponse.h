//
//  RankingInfoResponse.h
//  SurfNewsHD
//
//  Created by jsg on 14-11-25.
//  Copyright (c) 2014年 apple. All rights reserved.
//
#import "SurfJsonResponseBase.h"

@interface RankingNews : NSObject

@property long ranking_id;                               //1.图片新闻id
@property (nonatomic,strong) NSString *title;            //2.标题+
@property (nonatomic,strong) NSString *desc;             //3.描述+
@property (nonatomic,strong) NSString *time;              //4.发布时间
@property (nonatomic,strong) NSString *source;           //5.内容来源
@property (nonatomic,strong) NSString *imgUrl;           //6.图片Url
@property (nonatomic,strong) NSString *newsUrl;          //7.新闻Url
@property (nonatomic,strong) NSString *isTop;            //8.
@property (nonatomic,strong) NSString *type;             //9.
@property (nonatomic,strong) NSString *coid;             //10.分类ID
@property (nonatomic,strong) NSString *isTopOrderby;     //11.
@property (nonatomic,strong) NSString *webp_flag;        //12.
@property (nonatomic,strong) NSString *open_type;         /*13.打开方式 （0:正文方式打开
                                                          1:网页方式打开
                                                          2:以图集方式打开
                                                          3:以期刊方式打开）*/
@property (nonatomic,strong) NSString *iconId;           //14.图片Id
@property (nonatomic,strong) NSString *iconPath;         //15.icon访问路径
@property (nonatomic,strong) NSString *hot;              //16.图片路径
@property (nonatomic,strong) NSString *content_url;      //17.图片路径
@property (nonatomic,strong) NSString *positive_energy;  //18.正能量总值
@property (nonatomic,strong) NSString *negative_energy;  //19.负能量总值
@property (nonatomic,strong) NSString *total_energy;     //20.
@property (nonatomic,strong) NSString *positive_count;   //21.正能量人数
@property (nonatomic,strong) NSString *negative_count;   //22.负能量人数
@property (nonatomic,strong) NSString *is_energy;
@property (nonatomic,strong) NSString *recommendType;    //23.
@property (nonatomic,strong) NSString *imgc;             //24.
@property (nonatomic) int seqId;                         //25.
@property (nonatomic,strong) NSString *rankType;         //26.榜单类型+(0日榜 1周榜)
@property (nonatomic,strong) NSString *seqUpdate;        //27.榜单变化+(null不显示 0无变化， +上升 -下降)

@property(nonatomic,strong) NSNumber *isComment;        // 是否评论
@property(nonatomic,strong) NSNumber *comment_count;    // 评论总数

- (ThreadSummary *)getThread;
@end


//正能量                                                  //注释+表示页面上用到的变量
@interface PositiveNews : RankingNews

@end

//负能量
@interface NegativeNews : RankingNews

@end


@interface RankingInfoResponse : SurfJsonResponseBase
@property NSArray *positiveNews;
@property NSArray *negativeNews;
@end
