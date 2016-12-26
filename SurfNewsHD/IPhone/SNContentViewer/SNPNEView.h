//
//  SNPNEView.h
//  SurfNewsHD
//
//  Created by XuXg on 14/11/24.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMHTTPFetcher.h"
#import "SurfJsonRequestBase.h"


@interface EnergyDataRequest : SurfJsonRequestBase

@property long newsid;
@property NSInteger energy;
@property NSInteger type;
@property NSInteger clientType;

- (id)initWithThreadSummary:(ThreadSummary *)td andEnergyScore:(long)energyScore;

@end



@protocol SurfEnergyDelegate <NSObject>
// 分享正能量
-(void)shareEnergy:(long)energyScore;
-(void)showShareView;
-(void)closeEnergyView:(long)energyScore;


@end



// 正负能量
@interface SNPNEView : UIView

@property(nonatomic,weak)id<SurfEnergyDelegate> delegate;
@property(nonatomic,strong)GTMHTTPFetcher *httpFecther;

-(void)loadingWithThread:(ThreadSummary*)thread;
-(void)clearResource;
@end


// 光环按钮
@interface CustomCircleBtn : UIButton

+(id)circleButton:(BOOL)isPositive point:(CGPoint)p;


// 开始，暂停 动画
-(void)stateAction;
-(void)stopAction;
-(BOOL)isStop;

// 释放资源在不用的时候
-(void)clearResource;

@end

