//
//  MyFavMode.h
//  SurfNewsHD
//
//  Created by duanmu on 15/10/26.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyFavMode : SurfJsonRequestBase

@property(nonatomic)long newsId; /**<  新闻id */
@property(nonatomic)long coid; /**<  频道id */
@property(nonatomic)long type; /**<  类型区别热推及助手新闻，0为快讯自有新闻，1为rss新闻，3为微精选 */

@end


@interface unSubscribeCollectMode : SurfJsonRequestBase


@property(nonatomic)long newsId; /**<  频道id */
@property(nonatomic)long content_id; /**<  新闻id */

@end


//@interface getCollectedListMode : SurfJsonRequestBase
//
//
//@property(nonatomic)int page; /**<  页数,默认为1 */
//@property(nonatomic)int count; /**<  每页展示的条数 */
//
//@end
