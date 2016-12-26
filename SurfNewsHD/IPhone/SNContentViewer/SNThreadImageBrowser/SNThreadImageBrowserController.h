//
//  SNThreadImageBrowserViewController.h
//  SurfNewsHD
//
//  Created by Tianyao on 16/1/7.
//  Copyright © 2016年 apple. All rights reserved.
//

typedef enum
{
    SNThreadImageBrowserControllerOutImgViewPointLeftUp =1,
    SNThreadImageBrowserControllerOutImgViewPointRightUp,
    SNThreadImageBrowserControllerOutImgViewPointLeftDown,
    SNThreadImageBrowserControllerOutImgViewPointRightDown
}SNThreadImageBrowserControllerOutImgViewPointType;

#define myScreenHeight  [UIScreen mainScreen].bounds.size.height
#define myScreenWidth   [UIScreen mainScreen].bounds.size.width

@protocol SNThreadImageBrowserControllerDelegate <NSObject>

- (void)getCurPage:(NSInteger)curPage;

@end

@interface SNThreadImageBrowserController :UIViewController<UIScrollViewDelegate>
@property (nonatomic,assign)CGRect photoFrame;
@property (nonatomic,strong)id<SNThreadImageBrowserControllerDelegate>myDelegate;
-(id)initWithImgUrlArr:(NSArray*)array CurPage:(NSInteger)curpage;
-(id)initWithImgULocationArr:(NSArray*)array CurPage:(NSInteger)curpage;
@end
