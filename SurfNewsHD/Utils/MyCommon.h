//
//  MyCommon.h
//  SurfNews
//
//  Created by apple on 12-11-1.
//
//

#import <Foundation/Foundation.h>

@interface MyCommon : NSObject

+ (void)ensureLocalDirsPresent;

//数据库文件路径
+ (NSString *)surfDbFilePath;

//document文件夹路径
+ (NSString *)documentsPath;

//正文图片资源存放路径
//帖子正文中使用的图片都放置在此目录下
//数据库中有一个url映射表，维护了各image文件<-->对应的帖子之间的映射关系
+ (NSString *)threadsImageDir;

//帖子资源存放路径
//该目录下存放帖子自身的资源文件。【不包括帖子正文中引用的图片资源】
//[threadid].txt            -->帖子正文原文
//[threadid]_resolved.txt   -->预处理后的帖子正文原文，通常预处理完成后就可以将原文删除
//[threadid].logo           -->帖子预览图
//[threadid].banner         -->帖子banner图，只有图片帖才有banner图
+ (NSString *)threadsRscDir;

//频道分类资源存放路径
//目前此目录下有以下文件：
//cateslist.xml:
//  保存了上一次服务端返回的频道分类列表的原始xml，由于频道分类更新不是很频繁，我们可以直接通过缓存上一次xml来比对是否分类列表发生了更新
//[cateid].logo:
//  各分类的logo图。注：根据目前的UI设计方案，分类只展示名字，不展示logo，也就是说我们目前完全没必要下载logo图。
+ (NSString *)catesRscDir;

//可订阅频道资源存放路径
//目前此目录下有以下文件:
//[channelid].logo              -->该频道的logo图
//[channelid]_[threadid].logo   -->该频道下最新帖子的logo图
+ (NSString *)subsChannelsRscDir;

@end
