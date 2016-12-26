//
//  SNThreadViewerController.h
//  SurfNewsHD
//
//  Created by yuleiming on 14-7-3.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "PhoneSurfController.h"
#import "ThreadSummary.h"
#import "SNThreadViewer.h"
#import "SNToolBar.h"
#import "PhoneWeiboController.h"


@interface SNThreadViewerController : PhoneWeiboController < SNThreadViewerDelegate, SNToolBarDelegate>


-(id)initWithThread:(ThreadSummary*)thread;

// 是否从收藏打开
-(id)initWithThread:(ThreadSummary*)thread
      isFromCollect:(BOOL)isCollect;

//释放内存
-(void)cleanViewersResource;

@end
