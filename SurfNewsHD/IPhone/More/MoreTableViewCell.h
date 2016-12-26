//
//  MoreTableViewCell.h
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-5-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageLoadModelView.h"
#import "SliderSwitch.h"
#import "PhoneSurfController.h"
#import "BGRadioView.h"

@class SevenSwitch;

@interface MoreTableViewCell : UITableViewCell<SliderSwitchDelegate>
{   
    UILabel             *detailLabel;
    MODEL_CHANGE        modelChange;
    
    SliderSwitch        *sliderSwicthView_Txt;
    SliderSwitch        *sliderSwicthView_Image;
    SliderSwitch        *sliderSwicthView_Night;
    
    SevenSwitch         *mySwitch;
    SevenSwitch         *nightSwitch;
    UIImageView         *rightMarkIamgeView;
    UIImageView         *rankingMarkIamgeView;
    UIImageView         *notifiMarkIamgeView;

}

@property(nonatomic,assign)BOOL isIcon;


- (void)showNotifiSwitchBt;

- (void)showUpdateSign;

- (void)showImageModelView;

- (void)showTextModelView;

- (void)showNightModelView;

- (void)showCacheSize:(NSString*)cacheSize;

- (void)detailLabelRemove;

- (void)showRightMarkImage;

/**
 *  显示通知标记图片
 */
- (void)showNotifiMarkImage:(BOOL)isShow;

@end


typedef enum {
    IMGAE_ENUM = 0,
    TEXT_ENUM
}Model_Setting_ENUM;

@interface ModelSettingViewController : PhoneSurfController<BGRadioViewDelegate>{
    Model_Setting_ENUM      model_enum;
    
    BGRadioView *imageViewSortBy;
    BGRadioView *textViewSortBy;
}
- (void)setModelEnum:(Model_Setting_ENUM)model_E;

@end
