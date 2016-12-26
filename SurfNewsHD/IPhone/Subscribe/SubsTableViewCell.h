//
//  SubsTableViewCell.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThemeMgr.h"
#import "SurfTableViewCell.h"

@class SubsTableViewCell;
@class SubsChannelControl;
@class TopAndCloseView;
@class SubsChannel;


@interface SubsTableViewCell : SurfTableViewCell<UIAlertViewDelegate>{
    SubsChannel *_subsChannel;
    NSIndexPath *_cellIndex;
    UIView *_maskView;
    
    UIColor *_bgColor;
    UIColor *_selectBgColor;
    UIColor *_titleColor;
    UIColor *_lineColor; // 分割线颜色
    UIImage *_iconImage;
    
    BOOL _touchBegin;// 触摸时候的临时状态
}

+ (float)CellHeight;
- (void)reloadSubsChannel:(SubsChannel*)subs indexPath:(NSIndexPath*)path onlySubs:(BOOL)only;
@end


@class PictureThreadView;
@interface SubsThreadSummaryViewCell : SurfTableViewCell <UIGestureRecognizerDelegate>{
    UIColor *_titleColor;
    UIColor *_selectBgColor;
    UIColor *_bgColor;
    UIColor *_partinglineColor;
    UIFont *_errorFont;
    
    NSMutableArray *_threads;
    NSMutableArray *_threadsViwe;
    
    int _status; // 0 正常状态  1 加载状态   2 error
    
    CGRect _touchRect;
    
    UIActivityIndicatorView *_hotweel;
}


@property(nonatomic) NSTextAlignment titleAlignment;     // default is NSTextAlignmentLeft
@property(nonatomic) UIEdgeInsets titleEdgeInsets;       // default is UIEdgeZero

+ (float)LoadingOrErrorStateCellHeight;
- (void)reloadDataWithThreadSummaryArray:(NSArray*)threads isLoading:(BOOL)isLoading isError:(BOOL)error;

-(ThreadSummary*)getSelectionThreadSummary;

@end




@interface SubsChannelLoadMoreCell : SurfTableViewCell {
    UIColor *_bgColor;
    UIColor *_selectBgColor;
}
@property(nonatomic) NSString * title;
@property(nonatomic) UIColor *titleColor_N; // 夜间模式下的文字颜色
@property(nonatomic) UIColor *titleColor;
@end



// 置顶和退订控件
@class UITableViewEditingOperateView;
@interface CustomSubsChannelEditingView : UIView<UIGestureRecognizerDelegate>{
    UIColor *_bgColor;
    UIColor *_btnTextHLColor;   // 按钮文字高亮颜色
    UIColor *_btnHLBgColor;     // 按钮高亮背景颜色
    UIImage *_topImage;
    UIImage *_unsubsImage;
    UIColor *_separatorColor;   // 分割线颜色
    
    BOOL _topHightlight;    // 置顶高亮
    BOOL _unsubsHightlight; // 退订高亮
}
@property(nonatomic,weak)SubsChannel *subsChannel;
@property(nonatomic,weak)UITableViewEditingOperateView *operateView;
@end


// editingView操纵View
@interface UITableViewEditingOperateView : UIView
{
    UIView *_maskView;
}

// 这里只是创建和操作这个View
@property(nonatomic,strong)CustomSubsChannelEditingView *subsChannelEidtingView;

- (void)showOperateView:(CGRect)cellRect subsChannel:(SubsChannel*)sc;

- (void)hiddenOperateView;
@end