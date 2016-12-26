//
//  AboutViewController.h
//  iOSUIFrame
//
//  Created by Jerry Yu on 13-5-22.
//  Copyright (c) 2013年 adways. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSurfController.h"


@interface AboutViewController : PhoneSurfController<UIAlertViewDelegate>{
    NSInteger ClickNum;
    NSString *Token;
}

-(void)UserClicked:(UIGestureRecognizer *)gestureRecognizer;

@end
