//
//  SubscribeImagePool.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-2-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageDownloaderDelegate

- (void)appImageDidLoad:(NSIndexPath *)indexPath
            subsChannel:(SubsChannel*)channel
                  image:(UIImage *)img;

@end



@interface SubscribeImagePool : NSObject{
    NSMutableDictionary *_subsCannelDict;    // 频道池UITableView row排列

}

@property(nonatomic,strong) id<ImageDownloaderDelegate> delegate;


+ (SubscribeImagePool *)sharedInstance;


-(BOOL)isExistImage:(NSIndexPath *)indexPath subsChannel:(SubsChannel *)channel;
-(UIImage *)getImage:(NSIndexPath *)indexPath subsChannel:(SubsChannel *)channel;
-(void)loadImage:(NSIndexPath *)indexPath subChannel:(SubsChannel *)channel;
@end



