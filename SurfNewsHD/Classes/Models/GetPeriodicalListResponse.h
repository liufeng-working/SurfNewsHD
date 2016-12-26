//
//  GetPeriodicalListResponse.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"

//一期期刊, 3.0.0更新
@interface PeriodicalHeadContentTitle : NSObject

@property NSString *title;

@end

@interface PeriodicalHeadInfo : NSObject

@property NSString *iconViewPath;
@property NSString *iconTitle;
@property NSArray *contentTitle;

@end

@interface PeriodicalInfo : NSObject

@property long magazineId;                 //期刊ID
@property long periodicalId;               //某期ID
@property long long publishTime;           //发布时间
@property NSString *magazineName;          //期刊名
@property NSString *periodicalName;        //某期名
@property NSString *imageUrl;              //某期封面URL
@property PeriodicalHeadInfo *head;

//离线包相关，from iphone 1.1+
@property(nonatomic) long offlineZipSize;   //离线包大小
@property(nonatomic,strong) NSString* offlineZipUrl;//离线包url


@property NSInteger isNew;                 //本地属性,是否是新的一期期刊:1为新,0为旧
@property float scrollPosition;            //本地属性,上次滑动的位置
@property(nonatomic,strong) NSString *lastReadURL; //本地属性,最后一次阅读的链接

@end

//一种期刊列表的response
@interface GetPeriodicalListResponse : SurfJsonResponseBase

@property long long serverTime;
@property NSArray *item;

@end

//**********************************更新的期刊************************************
@interface UpdatePeriodicalInfo : NSObject

@property long magazineId;                 //期刊ID
@property NSString *magazineName;          //期刊名
@property NSString *magazineLogo;          //期刊Logo
@property long periodNum;                  //期刊期数
@property long long lastPeriodLongDate;    //最后的更新时间
@property NSInteger payType;                     //付费类型0免费1收费
@property NSArray *periods;                //每期的列表
@property NSInteger isOpen;                      //是否支持付费

@end

//更新的期刊列表的response
@interface UpdatePeriodicalListResponse : SurfJsonResponseBase

@property NSString *apicPass;
@property long long serverTime;
@property NSArray *item;

@end