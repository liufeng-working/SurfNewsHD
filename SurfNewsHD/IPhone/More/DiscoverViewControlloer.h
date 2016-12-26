//
//  DiscoverViewControlloer.h
//  SurfNewsHD
//
//  Created by jsg on 14-10-14.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSurfController.h"
#import "CustomCellBackgroundView.h"
#import "MoreTableViewCell.h"
#import "GuideViewController.h"
#import "SNThreadViewerController.h"
#import "SNThreadViewer.h"
#import "ThreadSummary.h"
#import "NSString+Extensions.h"


@interface DiscoverViewControlloer : PhoneSurfController<UITextFieldDelegate,UITableViewDataSource, NightModeChangedDelegate,UITableViewDelegate>
{
    UIButton *searchBtn;
    
    UITableView *discoverTableView;
    
    UILabel          *lab;
    
    BOOL keyboardShowing;
    
    UIImageView *notifiMarkIamgeView;
    UIButton * searchBtnField;
    UIImageView * searchImageview;
}

@end
