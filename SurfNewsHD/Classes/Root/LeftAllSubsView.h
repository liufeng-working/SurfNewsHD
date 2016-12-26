//
//  LeftAllSubsView.h
//  SurfNewsHD
//
//  Created by apple on 13-3-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftSubsChannelCell.h"
#import "SubsChannelsManager.h"
@protocol LeftAllSubsViewDelegate <NSObject>
-(void)singleTapDetected:(SubsChannel *)channel;
-(void)managerSubs;
@end
@interface LeftAllSubsView : UIView<SubsChannelChangedObserver,LeftSubsChannelCellDelegate>
{
    UIScrollView *scrollView;
}
@property(nonatomic,assign) id <LeftAllSubsViewDelegate>delegate;
-(void)reloadSubsList;
@end
