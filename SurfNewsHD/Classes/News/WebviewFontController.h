//
//  WebviewFontController.h
//  SurfNewsHD
//
//  Created by apple on 13-1-18.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WebviewFontController;
@protocol WebviewFontControllerDelegate
-(void)sliderChanged:(float)size;
@end
@interface WebviewFontController : UITableViewController
{
    UISlider *slider;
    float value;
}
@property(nonatomic,weak) id<WebviewFontControllerDelegate> fontDelegate;
@end
