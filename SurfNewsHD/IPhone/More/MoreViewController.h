//
//  MoreViewController.h
//  iOSUIFrame
//
//  Created by Jerry Yu on 13-5-22.
//  Copyright (c) 2013年 adways. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownLoadViewController.h"
#import "ImageLoadModelView.h"
#import "PhoneLoginController.h"
#import "SocialAccountController.h"
#import "ThreadsManager.h"
#import "PhoneSurfController.h"
#import "iTunesLookupUtil.h"
#import "FeedbackViewController.h"
#import "UserManager.h"
#import "CustomCellBackgroundView.h"
#import "OfflinesMagazineController.h"
#import "CameraViewController.h"

@class SettingViewController;
@class ProductInfoController;
@class MoreViewController;

@protocol AccountViewDelegate <NSObject>

-(void)didAccountView;

- (void)showCreditAnimalView:(NSString *)credit_Str;

@end

@protocol ShareCellViewDelegate <NSObject>

-(void)didShareCellView;

@end

@protocol IndicatorViewDelegate <NSObject>

-(void)didIndicatorView;

@end

@protocol ExpButtonViewDelegate <NSObject>

- (void)didExpButton;

@end

@interface LevelLabView : UIView{
    UILabel *lvlLab;
    UILabel *titleLab;
    UIImageView *whiteImage;
}

- (void)setLvlLab:(NSString *)lvlStr;
- (void)setTitleLab:(NSString *)lvlStr;

@end

@interface ExpButtonView : UIView{
    UILabel *explabel;
    UILabel *expLab;
}
@property (nonatomic, assign)id<ExpButtonViewDelegate>delegate;
- (void)setExpLab:(NSString *)labName;

@end

@interface AccountView : UIView<ExpButtonViewDelegate>{

    UIView *touchView;
    UIImageView *iconImageView;
    UILabel *titleLab;
    UILabel *numLab;
    UIButton *buttonLab;
    ExpButtonView *levelButton;
}
@property(nonatomic,assign)id<AccountViewDelegate>delegate;

/**
 *  用户信息发送改变
 */
-(void)updateUserInfo;

@end

@interface ShareCellView : UIView{
    UIImage *bgImage;
    UIImageView *bgImageView;
    UIView *touchView;
    UIImageView *iconImageView;
    UILabel *titleLab;
    
    UIImage         *bindSinaImage;
   
    UIImage         *unBindSinaImage;
    
    UIImageView *sinaImageView;
}
@property(nonatomic,assign)id<ShareCellViewDelegate>delegate;

@end

@interface IndicatorCellView : UIView
{
    UIView *touchView;
    UIImageView *iconImageView;
    UILabel *titleLab;
    UILabel *detailLab;
    UILabel *numberlabel;
    UILabel *detailLabel2;
    UIImageView *telephonechargeimageview;
    UILabel *telephonelabel;
    UIImageView *flowimageview;
    UILabel *flowlabel;
    UIImageView *redFlowImageView;
    UIImageView *whiteFlowImageView;
    UILabel *usedLabel;
    UILabel *allLabel;
    
    UIActivityIndicatorView *_activityView; // 风火轮
}

@property(nonatomic,assign)id<IndicatorViewDelegate>delegate;

// 更新UI
-(void)updateViewUI;
@end


@interface MoreButton : UIControl {
    __weak UIView *_selectView;
    __weak UIImageView *_iconImageView;
    __weak UILabel *_titleLab;
    UIImageView *notifiMarkIamgeView;
}

+(CGSize)sizeWithFits;

@property(nonatomic,copy)NSString* titleStr;
@property(nonatomic,assign)UIImage *btnImage;


-(void)showNotifiMark;

@end


@protocol UserCenterViewCrlDelegate <NSObject>

- (void)quitAccount;

@end

@interface MoreViewController : PhoneWeiboController<UIAlertViewDelegate, iTunesLookupUtilDelegate, FeedbackViewControllerDelegate, UserManagerObserver, NightModeChangedDelegate,  AccountViewDelegate, IndicatorViewDelegate, ShareCellViewDelegate, UserCenterViewCrlDelegate>
{
    __weak UIScrollView *_scrollView;
    BOOL              isHaveUserId;
    UILabel          *lab;
    NSInteger               collectCount;
    NSString         *cachesSize;
    BOOL              isCalcing;
    BOOL              selectMoreSubController;    //进入更多tab的子界面
    
    
    AccountView *accountView;
    ShareCellView *shareCellView;
    UIView *sectionView2;
    IndicatorCellView *indicatorCellView;
    
    UIImage *sectionView1_bgImage;
    UIImageView *sectionView1_bgImageView;
    
    UIImage *sectionView2_bgImage;
    UIImageView *sectionView2_bgImageView;

    __weak UIImageView *_line1;
    __weak UIImageView *_line2;
    __weak UIImageView *_line3;

    
    UIImageView *notifiMarkIamgeView;
}

@property (nonatomic, strong)     UITableView     *tableView;

-(BOOL)isShowUpDateStatus;
-(BOOL)isShowLoginStatus;

@end



@interface SettingViewController : PhoneSurfController<UITableViewDataSource, UITableViewDelegate>
{
    UITableView     *SettingTableView;
    NSString         *cachesSize;
}


@end


@interface ProductInfoController : PhoneSurfController<UITableViewDataSource, UITableViewDelegate>
{
    UITableView     *productInfoTableView;

    UILabel          *lab;
}

@end



@protocol UserCenterTableCellDelegate <NSObject>

- (void)didQuitBt:(id)sender;

@end


@class UserAlertView;

typedef enum
{
    User_Rportrait_Type = 0,
    User_Sex_Type
}UserAlert_Type;


@protocol UserAlertViewDelegate <NSObject>

- (void)didAlertBt:(NSUInteger)index andAlert_Type:(UserAlert_Type)type;

- (void)removeAlertView:(UserAlertView *)sendler;

@end


@interface UserCenterViewController : PhoneSurfController<UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UserCenterTableCellDelegate, UserAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraViewControllerDelegate>{
    
    UITableView *userTableView;
    UIView *bgView;
    UserAlertView *userAlertView;
    
    CameraViewController *cameraViewCrl;
}

@property (nonatomic, assign)id<UserCenterViewCrlDelegate>delegate;

@end

enum UserMenuItemIndex{
    User_Section0 = 0,
    User_Rportrait = 0,
    User_NickName,
    
    User_Section1 = User_Section0 + 1,
    User_Sex = 0,
    User_CellNum,
    
    User_Section2 = User_Section1 + 1,
    User_Experience = 0,
    
    User_Section3 = User_Section2 + 1,
    User_Level = 0,//,
    User_LevelInfo
//    User_LevelExplain
};


@interface UserCenterTableCell : UITableViewCell{
    UIImageView *headPicImageView;
    UILabel *desLab;
    UILabel *desLabInfo;
}
@property (nonatomic, assign)id<UserCenterTableCellDelegate>delegate;

- (void)showQuitBt;

- (void)setDesLab:(NSString *)desStr;
- (void)setDesLabInfo:(NSString *)desStr;
- (void)setDesLablevel:(NSString *)desStr;
- (void)setDesLabExp:(NSString *)desStr;
- (void)setDesLabPhone:(NSString *)desStr;

- (void)showHeadPic;

@end


@interface UserAlertView : UIView{
    UserAlert_Type alert_Type_;
    NSUInteger sex_Index;
    
    UIImageView *ladyImageView;
    UIImageView *menImageView;
}
@property (nonatomic, assign)id<UserAlertViewDelegate>delegate;

- (id)initWithFrame:(CGRect)frame WithUserAlert_Type:(UserAlert_Type)AlertType;

@end


@interface ModifyNickNameViewController : PhoneSurfController<UITextFieldDelegate>{
    UITextField *phoneTextField;
    
    BOOL keyboardShowing;

}

@end
