//
//  PeriodicalHtmlResolving.h
//  SurfNewsHD
//
//  Created by apple on 13-5-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetPeriodicalListResponse.h"
@interface PeriodicalLinkInfo : NSObject
//链接对应的其id
@property(nonatomic,strong) NSString* linkId;
//link
@property(nonatomic,strong) NSString* linkUrl;
@property(nonatomic,strong) NSString* linkTitle;
@property long magazineId;                 //期刊ID
@property long periodicalId;               //某期ID

@end


@interface PeriodicalHtmlResolvingResult : NSObject

//预处理后的正文
@property(nonatomic,strong) NSString* resolvedContent;

//所有链接
//元素类型：PeriodicalLinkInfo
@property(nonatomic,strong) NSMutableArray* herfArr;

@end

@interface PeriodicalLinkImageMapping : NSObject
{
    NSString* mappingPath_;
    NSMutableDictionary* dict_;
    PeriodicalLinkInfo*linkInfo;
}
-(id)initWithPeriodicalLink:(PeriodicalLinkInfo*)info;
-(BOOL)containsUrl:(NSString*)url;
-(NSString*)getImgLocalFileNameWithUrl:(NSString*)url;
-(NSString*)getImgLocalFilePathWithUrl:(NSString*)url;
-(void)addMappingWithUrl:(NSString*)url andImgLocalFileName:(NSString*)fileName;
-(void)removeMappingWithUrl:(NSString*)url;


@end


@interface PeriodicalHtmlResolving : NSObject
//获取期刊缩印页中所有链接
+(PeriodicalHtmlResolvingResult *)generateWithPeriodical:(PeriodicalInfo *)periodicalInfo
              andResolvedHtml:(NSData *)data;
//获取离线下载期刊缩印页
+(PeriodicalHtmlResolvingResult *)generateOfflinesWithPeriodical:(PeriodicalInfo *)periodicalInfo;
//获取期刊正文页中所有链接
+(PeriodicalHtmlResolvingResult *)generateWithPeriodicalContent:(PeriodicalLinkInfo *)periodicalInfo
                                                        :(NSData *)data;

@end
