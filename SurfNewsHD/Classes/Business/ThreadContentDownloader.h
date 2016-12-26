//
//  ThreadContentDownloader.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 注意：ThreadContentDownloader设计为单例
 */
@class ThreadSummary;
@interface ThreadContentDownloader : NSObject
{
    //key:ThreadSummary*
    //value:GTMHTTPFetcher*
    NSMutableDictionary* userDict_;
}

//access the singleton ThreadContentDownloader instance
+ (ThreadContentDownloader *)sharedInstance;

// 正文中的附加信息
-(void) download:(ThreadSummary*)thread isCollect:(BOOL)isCollect
withCompletionHandler:(void(^)(BOOL succeeded,NSString* content,ThreadSummary* thread))handler;
-(void) cancelDownload:(ThreadSummary*)thread;

@end
