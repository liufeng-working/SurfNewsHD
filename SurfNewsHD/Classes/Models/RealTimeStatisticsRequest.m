//
//  RealTimeStatisticsRequest.m
//  SurfNewsHD
//
//  Created by xuxg on 14-9-11.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "RealTimeStatisticsRequest.h"
#import "UserManager.h"
#import "GTMHTTPFetcher.h"
#import "NSString+Extensions.h"
#import "PhotoCollectionData.h"
#import "GetPeriodicalListResponse.h"


@implementation RealTimeBelleGirlData

-(id)initWhitThreadSummary:(id)obj andWithType:(RealTimeBelle_Type)belle_type{
    self = [super init];
    if (self){
        UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
        if (userInfo) {
            self.mobile = userInfo.phoneNum;
        }
        
        ThreadSummary *ts = (ThreadSummary *)obj;

        self.type = belle_type;
        if (belle_type != kBelleGirl_Refresh) {
            self.picId = ts.threadId;
        }
    }
    
    return self;
}

@end



// 实时统计接口
@implementation RealTimeStatisticsData

@synthesize newsId = __KEY_NAME_id;

-(id)initWhitThreadSummary:(id)obj rtsType:(RealTimeStatisticType)type
{
    self = [super init];
    if (self){
        UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
        if (userInfo) {
            self.mob = userInfo.phoneNum;
        }
        self.model = [NSString stringWithFormat:@"%d",type];

        if (type == kRTS_NewsList_TextNews || type == kRTS_NewsList_UrlNews || type == kRTS_NewsList_Photos || type == kRTS_NewsList_Periodical || type == kRTS_NewsList_RSSList || type == kRTS_RSSNews || type == kRTS_PushNotify_TextNews) {
            //这些type类型所用数据都是ThreadSummary
            ThreadSummary *ts = (ThreadSummary *)obj;
            
            self.newsId = [NSString stringWithFormat:@"%@",@(ts.threadId)];
            self.referer = ts.referer;
            
            self.type = [NSString stringWithFormat:@"%@",@(ts.channelType)];
            self.channelid = [NSString stringWithFormat:@"%@",@(ts.channelId)];
            self.newsPosition = @"";
            self.channelPosition = @"";
        }
        else if(type == kRTS_Photos){
            PhotoCollection *pc = (PhotoCollection *)obj;

            self.newsId = @"";
            self.referer = @"";
            self.type = @"";
            self.channelid = @"";
            self.newsPosition = @"";
            self.channelPosition = @"";
            self.albumid = [NSString stringWithFormat:@"%ld",pc.pcId];
            self.magazineid = @"";
            self.periodicalid = @"";
            
        }
        else if(type == kRTS_Periodical || type == kRTS_PushNotify_PeriodicalDetail){
            PeriodicalInfo *pi = (PeriodicalInfo *)obj;

            self.newsId = @"";
            self.referer = @"";
            self.type = @"";
            self.channelid = @"";
            self.newsPosition = @"";
            self.channelPosition = @"";
            self.albumid = @"";
            self.magazineid = [NSString stringWithFormat:@"%ld",pi.magazineId];
            self.periodicalid = [NSString stringWithFormat:@"%ld",pi.periodicalId];
        }

    }
    
    return self;
}

@end



@implementation RealTimeStatisticsManager {
    GTMHTTPFetcher *_httpFecther;
}

+ (RealTimeStatisticsManager *)sharedInstance
{
    static RealTimeStatisticsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RealTimeStatisticsManager alloc] init];
    });
    
    return sharedInstance;
}

-(BOOL)isBusy
{
    return [_httpFecther isFetching];
}


- (void)sendRealTimeUserActionStatistics:(id)obj andWithType:(RealTimeStatisticType)type and:(void(^)(BOOL succeeded))handler{
    
    NSURLRequest *request = [SurfRequestGenerator getRealTimeUserActionStatisticsRequest:obj andWithType:type];
    
    _httpFecther = [GTMHTTPFetcher fetcherWithRequest:request];
    [_httpFecther beginFetchWithCompletionHandler:^(NSData *data, NSError *error){
        
//        if (!error){
//            NSLog(@"sendRealTimeUserActionStatistics");
//            
//            NSString* body = [[NSString alloc] initWithData:data encoding:[[[_httpFecther response] textEncodingName] convertToStringEncoding]];
//            NSLog(@"body:%@", body);
//        }
        if (handler) {
            handler(!error);
        }
        
    }];
}


- (void)sendRealTimeBelleGirlActionStatistics:(id)obj andWithType:(RealTimeBelle_Type)type  and:(void(^)(BOOL succeeded))handler{
    
    if([_httpFecther isFetching])
        return;
    
    NSURLRequest *request = [SurfRequestGenerator getRealTimeBelleActionStatisticsRequest:obj andWithType:type];
    
    _httpFecther = [GTMHTTPFetcher fetcherWithRequest:request];
    [_httpFecther beginFetchWithCompletionHandler:^(NSData *data, NSError *error){
        
//        if (!error){
//            NSLog(@"sendRealTimeBelleGirlActionStatistics");
//            
//            NSString* body = [[NSString alloc] initWithData:data encoding:[[[_httpFecther response] textEncodingName] convertToStringEncoding]];
//            NSLog(@"body:%@", body);
//        }
        handler(!error);
    }];
}

@end


