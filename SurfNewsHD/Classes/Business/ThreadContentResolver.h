//
//  ThreadContentResolver.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneNewsData.h"
#import "PhoneNewsManager.h"
@class ThreadSummary;


//---------即将被废弃---------------
@interface ThreadContentImageInfo : NSObject
//图片对应的html id
@property(nonatomic,strong) NSString* imageId;
//图片的url
@property(nonatomic,strong) NSString* imageUrl;
@end


@interface ThreadContentImageInfoV2 : NSObject
{
    //不要直接使用以下成员变量，请使用property
@public
    __strong NSString* _imageId;
    __strong NSString* _imageUrl;
    __strong NSString* _expectedLocalPath;
    __strong NSString* _imageText;
}
//图片对应的html id
@property(nonatomic,strong,readonly) NSString* imageId;
//图片的url
@property(nonatomic,strong,readonly) NSString* imageUrl;
//图片的文字描述信息
@property(nonatomic,strong,readonly) NSString* imageText;
//本地图片是否已经下载完毕
//负责下载图片的模块有责任在图片下载完成后将该属性设为YES
@property(nonatomic) BOOL isLocalImageReady;
//下载进度，范围：[0,1]
//只有在isLocalImageReady为NO时，才有实际意义
//负责下载图片的模块有责任在图片下载进度更新时来改写此属性
@property(nonatomic) float downloadingProgress;
//预料中图片的本地路径
//@isLocalImageReady为YES时，意味着此路径的文件一定存在
@property(nonatomic,strong,readonly) NSString* expectedLocalPath;

@property(nonatomic,getter = isLoadimgHDImage)BOOL loadingHDImage;// 正在加载高清图片
@end


//---------即将被改成私有，不对外开放----------
@interface ThreadContentImageMapping : NSObject
{
    NSString* mappingPath_;
    NSMutableDictionary* dict_;
}
-(id)initWithThread:(ThreadSummary*)thread;
-(BOOL)containsUrl:(NSString*)url;
-(NSString*)getImgLocalFileNameWithUrl:(NSString*)url;
-(void)addMappingWithUrl:(NSString*)url andImgLocalFileName:(NSString*)fileName;
-(void)removeMappingWithUrl:(NSString*)url;
@end


@interface ThreadContentResolvingResultV2 : NSObject
{
    //不要直接使用以下成员变量，请使用property
@public
    __strong NSString* _resolvedContent;
    BOOL _hasUndownloadedImage;
    __strong NSMutableArray* _contentImgInfoArray;
}
//预处理后的正文
@property(nonatomic,strong,readonly) NSString* resolvedContent;

//工具属性，用来快速判断contentImgInfoArray中是否有未下载完成的图片
@property(nonatomic,readonly,getter = _hasUndownloadedImage,readonly) BOOL hasUndownloadedImage;

//正文包含的所有图片信息
//元素类型：ThreadContentImageInfoV2
@property(nonatomic,strong,readonly) NSMutableArray* contentImgInfoArray;

@end



@interface ThreadContentResolver : NSObject

//---------即将被废弃----------
//需要改写成新版的手机报解析代码
+(NSString*) resolveContent:(NSString*)content
            OfPhoneNewsData:(PhoneNewsData*)thread;


//正文内容解析
//V2后缀为历史原因，V1的解析代码已经被废弃
+(ThreadContentResolvingResultV2*) resolveContentV2:(NSString*)content
                                           imgsDict:(NSDictionary*)imgDict
                                           OfThread:(ThreadSummary*)thread;

//解析正文内容，获得所有的图片信息
//返回数组的元素类型：ThreadContentImageInfoV2
+(NSArray*) extractImgNodesFromContent:(NSString*)content
                              OfThread:(ThreadSummary*)thread;

@end
