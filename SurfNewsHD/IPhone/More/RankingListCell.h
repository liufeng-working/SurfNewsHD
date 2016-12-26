//
//  RankingListCell.h
//  SurfNewsHD
//
//  Created by jsg on 14-11-25.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RankingListCell : UITableViewCell{
    
    UILabel *indexLabel;     //榜单序号
    UILabel *titleLabel;     //新闻标题
    UILabel *soureLabel;     //新闻来源
    UIImageView *typeImgView;      //新闻类型
    UIImageView *statusImgView;  //状态
    UILabel *countLabel;  //能量人数
    UILabel *energyLabel;  //能量值
    
    BOOL isNightMode;
}

@property (nonatomic, retain) UILabel* indexLabel;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *soureLabel;
@property (nonatomic, retain) UIImageView *typeImgView;

@property (nonatomic, retain) UIImageView *statusImgView;
@property (nonatomic, retain) UILabel *countLabel;
@property (nonatomic, retain) UILabel *energyLabel;

@end
