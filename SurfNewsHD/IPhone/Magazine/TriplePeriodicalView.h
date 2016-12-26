//
//  TriplePeriodicalView.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PathUtil.h"
#import "GetPeriodicalListResponse.h"
#import "ImageDownloader.h"
#import "OfflineDownloader.h"
#import "CoverImageControl.h"

/**
 SYZ -- 2014/08/11
 TriplePeriodicalViewDelegate实现了点击期刊封面的delegate方法
 */
@protocol TriplePeriodicalViewDelegate <NSObject>

- (void)periodicalClicled:(PeriodicalInfo*)periodical;

@end

/**
 SYZ -- 2014/08/11
 TriplePeriodicalView展示两本期刊封面
 是有两个CoverImageControl组成的view
 具体请参考CoverImageControl
 */
//原来是一行三本期刊视图,后来改为一行两本,所以这里的类名开头为Triple
@interface TriplePeriodicalView : UIView
{    
    CoverImageControl *periodical1;
    CoverImageControl *periodical2;
}

@property(nonatomic, weak) id<TriplePeriodicalViewDelegate> delegate;
@property(nonatomic, strong) NSArray *periodicalArray;

- (void)loadData:(NSArray*)array;

@end
