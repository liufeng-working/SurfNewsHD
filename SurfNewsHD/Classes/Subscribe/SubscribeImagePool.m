//
//  SubscribeImagePool.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-2-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SubscribeImagePool.h"
#import "GetSubsCateResponse.h"
#import "NSString+Extensions.h"
#import "SubsChannelsListResponse.h"
#import "PathUtil.h"
#import "ImageDownloader.h"


#define CategoryCacheCount 20   // 分类频道缓存总数

@interface SubscribeImgData : NSObject

@property(nonatomic,strong)NSIndexPath *indexP;
@property(nonatomic,strong)NSMutableDictionary *imagePool;
@property(nonatomic,strong)SubsChannel *subsChannel;

@end
@implementation SubscribeImgData
@synthesize imagePool;
@synthesize subsChannel;
@synthesize indexP;

@end



@implementation SubscribeImagePool



+ (SubscribeImagePool *)sharedInstance{   
    static SubscribeImagePool *sharedInstance = nil;
    static dispatch_once_t onceToken;    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SubscribeImagePool alloc] init];
    });
    return sharedInstance;
}
- (id)init{
    if (self = [super init]) {        
 
        _subsCannelDict = [NSMutableDictionary dictionaryWithCapacity:50];       
    }
    return self;    
}

- (void)dealloc{

    [_subsCannelDict removeAllObjects];       
}



// 加载分类图片
-(void)loadImage:(NSIndexPath *)indexPath subChannel:(SubsChannel *)channel
{    
    if (indexPath == nil || channel == nil)
        return;    

    bool isExistSubsCannel = NO; // 是否存在SubsCannel
    NSIndexPath *myIndexPath = indexPath;
    NSArray *keys = [_subsCannelDict allKeys];
    for (int i=0; i<keys.count; ++i) {
        NSIndexPath *tempIdxP = [keys objectAtIndex:i];
        if (tempIdxP.row == indexPath.row) {
            isExistSubsCannel = YES;
            myIndexPath = tempIdxP;
            break;
        }
    }
    
    
    // 队列中不存在NSIndexPath
    if (!isExistSubsCannel)
    {
        [_subsCannelDict setObject:[NSMutableDictionary dictionary] forKey:myIndexPath];
        
        // 图片容器大于容量
        if (_subsCannelDict.count > CategoryCacheCount){             
            NSArray *sortkeys = [[_subsCannelDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                if (((NSIndexPath *)obj1).row < ((NSIndexPath *)obj2).row) {
                    return  NSOrderedAscending;
                }
                return NSOrderedDescending;                
            }];
            
            NSUInteger idx = [sortkeys indexOfObject:myIndexPath];
            if (idx <= CategoryCacheCount / 2) {    // 删除最后的数据                
                NSIndexPath* lastPath = [sortkeys lastObject];                
                [_subsCannelDict removeObjectForKey:lastPath];
            }
            else{ // 删除第一个数据                
                 NSIndexPath* firstPath = [sortkeys objectAtIndex:0];
                 [_subsCannelDict removeObjectForKey:firstPath];
            }
        }
    }
    
    
    NSMutableDictionary *imgPool = [_subsCannelDict objectForKey:myIndexPath];    
    UIImage *oldImg = [imgPool objectForKey:[NSNumber numberWithLong:channel.channelId]];
    if (oldImg == nil) {        
        
        // 加载图片数据
        NSString *imgPath = [PathUtil pathOfSubsChannelLogo:channel];
        NSFileManager* fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:imgPath]) { // 图片文件不存在
            
            SubscribeImgData *data = [SubscribeImgData new];
            [data setImagePool:imgPool];
            [data setSubsChannel:channel];
            [data setIndexP:myIndexPath];
            ImageDownloadingTask *task = [ImageDownloadingTask new];
            [task setImageUrl:channel.ImageUrl];
            [task setUserData:data];
            [task setTargetFilePath:imgPath];
            [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt)
            {                
                if(succeeded && idt != nil){
                    UIImage* tempImg = [UIImage imageWithData:[idt resultImageData]];
                    NSNumber *idKey = [NSNumber numberWithLong:[idt.userData subsChannel].channelId];
                    [[idt.userData imagePool] setObject:tempImg forKey:idKey];
                    
                    // 通知更新图片
                    [[self delegate] appImageDidLoad:[idt.userData indexP]
                                         subsChannel:[idt.userData subsChannel]
                                               image:tempImg];
                 
                }
            }];
            [[ImageDownloader sharedInstance] download:task];
        }
        else { // 图片存在
            NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
            UIImage *tempImage = [UIImage imageWithData:imgData];
            [imgPool setObject:tempImage
                        forKey:[NSNumber numberWithLong:channel.channelId]];
            
            // 通知更新图片
            [[self delegate] appImageDidLoad:myIndexPath
                                 subsChannel:channel
                                       image:tempImage];
            
        }
    }
    else{        
        // 通知更新图片
        [[self delegate] appImageDidLoad:myIndexPath
                             subsChannel:channel
                                   image:oldImg];
    }
}

-(BOOL)isExistImage:(NSIndexPath *)indexPath
        subsChannel:(SubsChannel *)channel{
    
    NSMutableDictionary *dic = [_subsCannelDict objectForKey:indexPath];    
    if (dic != nil) {
        NSNumber* key = [NSNumber numberWithLong:channel.channelId];
        if ([dic objectForKey:key] != nil) {
            return YES;
        }        
    }
    return NO;
}

-(UIImage *)getImage:(NSIndexPath *)indexPath subsChannel:(SubsChannel *)channel{
    UIImage *image = nil;    
    NSMutableDictionary *dic = [_subsCannelDict objectForKey:indexPath];
    if (dic != nil) {
        NSNumber* key = [NSNumber numberWithLong:channel.channelId];        
        image = [dic objectForKey:key];
    }    
    return image;
}

// 删除图片
- (void)removeImageWithIndexPath:(NSIndexPath *)indexPath{
    if (indexPath != nil) {
        NSMutableDictionary *dire = [_subsCannelDict objectForKey:indexPath];
        if (dire != nil) {
             [dire removeAllObjects];
        }       
        [_subsCannelDict removeObjectForKey:indexPath];
    }
}







@end
