//
//  ContentShareView.h
//  SurfNewsHD
//
//  Created by jsg on 13-10-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageMutiButton.h"

#define UISELECTBUTTON_MIN_NUMBER 3
#define InitialTag          10000
typedef enum
{
    Weixin,
    WeixinTimeline,
    SinaWeibo,
    TencentWeibo,
//    Renren,
    ChinaMobileWeibo,
    ChinaSMS
} ShareMode;

@interface ContentShareView : UIView<UITextViewDelegate,UITextFieldDelegate,UIScrollViewDelegate,ImageMutiButtonDelegate>{
    
    UIScrollView *m_mainScreen;
    UITextView *m_shareWord;
    UILabel *m_lineLabel;
    UITextField *m_shareAds;
    UIScrollView *m_scrollPhotos;
    UILabel *m_remainLab;
    UIButton *m_clearButton;    
    NSMutableArray *m_numOfPhotos;
    
    NSInteger textViewHeight;
    NSInteger textFieldHeight;
    NSInteger scrollPhotosHeight;
    
    NSMutableArray *m_Array;
    NSInteger seletedCount;
    NSInteger isRepeat;
    
    //SYZ 分享图片数组地址 ，选中文字，新闻链接
    NSMutableArray *m_shareArray;
    NSString *m_shareStr;
    NSString *m_shareNewsAds;
    ShareMode m_shareToWeibo;
    UIImage *m_shareImage;
}

@property (nonatomic) UIScrollView *m_mainScreen;
@property (nonatomic) UITextView *m_shareWord;
@property (nonatomic) UILabel *m_lineLabel;
@property (nonatomic) UITextField *m_shareAds;
@property (nonatomic) UIScrollView *m_scrollPhotos;
@property (nonatomic) NSMutableArray *m_numOfPhotos;
@property (nonatomic) UILabel * m_remainLab;
@property (nonatomic) UIButton *m_clearButton;
@property (nonatomic) UIImage *m_shareImage;

@property (nonatomic) NSMutableArray *m_shareArray;
@property (nonatomic) NSString *m_shareStr;
@property (nonatomic) NSString *m_shareNewsAds;
@property (nonatomic) ShareMode m_shareToWeibo;

- (void)initShareWord;
- (void)initShareAds;
- (void)initSharePhotos;
- (void)remainlab:(NSString *)str;
- (void)reloadPhotosOnline;
- (void)reloadPhotosOffline;
- (void)addSubviews;
- (void)ShareImgArray:(NSInteger)imgIndex;
- (IBAction)clearPressed:(id)sender;
- (ImageMutiButton *)ImageViewWithIndex:(NSUInteger)index;
- (void)reloadAllImageMutiButton;
- (void)nightModeChange;
- (BOOL)orientationImg:(CGFloat)height
                      :(CGFloat)width;

- (void)setShareWordText:(NSString*)text;
- (void)setShareMode:(ShareMode)mode;
- (void)setShareAds:(NSString*)ads;
- (void)setShareNewsAds:(NSString*)newsAds;
- (void)setShareStr:(NSString*)str;

- (void)setNumOfPhotos:(NSMutableArray*)photos;
- (void)setPic:(UIImage*)pic;
@end
