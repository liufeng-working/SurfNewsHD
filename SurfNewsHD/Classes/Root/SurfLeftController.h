//
//  SurfLeftController.h
//  SurfNewsHD
//
//  Created by apple on 13-1-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//
#ifdef ipad
#import "SurfNewsViewController.h"
#import "SubsChannelsListResponse.h"
#import "LeftSubsChannelCell.h"
#import "LeftAllSubsView.h"
#import "SurfSettingController.h"
#import "MGSplitDividerView.h"
@class SurfLeftController;
@protocol SurfLeftControllerDelegate <NSObject>
//Section
- (NSInteger)numberOfSectionsInLeft:(SurfLeftController *)controller;
//Row
- (NSInteger)numberOfRowsInSection:(NSInteger)section
                              left:(SurfLeftController *)controller;
//SelectRow
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
                         left:(SurfLeftController *)controller;
//row Height
- (CGFloat)numberOfAtIndexPath:(NSIndexPath *)indexPath
                      left:(SurfLeftController *)controller;
//TableView Height
- (CGFloat)heightForTableViewInSection:(NSInteger)section
                      left:(SurfLeftController *)controller;
//can Move
- (BOOL)scrollViewCanMoveLeft:(UIViewController *)controller
        numberOfRowsInSection:(NSInteger)section;
//SubsChannel
- (SubsChannel *)scrollViewForChannel:(UIViewController *)controller
        numberOfIndexPath:(NSIndexPath *)section;
-(NSIndexPath *)currentIndex;
@optional
-(void)splitePosition:(CGFloat)position Animated:(BOOL)animate;
-(CGFloat)splitePositionInLeft:(UIViewController *)controller;
@end

@interface SurfLeftController : SurfNewsViewController<UITableViewDataSource,
UITableViewDelegate,UIGestureRecognizerDelegate,LeftAllSubsViewDelegate>
{
    float beganTouchPosition;
    LeftSubsChannelCell *selectCell;
    
    UIImageView *maskTopView;
    UIImageView *maskBottomView;
    
    LeftAllSubsView *leftAllSubsView;
    
    UIButton *headerLogo;
    
    BOOL canMove;
    MGSplitDividerBeganStyle style;
}
@property(nonatomic,assign) id <SurfLeftControllerDelegate>delegate;
-(void)reloadTableView;
-(void)reloadMaskView;
-(void)loginAction;
@end
#endif