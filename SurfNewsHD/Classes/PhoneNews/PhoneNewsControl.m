//
//  PhoneNewsControl.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-3-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneNewsControl.h"
#import "UIColor+extend.h"
#import "PhoneNewsManager.h"
#import "ImageUtil.h"


#define kNewsCtrlWidth 150.f
#define kNewsCtrlHeight 150.f
#define kNewsDateCtrlWidth 72.f
#define kBgColorValue 0xFFd5d0c8



@implementation PNCtrlBase

+ (CGSize)fitSize{
    return (CGSize){kNewsCtrlWidth, kNewsCtrlHeight};
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}
- (id)initWithPoint:(CGPoint)point{
    CGRect rect = {point, [PNCtrlBase fitSize]};
    self = [super initWithFrame:rect];
    if (self) {
        // Initialization code
        [self initDeleteButton];
        [self setBackgroundColor:[UIColor colorWithHexValue:kBgColorValue]];
        
        [self addTarget:self action:@selector(ctrlClickEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)dealloc{
    [_deleteButton removeTarget:self action:@selector(deleteButtonClickEvent:)
               forControlEvents:UIControlEventTouchUpInside];
    
    [self removeTarget:self action:@selector(ctrlClickEvent) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark DeleteButton
- (void)initDeleteButton{
    if (_deleteButton)
    {
        return;
    }

    UIImage *btnImg = [UIImage imageNamed:@"delete"];
    CGSize btnSize = [btnImg size];    
    CGRect btnRect = CGRectMake(kNewsCtrlWidth-btnSize.width, kNewsCtrlHeight-btnSize.height, btnSize.width, btnSize.height);
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteButton setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [_deleteButton setFrame:btnRect];
    [_deleteButton addTarget:self action:@selector(deleteButtonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_deleteButton];
}


- (void)deleteButtonClickEvent:(UIButton*)btn{
    if (_deleteClickEvent) {
        _deleteClickEvent(self);
    }
}

-(void)ctrlClickEvent{
    if (_clickEvent) {
        _clickEvent(self);
    }
}

@end



////////////////////////////////////////////////////////////////////////
@interface PhoneNewCtrl ()
@property(nonatomic,strong)UIImageView *imgView;
@property(nonatomic,strong)UILabel *titleLabel;
@end


@implementation PhoneNewCtrl
@synthesize imgView = _imgView;
@synthesize phoneData = _phoneData;

static UIImage* defaultImage = nil;


- (id)initWithPoint:(CGPoint)point{
    if (self = [super initWithPoint:point]) {        
        
        float lrMarge = 10.f;
        float titleFontSize = 12.f;
        UIFont *font = [UIFont boldSystemFontOfSize:titleFontSize];
        CGRect titleRect = CGRectZero;
        titleRect.origin.x = lrMarge;
        titleRect.size.width = CGRectGetWidth([self bounds]) - lrMarge * 2.f;
        titleRect.size.height = font.lineHeight * 2.f;
        titleRect.origin.y = ([self bounds].size.height - titleRect.size.height) * 0.5f;
        
        _titleLabel = [UILabel new];
        [_titleLabel setHidden:YES];
        [_titleLabel setFont:font];
        [_titleLabel setNumberOfLines:2];
        [_titleLabel setFrame:titleRect];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];       
        [self insertSubview:_titleLabel belowSubview:_deleteButton];
        

        if (defaultImage == nil) {
            defaultImage = [ImageUtil imageCenterWithImage:[UIImage imageNamed:@"loading"]
                                          targetSize:[self bounds].size
                                     backgroundColor:[UIColor colorWithHexValue:KImageDefaultBGColor]];
        }
        
        _imgView = [[UIImageView alloc] initWithFrame:[self bounds]];
        [self insertSubview:_imgView belowSubview:_deleteButton];
    }
    return self;
}

- (void)reloadDate:(PhoneNewsData*)newData{
    _phoneData = newData;
    if (_phoneData != nil) {
        _imgView.image = defaultImage; // 显示加载图片
        [[PhoneNewsManager sharedInstance] getPhoneNewsCoverImg:_phoneData complete:^(BOOL result, UIImage *img) {
            if (result && img != nil) {
                [self setCoverImage:img];
                [self showTitle:NO];
            }
            else{
                // 图片加载异常，显示Title
                [self showTitle:YES];
            }
        }];
    }
    
}

- (void)setCoverImage:(UIImage*)img{
    CGSize imgSize = img.size;
    CGSize targetSize = [self bounds].size;
    UIColor *imgBgColor = [UIColor colorWithHexValue:KImageDefaultBGColor];
    if (imgSize.width > targetSize.width || imgSize.height > targetSize.height) {        
        _imgView.image = [ImageUtil imageWithImage:img scaledToSizeWithSameAspectRatio:targetSize backgroundColor:imgBgColor];
    }
    else{
        _imgView.image = [ImageUtil imageCenterWithImage:img targetSize:targetSize backgroundColor:imgBgColor];
    }
}

- (void)showTitle:(BOOL)isShow{
    if (isShow) {
        [_imgView setHidden:YES];
        [_titleLabel setHidden:NO];
        [_titleLabel setText:_phoneData.title];
    }
    else{
        [_imgView setHidden:NO];
        [_titleLabel setHidden:YES];      
    }
}
@end




////////////////////////////////////////////////////////////////////////
@interface  FavsThreadCtrl()
@property(nonatomic,strong) UILabel *title;
@property(nonatomic,strong) UILabel *content;
@property(nonatomic,strong) UILabel *date;
@end

@implementation FavsThreadCtrl


- (id)initWithPoint:(CGPoint)point{
    if (self = [super initWithPoint:point]) {
        
        float marginLeft = 8.f;
        float marginRight = 8.f;
        float marginTop = 18.f;
        float titleFontSize = 12.f;
        float contentFontSize = 10.f;
        int contentColorValue = 0xFF9d9696;       
        
        
        UIFont *font = [UIFont boldSystemFontOfSize:titleFontSize];
        CGRect rect = [self bounds];
        rect.origin = CGPointMake(marginLeft, marginTop);
        rect.size.width -= (marginRight + marginLeft);
        rect.size.height = font.lineHeight+font.lineHeight;        
        _title = [[UILabel alloc] initWithFrame:rect];
        [_title setFont:font];
        [_title setNumberOfLines:2];
        [_title setTextColor:[UIColor blackColor]];
        [_title setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_title];
        
        
        // init content
        UIColor *conteColor = [UIColor colorWithHexValue:contentColorValue];
        UIFont *conteFont = [UIFont boldSystemFontOfSize:contentFontSize];
        rect.origin.y += rect.size.height + 10.f;
        rect.size.height = conteFont.lineHeight + conteFont.lineHeight + conteFont.lineHeight;
        _content = [[UILabel alloc] initWithFrame:rect];
        [_content setFont:conteFont];
        [_content setNumberOfLines:3];
        [_content setTextColor:conteColor];
        [_content setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_content];
        
        // init date
        rect.origin.y += rect.size.height + 15.f;
        rect.size.height = conteFont.lineHeight;
        _date = [[UILabel alloc] initWithFrame:rect];
        [_date setFont:conteFont];
        [_date setTextColor:conteColor];
        [_date setTextAlignment:NSTextAlignmentLeft];
        [_date setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_date];
        
    }
    return self;
}
- (void)reloadDate:(FavThreadSummary*)favTS{
    _favTS = favTS;
    
    _title.text = [_favTS title];
    _content.text = [_favTS desc];
    _date.text = nil;
    if ([_favTS creationDate] > 0.f) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[_favTS creationDate]/1000.f];
        NSDateFormatter *dateFormat = [NSDateFormatter new];        
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
         _date.text = [dateFormat stringFromDate:date];
    }
}

@end


////////////////////////////////////////////////////////////////////////
@interface PhoneNewsDateView ()

@property(nonatomic,strong)UIImageView *imgView;
@property(nonatomic,strong)UILabel *dayLabel;
@property(nonatomic,strong)UILabel *monthLabel;
@property(nonatomic,strong)UILabel *yearLable;
@end


@implementation PhoneNewsDateView
+ (CGSize)fitSize{
    return (CGSize){kNewsDateCtrlWidth, kNewsCtrlHeight};
}
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
}
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}
- (id)initWithPoint:(CGPoint)point{
    CGRect rect = {point, [PhoneNewsDateView fitSize]};
    if (self = [super initWithFrame:rect]) {
        _imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"category"]];
        [self addSubview:_imgView];
        
        // day
        UIFont *dayFont = [UIFont boldSystemFontOfSize:30.f];
        CGRect rect = CGRectMake(0.f, 14.f + 14.f, kNewsDateCtrlWidth, dayFont.lineHeight+dayFont.descender);        
        
        _dayLabel = [[UILabel alloc] initWithFrame:rect];
        [_dayLabel setFont:dayFont];
        [_dayLabel setTextColor:[UIColor blackColor]];        
        [_dayLabel setTextAlignment:NSTextAlignmentRight];
        [_dayLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_dayLabel];
        
        // month
        float udgap = 2.f; // 上下间隔
        NSInteger textColorValue = 0xFF9d9696;
        UIColor *color = [UIColor colorWithHexValue:textColorValue];
        UIFont *monthFont = [UIFont boldSystemFontOfSize:12.f];
        rect.origin.y += rect.size.height + udgap;
        rect.size.height = monthFont.lineHeight;
        _monthLabel = [[UILabel alloc] initWithFrame:rect];
        [_monthLabel setFont:monthFont];
        [_monthLabel setTextColor:color];
        [_monthLabel setTextAlignment:NSTextAlignmentRight];
        [_monthLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_monthLabel];
        
        
        // year
        rect.origin.y += rect.size.height + udgap;
        _yearLable = [[UILabel alloc] initWithFrame:rect];
        [_yearLable setFont:monthFont];
        [_yearLable setTextColor:color];
        [_yearLable setTextAlignment:NSTextAlignmentRight];
        [_yearLable setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_yearLable];

    }
    return self;
}

- (void)relaodDate:(NSDate*)date{
    
    _dayLabel.text = nil;
    _monthLabel.text = nil;
    _yearLable.text = nil;
    
    if (date) {
        NSDateFormatter *dateFormat = [NSDateFormatter new];
        [dateFormat setDateFormat:@"dd"];
        _dayLabel.text = [dateFormat stringFromDate:date];
     
        [dateFormat setDateFormat:@"MM月"];
        _monthLabel.text = [dateFormat stringFromDate:date];
        
        [dateFormat setDateFormat:@"yyyy年"];
        _yearLable.text = [dateFormat stringFromDate:date];        
        
    }
}
@end