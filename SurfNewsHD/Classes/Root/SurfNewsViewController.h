//
//  SurfNewsViewController.h
//  SurfNewsHD
//
//  Created by apple on 12-11-27.
//  Copyright (c) 2012年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    ViewTitleStateNormal = 0,     // 正常状态（2条线）
    ViewTitleStateSpecial = 1,    // 特殊状态（1条线）
    ViewTitleStateNone = 2        // 没有线,以及背景
} ViewTitleState;
@interface SurfNewsViewController : UIViewController
{
    UILabel *surfTitlelabel;
}
@property(nonatomic,readonly) float StateBarHeight; // 默认60
@property(nonatomic) ViewTitleState titleState;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
-(void)popViewControllerAnimated:(BOOL)animated;
@end
