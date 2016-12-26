//
//  SurfDbManager.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfDbManager.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "PathUtil.h"
#import "ThreadSummary.h"
#import "FileUtil.h"
#import "NSString+Extensions.h"
#import "GetSubsCateResponse.h"
#import "HotChannelsListResponse.h"
#import "SubsChannelsListResponse.h"
#import "NewsCommentModel.h"

/*
//sqlite FAQ:
//http://www.sqlite.org/faq.html
//
//sqlite built-in Datatypes
//http://www.sqlite.org/datatype3.html
//  TEXT-->
        CHARACTER(20)
        VARCHAR(255)
        VARYING CHARACTER(255)
        NCHAR(55)
        NATIVE CHARACTER(70)
        NVARCHAR(100)
        TEXT
        CLOB
//  NUMERIC-->
        NUMERIC
        DECIMAL(10,5)
        BOOLEAN
        DATE
        DATETIME
//  INTEGER-->
        INT
        INTEGER
        TINYINT
        SMALLINT
        MEDIUMINT
        BIGINT
        UNSIGNED BIG INT
        INT2
        INT8
//  REAL-->
        REAL
        DOUBLE
        DOUBLE PRECISION
        FLOAT
//  NONE-->
        BLOB
*/

//数据库版本表名
#define VersionTableName "VersionTable"
//用户信息表名
#define UserTableName "UserTable"
//微博信息表名
#define WeiboTableName "WeiboTable"
//阅读记录表名
#define ReadingHistoryTableName "ReadingHistoryTable"
//赞表名,from db version 1
#define RatingHistoryTableName "RatingHistoryTable"
//流量记录表名
#define DataTransferRecordTableName "DataTransferRecordTable"
//用户操作记录表名
#define UserActionRecordTableName "UserActionRecordTable"
// 新闻评论点赞记录表名
#define NewsCommentPraiseTableName "NewsCommentPraiseTable"

//中国移动微博表字段标识
#define ChinaMobileProvider 0
//新浪微博表字段标识
#define SinaProvider 1
//腾讯微博表字段标识
#define TencentProvider 2
//人人网表字段标识
#define RenrenProvider 3

@implementation NSString (SqlEscape)

-(NSString*)escapeStringForSql
{
    return [self stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
}

@end


@implementation SurfDbManager(private)

//初始化surfdb，确保db可用
-(void)initDb
{
    NSString* expectedDbFilePath = [PathUtil surfDbFilePath];
    NSFileManager* fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:expectedDbFilePath]
       && [FileUtil fileSizeAtPath:expectedDbFilePath] > 0)
    {
        //db文件存在，尝试用fmdb打开
        fmdb_ = [FMDatabase databaseWithPath:expectedDbFilePath];
        if([fmdb_ open])
        {
            //检测是否需要更新数据库
            [self updateDbIfNecessary];
        }
        else
        {
            //TODO
            //数据库文件损坏？被篡改？
            
            //直接删除
            [[NSFileManager defaultManager] removeItemAtPath:expectedDbFilePath error:nil];
            
            [fmdb_ open];
            [self createTables];
            
            [initDelegate_ dbHasBeenRecoveredFromCurruption];
        }
    }
    else
    {
        //直接创建新数据库
        fmdb_ = [FMDatabase databaseWithPath:expectedDbFilePath];
        
        //增加Do Not Backup属性
        [FileUtil addSkipBackupAttributeForPath:expectedDbFilePath];
        
        [fmdb_ open];
        
        //建表
        [self createTables];
    }
    
}

//检测surfdb是否是最新版
//如果是旧版，需要执行更新操作
-(void)updateDbIfNecessary
{
    //打开VersionTable，查看数据库版本，作相应的更新操作
    FMResultSet* result = [fmdb_ executeQuery:@"SELECT db_version FROM VersionTable"];
    if(result != nil && [result next])
    {
        int dbVersion = [result intForColumnIndex:0];
        
        //TODO
        if(dbVersion < 2)
        {
            if (dbVersion < 1) {
                //0-->1
                //增加赞表
                [fmdb_ executeUpdate:@"CREATE TABLE "RatingHistoryTableName" (\
                 thread_id TEXT DEFAULT NULL,\
                 thread_type integer DEFAULT 0,\
                 channel_id TEXT DEFAULT NULL,\
                 title TEXT,\
                 rating_date DOUBLE DEFAULT NULL,\
                 ext_int0 INT DEFAULT 0,\
                 ext_int1 INT DEFAULT 0,\
                 ext_int2 INT DEFAULT 0,\
                 ext_int3 INT DEFAULT 0,\
                 ext_str0 TEXT DEFAULT NULL,\
                 ext_str1 TEXT DEFAULT NULL,\
                 ext_str2 TEXT DEFAULT NULL,\
                 ext_str3 TEXT DEFAULT NULL,\
                 Primary Key(thread_id,channel_id))"];
                [fmdb_ executeUpdate:@"CREATE INDEX index_rating_date \
                 ON "RatingHistoryTableName"(rating_date)"];
            }
            
            if (dbVersion < 2) {
                // 增加新闻评论点赞表
                [self buildNewsCommentTable:fmdb_];
            }
            
            
            //db version升级到2
            [fmdb_ executeUpdate:@"UPDATE VersionTable SET db_version = 2"];
        }
    }
}

-(void)createTables
{
    do
    {
        [fmdb_ beginTransaction];
        
        ////VersionTable
        if(![fmdb_ executeUpdate:@"CREATE TABLE "VersionTableName" (\
         db_version integer DEFAULT 0,\
         server_cate_version integer DEFAULT 0,\
         ext_int0 INT DEFAULT 0,\
         ext_int1 INT DEFAULT 0,\
         ext_str0 TEXT DEFAULT NULL,\
         ext_str1 TEXT DEFAULT NULL)"])
            break;
        //当前db_version版本为1
        //server_cate_version:
        //  服务端的分类列表版本。现在分类列表每次都是全量下发，没有对分类列表进行版本管理。为防止日后出现版本管理，特预留此字段。目前未使用，固定为0
        if(![fmdb_ executeUpdate:@"INSERT INTO "VersionTableName"(db_version,server_cate_version) VALUES(2,0)"])
            break;
        
        ////UserTable
        //用户信息表，设计为支持多用户
        //password需要加密后存入数据库!!!
        //ticket
        //  单点登录票据
        //ticket_expired_date
        //  ticket失效时间。
        if(![fmdb_ executeUpdate:@"CREATE TABLE "UserTableName" (\
         user_id TEXT PRIMARY KEY DEFAULT NULL,\
         user_name TEXT DEFAULT NULL,\
         password TEXT DEFAULT NULL,\
         ticket TEXT DEFAULT NULL,\
         ticket_expired_date DOUBLE DEFAULT 0,\
         phone_number TEXT DEFAULT NULL,\
         phone_location TEXT DEFAULT NULL,\
         email TEXT DEFAULT NULL,\
         ext_int0 INT DEFAULT 0,\
         ext_int1 INT DEFAULT 0,\
         ext_int2 INT DEFAULT 0,\
         ext_int3 INT DEFAULT 0,\
         ext_str0 TEXT DEFAULT NULL,\
         ext_str1 TEXT DEFAULT NULL,\
         ext_str2 TEXT DEFAULT NULL,\
         ext_str3 TEXT DEFAULT NULL)"])
            break;
        
        ////WeiboTable
        //微博信息表
        //account:
        //  微博账号(如果可以获取到，我们需要记录下来)
        //service_provider:
        //  0-chinamobile
        //  1-sina
        //  2-tencent
        //  3-renren 
        //service_version:
        //  标记各微博API自己的版本号，以便日后微博API升级后可以平滑过渡
        //binded_userid:
        //  该微博账号绑定的冲浪用户id
        //account_info:
        //  微博绑定后获取到的用户相关的信息，如果可以获取，我们需要存下来，以备日后所需
        //tencent_open_id:
        //tencent_open_key:
        //  仅用于腾讯微博
        if(![fmdb_ executeUpdate:@"CREATE TABLE "WeiboTableName" (\
             account TEXT DEFAULT NULL,\
             service_provider integer NOT NULL DEFAULT 0,\
             service_version TEXT DEFAULT NULL,\
             binded_userid TEXT DEFAULT NULL,\
             access_token TEXT,\
             access_token_expired_date DOUBLE DEFAULT NULL,\
             refresh_token TEXT DEFAULT NULL,\
             refresh_token_expired_date DOUBLE DEFAULT NULL,\
             account_info TEXT,\
             tencent_open_id TEXT,\
             tencent_open_key TEXT,\
             ext_int0 INT DEFAULT 0,\
             ext_int1 INT DEFAULT 0,\
             ext_str0 TEXT DEFAULT NULL,\
             ext_str1 TEXT DEFAULT NULL)"])
            break;
        
        ////ReadingHistoryTable
        //阅读历史表
        //thread_id:
        //  帖子id
        //thread_type:
        //  帖子类型
        //channel_id:
        //  所属频道id
        //reading_date:
        //  阅读日期
        // ext_int0 扩展参数变成 用户点击的正负能量值
        if(![fmdb_ executeUpdate:@"CREATE TABLE "ReadingHistoryTableName" (\
             thread_id TEXT DEFAULT NULL,\
             thread_type integer DEFAULT 0,\
             channel_id TEXT DEFAULT NULL,\
             title TEXT,\
             reading_date DOUBLE DEFAULT NULL,\
             ext_int0 INT DEFAULT 0,\
             ext_int1 INT DEFAULT 0,\
             ext_int2 INT DEFAULT 0,\
             ext_int3 INT DEFAULT 0,\
             ext_str0 TEXT DEFAULT NULL,\
             ext_str1 TEXT DEFAULT NULL,\
             ext_str2 TEXT DEFAULT NULL,\
             ext_str3 TEXT DEFAULT NULL,\
             Primary Key(thread_id,channel_id))"])
            break;
        if(![fmdb_ executeUpdate:@"CREATE INDEX index_reading_date \
             ON "ReadingHistoryTableName"(reading_date)"])
            break;
        
        
        ////RatingHistoryTable
        //赞表,from db version 1
        //thread_id:
        //  帖子id
        //thread_type:
        //  帖子类型
        //channel_id:
        //  所属频道id
        //rating_date:
        //  阅读日期
        if(![fmdb_ executeUpdate:@"CREATE TABLE "RatingHistoryTableName" (\
             thread_id TEXT DEFAULT NULL,\
             thread_type integer DEFAULT 0,\
             channel_id TEXT DEFAULT NULL,\
             title TEXT,\
             rating_date DOUBLE DEFAULT NULL,\
             ext_int0 INT DEFAULT 0,\
             ext_int1 INT DEFAULT 0,\
             ext_int2 INT DEFAULT 0,\
             ext_int3 INT DEFAULT 0,\
             ext_str0 TEXT DEFAULT NULL,\
             ext_str1 TEXT DEFAULT NULL,\
             ext_str2 TEXT DEFAULT NULL,\
             ext_str3 TEXT DEFAULT NULL,\
             Primary Key(thread_id,channel_id))"])
            break;
        if(![fmdb_ executeUpdate:@"CREATE INDEX index_rating_date \
             ON "RatingHistoryTableName"(rating_date)"])
            break;
        
        
        //DataTransferRecordTable
        //流量记录表
        //in_count
        //  下载字节数
        //out_count
        //  上行字节数
        //date
        //  该笔记录发生的时间
        //bearer_type
        //  网络类型。0-wifi；1-移动数据
        if(![fmdb_ executeUpdate:@"CREATE TABLE "DataTransferRecordTableName" (\
             in_count INT,\
             out_count INT,\
             date DOUBLE PRIMARY KEY,\
             bearer_type INT,\
             ext_int0 INT DEFAULT 0,\
             ext_int1 INT DEFAULT 0,\
             ext_int2 INT DEFAULT 0,\
             ext_int3 INT DEFAULT 0,\
             ext_str0 TEXT DEFAULT NULL,\
             ext_str1 TEXT DEFAULT NULL,\
             ext_str2 TEXT DEFAULT NULL,\
             ext_str3 TEXT DEFAULT NULL)"])
            break;
        
        //UserActionRecordTable
        //用户操作记录信息表
        //此表用于记录用户的操作记录统计
        //服务端不止一次表示过要统计用户对功能点的使用情况，
        //然而至今未有方案出台。
        //action_no
        //  功能点序号
        //count
        //  累计使用次数
        if(![fmdb_ executeUpdate:@"CREATE TABLE "UserActionRecordTableName" (\
             action_no INT PRIMARY KEY,\
             count INT,\
             ext_int0 INT DEFAULT 0,\
             ext_int1 INT DEFAULT 0,\
             ext_str0 TEXT DEFAULT NULL,\
             ext_str1 TEXT DEFAULT NULL)"])
            break;
        
        
        // 创建用户评论点赞表
        if (![self buildNewsCommentTable:fmdb_]) {
            break;
        }
        
        
        [fmdb_ commit];
        
        //all done
        return;
    } while (0);

    //error occurred
    //TODO
    JLog(@"create table error:%@,可能因为数据库表结构发生改变,请先尝试删除数据库文件或者删除程序",[fmdb_ lastErrorMessage]);
    [fmdb_ rollback];
    @throw NSGenericException;
}

/**
 *  创建一个新闻评论点赞的表格
 *
 *  @param fmdb 数据库对象
 *
 *  @return 是否创建成功
 */
-(BOOL)buildNewsCommentTable:(FMDatabase*)fmdb
{
    // 新闻评论点赞
    // thread_id: 帖子id
    // comment_id: 评论ID
    // attitude:    对评论的态度 -1. 喷  0. 没有态度  1.赞
    // user_id :用户iD
    // ext_int0: 2015.10.30 by xuxg 正文是否投票  0:没有 1投票
    return [fmdb_ executeUpdate:@"CREATE TABLE "NewsCommentPraiseTableName" (\
         thread_id TEXT DEFAULT NULL,\
         comment_id TEXT DEFAULT NULL,\
         user_id TEXT DEFAULT NULL,\
         attitude INT DEFAULT 0,\
         ext_int0 INT DEFAULT 0,\
         ext_int1 INT DEFAULT 0,\
         ext_str0 TEXT DEFAULT NULL,\
        ext_str1 TEXT DEFAULT NULL)"];
}
@end



@implementation SurfDbManager

+ (SurfDbManager *)sharedInstance
{
    static SurfDbManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SurfDbManager alloc] init];
    });
    
    return sharedInstance;
}

-(void)initDbWithDelegate:(id<SurfDbManagerInitProtocol>)delegate
{
    initDelegate_ = delegate;
    [self initDb];
}

-(BOOL)addReadingHistory:(ThreadSummary*) thread
{
    NSString* sql = [[NSString alloc] initWithFormat:@"INSERT INTO "ReadingHistoryTableName"(thread_id,thread_type,channel_id,title,reading_date) VALUES('%@',%d,'%@','%@',%f)",@(thread.threadId),0,@(thread.channelId),[thread.title escapeStringForSql],[[NSDate date] timeIntervalSince1970]];
    
    return [fmdb_ executeUpdate:sql];
}

-(BOOL)isThreadRead:(ThreadSummary*)thread
{
    NSString* sql = [[NSString alloc] initWithFormat:@"SELECT thread_id FROM "ReadingHistoryTableName" WHERE thread_id = '%@' AND channel_id = '%@'",@(thread.threadId),@(thread.channelId)];
    
    FMResultSet* result = [fmdb_ executeQuery:sql];
    return [result next];
}

-(long)energyScore:(ThreadSummary*)thread
{
    NSString* sql = [[NSString alloc] initWithFormat:@"SELECT ext_int0 FROM "ReadingHistoryTableName" WHERE thread_id = '%@' AND channel_id = '%@'",@(thread.threadId),@(thread.channelId)];
    
    FMResultSet* result = [fmdb_ executeQuery:sql];
    if ([result next]) {
        return [result intForColumn:@"ext_int0"];
    }
    return 0;
}

-(BOOL)saveEnergyScore:(ThreadSummary*)thread energyScore:(int)score
{
    NSString *sql = [NSString stringWithFormat:@"UPDATE "ReadingHistoryTableName" SET ext_int0='%d' WHERE thread_id = '%@' AND channel_id='%@'",score, @(thread.threadId), @(thread.channelId)];
    return  [fmdb_ executeUpdate:sql];
}


//标记某个帖子为“已赞”
-(BOOL)addRatingHistory:(ThreadSummary*) thread
{
    return [fmdb_ executeUpdate:@"INSERT INTO "RatingHistoryTableName" (thread_id,thread_type,channel_id,title,rating_date) VALUES (?,?,?,?,?)",[NSNumber numberWithLong:thread.threadId],[NSNumber numberWithInt:0],[NSNumber numberWithLong:thread.channelId],thread.title,[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]];
}

//查询某个帖子是否已赞
-(BOOL)isThreadRated:(ThreadSummary*)thread
{
    NSString* sql = [[NSString alloc] initWithFormat:@"SELECT thread_id FROM "RatingHistoryTableName" WHERE thread_id = '%@' AND channel_id = '%@'",@(thread.threadId), @(thread.channelId)];
    
    FMResultSet* result = [fmdb_ executeQuery:sql];
    return [result next];
}

#pragma mark - 段子频道帖子 赞、踩

// 标记段子频道帖子 赞
- (BOOL)addUpedOrDownedHistory:(ThreadSummary *)thread {
    int type = thread.uped ? 1 : 2;
    
    return [fmdb_ executeUpdate:@"INSERT INTO "RatingHistoryTableName" (thread_id,thread_type,channel_id,title,rating_date,ext_int0) VALUES (?,?,?,?,?,?)",[NSNumber numberWithLong:thread.threadId],[NSNumber numberWithInt:0],[NSNumber numberWithLong:thread.channelId],thread.title,[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]],[NSNumber numberWithInt:type]];  // 赞为1 踩为2
}

// 查询段子频道帖子 赞或踩
- (int)isThreadUpedOrDowned:(ThreadSummary *)thread {
    NSString* sql = [[NSString alloc] initWithFormat:@"SELECT ext_int0 FROM "RatingHistoryTableName" WHERE thread_id = '%@' AND channel_id = '%@'",@(thread.threadId), @(thread.channelId)];
    
    FMResultSet* result = [fmdb_ executeQuery:sql];
    while ([result next]) {
        return [result intForColumn:@"ext_int0"];
    }
    return 0;
}

#pragma mark -----

// 新闻是否投票
-(BOOL)isNewsVote:(NSInteger)newId
{
    NSString* sql = [[NSString alloc] initWithFormat:@"SELECT thread_id FROM "NewsCommentPraiseTableName" WHERE thread_id = '%@' AND ext_int0 = '1'",@(newId)];
    FMResultSet* result = [fmdb_ executeQuery:sql];
    return [result next];
}
// 标记新闻评论观点
-(BOOL)addNewsVote:(NSInteger)newId
{
    return [fmdb_ executeUpdate:@"INSERT INTO "NewsCommentPraiseTableName" (thread_id,ext_int0) VALUES (?,1)",@(newId)];
}

// 查询新闻评论是否点赞
-(BOOL)isCommentRated:(CommentBase*)comment
{
    NSString* sql = [[NSString alloc] initWithFormat:@"SELECT thread_id FROM "NewsCommentPraiseTableName" WHERE thread_id = '%ld' AND comment_id = '%ld'",comment.newsid,comment.commentId];
    
    FMResultSet* result = [fmdb_ executeQuery:sql];
    return [result next];
    
}
// 标记新闻评论观点
-(BOOL)addCommentRatingHistory:(CommentBase*)comment
{
    return [fmdb_ executeUpdate:@"INSERT INTO "NewsCommentPraiseTableName" (thread_id,comment_id,attitude) VALUES (?,?,?)",[NSNumber numberWithLong:comment.newsid],[NSNumber numberWithLong:comment.commentId], [NSNumber numberWithInteger:comment.attitude]];
}


-(SurfUserInfo*)getUserInfo
{
    return nil;
}

-(BOOL)setUserInfo:(SurfUserInfo*)userInfo
{
    return TRUE;
}

-(BOOL)deleteUserInfo
{
    return TRUE;
}

//获取用户绑定的微博信息
-(NSDictionary*)getSinaWeiboInfoForUser:(NSString*)userId
{
    NSString* sql = [[NSString alloc] initWithFormat:@"SELECT * FROM "WeiboTableName" WHERE binded_userid = '%@' AND service_provider = '%d'", userId, SinaProvider];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    FMResultSet* result = [fmdb_ executeQuery:sql];
    while ([result next]) {
        if ([self tokenHasExpired:[result doubleForColumn:@"access_token_expired_date"]]) {
            break;
        }
        [dict setValue:[result stringForColumn:@"access_token"] forKey:@"access_token"];
        [dict setValue:[result stringForColumn:@"account_info"] forKey:@"uid"];
    }
    return dict;
}

-(NSDictionary*)getTencentWeiboInfoForUser:(NSString*)userId
{
    NSString* sql = [[NSString alloc] initWithFormat:@"SELECT * FROM "WeiboTableName" WHERE binded_userid = '%@' AND service_provider = '%d'", userId, TencentProvider];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    FMResultSet* result = [fmdb_ executeQuery:sql];
    while ([result next]) {
        if ([self tokenHasExpired:[result doubleForColumn:@"access_token_expired_date"]]) {
            break;
        }
        [dict setValue:[result stringForColumn:@"access_token"] forKey:@"access_token"];
        [dict setValue:[result stringForColumn:@"tencent_open_id"] forKey:@"tencent_open_id"];
    }
    return dict;
}

-(NSDictionary*)getRenrenWeiboInfoForUser:(NSString*)userId
{
    NSString* sql = [[NSString alloc] initWithFormat:@"SELECT * FROM "WeiboTableName" WHERE binded_userid = '%@' AND service_provider = '%d'", userId, RenrenProvider];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    FMResultSet* result = [fmdb_ executeQuery:sql];
    while ([result next]) {
        [dict setValue:[[result stringForColumn:@"access_token"] urlDecodedString] forKey:@"access_token"];
    }
    return dict;
}

-(NSDictionary*)getCMWeiboInfoForUser:(NSString*)userId
{
    NSString* sql = [[NSString alloc] initWithFormat:@"SELECT * FROM "WeiboTableName" WHERE binded_userid = '%@' AND service_provider = '%d'", userId, ChinaMobileProvider];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    FMResultSet* result = [fmdb_ executeQuery:sql];
    while ([result next]) {
        if ([self tokenHasExpired:[result doubleForColumn:@"access_token_expired_date"]]) {
            break;
        }
        [dict setValue:[result stringForColumn:@"access_token"] forKey:@"access_token"];
    }
    return dict;
}

//添加用户绑定的微博信息
-(BOOL)addSinaWeiboInfoForUser:(NSString*)userId infoDictionary:(NSDictionary*)info
{
    NSDate *expiresAt = [[NSDate alloc] initWithTimeIntervalSinceNow:(NSTimeInterval)[[info valueForKey:@"expires_in"] doubleValue]];
    double expiredDate = (double)[expiresAt timeIntervalSince1970];

    //在插入之前先删除
    if (![self clearSinaWeiboInfoForUser:userId]) {
        return NO;
    }
    
    return [fmdb_ executeUpdate:
            @"INSERT INTO "WeiboTableName" (service_provider,\
                                            binded_userid,\
                                            account_info,\
                                            access_token,\
                                            access_token_expired_date) \
            VALUES (?,?,?,?,?)", [NSNumber numberWithInt:SinaProvider],
                                 [NSString stringWithFormat:@"%@", userId],
                                 [info valueForKey:@"uid"],
                                 [info valueForKey:@"access_token"],
                                 [NSNumber numberWithDouble:expiredDate]];
}

-(BOOL)addTencentWeiboInfoForUser:(NSString*)userId infoDictionary:(NSDictionary*)info
{
    NSDate *expiresAt = [[NSDate alloc] initWithTimeIntervalSinceNow:(NSTimeInterval)[[info valueForKey:@"expires_in"] doubleValue]];
    double expiredDate = (double)[expiresAt timeIntervalSince1970];
    
    //在插入之前先删除
    if (![self clearTencentWeiboInfoForUser:userId]) {
        return NO;
    }
    
    return [fmdb_ executeUpdate:
            @"INSERT INTO "WeiboTableName" (service_provider,\
                                            binded_userid,\
                                            access_token,\
                                            access_token_expired_date,\
                                            refresh_token,\
                                            tencent_open_id) \
            VALUES (?,?,?,?,?,?)", [NSNumber numberWithInt:TencentProvider],
                                   [NSString stringWithFormat:@"%@", userId],
                                   [info valueForKey:@"access_token"],
                                   [NSNumber numberWithDouble:expiredDate],
                                   [info valueForKey:@"refresh_token"],
                                   [info valueForKey:@"openid"]];
}

-(BOOL)addRenrenWeiboInfoForUser:(NSString*)userId infoDictionary:(NSDictionary*)info
{
    NSDate *expiresAt = [[NSDate alloc] initWithTimeIntervalSinceNow:(NSTimeInterval)[[info valueForKey:@"expires_in"] doubleValue]];
    double expiredDate = (double)[expiresAt timeIntervalSince1970];
    
    //在插入之前先删除
    if (![self clearRenrenWeiboInfoForUser:userId]) {
        return NO;
    }
    
    return [fmdb_ executeUpdate:
            @"INSERT INTO "WeiboTableName" (service_provider,\
                                            binded_userid,\
                                            access_token,\
                                            access_token_expired_date) \
            VALUES (?,?,?,?)", [NSNumber numberWithInt:RenrenProvider],
                               [NSString stringWithFormat:@"%@", userId],
                               [info valueForKey:@"access_token"],
                               [NSNumber numberWithDouble:expiredDate]];
}

-(BOOL)addCMWeiboInfoForUser:(NSString*)userId infoDictionary:(NSDictionary*)info
{
    NSDate *expiresAt = [[NSDate alloc] initWithTimeIntervalSinceNow:(NSTimeInterval)[[info valueForKey:@"expires_in"] doubleValue]];
    double expiredDate = (double)[expiresAt timeIntervalSince1970];
    
    //在插入之前先删除
    if (![self clearCMWeiboInfoForUser:userId]) {
        return NO;
    }
    
    return [fmdb_ executeUpdate:
            @"INSERT INTO "WeiboTableName" (service_provider,\
                                            binded_userid,\
                                            access_token,\
                                            access_token_expired_date,\
                                            refresh_token) \
            VALUES (?,?,?,?,?)", [NSNumber numberWithInt:ChinaMobileProvider],
                                 [NSString stringWithFormat:@"%@", userId],
                                 [info valueForKey:@"access_token"],
                                 [NSNumber numberWithDouble:expiredDate],
                                 [info valueForKey:@"refresh_token"]];
}

//清空用户绑定的微博信息
//即取消微博绑定
-(BOOL)clearSinaWeiboInfoForUser:(NSString*)userId
{
    return [fmdb_ executeUpdate:@"DELETE FROM "WeiboTableName" WHERE binded_userid = (?) AND service_provider = (?)",
            [NSString stringWithFormat:@"%@", userId],
            [NSNumber numberWithInt:SinaProvider]];
}

-(BOOL)clearTencentWeiboInfoForUser:(NSString*)userId
{
    return [fmdb_ executeUpdate:@"DELETE FROM "WeiboTableName" WHERE binded_userid = (?) AND service_provider = (?)",
            [NSString stringWithFormat:@"%@", userId],
            [NSNumber numberWithInt:TencentProvider]];
}

-(BOOL)clearRenrenWeiboInfoForUser:(NSString*)userId
{
    return [fmdb_ executeUpdate:@"DELETE FROM "WeiboTableName" WHERE binded_userid = (?) AND service_provider = (?)",
            [NSString stringWithFormat:@"%@", userId],
            [NSNumber numberWithInt:RenrenProvider]];
}

-(BOOL)clearCMWeiboInfoForUser:(NSString*)userId
{
    return [fmdb_ executeUpdate:@"DELETE FROM "WeiboTableName" WHERE binded_userid = (?) AND service_provider = (?)",
            [NSString stringWithFormat:@"%@", userId],
            [NSNumber numberWithInt:ChinaMobileProvider]];
}

//判断token是否过期
- (BOOL)tokenHasExpired:(double)time
{
    NSDate *expiresAt = [[NSDate alloc] initWithTimeIntervalSince1970:(NSTimeInterval)time];
    if ([expiresAt compare:[NSDate date]] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}

@end
