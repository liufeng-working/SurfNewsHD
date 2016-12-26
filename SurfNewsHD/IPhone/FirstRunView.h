//
//  FirstRunView.h
//  SurfBrowser
//
//  Created by  on 11-12-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstRunView : UIView{

    UIImageView *imageView;
    NSInteger viewType;
}
- (id)initShowViewType:(NSString *)key;
@end


typedef enum
{
    MainApp_Type = 0,        //初入应用新手提示
    MainBody_Type = 1       //初入正文新手提示
} MainViewGuide_Type;



// 主界面新手引导
@interface MainViewGuide : UIView{
    MainViewGuide_Type mainViewGuideType;
    UIImageView *imagev;
}
-(id)initWithFrame:(CGRect)frame andWithType:(MainViewGuide_Type)mianType;

@end

