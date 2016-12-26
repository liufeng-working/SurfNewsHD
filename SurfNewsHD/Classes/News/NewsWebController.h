//
//  NewsWebController.h
//  SurfNewsHD
//
//  Created by apple on 13-1-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfNewsViewController.h"
#import "HotChannelsThreadsResponse.h"
#import "NewsWebListView.h"
#import "RefreshWebView.h"
#import "MBProgressHUD.h"
#import "ThreadContentDownloader.h"
#import "FPPopoverController.h"
#import "WebviewFontController.h"
#import "ImageDownloader.h"
#import "FavsManager.h"
#import "NewsGalleryView.h"
#import "MyWindow.h"
#import "PhoneNewsData.h"
#import "PhoneNewsManager.h"
typedef enum {
    NewsWebrStyleHot = 0,   //热推,默认
    NewsWebrStyleSubs = 1,  //订阅源
    NewsWebrStyleNewest = 2,//最近更新
    NewsWebrStyleFav = 3,    //收藏
    NewsWebrStylePhoneNews = 4    //手机报
} NewsWebrStyle;

@interface NewsWebController : SurfNewsViewController<NewsWebListViewDelegate,RefreshWebViewDelegate,
UIWebViewDelegate,WebviewFontControllerDelegate,MultiDragDelegate,UIGestureRecognizerDelegate,
UIAlertViewDelegate>
{
    NSMutableArray *channels;
    NewsWebListView *webListView;
    RefreshWebView *webview;
    NSMutableArray *imageDownloaderArr;
    UIButton *collection;
    UIImageView *loadingView;
    UILabel *loadingLabel;
    
    HotChannel *hotChannel;
    SubsChannel *subsChannel;
    UIButton *loading_Eror;
#ifdef ipad
    
#else
    UIImageView *bgImage;
#endif
}
//传入请求数据，可以刷新数据
@property(nonatomic,strong) HotChannel *hotChannel;
@property(nonatomic,strong) SubsChannel *subsChannel;
@property(nonatomic) NewsWebrStyle webStyle;

@property(nonatomic,strong) ThreadSummary*currentThread;
@property(nonatomic,strong) PhoneNewsData*currentNewsData;
//传入数组数据，不可以刷新数据
@property(nonatomic,strong) NSMutableArray *channels;
@property(nonatomic) NSInteger currentIndex;
-(void)downloadedImages:(NSArray *)imageArr;

@end
