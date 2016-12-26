//
//  LoadingView.h
//  SurfNewsHD
//
//  Created by apple on 13-1-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>


// 内容加载委托
@protocol LoadContentDelegate <NSObject>
@optional
- (void)refreshContent:(id)sender;  // 刷新频道内容
- (void)loadMoreContent:(id)sender;  // 加载更过频道内容
@end



typedef enum {
    kPRStateNormal = 0,     // 正常状态
    kPRStatePulling = 1,    // 拉伸状态
    kPRStateLoading = 2,    // 加载状态
    kPRStateHitTheEnd = 3,  // 结束状态
    kPRStateLocalDisplay    // 部分显示
} PRState;

typedef enum {
    StateDescriptionTableStyleTop = 0,
    StateDescriptionTableStyleBottom = 1,
    StateDescriptionWebStyleTop = 2,
    StateDescriptionWebStyleBottom = 3
} StateDescriptionStyle;

@interface LoadingView : UIView {
    UILabel *_stateLabel;
    UILabel *_dateLabel;
    UIActivityIndicatorView *_activityView;
    CALayer *_arrow;
    BOOL _loading;
    NSDate *refreshDate;
}
@property (nonatomic,getter = isLoading) BOOL loading;
@property (nonatomic,getter = isAtTop) BOOL atTop;
@property (nonatomic) PRState state;
@property (nonatomic) StateDescriptionStyle style;

- (id)initWithFrame:(CGRect)frame atTop:(BOOL)top;
- (void)updateRefreshTitle:(NSString *)title;
- (void)updateRefreshDate:(NSDate *)date;
- (void)setState:(PRState)state animated:(BOOL)animated;
@end