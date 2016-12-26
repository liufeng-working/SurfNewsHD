//
//  PathUtil.m
//  SurfNews
//
//  Created by apple on 12-11-1.
//
//

#import "PathUtil.h"
#import "FileUtil.h"
#import "HotChannelsListResponse.h"
#import "SubsChannelsListResponse.h"
#import "GetMagazineSubsResponse.h"
#import "GetPeriodicalListResponse.h"
#import "ThreadSummary.h"
#import "SubsChannelsManager.h"
#import "MagazineManager.h"
#import "UpdateSplashResponse.h"
#import "OfflineIssueInfo.h"
#import "PhotoCollectionData.h"
#import "AdvertisementManager.h"
#import "RankingInfoResponse.h"

static NSString* DOCPATH = nil;
#define HotChannelsDir @"HotChannels"
#define SubsChannelsDir @"SubsChannels"
#define FavsDir @"Favs"
#define OfflinesDir @"Offlines"
#define NewestDir @"Newest"
#define UserDir @"User"
#define PhoneNew @"PhoneNew" //手机报
#define Magazine @"Magazine"
#define OthersDir @"Others"
#define PhotoCollectionDir @"PhotoCollection"   // 图集路径
#define HotIcon @"hotIcon"                      // 新闻列表中热点图标
#define NotifiDir @"NotifiDir"                  // 推送文件夹
#define AdvertisementDir @"Advertisement"       // 广告文件夹

#import "PeriodicalHtmlResolving.h"

@implementation PathUtil

+ (void)ensureLocalDirsPresent
{
    NSFileManager* fm = [NSFileManager defaultManager];
    
    NSString* dir0 = [[self documentsPath] stringByAppendingPathComponent:HotChannelsDir];
    NSString* dir1 = [[self documentsPath] stringByAppendingPathComponent:SubsChannelsDir];
    NSString* dir2 = [[self documentsPath] stringByAppendingPathComponent:FavsDir];
    NSString* dir3 = [[self documentsPath] stringByAppendingPathComponent:OfflinesDir];
    NSString* dir4 = [[self documentsPath] stringByAppendingPathComponent:NewestDir];
    NSString* dir5 = [[self documentsPath] stringByAppendingPathComponent:UserDir];
    NSString* dir6 = [[self documentsPath] stringByAppendingPathComponent:PhoneNew];
    NSString* dir7 = [[self documentsPath] stringByAppendingPathComponent:Magazine];
    NSString* dir8 = [[self documentsPath] stringByAppendingPathComponent:OthersDir];
    NSString* dir9 = [[self documentsPath] stringByAppendingPathComponent:PhotoCollectionDir];
    NSString* dir10 = [[self documentsPath] stringByAppendingPathComponent:HotIcon];
    NSString* dir11 = [[self documentsPath] stringByAppendingPathComponent:AdvertisementDir];
    
    [fm createDirectoryAtPath:dir0 withIntermediateDirectories:NO attributes:nil error:nil];
    [fm createDirectoryAtPath:dir1 withIntermediateDirectories:NO attributes:nil error:nil];
    [fm createDirectoryAtPath:dir2 withIntermediateDirectories:NO attributes:nil error:nil];
    [fm createDirectoryAtPath:dir3 withIntermediateDirectories:NO attributes:nil error:nil];
    [fm createDirectoryAtPath:dir4 withIntermediateDirectories:NO attributes:nil error:nil];
    [fm createDirectoryAtPath:dir5 withIntermediateDirectories:NO attributes:nil error:nil];
    [fm createDirectoryAtPath:dir6 withIntermediateDirectories:NO attributes:nil error:nil];
    [fm createDirectoryAtPath:dir7 withIntermediateDirectories:NO attributes:nil error:nil];
    [fm createDirectoryAtPath:dir8 withIntermediateDirectories:NO attributes:nil error:nil];
    [fm createDirectoryAtPath:dir9 withIntermediateDirectories:NO attributes:nil error:nil];
    [fm createDirectoryAtPath:dir10 withIntermediateDirectories:NO attributes:nil error:nil];
    [fm createDirectoryAtPath:dir11 withIntermediateDirectories:NO attributes:nil error:nil];
    //
    [fm createDirectoryAtPath:[self dirOfPhoneNewsCover] withIntermediateDirectories:YES attributes:nil error:nil];
    [fm createDirectoryAtPath:[self dirOfPhoneNewsZip] withIntermediateDirectories:YES attributes:nil error:nil];
    
    //DO NOT BACKUP
    [FileUtil addSkipBackupAttributeForPath:[self documentsPath]];  //保险起见，把documents根目录也设为DO NOT BACKUP
    [FileUtil addSkipBackupAttributeForPath:dir0];
    [FileUtil addSkipBackupAttributeForPath:dir1];
    [FileUtil addSkipBackupAttributeForPath:dir2];
    [FileUtil addSkipBackupAttributeForPath:dir3];
    [FileUtil addSkipBackupAttributeForPath:dir4];
    [FileUtil addSkipBackupAttributeForPath:dir5];
    [FileUtil addSkipBackupAttributeForPath:dir6];
    [FileUtil addSkipBackupAttributeForPath:dir7];
    [FileUtil addSkipBackupAttributeForPath:dir8];
    [FileUtil addSkipBackupAttributeForPath:dir9];
    [FileUtil addSkipBackupAttributeForPath:dir10];
    [FileUtil addSkipBackupAttributeForPath:dir11];
}

+ (NSString *)surfDbFilePath
{
    return [[self documentsPath] stringByAppendingPathComponent:@"SurfNewsDb.db"];
}

+ (NSString *)documentsPath
{
    if(!DOCPATH)
    {
        DOCPATH = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    }
    return DOCPATH;
}

+ (NSString *)pathOfResourceNamed:(NSString*)name
{
    return [[NSBundle mainBundle] pathForResource:[[name lastPathComponent] stringByDeletingPathExtension] ofType:[name pathExtension]];
}

+ (NSString *)pathOfResourceNamed:(NSString *)name inBundleDir:(NSString*)dir
{
    return [[NSBundle mainBundle] pathForResource:[[name lastPathComponent] stringByDeletingPathExtension] ofType:[name pathExtension] inDirectory:dir];
}

+ (NSString*)rootPathOfHotChannels
{
    return [[self documentsPath] stringByAppendingPathComponent:HotChannelsDir];
}

+ (NSString*)rootPathOfMoreViewVC
{
    return [[self documentsPath] stringByAppendingPathComponent:HotChannelsDir];
}

+ (NSString*)rootPathOfSubsChannels
{
    return [[self documentsPath] stringByAppendingPathComponent:SubsChannelsDir];
}

+ (NSString*)rootPathOfFavs
{
    return [[self documentsPath] stringByAppendingPathComponent:FavsDir];
}

+ (NSString*)rootPathOfOfflines
{
    return [[self documentsPath] stringByAppendingPathComponent:OfflinesDir];
}
+ (NSString*)rootPathOfNewest
{
    return [[self documentsPath] stringByAppendingPathComponent:NewestDir];
}
+ (NSString*)rootPathOfUser
{
    return [[self documentsPath] stringByAppendingPathComponent:UserDir];
}
+ (NSString*)rootPathOfPhoneNews
{
     return [[self documentsPath] stringByAppendingPathComponent:PhoneNew];
}
+ (NSString*)rootPathOfMagazines
{
    return [[self documentsPath] stringByAppendingPathComponent:Magazine];
}
+ (NSString*)rootPathOfOthers
{
    return [[self documentsPath] stringByAppendingPathComponent:OthersDir];
}
+ (NSString*)rootPathOfPhotoCollection
{
    return [[self documentsPath] stringByAppendingPathComponent:PhotoCollectionDir];
}
+ (NSString*)rootPathOfNotiFidir{
    return [[self documentsPath] stringByAppendingPathComponent:NotifiDir];
}
+ (NSString*)rootPathOfAdvertisementDir
{
     return [[self documentsPath] stringByAppendingPathComponent:AdvertisementDir];
}

+ (NSString*)listPathOfNewestList
{
    return [[PathUtil rootPathOfNewest] stringByAppendingPathComponent:@"newestInfo.txt"];
}
//+ (NSString*)pathOfHotChannelIsNew
//{
//    return [[self rootPathOfHotChannels] stringByAppendingPathComponent:@"isnew.txt"];
//}
//以后红点部分统一整合 modify by jsg
+ (NSString*)pathOfHotChannelSelected
{
    return [[self rootPathOfHotChannels] stringByAppendingPathComponent:@"selected.txt"];
}
+ (NSString*)pathOfHotChannelSelectedMoreVC
{
    return [[self rootPathOfMoreViewVC] stringByAppendingPathComponent:@"selectedMoreVC.txt"];
}
+ (NSString*)pathOfHotChannelSortInfo
{
    return [[self rootPathOfHotChannels] stringByAppendingPathComponent:@"sortinfo.txt"];
}
+ (NSString*)pathOfSubsChannelSortInfo
{
    return [[self rootPathOfSubsChannels] stringByAppendingPathComponent:@"sortinfo.txt"];
}
+ (NSString*)pathOfUserSubsChannelSortInfo:(NSString *)userId
{
    return [[self rootPathOfSubsChannels] stringByAppendingPathComponent:
            [NSString stringWithFormat:@"sortinfo_%@.txt",userId]];
}
+ (NSString*)pathOfMagazineSortInfo
{
    return [[self rootPathOfMagazines] stringByAppendingPathComponent:@"sortinfo.txt"];
}
+ (NSString*)pathOfUserMagazineSortInfo:(NSString *)userId
{
    return [[self rootPathOfMagazines] stringByAppendingPathComponent:
            [NSString stringWithFormat:@"sortinfo_%@.txt",userId]];
}
+ (NSString*)pathOfUserInfo
{
    return [[self rootPathOfUser] stringByAppendingPathComponent:@"userinfo.txt"];
}

+ (NSString *)pathUserHeadPic{
    return [[self rootPathOfUser] stringByAppendingPathComponent:@"headPic.png"];
}

+ (NSString*)pathOfPhoneNewsList:(NSString*)userId{
    return [[self rootPathOfPhoneNews] stringByAppendingPathComponent:
            [NSString stringWithFormat:@"newsList_%@.txt",userId]];
}
+ (NSString*)dirOfPhoneNewsCover{
    return [[self rootPathOfPhoneNews] stringByAppendingPathComponent:@"/Cover"];;
}
// 手机报Zip包路径
+ (NSString*)dirOfPhoneNewsZip{
    return [[self rootPathOfPhoneNews] stringByAppendingPathComponent:@"/newsZip"];
}

+ (NSString*)pathOfHotChannel:(HotChannel*)channel
{
    return [self pathOfHotChannelId:channel.channelId];
}

+ (NSString*)pathOfHotChannelId:(long)channelId
{
    return [[self rootPathOfHotChannels] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",channelId]];
}

+ (NSString*)pathOfHotChannelInfo:(HotChannel *)channel
{
    return [[self pathOfHotChannel:channel] stringByAppendingPathComponent:@"info.txt"];
}

+ (NSString*)pathOfHotChannelInfoWithChannelId:(long)channelId
{
    return [[[self rootPathOfHotChannels] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",channelId]] stringByAppendingPathComponent:@"info.txt"];
}
// 热推频道热点图标
+ (NSString*)pathOfHotIconDir
{
    return [[self documentsPath] stringByAppendingPathComponent:HotIcon];
}

+ (NSString*)pathOfSubsChannel:(SubsChannel*)channel
{
    return [self pathOfSubsChannelId:channel.channelId];
}

+ (NSString*)pathOfSubsChannelInfo:(SubsChannel*)channel
{
    return [[self pathOfSubsChannel:channel] stringByAppendingPathComponent:@"info.txt"];
}

+ (NSString*)pathOfSubsChannelInfoWithChannelId:(long)channelId
{
    return [[[self rootPathOfSubsChannels] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",channelId]] stringByAppendingPathComponent:@"info.txt"];
}

+ (NSString*)pathOfSubsChannelLogo:(SubsChannel*)channel
{
    //已订阅频道
    if([[SubsChannelsManager sharedInstance] isChannelSubscribed:channel.channelId])
        return [[self pathOfSubsChannel:channel] stringByAppendingPathComponent:@"logo.img"];
    else    //未订阅的频道，返回临时路径
        return [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.img",channel.channelId]];
        
}

+ (NSString*)nameOfSubsChannelLatestImage:(SubsChannel*)channel
{
    //[threadid].latest
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator* enumerator = [fm enumeratorAtPath:[self pathOfSubsChannel:channel]];
    
    NSString* name = nil;
    while (name = [enumerator nextObject])
    {
        [enumerator skipDescendants];
        if([name hasSuffix:@".latest"])
            return name;
    }
    return nil;
}

+ (NSString*)pathOfSubsChannelId:(long)channelId
{
    return [[self rootPathOfSubsChannels] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",channelId]];
}

+ (NSString*)pathOfNotifiId:(long)channelId
{
    return [[self rootPathOfNotiFidir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%ld",HotChannelsDir,channelId]];
}


+ (NSString*)pathOfThread:(ThreadSummary*)thread
{
    /*if([thread isMemberOfClass:[OfflineThreadSummary class]])   //离线帖
    {
        return [[self rootPathOfOfflines] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%ld/%ld",thread.channelId,thread.threadId]];
    }
    else */if([thread isMemberOfClass:[FavThreadSummary class]])  //收藏帖
    {
        FavThreadSummary* t = (FavThreadSummary*)thread;
        NSDateFormatter* df = [NSDateFormatter new];
        [df setDateFormat:@"yyyyMMddHmmss"];
        return [[self rootPathOfFavs] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@",@(thread.channelId),@(thread.threadId),[df stringFromDate:[NSDate dateWithTimeIntervalSince1970:t.creationDate / 1000.0]]]];
    }
    else if([thread isMemberOfClass:[SplashNewsThreadSummary class]])
    {
        return [[self rootPathOfOthers] stringByAppendingPathComponent:@"newsthread"];
    }
    else    //普通帖
    {
        if(HotChannelThread==thread.threadM)
        {
            return [[self pathOfHotChannelId:thread.channelId] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",@(thread.threadId)]];
        }
        else if(SubChannelThread==thread.threadM)
        {
            return [[self pathOfSubsChannelId:thread.channelId] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",@(thread.threadId)]];
        }
        else
        {
            return [[self pathOfSubsChannelId:thread.channelId] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",@(thread.threadId)]];
        }
    }
}

+ (NSString*)pathOfThreadInfo:(ThreadSummary*)thread
{
    return [[self pathOfThread:thread] stringByAppendingPathComponent:@"info.txt"];
}

+ (NSString*)pathOfThreadInfoWithThreadId:(long)threadId inHotChannel:(HotChannel*)channel
{
    return [[[self pathOfHotChannel:channel] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",threadId]] stringByAppendingPathComponent:@"info.txt"];
}

+ (NSString*)pathOfThreadInfoWithThreadId:(long)threadId inSubsChannel:(SubsChannel *)channel
{
    return [[[self pathOfSubsChannel:channel] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",threadId]] stringByAppendingPathComponent:@"info.txt"];
}
+ (NSString*)pathOfThreadInfoWithThreadId:(long)threadId inChannelId:(long)channelId
{
    return [[[self pathOfSubsChannelId:channelId] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",threadId]]stringByAppendingPathComponent:@"info.txt" ];
}
+ (NSString*)pathOfThreadContent:(ThreadSummary*)thread
{
    return [[self pathOfThread:thread] stringByAppendingPathComponent:@"content.txt"];
}

+ (NSString*)pathOfThreadLogo:(ThreadSummary*)thread
{
    return [[self pathOfThread:thread] stringByAppendingPathComponent:@"logo.img"];
}
+ (NSString*)pathOfThreadMultiLogo:(ThreadSummary*)thread
                      atImageIndex:(NSUInteger)imgIdex
{
    return [[self pathOfThread:thread] stringByAppendingPathComponent:[NSString stringWithFormat:@"logo_multi_%@.img", @(imgIdex)]];
}

+ (NSString*)pathOfThreadImageMapping:(ThreadSummary*)thread
{
    return [[self pathOfThread:thread] stringByAppendingPathComponent:@"imgmapping.txt"];
}

+ (NSString*)pathOfMagazine:(MagazineSubsInfo*)magazine
{
    return [self pathOfMagazineId:magazine.magazineId];
}

+ (NSString*)pathOfMagazineId:(long)magazineId
{
    return [[self rootPathOfMagazines] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",magazineId]];
}

+ (NSString*)pathOfMagazineInfo:(MagazineSubsInfo*)magazine
{
    return [[self pathOfMagazine:magazine] stringByAppendingPathComponent:@"info.txt"];
}

+ (NSString*)pathOfMagazineServerTime:(long)magazineId
{
    return [[self pathOfMagazineId:magazineId] stringByAppendingPathComponent:@"serverTime.txt"];
}

+ (NSString*)pathOfMagazineInfoWithMagazineId:(long)magazineId
{
    return [[[self rootPathOfMagazines] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",magazineId]] stringByAppendingPathComponent:@"info.txt"];
}

+ (NSString*)pathOfMagazineServerTimeWithChannelId:(long)magazineId
{
    return [[[self rootPathOfMagazines] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",magazineId]] stringByAppendingPathComponent:@"info.txt"];
}

+ (NSString*)pathOfMagazineLogoWithMagazineId:(long)magazineId
{
    //已订阅期刊
    if([[MagazineManager sharedInstance] isMagazineSubscribed:magazineId])
        return [[self pathOfMagazineId:magazineId] stringByAppendingPathComponent:@"logo.img"];
    else    //未订阅的期刊,返回临时路径
        return [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.img",magazineId]];
}

+ (NSString*)pathOfPeriodical:(PeriodicalInfo*)periodical
{
    return [self pathOfPeriodicalWithPeriodicalId:periodical.periodicalId inMagazineId:periodical.magazineId];
}

+ (NSString*)pathOfPeriodicalInfo:(PeriodicalInfo*)periodical
{
    return [self pathOfPeriodicalInfoWithPeriodicalId:periodical.periodicalId inMagazineId:periodical.magazineId];
}

+ (NSString*)pathOfUpdatePeriodicalInfo:(UpdatePeriodicalInfo*)periodical
{
    return [self pathOfUpdatePeriodicalInfoWithMagazineId:periodical.magazineId];
}

+ (NSString*)pathOfPeriodicalWithPeriodicalId:(long)periodicalId inMagazineId:(long)magazineId
{
    return [[self pathOfMagazineId:magazineId] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",periodicalId]];
}

+ (NSString*)pathOfPeriodicalInfoWithPeriodicalId:(long)periodicalId inMagazineId:(long)magazineId
{
    return [[[self pathOfMagazineId:magazineId] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",periodicalId]]stringByAppendingPathComponent:@"info.txt" ];
}

+ (NSString*)pathOfUpdatePeriodicalInfoWithMagazineId:(long)magazineId
{
    return [[self pathOfMagazineId:magazineId] stringByAppendingPathComponent:@"updateInfo.txt"];
}

+ (NSString*)pathOfPeriodicalContentIndexWithPeriodicalId:(long)periodicalId inMagazineId:(long)magazineId
{
    return [[[self pathOfMagazineId:magazineId] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",periodicalId]]stringByAppendingPathComponent:@"index.txt" ];
}
+ (NSString*)pathOfPeriodicalMappingWithPeriodicalId:(long)periodicalId inMagazineId:(long)magazineId
{
    return [[[self pathOfMagazineId:magazineId] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",periodicalId]]stringByAppendingPathComponent:@"linkmapping.txt" ];
}
+ (NSString*)pathOfPeriodicalContentWithLinkInfo:(PeriodicalLinkInfo *)info
{
    return [[self pathOfPeriodicalWithPeriodicalId:info.periodicalId inMagazineId:info.magazineId] stringByAppendingPathComponent:[NSString stringWithFormat:@"article%@",info.linkId]];
}

+ (NSString*)pathOfPeriodicalLogo:(PeriodicalInfo*)periodical
{
    //已订阅期刊
    if([[MagazineManager sharedInstance] isMagazineSubscribed:periodical.magazineId])
        return [[self pathOfPeriodical:periodical] stringByAppendingPathComponent:@"logo.img"];
    else    //未订阅的期刊,返回临时路径
        return [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.img",periodical.periodicalId]];
}

+ (NSString*)pathOfUpdatePeriodical:(UpdatePeriodicalInfo*)up
{
    PeriodicalInfo *info;
    if (up.periods) {
        info = up.periods[0];
    }
    return [self pathOfPeriodicalWithPeriodicalId:info.periodicalId inMagazineId:up.magazineId];
}

+ (NSString*)pathOfUpdatePeriodicalImage:(UpdatePeriodicalInfo*)up
{
    PeriodicalInfo *info;
    PeriodicalHeadInfo *head;
    if (up.periods) {
        info = up.periods[0];
        head = (PeriodicalHeadInfo *)info.head;
    }
    return [self pathOfUpdatePeriodicalImageInMagezine:up.magazineId periodical:info.periodicalId imageURL:head.iconViewPath];
}

+ (NSString*)pathOfUpdatePeriodicalImageInMagezine:(long)magazineId periodical:(long)periodicalId imageURL:(NSString*)url
{
    //已订阅期刊
    if([[MagazineManager sharedInstance] isMagazineSubscribed:magazineId])
        return [[self pathOfPeriodicalWithPeriodicalId:periodicalId inMagazineId:magazineId] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.img", @([url hash])]];
    else    //未订阅的期刊,返回临时路径
        return [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.img",@([url hash])]];
}

+ (NSString*)pathOfSplashNewsImage
{
    return [[self rootPathOfOthers] stringByAppendingPathComponent:@"newssplash"];
}
+ (NSString*)pathOfSplashDataFile
{
    return [[self rootPathOfOthers] stringByAppendingPathComponent:@"splashdata"];
}

#pragma mark - 离线
+ (NSString*)pathOfOfflineMagazine
{
    return [[self rootPathOfOfflines] stringByAppendingPathComponent:Magazine];
}

+ (NSString*)pathOfOfflineMagazineInfo
{
    return [[self pathOfOfflineMagazine] stringByAppendingPathComponent:@"info.txt"];
}

+ (NSString*)pathOfOfflineDataForIssue:(OfflineIssueInfo*)issues
{
    return [[[self pathOfOfflineMagazine] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld", issues.magId]]stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld", issues.issId]];
}

+ (NSString*)pathOfflinesOfMagazineId:(long)magazineId
{
    return [[self pathOfOfflineMagazine]
            stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",magazineId]];
}

+ (NSString*)pathOfflinesOfPeriodicalWithPeriodicalId:(long)periodicalId
                                         inMagazineId:(long)magazineId
{
    return [[self pathOfflinesOfMagazineId:magazineId]stringByAppendingPathComponent:
            [NSString stringWithFormat:@"%ld",periodicalId]];
}

+ (NSString*)pathOfflinesOfPeriodicalIndexWithPeriodicalId:(long)periodicalId
                                              inMagazineId:(long)magazineId
{
    return [[self pathOfflinesOfPeriodicalWithPeriodicalId:periodicalId inMagazineId:magazineId]
            stringByAppendingPathComponent:@"index.xml"];
}

#pragma mark 图集频道列表
+ (NSString*)pathOfPhotoCollectionChannel:(PhotoCollectionChannel*)pccInfo{
    NSString *cidStr = [NSString stringWithFormat:@"%ld",pccInfo.cid];
    return [[self rootPathOfPhotoCollection] stringByAppendingPathComponent:cidStr];
}
+ (NSString*)pathOfPhotoCollectionChannelListInfo{
    return [[self rootPathOfPhotoCollection] stringByAppendingPathComponent:@"info.txt"];
}
+ (NSString*)pathOfPhotoCollectionChannelSortInfo
{
    return [[self rootPathOfPhotoCollection] stringByAppendingPathComponent:@"sortinfo.txt"];
}
+ (NSString*)pathOfPhotoCollectionChannelLocalInfo:(u_long)pccId{
    NSString *str = [NSString stringWithFormat:@"%ld/localInfo.txt", pccId];
    return [[self rootPathOfPhotoCollection] stringByAppendingPathComponent:str];
}

// 图集路径
+ (NSString*)pathOfPhotoCollection:(PhotoCollection*)pcInfo
{
    NSString *cidStr = [NSString stringWithFormat:@"%ld/%ld",pcInfo.coid, pcInfo.pcId];
    return [[self rootPathOfPhotoCollection] stringByAppendingPathComponent:cidStr];
}
//+ (NSString*)pathOfPhotoCollectionWithPCId:(long)pcId
//{
//    return [[self rootPathOfPhotoCollection] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",pcId]];
//}
// 图集信息文件路径
+ (NSString*)pathOfPhotoCollectionInfo:(PhotoCollection*)pcInfo
{
    return [self pathOfPhotoCollectionInfoWithId:pcInfo.coid photoCollectionId:pcInfo.pcId];
}
+ (NSString*)pathOfPhotoCollectionInfoWithId:(u_long)pccId photoCollectionId:(u_long)pcId
{
    NSString *cidStr = [NSString stringWithFormat:@"%ld/%ld/info.txt",pccId, pcId];
    return [[self rootPathOfPhotoCollection] stringByAppendingPathComponent:cidStr];
}

+ (NSString*)pathOfPhotoCollectionIcon:(PhotoCollection*)pc
{
    if (pc.isTempData) {
        NSString *tempDir = [self pathOfPhotoCollectionTempFolderWithId:pc.coid];
        NSString *iconName = [NSString stringWithFormat:@"%ld_icon.img",pc.pcId];
        return [tempDir stringByAppendingPathComponent:iconName];
    }
    return [[self pathOfPhotoCollection:pc] stringByAppendingPathComponent:@"icon.img"];
}
// 图集内容文件
+ (NSString*)pathOfPhotoCollectionContentInfo:(PhotoCollection*)pcInfo
{
    NSString *cidStr = [NSString stringWithFormat:@"%ld/%ld/content.txt",pcInfo.coid, pcInfo.pcId];
    return [[self rootPathOfPhotoCollection] stringByAppendingPathComponent:cidStr];
}
// 图集临时文件夹
+ (NSString*)pathOfPhotoCollectionTempFolderWithId:(u_long)pccId
{
    NSString *cidStr = [NSString stringWithFormat:@"%ld/tempFolder",pccId];
    return [[self rootPathOfPhotoCollection] stringByAppendingPathComponent:cidStr];
}



+ (NSString*)pathOfPhotoDataImage:(PhotoData*)pd
{
    if ([pd isCacheData]) {
        NSString *tempFolder = [self pathOfPhotoCollectionTempFolderWithId:pd.coid];
        NSString *imageName = [NSString stringWithFormat:@"%ld_%ld.img",pd.cover_id,pd.pId];
        return [tempFolder stringByAppendingPathComponent:imageName];
    }

    NSString *cidStr = [NSString stringWithFormat:@"%ld/%ld/%ld.img",pd.coid, pd.cover_id, pd.pId];
    return [[self rootPathOfPhotoCollection] stringByAppendingPathComponent:cidStr];
}

// 广告
+ (NSString*)pathOfAdvertisementInfo
{
    return [[self rootPathOfAdvertisementDir] stringByAppendingPathComponent:@"ad.txt"];
}
+ (NSString*)pathOfAdvertisementImage:(AdvertisementInfo*)adInfo
{
    // 图片命名规则 coid_adId.img
    NSString *imgName = [NSString stringWithFormat:@"%@_%@.img",adInfo.coid, adInfo.adId];
    return [[self rootPathOfAdvertisementDir] stringByAppendingPathComponent:imgName];
}

// 正负能量日，周排行榜
+ (NSString*)pathOfDayRankingList
{
    return [[self rootPathOfOthers] stringByAppendingPathComponent:@"dayRankingList.txt"];
}
+ (NSString*)PathOfWeekRankingList
{
    return [[self rootPathOfOthers] stringByAppendingPathComponent:@"weekRankingList.txt"];
}


+ (NSString *)pathOfCityRssList{
    return [[self rootPathOfOthers] stringByAppendingPathComponent:@"CityRssList.txt"];

}

// 发现-》搜索-》搜索历史记录
+(NSString*)pathOfSearchHistory
{
    return [[self rootPathOfOthers] stringByAppendingPathComponent:@"dis_search_history.txt"];
}

@end
