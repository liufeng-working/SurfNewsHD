//
//  DismissTableView.h
//  SurfNewsHD
//
//  Created by apple on 13-6-18.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSurfController.h"
@interface DismissTableView : UITableView
{
    float startY;
    UIImageView *bgImageView;
}

@property(nonatomic,strong) PhoneSurfController *dismissController;
@end
