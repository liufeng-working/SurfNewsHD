//
//  PhoneShareWeiboView.h
//  SurfNewsHD
//
//  Created by XuXg on 15/1/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneshareWeiboInfo.h"

@interface WeiboInfo : NSObject

@property(nonatomic,readonly)NSString *title;
@property(nonatomic,readonly)UIImage *weiboIcon;
@property(nonatomic,readonly)WeiboType weiboType;

-(id)initWithWeiboType:(WeiboType)type;
@end


@protocol PhoneShareButtonDelegate <NSObject>

@required
-(void)btnClickWithType:(NSInteger)index;

@end
@interface PhoneShareButton : UIControl

@property(nonatomic,assign)id<PhoneShareButtonDelegate> buttonDelegate;
@property(nonatomic,strong)WeiboInfo * weiboInfo;

@end

@protocol PhoneShareBgViewDelegate <NSObject>

@required
-(void)selectWeiboTypeWithIndex:(NSInteger)index;

@end

@interface PhoneShareBgView : UIView<PhoneShareButtonDelegate>

@property(nonatomic,assign)id<PhoneShareBgViewDelegate> bgViewDelegate;
@property(nonatomic,strong)NSArray * weiBoInfoList;
@property(nonatomic,strong)UIColor * backGroundColor;  //默认是白色

@end



@interface PhoneShareWeiboView : UIView<PhoneShareBgViewDelegate>

@property(nonatomic,strong)UIColor *weiboViewBgColor; // 默认 0.5透明黑色

-(void)weiboModel:(WeiboViewLayoutModel)model
        weiboType:(WeiboType)type;

@end
