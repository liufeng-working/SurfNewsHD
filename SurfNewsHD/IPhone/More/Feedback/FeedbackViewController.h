//
//  FeedbackViewController.h
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-6-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSurfController.h"
#import "BgScrollView.h"
#import "TQStarRatingView.h"

@protocol FeedbackViewControllerDelegate;

@interface FeedbackViewController : PhoneSurfController<UITextViewDelegate, UIAlertViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, BgScrollViewDelegate, NightModeChangedDelegate,StarRatingViewDelegate>
{
    BOOL             isLogin;
    BgScrollView    *bgView;
    UIView          *feedBackBgView;
    UITextView      *feedBackTextView;
    UILabel         *contLab;
    UILabel         *placeHoldLab;
    UILabel         *placeHoldLab2;
    UILabel         *FirstLabel;
    UILabel         *SecondLabel;
    UIImageView     *Line;
    UIImageView     *HalfStarImageView;
    UIImage         *HalfStarImage;
    UITapGestureRecognizer *TapOnce;
    float            endY;
    BOOL keyboardShowing;
    NSMutableDictionary *_results;
    
    UILabel * _npsLabel;         //用于显示 APP推荐度 的分数
    UILabel * _sfnLabel;         //用于显示 使用满意度 的分数
}
@property (nonatomic, strong) TQStarRatingView *starRatingView;
@property (nonatomic, strong) TQStarRatingView *starRatingViewSecond;
@property (nonatomic, assign) id<FeedbackViewControllerDelegate>    delegate;

@end


@protocol FeedbackViewControllerDelegate <NSObject>

- (void)didFinishi:(FeedbackViewController *)feedbackViewCrl;

@end