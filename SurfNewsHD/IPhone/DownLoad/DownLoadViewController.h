//
//  DownLoadViewController.h
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-6-3.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OfflineDownloader.h"
#import "DownLoadLabel.h"
#import "BgScrollView.h"

typedef enum {
    STATE_ERRORNULL = 0,
    STATEHOTCHANNELS,
    STATE_SUBSCHANNELS,
    STATE_VOLUMES,
    STATE_IMAGES,
    STATE_MAGAZINE
} DownloadOperationModel;



@interface DownLoadViewController : UIViewController<UIAlertViewDelegate>
{
    //UI进度条
    UIImageView     *imageProBgView;
    UIImageView     *imageProView;
    DownLoadLabel         *downText;
//    UILabel         *downText;
//    UILabel         *downNumLab;
    DownLoadLabel    *downNumLab;
    UIButton        *closeBt;
    UIView          *wihteBgView;
    //加入队列动态
    UILabel     *animationNumView;
    
}

+ (DownLoadViewController *)sharedInstance;
- (void)singleThreadTaskBeginDownLoad:(NSString *)name;
- (void)singleThreadTaskDownLoad:(NSString *)name
                        andCount:(NSInteger)completionCount
                         ofTotal:(NSInteger)total;
- (void)singleThreadTaskEndDownLoad:(NSString *)name;
- (void)didFinishDownLoad;
- (void)singleMagazineTaskBeginDownLoad:(NSString *)name;
- (void)singleMagazineTaskDownLoad:(NSString *)name andPercent:(float)percent;
- (void)singleMagazineTaskUnzip:(NSString *)name andPercent:(float)percent;
- (void)singleMagazineTaskEndDownLoad:(NSString *)name;

- (void)changeCloseBtState:(BOOL)canTouch;
- (BOOL)isAddSubviews;
- (void)clickCloseBt;
//加入下载队列动画
- (void)animationNum:(NSInteger)countValue;
- (void)deleteImage;

- (void)setHiddenView:(BOOL)hidden;

@end
