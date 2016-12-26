//
//  SNReportModel.h
//  SurfNewsHD
//
//  Created by XuXg on 15/10/20.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurfJsonRequestBase.h"
#import "SurfJsonResponseBase.h"
#import "MJExtension.h"


////////////////
// 获取举报类型
@interface SNReportInfo : NSObject

@property(nonatomic, strong) NSNumber *resportId;
@property(nonatomic, strong) NSString *reportType;
@end


@interface SNReportResponse : SurfJsonResponseBase

@property NSArray *item;
@end


//////////////////////////////////////////
// 提交举报

@interface SNReportSubmitRequest : SurfJsonRequestBase

@property(nonatomic)long newsId; /**<  新闻id */
@property(nonatomic,strong)NSString *newsTitle; /**<  新闻标题 */
@property(nonatomic)long channelId; /**<  新闻频道 */
@property(nonatomic,strong)NSString *content; /**<  举报信息 */

@end






