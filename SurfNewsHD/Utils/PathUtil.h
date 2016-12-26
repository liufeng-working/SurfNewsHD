//
//  PathUtil.h
//  SurfNews
//
//  Created by apple on 12-11-1.
//
//

#import <Foundation/Foundation.h>

@class HotChannel;
@class SubsChannel;
@class ThreadSummary;
@class MagazineSubsInfo;
@class PeriodicalInfo;
@class PeriodicalLinkInfo;
@class OfflineIssueInfo;
@class PhotoCollectionChannel;
@class PhotoCollection;
@class PhotoData;
@class AdvertisementInfo;
@class UpdatePeriodicalInfo;


@interface PathUtil : NSObject

+ (void)ensureLocalDirsPresent;

//数据库文件路径
+ (NSString *)surfDbFilePath;

//document文件夹路径
+ (NSString *)documentsPath;

//获取main bundle根目录中名称为@name的资源的路径
+ (NSString *)pathOfResourceNamed:(NSString*)name;

//获取main bundle下指定目录中名称为@name的资源的路径
+ (NSString *)pathOfResourceNamed:(NSString *)name inBundleDir:(NSString*)dir;

+ (NSString*)rootPathOfHotChannels;
+ (NSString*)rootPathOfMoreViewVC;
+ (NSString*)rootPathOfSubsChannels;
+ (NSString*)rootPathOfFavs;
+ (NSString*)rootPathOfOfflines;
+ (NSString*)rootPathOfNewest;
+ (NSString*)rootPathOfUser;
+ (NSString*)rootPathOfPhoneNews;
+ (NSString*)rootPathOfMagazines;
+ (NSString*)rootPathOfOthers;
+ (NSString*)rootPathOfPhotoCollection;
+ (NSString*)rootPathOfNotiFidir;
+ (NSString*)rootPathOfAdvertisementDir;    // 保存广告信息目录

//最新本地文件缓存列表
+ (NSString*)listPathOfNewestList;
//最新新闻显示列表
//+ (NSString*)pathOfHotChannelIsNew;
//用户选中信息文件路径
+ (NSString*)pathOfHotChannelSelected;
//用户选中更多控件路径
+ (NSString*)pathOfHotChannelSelectedMoreVC;
//热推频道排序文件路径
+ (NSString*)pathOfHotChannelSortInfo;
//订阅频道排序文件路径
+ (NSString*)pathOfSubsChannelSortInfo;
//用户订阅频道排序文件路径
+ (NSString*)pathOfUserSubsChannelSortInfo:(NSString *)userId;
//订阅期刊排序文件路径
+ (NSString*)pathOfMagazineSortInfo;
//用户订阅期刊排序文件路径
+ (NSString*)pathOfUserMagazineSortInfo:(NSString *)userId;

//用户信息列表
+ (NSString*)pathOfUserInfo;

// 手机报列表
+ (NSString*)pathOfPhoneNewsList:(NSString*)userId;
+ (NSString*)dirOfPhoneNewsCover;    // 手机报封面路径
+ (NSString*)dirOfPhoneNewsZip;      // 手机报Zip包路径

//热推频道文件夹
//形如：Doc/HotChannels/12345/
+ (NSString*)pathOfHotChannel:(HotChannel*)channel;
+ (NSString*)pathOfHotChannelId:(long)channelId;
//热推频道信息文件路径
+ (NSString*)pathOfHotChannelInfo:(HotChannel*)channel;
+ (NSString*)pathOfHotChannelInfoWithChannelId:(long)channelId;
+ (NSString*)pathOfHotIconDir; // 热推频道热点图标

//用户订阅频道文件夹
//形如：Doc/SubsChannels/23456/
+ (NSString*)pathOfSubsChannel:(SubsChannel*)channel;
//用户订阅频道信息文件路径
+ (NSString*)pathOfSubsChannelInfo:(SubsChannel*)channel;
+ (NSString*)pathOfSubsChannelInfoWithChannelId:(long)channelId;
//用户订阅频道logo文件路径
+ (NSString*)pathOfSubsChannelLogo:(SubsChannel*)channel;
//用户订阅频道最新更新图片文件名
//格式如下：[threadid].latest
//返回nil表示不存在最新更新图片文件
+ (NSString*)nameOfSubsChannelLatestImage:(SubsChannel*)channel;

//帖子文件夹
//.../[channelid]/[threadid]/
//形如：
//Doc/HotChannels/12345/80901/
//Doc/SubsChannels/23456/78789/
+ (NSString*)pathOfThread:(ThreadSummary*)thread;
//帖子信息文件路径
+ (NSString*)pathOfThreadInfo:(ThreadSummary*)thread;
+ (NSString*)pathOfThreadInfoWithThreadId:(long)threadId inHotChannel:(HotChannel*)channel;
+ (NSString*)pathOfThreadInfoWithThreadId:(long)threadId inSubsChannel:(SubsChannel *)channel;
+ (NSString*)pathOfThreadInfoWithThreadId:(long)threadId inChannelId:(long)channelId;
//帖子正文文件路径
+ (NSString*)pathOfThreadContent:(ThreadSummary*)thread;
//帖子logo路径
//注意：
//对于大图帖，这个logo即为banner图
//对于普通帖，这个logo即为预览图
+ (NSString*)pathOfThreadLogo:(ThreadSummary*)thread;

// 新闻列表中得多图新闻的图片路径（multiImg）
+ (NSString*)pathOfThreadMultiLogo:(ThreadSummary*)thread atImageIndex:(NSUInteger)imgIdex;

//帖子正文图片映射文件
+ (NSString*)pathOfThreadImageMapping:(ThreadSummary*)thread;

//期刊文件夹
//形如：Doc/Magazines/34567/
+ (NSString*)pathOfMagazine:(MagazineSubsInfo*)magazine;
//热推频道信息文件路径
+ (NSString*)pathOfMagazineId:(long)magazineId;
+ (NSString*)pathOfMagazineInfo:(MagazineSubsInfo*)magazine;
+ (NSString*)pathOfMagazineServerTime:(long)magazineId;
+ (NSString*)pathOfMagazineInfoWithMagazineId:(long)magazineId;
+ (NSString*)pathOfMagazineLogoWithMagazineId:(long)magazineId;
+ (NSString*)pathOfPeriodical:(PeriodicalInfo*)periodical;
+ (NSString*)pathOfPeriodicalInfo:(PeriodicalInfo*)periodical;
+ (NSString*)pathOfUpdatePeriodicalInfo:(UpdatePeriodicalInfo*)periodical;
+ (NSString*)pathOfPeriodicalWithPeriodicalId:(long)periodicalId inMagazineId:(long)magazineId;
+ (NSString*)pathOfPeriodicalInfoWithPeriodicalId:(long)periodicalId inMagazineId:(long)magazineId;
+ (NSString*)pathOfUpdatePeriodicalInfoWithMagazineId:(long)magazineId;
+ (NSString*)pathOfPeriodicalContentIndexWithPeriodicalId:(long)periodicalId inMagazineId:(long)magazineId;
+ (NSString*)pathOfPeriodicalLogo:(PeriodicalInfo*)periodical;
+ (NSString*)pathOfUpdatePeriodical:(UpdatePeriodicalInfo*)up;
+ (NSString*)pathOfUpdatePeriodicalImage:(UpdatePeriodicalInfo*)up;
+ (NSString*)pathOfUpdatePeriodicalImageInMagezine:(long)magazineId periodical:(long)periodicalId imageURL:(NSString*)url;
+ (NSString*)pathOfPeriodicalMappingWithPeriodicalId:(long)periodicalId inMagazineId:(long)magazineId;
+ (NSString*)pathOfPeriodicalContentWithLinkInfo:(PeriodicalLinkInfo *)linfo;

//动态更新的闪屏图的路径
+ (NSString*)pathOfSplashNewsImage; //支持跳转协议的新版闪屏图
+ (NSString*)pathOfSplashDataFile;  //闪屏协议数据，用于每次更新时的比对

//期刊离线包
+ (NSString*)pathOfOfflineMagazine;
+ (NSString*)pathOfOfflineMagazineInfo;
+ (NSString*)pathOfOfflineDataForIssue:(OfflineIssueInfo*)issues;
+ (NSString*)pathOfflinesOfMagazineId:(long)magazineId;
+ (NSString*)pathOfflinesOfPeriodicalWithPeriodicalId:(long)periodicalId inMagazineId:(long)magazineId;
+ (NSString*)pathOfflinesOfPeriodicalIndexWithPeriodicalId:(long)periodicalId inMagazineId:(long)magazineId;


// 图集路径
//形如：Doc/PhotoCollection/12345/
+ (NSString*)pathOfPhotoCollectionChannel:(PhotoCollectionChannel*)channel;
+ (NSString*)pathOfPhotoCollectionChannelListInfo;
+ (NSString*)pathOfPhotoCollectionChannelSortInfo;// 图集频道列表排序路径
+ (NSString*)pathOfPhotoCollectionChannelLocalInfo:(u_long)pccId;


+ (NSString*)pathOfPhotoCollection:(PhotoCollection*)pcInfo;
//+ (NSString*)pathOfPhotoCollectionWithPCId:(long)pcId;
+ (NSString*)pathOfPhotoCollectionInfo:(PhotoCollection*)pcInfo;
+ (NSString*)pathOfPhotoCollectionInfoWithId:(u_long)pccId photoCollectionId:(u_long)pcId;
+ (NSString*)pathOfPhotoCollectionIcon:(PhotoCollection*)pc;// 封面路径
+ (NSString*)pathOfPhotoCollectionContentInfo:(PhotoCollection*)pcInfo;// 图集内容文件
+ (NSString*)pathOfPhotoCollectionTempFolderWithId:(u_long)pccId;// 图集临时文件夹

+ (NSString*)pathOfPhotoDataImage:(PhotoData*)pd;

// 广告
+ (NSString*)pathOfAdvertisementInfo;
+ (NSString*)pathOfAdvertisementImage:(AdvertisementInfo*)adInfo;

// 正负能量日，周排行榜
+ (NSString*)pathOfDayRankingList;
+ (NSString*)PathOfWeekRankingList;

//城市列表
+ (NSString *)pathOfCityRssList;

//头像路径
+ (NSString *)pathUserHeadPic;

// 发现-》搜索-》搜索历史记录
+(NSString*)pathOfSearchHistory;

@end
