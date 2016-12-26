//
//  FlowIndicatorViewController.h
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-5-23.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSurfController.h"
#import "BgScrollView.h"


@class FlowData;
@class PackflowData;

@protocol AllPreViewDelegate <NSObject>

- (void)clickBt:(UIButton *)bt;

@end



@interface AllPreView: UIView
{
    float remain;
    float used;
    float balance;
    UILabel *balanceLab;
    UILabel *remainintLab;
    UILabel *usedintLab;
    UIButton *rechargebt;
    UIButton *lobbybt;
}
@property (nonatomic, assign) BOOL             isTwenty;
@property (nonatomic, strong) FlowData        *flowData;
@property (nonatomic, assign) id<AllPreViewDelegate>    allPreDelegate;
@end

typedef enum {
    ALL_MODEL = 0,
    MEAL_MODEL
} PROGRESS_TYPE;

@interface AllPreViewProgressView: UIView
{
    float        x;
    float       progress;
    UILabel     *usedLab;
    UILabel     *allLab;
    UIImageView *progressBg;
    UIView *progressView;
    UIImageView *dayIndexIamgeView;
}
@property (nonatomic, assign) BOOL             isTwenty;
@property (nonatomic, assign) BOOL             isFull;
@property (nonatomic, strong) FlowData        *flowData;
@property (nonatomic, assign) PROGRESS_TYPE     progressType;
@property (nonatomic, strong) PackflowData    *packData;
- (void)setProgressViewBgColor:(UIColor *)colorSet;
@end



@interface MealView: UIView<UIScrollViewDelegate>
{
    BgScrollView    *bgScrollView;
}
@property (nonatomic, assign) BOOL             isFirst;
@property (nonatomic, strong) FlowData        *flowData;
@end



@interface FlowIndicatorViewController : PhoneSurfController<UIScrollViewDelegate, AllPreViewDelegate>
{
    BOOL            isTwenty;
    UIButton        *allPreviewBt;
    UIButton        *mealBt;
    UIImageView     *loadingImageView;
    BgScrollView    *bgScrollView;
    FlowData        *flowData;
    MealView        *mealView;
    
    UIActivityIndicatorView *_activityView;
    UIView *bgView;
}

@end
