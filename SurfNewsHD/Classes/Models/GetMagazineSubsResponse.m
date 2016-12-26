//
//  GetMagazineSubsResponse.m
//  SurfNewsHD
//
//  Created by SYZ on 13-5-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "GetMagazineSubsResponse.h"
#import "GetPeriodicalListResponse.h"

@implementation MagazineSubsInfo

@synthesize magazineId = __KEY_NAME_id;
@synthesize periodicalArray = __ELE_TYPE_PeriodicalInfo;

- (id)init
{
    if (self = [super init]) {
        self.refreshPeridical = YES;
        self.getPeriodicalSuccess = YES;
        self.periodicalArray = [NSMutableArray new];
    }
    return self;
}

- (id)initWithMagazineInfo:(MagazineInfo*)magazineInfo
{
    if (self = [super init]) {
        self.getPeriodicalSuccess = YES;
        self.periodicalArray = [NSMutableArray new];
        
        self.name = magazineInfo.magazineName;
        self.imageUrl = magazineInfo.iconUrl;
        self.coverUrl = magazineInfo.imageUrl;
        self.payType = magazineInfo.payType;
        self.subsCount = magazineInfo.orderedCount;
        self.magazineId = magazineInfo.magazineId;
        _rssType = 6;
        //_inVisible                      //期刊对客户端是否可见
        //_index
        //_desc
    }
    return self;
}

@end

//******************************************************************************

@implementation GetMagazineSubsResponse

@synthesize item = __ELE_TYPE_MagazineSubsInfo;

@end
