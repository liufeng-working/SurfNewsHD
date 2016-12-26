//
//  SlideView.h
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-5-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ImageLoadModelView.h"


@protocol SliderSwitchDelegate;



@interface SliderSwitch : UIView
{
    UIImageView *backgroundImageView;
    UIView *line1, *line2, *line3;
}
@property(nonatomic)int numberOflabels;
@property(nonatomic,retain)UILabel *labelOne,*labelTwo,*labelThree,*labelFour;
@property(nonatomic,retain)UIButton *toggleButton;
@property(nonatomic,assign)id<SliderSwitchDelegate> delegate;
@property (nonatomic, assign) MODEL_CHANGE      modelChange;



- (void)setFrameHorizontal:(CGRect)frame numberOfFields:(NSInteger)number withCornerRadius:(CGFloat)cornerRadius;
- (void)setText:(NSString *)text forTextIndex:(NSInteger )number;

- (void)refresh;

- (void)setFrameBackgroundColor:(UIColor *)color;
- (void)setSwitchFrameColor:(UIColor *)color;
- (void)setTextColor:(UIColor *)color;
- (void)setTextFont:(UIFont *)font;
-(void)setSwitchBorderWidth:(CGFloat)width;



@end



@protocol SliderSwitchDelegate <NSObject>
-(void)slideView:(SliderSwitch *)slideswitch switchChangedAtIndex:(NSUInteger)index;

@end


