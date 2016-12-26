//
//  BelleGirlDesView.h
//  SurfNewsHD
//
//  Created by XuXg on 15/11/11.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>


/**********************不喜欢 举报 小窗口*****************************/
typedef NS_ENUM(NSInteger, BelleMore_type) {
    Belle_hate = 1,  // 不喜欢
    Belle_report     //举报
} ;


/**********************爱心小窗口*****************************/
@protocol LikeBelleGirlViewDelegate <NSObject>
- (void)setLikeGirlLoveValue;
@end




/**********************美女浏览页*****************************/
@protocol BelleGirlDesViewDelegate <NSObject>
- (void)nextRight;
- (void)priorLeft;
- (void)didBelleGirlDesViewToolBarBelleGirlBt:(ThreadSummary*)ts;

@end


@protocol BelleGirlViewDelegate;

@interface BelleGirlView : UIView
@property (nonatomic, assign)id<BelleGirlViewDelegate>delegate;

@end



@protocol BelleGirlViewDelegate <NSObject>

- (void)removeBelleView:(BelleGirlView *)belleView;

- (void)clickBt:(BelleMore_type)index;

@end


@interface LikeBelleGirlView : UIView{
    UIImageView *loveIconImageView;
    UILabel *loveValue;
}
@property(nonatomic,assign)CGPoint loveCenter;
@property (nonatomic, assign)id<LikeBelleGirlViewDelegate>delegate;
- (void)setLoveValue:(NSInteger)loveValueint;

@end


/**
 *  美女详情界面
 */
@interface BelleGirlDesView : UIView<UIScrollViewDelegate, LikeBelleGirlViewDelegate>{
    UIScrollView *mainScrollView;
    
    UIImage *_img;
    UIImageView *_belleImageView;
    
    float belleimage_W;
    float belleimage_H;
    
    LikeBelleGirlView *likeView;
    
}
@property (nonatomic, weak)id<BelleGirlDesViewDelegate>delegate;
@property (nonatomic, strong)ThreadSummary *thread;

// 更新状态
-(void)updateState;

@end


