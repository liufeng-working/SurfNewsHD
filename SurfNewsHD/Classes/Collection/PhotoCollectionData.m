//
//  PhotoCollectionData.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-7-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhotoCollectionData.h"
#import "EzJsonParser.h"
#import "PathUtil.h"

@implementation PhotoData
@synthesize pId = __KEY_NAME_id;
@synthesize isCacheData = __DO_NOT_SERIALIZE_ChcheData;
@synthesize isLoadingImage = __DO_NOT_SERIALIZE_LOADINGIMAGE;
@end



@implementation PhotoCollection

//@synthesize pcId = __KEY_NAME_id;
//@synthesize imgs = __ELE_TYPE_PhotoData;


@synthesize pcId = __KEY_NAME_id;
@synthesize isTempData = __DO_NOT_SERIALIZE_;


//@synthesize serviceTime = __DO_NOT_SERIALIZE_;
//-(void)setTime:(double)time{
//    _time = time;    
//    self.serviceTime = [NSDate dateWithTimeIntervalSince1970:time/1000.f];
//}




@end




@implementation PhotoCollectionChannel
@synthesize cid = __KEY_NAME_id;
@synthesize listScrollOffsetY = __DO_NOT_SERIALIZE_OffSetY;

- (void)setName:(NSString *)name{
    // 删除新华2个字   
    NSRange range = [name rangeOfString:@"新华"];
    if (range.location != NSNotFound && range.location == 0 && name.length > 2) {
        _name = [name substringFromIndex:2];
        return;
    }
    _name = name;
}
@end




@implementation PCCLocalInfo

- (id)initWithPCChannel:(PhotoCollectionChannel*)pcc{
    if (self = [super init]) {
        _cid = pcc.cid;
    }
    return self;
}

- (void)saveToFile{
    NSString *path = [PathUtil pathOfPhotoCollectionChannelLocalInfo:_cid];
    NSString *content = [EzJsonParser serializeObjectWithUtf8Encoding:self];
    [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)loadDateFromFile {
    NSString *path = [PathUtil pathOfPhotoCollectionChannelLocalInfo:_cid];
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        PCCLocalInfo *tempInfo = [EzJsonParser deserializeFromJson:content AsType:[PCCLocalInfo class]];
        if (tempInfo != nil) {
            [self copyInfo:tempInfo];
        }
    }
}

-(void)copyInfo:(PCCLocalInfo*)info{
    _cid = info.cid;
    _refreshTimeInterval = info.refreshTimeInterval;
    _getMoreTimeInterval = info.getMoreTimeInterval;
}
@end