//
//  SNCollectMode.h
//  SurfNewsHD
//
//  Created by XuXg on 15/10/28.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurfJsonResponseBase.h"

// 收藏详情
@interface SNCollectSummary : NSObject


@property(nonatomic,strong)NSNumber *newsId;    /**< 新闻id */
@property(nonatomic,strong)NSString *title;     /**< 新闻标题 */
@property(nonatomic,strong)NSNumber *showTime;  /**< 新闻时间 */
@property(nonatomic,strong)NSString *source;    /**< 新闻来源 */
@property(nonatomic,strong)NSString *contentUrl;/**< 新闻来源 */
@property(nonatomic,strong)NSString *newsUrl;   /**< 新闻来源 */
@property(nonatomic,strong)NSNumber *openType;  /**< 新闻打开类型 */
@property(nonatomic,strong)NSNumber *coid;      /**< 新闻频道Id */


// 转换成新闻详情
-(ThreadSummary*)converThreadSummary;
@end


// 收藏请求
@interface SNCollectListResponse : SurfJsonResponseBase

@property(nonatomic,strong)NSArray *news; /**<  收藏新闻*/

@end
