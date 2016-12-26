//
//  PastPeriodicalCell.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TriplePeriodicalView.h"

/**
 SYZ -- 2014/08/11
 PastPeriodicalTitle仅仅是用来显示“往期期刊”文本文字
 实现了白天/夜间模式切换的方法
 */
@interface PastPeriodicalTitle : UIView
{
    UILabel *titleLabel;
}

- (void)applyTheme:(BOOL)isNight;

@end

/**
 SYZ -- 2014/08/11
 PastPeriodicalCellDelegate用于跳转到期刊的索引页
 */
@protocol PastPeriodicalCellDelegate<NSObject>

- (void)readPeriodicalContent:(PeriodicalInfo*)periodical;

@end

/**
 SYZ -- 2014/08/11
 PastPeriodicalCell用于往期期刊的展示
 包含的view是TriplePeriodicalView,具体请参考TriplePeriodicalView类
 */

//往期期刊cell试图
@interface PastPeriodicalCell : UITableViewCell <TriplePeriodicalViewDelegate>
{
    TriplePeriodicalView *triplePeriodicalView;
}

@property(nonatomic, weak) id<PastPeriodicalCellDelegate> delegate;

//加载往期期刊数据
- (void)loadPastPeriodical:(NSArray *)array;

@end
