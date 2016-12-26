//
//  SurfRootViewController.h
//  SurfNewsHD
//
//  Created by apple on 12-11-27.
//  Copyright (c) 2012年 apple. All rights reserved.
//

#import "SurfNewsViewController.h"
#import "MGSplitViewController.h"
#import "SurfLeftController.h"
#import "SurfRightController.h"
#import "SubsChannelsListResponse.h"


@interface SurfRootViewController :
MGSplitViewController<MGSplitViewControllerDelegate,
SurfLeftControllerDelegate,SurfRightControllerDelegate,
SubsChannelChangedObserver>
{
    SurfLeftController *leftController;
    SurfRightController *rightController;
    NSInteger currentSelect;
    NSIndexPath *currentIndex;
    NSMutableArray *subsChannels;

}

@property(nonatomic,strong) SurfRightController *rightController;
@property(nonatomic,strong) SurfLeftController *leftController;
-(void)changedSelectController:(NSIndexPath *)changedIndex;

@property(nonatomic) BOOL willAppear;

@end
