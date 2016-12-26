//
//  ContentShareController.h
//  SurfNewsHD
//
//  Created by jsg on 13-10-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuth2Client.h"
#import "ContentShareView.h"
#import "PhoneSurfController.h"
#import "PhoneSinaWeiboUserFriendsController.h"

@class ContentShareController;

@interface ContentShareController : PhoneSurfController<SendWeiboDelegate, NightModeChangedDelegate, PhoneSinaWeiboUserFriendsControllerDelegate>
{
    ContentShareView* m_contentShareView;
    UIView *m_toolsBottomBar;
    UIButton *shareButton;
    UIButton *sendButton;
    SendWeibo *sendWeibo;
    BOOL keyboardShowing;
}
- (ContentShareView *)curShareView;
- (IBAction)share:(id)sender;
- (IBAction)send:(id)sender;
- (void)clearButtonOnToolsBar;
@end
