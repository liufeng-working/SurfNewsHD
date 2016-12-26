//
//  CityManage.m
//  SurfNewsHD
//
//  Created by yujiuyin on 14/12/22.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "CityManager.h"
#import "FileUtil.h"
#import "PathUtil.h"
#import "NSString+Extensions.h"
#import "EzJsonParser.h"


@implementation CityRssListData

@end


@implementation CityRssData

@synthesize cityRssList = __ELE_TYPE_CityRssListData;

@end


@implementation CityManager


+ (CityManager*)sharedInstance
{
    static CityManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [CityManager new];
    });
    return sharedInstance;
}

- (CityRssData *)getCityRssData
{
    NSString *cityPath = [PathUtil pathOfCityRssList];
    if ([FileUtil fileExists:cityPath]) {
        NSString *fileContent = [NSString stringWithContentsOfFile:cityPath encoding:NSUTF8StringEncoding error:nil];
        
        if(fileContent && ![fileContent isEmptyOrBlank]){
            cityRssData = [EzJsonParser deserializeFromJson:fileContent AsType:[CityRssData class]];
        }
    }
    
    if (cityRssData) {
        return cityRssData;
    }
    return nil;
}


- (void)saveCityRssDataWithBodyStr:(NSString *)body
{
    CityRssData *cityRssInfo = [EzJsonParser deserializeFromJson:body AsType:[CityRssData class]];
    
    NSString *bodyStr = [EzJsonParser serializeObjectWithUtf8Encoding:cityRssInfo];
    
    NSString *cityPath = [PathUtil pathOfCityRssList];
    if ([FileUtil fileExists:cityPath]) {
        [FileUtil deleteFileAtPath:cityPath];
    }
    [bodyStr writeToFile:cityPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
