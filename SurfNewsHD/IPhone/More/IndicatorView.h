//
//  IndicatorView.h
//  iOSUIFrame
//
//  Created by Jerry Yu on 13-5-22.
//  Copyright (c) 2013年 adways. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IndicatorViewDelegate;
@interface IndicatorView : UIView {
	UIActivityIndicatorView     *activityIndicator_;
    UIImageView                 *containerView_;
    UILabel                     *messageLabel_;
    UIButton                    *closeButton_;
    id<IndicatorViewDelegate>   delegate_;
}

@property (nonatomic, readonly) UIActivityIndicatorView     *activityIndicator;
@property (nonatomic, readonly) UILabel                     *messageLabel;
@property (nonatomic, readonly) UIImageView                 *containerView;
@property (nonatomic, assign)   id<IndicatorViewDelegate>   delegate;

- (void)hideCloseButton:(BOOL)hidden;
- (id) initWithOutBgWithFrame:(CGRect)frame;
@end

@protocol IndicatorViewDelegate <NSObject>

- (void)indicatorViewDidTapCloseButton:(IndicatorView*)indicatorView;

@end