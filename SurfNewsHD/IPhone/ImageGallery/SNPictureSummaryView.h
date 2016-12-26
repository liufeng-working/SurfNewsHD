//
//  SNPictureSummary.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-6-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

// 这个是一个固定大小的控件
@interface SNPictureSummaryView : UIView{
    UIScrollView *_scrollView;
    UILabel *_titleLabel;
    UILabel *_descLabel;
    
    float _unfoldY; // 展开的Y坐标
    float _foldY;   // 收缩的Y坐标
    
    UIImage *_upArrow;
    UIImage *_downArrow;
    
    UIButton *_unfoldBtn;  // 展开按钮
}

@property(nonatomic,weak,readonly)NSString *title;
@property(nonatomic,weak,readonly)NSString *describe;

- (id)initWithBottomY:(float)btmY;

//设置默认状态
- (void)setNormalState:(BOOL)isAction;
- (void)setTitle:(NSString *)title;
- (void)setDesc:(NSString *)desc;

- (void)setBottomY:(float)btmY;
@end
