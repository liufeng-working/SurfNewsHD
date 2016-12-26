//
//  GetMagazineSubsResponse.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"
#import "GetMagazineListResponse.h"
#import "GetPeriodicalListResponse.h"

//坑爹的返回,接口的返回值是包括栏目和期刊
//要判断rssType
@interface MagazineSubsInfo : NSObject

@property NSString *index;
@property NSString *desc;                     //期刊描述
@property NSString *name;                     //期刊名称
@property NSString *imageUrl;                 //期刊icon链接
@property NSString *coverUrl;                 //期刊封面链接
@property NSInteger isVisible;                      //期刊对客户端是否可见
@property NSInteger rssType;                        //1:栏目, 6:刊物
@property NSInteger payType;                        //0:免费, 1:收费
@property long subsCount;                     //期刊订阅人数
@property long magazineId;                    //期刊ID

@property BOOL refreshPeridical;              //本地属性,是否刷新期刊列表
@property BOOL getPeriodicalSuccess;          //本地属性,成功获取每期期刊,默认值为YES
@property NSMutableArray *periodicalArray;    //本地属性,每期期刊列表

@property UpdatePeriodicalInfo *lastUpdatePeriodicalInfo;    //本地属性，最新的一期期刊

- (id)initWithMagazineInfo:(MagazineInfo*)magazineInfo;

@end

//******************************************************************************

//期刊订阅的response
@interface GetMagazineSubsResponse : SurfJsonResponseBase

@property NSString *apicPass;
@property NSArray *item;

@end
