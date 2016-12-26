//
//  PhoneSettingBar.m
//  SurfNewsHD
//
//  Created by apple on 13-6-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSettingBar.h"
#import "AppSettings.h"
#import "ThemeMgr.h"

@implementation PhoneSettingBar
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        ThemeMgr *themeMgr = [ThemeMgr sharedInstance];
        
        shadowView = [[UIView alloc] initWithFrame:self.bounds];
        shadowView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        [self addSubview:shadowView];
        
        float w = CGRectGetWidth(frame);
        float h = CGRectGetHeight(frame);
        CGRect bgVR = CGRectMake(0.f, h, w, 120.0f);
        bgView = [[UIView alloc] initWithFrame:bgVR];
        bgView.backgroundColor = [UIColor colorWithHexString:[themeMgr isNightmode]?@"2D2E2F":@"FFFFFF"];
        [self addSubview:bgView];
        
        UIImageView *fontSize = [[UIImageView alloc] initWithFrame:CGRectMake(15.0f, 25.0f, 20.0f, 25.0f)];
        fontSize.image  = [UIImage imageNamed:@"fontSize.png"];
        [bgView addSubview:fontSize];
        
        sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, fontSize.frame.origin.y,
                                                                       70.0f, 25.0f)];
        sizeLabel.backgroundColor = [UIColor clearColor];
        [sizeLabel setTextAlignment:NSTextAlignmentCenter];
        sizeLabel.font = [UIFont systemFontOfSize:15.0f];
        sizeLabel.textColor = [UIColor colorWithHexString:[themeMgr isNightmode ]?@"FFFFFF":@"999292"];
        sizeLabel.text = @"正文字号";
        [bgView addSubview:sizeLabel];

        UIImageView *nightModel = [[UIImageView alloc] initWithFrame:CGRectMake(15.0f,
                                                                                CGRectGetMaxY(fontSize.frame) + 20.0f,
                                                                                20.0f, 25.0f)];
        nightModel.image  = [UIImage imageNamed:@"nightModel.png"];
        [bgView addSubview:nightModel];

        nightLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, nightModel.frame.origin.y,
                                                                       70.0f, 25.0f)];
        nightLabel.backgroundColor = [UIColor clearColor];
        [nightLabel setTextAlignment:NSTextAlignmentCenter];
        nightLabel.font = [UIFont systemFontOfSize:15.0f];
        nightLabel.textColor = [UIColor colorWithHexString:[themeMgr isNightmode ]?@"FFFFFF":@"999292"];
        nightLabel.text = @"夜间模式";
        [bgView addSubview:nightLabel];

        
        if (!sliderSwicthView_Txt) {
            sliderSwicthView_Txt = [[SliderSwitch alloc] init];
            [sliderSwicthView_Txt setDelegate:self];
            [sliderSwicthView_Txt setModelChange:TEXT_MODEL];
            [sliderSwicthView_Txt setFrameHorizontal:CGRectMake(110.0f, sizeLabel.frame.origin.y, 200.0f, 25.0f) numberOfFields:4 withCornerRadius:4.0];
            [sliderSwicthView_Txt setText:@"小" forTextIndex:1];
            [sliderSwicthView_Txt setText:@"中" forTextIndex:2];
            [sliderSwicthView_Txt setText:@"大" forTextIndex:3];
            [sliderSwicthView_Txt setText:@"极大" forTextIndex:4];
            [bgView addSubview:sliderSwicthView_Txt];
        }
        [sliderSwicthView_Txt refresh];
        
        if (!sliderSwicthView_Night) {
            sliderSwicthView_Night = [[SliderSwitch alloc] init];
            [sliderSwicthView_Night setDelegate:self];
            [sliderSwicthView_Night setModelChange:NIGHT_MODEL];
            [sliderSwicthView_Night setFrameHorizontal:CGRectMake(110.0f, nightLabel.frame.origin.y, 200.0f, 25.0f) numberOfFields:2 withCornerRadius:4.0];
            [sliderSwicthView_Night setText:@"关" forTextIndex:1];
            [sliderSwicthView_Night setText:@"开" forTextIndex:2];
            
            [bgView addSubview:sliderSwicthView_Night];
        }
        [sliderSwicthView_Night refresh];
    }
    return self;
}


// 显示设置面板，动态
- (void)showSettingBar:(BOOL)isShow
             isAnimate:(BOOL)animate
            completion:(void (^)(BOOL finished))completion
{
    float h = CGRectGetHeight(self.bounds);
    float bgH = CGRectGetHeight(bgView.bounds);
    float bgW = CGRectGetWidth(bgView.bounds);
    
    if (animate) {
        [UIView animateWithDuration:0.3f animations:^{
            if (isShow) {
                shadowView.alpha = 1.f;
                bgView.frame = CGRectMake(0.f, h-bgH-43, bgW ,bgH);
            }
            else {
                shadowView.alpha = 0.f;
                bgView.frame = CGRectMake(0.f, h, bgW, bgH);
            }
        } completion:completion];
    }
    else {
        if (isShow) {
            shadowView.alpha = 1.f;
            bgView.frame = CGRectMake(0.f, h-bgH-43, bgW ,bgH);
        }
        else {
            shadowView.alpha = 0.f;
            bgView.frame = CGRectMake(0.f, h, bgW, bgH);
        }
    }
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate hiddenSettingBar];
}

-(void)slideView:(SliderSwitch *)slideswitch switchChangedAtIndex:(NSUInteger)index{
    if (TEXT_MODEL == slideswitch.modelChange) {        
        if (index == 0) {
            [self.delegate settingFontSize:kWebContentSize1];
        }
        else if (index == 1)
        {
            [self.delegate settingFontSize:kWebContentSize2];
        }
        else if (index == 2)
        {
            [self.delegate settingFontSize:kWebContentSize3];
        }
        else if (index == 3)
        {
            [self.delegate settingFontSize:kWebContentSize4];
        }
    }
    else if (NIGHT_MODEL == slideswitch.modelChange)
    {
        [[ThemeMgr sharedInstance] changeNightmode:(index == 1)];

        ThemeMgr *themeMgr = [ThemeMgr sharedInstance];
        bgView.backgroundColor = [UIColor colorWithHexString:[themeMgr isNightmode ]?@"2D2E2F":@"FFFFFF"];
        sizeLabel.textColor =  [UIColor colorWithHexString:[themeMgr isNightmode ]?@"FFFFFF":@"999292"];
        nightLabel.textColor =  [UIColor colorWithHexString:[themeMgr isNightmode ]?@"FFFFFF":@"999292"];
        [sliderSwicthView_Txt refresh];
        [sliderSwicthView_Night refresh];

    }

    [self.delegate hiddenSettingBar];
}


@end
