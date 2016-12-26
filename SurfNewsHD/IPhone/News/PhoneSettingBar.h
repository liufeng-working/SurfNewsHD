//
//  PhoneSettingBar.h
//  SurfNewsHD
//
//  Created by apple on 13-6-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SliderSwitch.h"

@class PhoneSettingBar;
@protocol PhoneSettingBarDelegate

@required
// 菜单中字体大小改变
-(void)settingFontSize:(float)size;

// 隐藏设置栏
-(void)hiddenSettingBar;
@end


@interface PhoneSettingBar : UIView<SliderSwitchDelegate>
{
    UIView *bgView;
    UIView *shadowView;
    UILabel *nightLabel;
    UILabel *sizeLabel;
        
    SliderSwitch        *sliderSwicthView_Txt;
    SliderSwitch        *sliderSwicthView_Night;
}
@property(nonatomic,weak) id<PhoneSettingBarDelegate> delegate;


// 显示设置面板，动态
- (void)showSettingBar:(BOOL)isShow
             isAnimate:(BOOL)animate
            completion:(void (^)(BOOL finished))completion;
@end
