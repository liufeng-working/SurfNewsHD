//
//  WeatherRefreshView.h
//  SurfNewsHD
//
//  Created by NJWC on 16/1/25.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RefreshViewHeight 35   //刷新view的高度
#define RefreshViewWidth  35   //刷新view的宽度
#define RefreshDistance   55   //刷新的位置
#define PullMaxDistance   110  //最大拉伸距离

@protocol WeatherRefreshViewDelegate <NSObject>

@required
//判断是否应该进行刷新
-(void)shouldStartRefreshWeather;

@optional
//刷新结束，停止转动(停止的是控制器里，刷新按钮的转动)
-(void)refreshAnimationDidEnd;

@end

@interface WeatherRefreshView : UIView

@property(nonatomic,assign) CGFloat pullDistance;   //下拉的距离
@property(nonatomic,assign) BOOL    isEnd;          //拖拽结束
@property(nonatomic,assign) BOOL    isAnimation;    //是否正在进行动画
@property(nonatomic,weak)id<WeatherRefreshViewDelegate> delegate;

//最后的旋转动画
- (void)startAnimation;

//停止动画
- (void)stopAnimation;

@end
