//
//  LoadingController.h
//  SurfNewsHD
//
//  Created by apple on 13-1-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfNewsViewController.h"
#import "NewVersionGuideView.h"
#import "GuideViewController.h"

@interface LoadingController : SurfNewsViewController<NewVersionGuideViewDelegate,
GuideViewControllerDelegate>
{
    UIImageView *loadingImage;
    UIActivityIndicatorView *_activityView;
}

@end
