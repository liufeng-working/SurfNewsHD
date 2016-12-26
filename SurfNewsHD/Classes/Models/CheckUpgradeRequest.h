//
//  CheckUpgradeRequest.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurfJsonRequestBase.h"
#import "SurfJsonResponseBase.h"


@interface CheckUpgradeRequest : SurfJsonRequestBase

@property NSInteger reqType;  //0-自动更新；1-手动更新

@end



// 暂定为企业版检查软件更新请求返回数据
@interface SoftUpdateInfo : NSObject

@property(nonatomic,strong) NSString *verName;          // 版本号
@property(nonatomic,strong) NSString *updateUrl;        // 安装包下载地址
@property(nonatomic,strong) NSString *force;            // 是否强制升级
@property(nonatomic,strong) NSString *ut;               // 更新内容
@property(nonatomic,strong) NSString *upgradeContent;   // 版本更新内容

@end


@interface CheckUpgradeEnterpriseResponse : SurfJsonResponseBase

@property(nonatomic,strong) SoftUpdateInfo *sd;


@end



