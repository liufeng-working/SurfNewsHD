//
//  StockMarketThreadView.h
//  SurfNewsHD
//
//  Created by jsg on 14-4-29.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,stockTag)
{
    stockTagShangHai = 200,
    stockTagShenZhen,
    stockTagStartup,
};

@protocol StockMarketThreadViewDelegate <NSObject>

@optional

-(void)addUrlWithTag:(stockTag)tag;

@end
@interface StockMarketThreadView : UIView
{
    UIControl *_ShanghaiStock;
    UIImageView *_ShanghaiBanner;
    UILabel *_nameSH;
    UILabel *_newestSH;
    UILabel *_upsSH;
    UILabel *_rangeSH;
    UIImageView *_upOrdownSH;
    
    UIControl *_ShenZhenStock;
    UIImageView *_ShenZhenBanner;
    UILabel *_nameSZ;
    UILabel *_newestSZ;
    UILabel *_upsSZ;
    UILabel *_rangeSZ;
    UIImageView *_upOrdownSZ;
    
    UIControl *_StartupStock;
    UIImageView *_StartupBanner;
    UILabel *_nameSS;
    UILabel *_newestSS;
    UILabel *_upsSS;
    UILabel *_rangeSS;
    UIImageView *_upOrdownSS;
    
    UIView *_SeparatorLine;
    
    CGRect _RectBanner;
    
    UILabel *timeLabel;
    
    NSMutableArray *array;
    
    int _httpRequestCount;
    
}

@property(nonatomic,assign)id<StockMarketThreadViewDelegate> delegate;
@property (nonatomic,strong) NSMutableArray *array;
@property (nonatomic,strong) UIView *_SeparatorLine;

//- (void)initWithModel:(NSMutableArray*)arr;
- (void)reloadUpsOrRange:(NSInteger)index direction:(float)UpOrRange;
- (void)addLabel:(CGRect)rect position:(NSInteger)place;
- (NSString*)GetLocalTime;
@end
