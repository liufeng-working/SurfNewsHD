//
//  PhoneMagazineCell.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetMagazineSubsResponse.h"
#import "MagazineManager.h"
#import "OfflineDownloader.h"
#import "FileUtil.h"
#import "CoverImageControl.h"

#define CellHeightWithImage  285.0f  //图片:150+MagazineIconAndNameView:45+3行文字:90（3 * 26 + 2 + 2 * 5）
#define CellHeightNoImage    140.0f  //MagazineIconAndNameView45+3行文字90（3 * 26 + 2 + 2 * 5）+ marginTop:5
#define CellShadowHeight     1.0f
#define CellSpace            15.0f


//期刊封面和期刊名称视图
@interface MagazineIconAndNameView : UIControl
{
    UIView *dividerLineView;                       //分割线 SYZ -- 2014/08/11
    UIImageView *logoImageView;                    //logo图片
    UILabel *nameLabel;                            //期刊名称
    UIButton *setTopButton;                        //置顶按钮
    UIImageView *redBg;                            //红色背景
//    UILabel *periodsCountLabel;                    //periods-本地期数
}

- (id)initWithTarget:(id)target;
- (void)applyTheme;
//加载数据
- (void)loadData:(UpdatePeriodicalInfo*)up;


@end

typedef enum
{
    ReloadNormal = 0,       //普通模式
    ReloadDelete = 1,       //删除模式
    ReloadSetTop = 2        //置顶模式
} ReloadMode;

@protocol PhoneMagazineCellDelegate <NSObject>

@optional
//阅读该期的正文
- (void)readPeriodicalContent:(MagazineSubsInfo*)magazine;
//当MagazineIconAndNameView被点击后的delegate方法
- (void)tableViewRowSelected:(MagazineSubsInfo *)magazine;
//当cell处于显示删除按钮时,恢复到原来的位置
- (void)resetCellViewFrame;
//某一行时操作类型,具体请参考ReloadMode
- (void)setReloadMode:(ReloadMode)mode atIndex:(NSInteger)index;

@end

/**
 SYZ -- 2014/08/11
 PhoneMagazineCell,期刊Tab页的cell,俗称“卡片“
 bgView                    卡片的背景
 imageView                 新闻图片,根据服务器返回的数据决定是否显示
 imageTitleBgView          新闻图片的标题背景,根据服务器返回的数据决定是否显示
 imageTitleLabel           新闻图片的标题,根据服务器返回的数据决定是否显示
 timeImageView             时间背景
 timeLabel                 时间
 titleLabel1               标题1,根据服务器返回的数据决定是否显示
 lineView1                 分割线1,根据服务器返回的数据决定是否显示
 titleLabel2               标题2,根据服务器返回的数据决定是否显示
 lineView2                 分割线2,根据服务器返回的数据决定是否显示
 titleLabel3               标题3,根据服务器返回的数据决定是否显示
 iconAndNameView           具体请参考MagazineIconAndNameView
 deleteButton              卡片向左滑动时显示删除按钮,根据实际情况初始化
 CAGradientLayer *gradient 卡片的最底部有一个阴影
 */

@interface PhoneMagazineCell : UITableViewCell <UIAlertViewDelegate>
{
    UIView *bgView;
    UIImageView *imageView;
    UIView *imageTitleBgView;
    UILabel *imageTitleLabel;
    UIImageView *timeImageView;
    UILabel *timeLabel;
    UILabel *titleLabel1;
    UIImageView *lineView1;
    UILabel *titleLabel2;
    UIImageView *lineView2;
    UILabel *titleLabel3;
    
    MagazineIconAndNameView *iconAndNameView;
    
    UIButton *deleteButton;
    
    CAGradientLayer *gradient;
    
    float x;               //卡片向左滑动时有一个基准坐标x值
}

@property(nonatomic, weak) id<PhoneMagazineCellDelegate> delegate;
@property(nonatomic, strong) UpdatePeriodicalInfo *updatePeriodicalInfo;

- (void)loadUpdatePeriodicalInfo:(UpdatePeriodicalInfo *)up;
- (void)applyTheme;
- (void)resetViewFrame;


@end
