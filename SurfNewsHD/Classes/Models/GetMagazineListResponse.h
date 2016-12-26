//
//  GetMagazineListResponse.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"

@interface MagazineInfo : NSObject

@property NSString *magazineName;               //期刊名
@property NSString *iconUrl;                    //icon链接
@property NSString *imageUrl;                   //image链接
@property NSString *detailUrl;                  //详情链接
@property long publishTime;                     //发布时间
@property long magazineId;                      //期刊ID
@property NSInteger orderedCount;               //订购数量
@property NSInteger payType;                          //0:免费, 1:收费

@end

//******************************************************************************

//全部期刊列表
@interface GetMagazineListResponse : SurfJsonResponseBase

@property NSString *apicPass;
@property NSArray *item;

@end
