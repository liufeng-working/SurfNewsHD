//
//  stockMarketInfoManager.m
//  SurfNewsHD
//
//  Created by jsg on 14-5-5.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "stockMarketInfoManager.h"
#import "GTMHTTPFetcher.h"
#import "stockMarketInfoResponse.h"
#import "NSString+Extensions.h"
#import "EzJsonParser.h"
#import "AppSettings.h"
#import "SurfRequestGenerator.h"
#import "Encrypt.h"

@implementation stockMarketInfoManager
@synthesize stockMarketInfoList;

+ (stockMarketInfoManager*)sharedInstance{
    static stockMarketInfoManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[stockMarketInfoManager alloc] init];
    });
    return sharedInstance;
}

-(id)init
{
    self = [super init];
    if (!self) return nil;
    
    stockMarketInfoList = [[NSMutableArray alloc] initWithCapacity:3];
    return self;
}

- (void)refreshStockMarketInfo:(void (^)(BOOL succeeded,NSArray*))completion
{
    id req = [SurfRequestGenerator stockMarketInfoRequest];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
     {
         BOOL succeeded = NO;
         if(!error)
         {
             NSString *body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
             stockMarketInfoResponse* res = [EzJsonParser deserializeFromJson:body AsType:[stockMarketInfoResponse class]];
             
            
            
            //判断数据大小
            float epsinon = 0.000001f;
            if (res && [res.item count] > 0) {
                succeeded = YES;
                [stockMarketInfoList removeAllObjects];
                 for (stockMarketInfo *stock in res.item) {
                     if([stock.ups floatValue] >= epsinon){
                         stock.ups = [NSString stringWithFormat:@"+%@", stock.ups];
                     }
                     if([stock.range floatValue] >= epsinon){
                         stock.range = [NSString stringWithFormat:@"+%@", stock.range];
                     }
                     
                     [stockMarketInfoList addObject:stock];
                 }
            }
         }
         
         if (completion) {
             completion(succeeded,stockMarketInfoList);
         }
     }];

}
@end


