//
//  NotInteresNewsView.m
//  NotInterestNewsView
//
//  Created by NJWC on 16/1/27.
//  Copyright © 2016年 LF. All rights reserved.
//

#import "NotInteresNewsView.h"

#define MARGIN        5   //留白间隔
#define AnimationTime 0.3 //动画时间
#define ShadowMarginY 5.f //y坐标距离点击点的偏移距离
#define MarginLAndR   10.f //背景图与左右两边的距离
#define IMAGE(name)   [UIImage imageNamed:name] //返回一个图片
@interface NotInteresNewsView ()
{
    ButtonType       _type;        //按钮的类型
    CGPoint          _clickPoint;  //记录点击的点的坐标
    NSArray        * _titleArray;  //不感兴趣的标题
    UILabel        * _reasonLabel; //显示选择了几条理由
    UIButton       * _sureBtn;     //确认按钮
    UIControl      * _shadowCon;   //遮罩层
    UIImageView    * _bgImageView; //白色背景层
    NSMutableArray * _btnArray;    //装按钮的数组
}

@end

@implementation NotInteresNewsView

/**
 *  初始化方法
 *
 *  @param clickPoint 点击点的坐标
 *
 *  @param type 点击按钮的类型
 *
 *  @return view对象
 */
-(instancetype)initWithClickPoint:(CGPoint)clickPoint withType:(ButtonType)type
{
    self = [super init];
    if (self) {
        //首先设置view的属性
        self.frame = CGRectMake(0, 0, kContentWidth, kContentHeight);
        self.backgroundColor = [UIColor clearColor];
        
        //记录点击的点
        _clickPoint = clickPoint;
        //记录类型
        _type = type;
        
        //添加遮罩层
        UIControl * contr =[[UIControl alloc]initWithFrame:self.bounds];
        _shadowCon = contr;
        contr.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.5];
        [contr addTarget:self action:@selector(shadowClick) forControlEvents:UIControlEventTouchDown];
        [self addSubview:contr];
        
        //初始化数组
        _btnArray = [[NSMutableArray alloc]initWithCapacity:0];
        _titleArray = [NSArray arrayWithObjects:@"重复",@"旧闻",@"质量差",@"其他",nil];
        
        //添加子视图
        [self addSubviews];
    }
    return self;
}

/**
 *  添加子视图
 */
-(void)addSubviews
{
    /** NOCHANGE取值
     *  1  背景层大小，根据图片大小确定
     *
     *  0  背景层大小，根据屏幕尺寸等比例放大，保持距离左右两边距离为MarginLAndR 定值
     */
#define NOCHANGE 0
    
    CGFloat bgY;     //背景的y坐标
    CGFloat topMargin;  //确认按钮距离上方的距离
    UIImage * bgImg = [self getBackgroundImage]; //背景图片
#if NOCHANGE
    CGFloat bgW = bgImg.size.width;
    CGFloat bgX = (kContentWidth - bgW) / 2.0;
#else
    CGFloat bgX = MarginLAndR;
    CGFloat bgW = kContentWidth - 2*MarginLAndR;
#endif
    CGFloat scale = bgW / bgImg.size.width;//新宽与旧宽的比，用于后面等比例放大其他控件
    CGFloat bgH = bgImg.size.height * scale;
    
    if (_clickPoint.y > kContentHeight / 2.0) {
        bgY = _clickPoint.y - bgH - ShadowMarginY;
        topMargin = MARGIN * scale;
    }else{
        bgY = _clickPoint.y + ShadowMarginY;
        topMargin = (MARGIN + 7.f) * scale;
    }
    
    //白色的背景层
    UIImageView * bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(kContentWidth, _clickPoint.y, bgW,bgH)];
    _bgImageView = bgImageView;
    bgImageView.image = bgImg;
    bgImageView.userInteractionEnabled = YES;
    bgImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [_shadowCon addSubview:bgImageView];
    
    //增加一个出来的动画
    [UIView animateWithDuration:AnimationTime animations:^{
        bgImageView.transform = CGAffineTransformIdentity;
        bgImageView.frame = CGRectMake(bgX, bgY, bgW, bgH);
    }];
    
    
    //@"不感兴趣"  按钮
    UIImage * sureBgImg = IMAGE(@"nointerest_sure");
    CGFloat sW = sureBgImg.size.width * scale;
    CGFloat sH = sureBgImg.size.height * scale;
    CGFloat sX = bgW - MARGIN - sW;
    CGFloat sY = topMargin;
    UIButton * noInterBtn = [[UIButton alloc]initWithFrame:CGRectMake(sX, sY, sW, sH)];
    _sureBtn = noInterBtn;
    [self setSureBtnTitle:0];
    [noInterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    noInterBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [noInterBtn setBackgroundImage:sureBgImg forState:UIControlStateNormal];
    [noInterBtn setBackgroundImage:sureBgImg forState:UIControlStateHighlighted];
    [noInterBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [bgImageView addSubview:noInterBtn];
    
    
    //@"可选理由，精致屏蔽"  label
    CGFloat rW = 150;//随便给一个感觉足够长的
    CGFloat rH = sH;
    CGFloat rX = MARGIN;
    CGFloat rY = sY;
    UILabel * reasonL = [[UILabel alloc]initWithFrame:CGRectMake(rX, rY, rW, rH)];
    _reasonLabel = reasonL;
    [self setReasonLabelTitlt:0];
    reasonL.textColor = [UIColor colorWithHexString:@"333333"];
    reasonL.font = [UIFont systemFontOfSize:10];
    [bgImageView addSubview:reasonL];
    
    
    //四个选项按钮
    UIImage * btnNormalImg = IMAGE(@"nointerest_btnNormal");
    UIImage * btnSelsctImg = IMAGE(@"nointerest_btnSelect");
    CGFloat bW = btnNormalImg.size.width * scale;
    CGFloat bH = btnNormalImg.size.height * scale;
    CGFloat btnMarginHor = (bgW - 2 * bW) / 3.0; //水平方向间隔
    CGFloat btnMarginVer = (bgH - sH - topMargin - 2 * bH) / 3.0;//垂直方向间隔
    for (NSInteger i = 0; i < _titleArray.count; i++) {
        NSInteger X = i%2;
        NSInteger Y = i/2;
        CGFloat bX = btnMarginHor + (bW + btnMarginHor)*X;
        CGFloat bY = sH + topMargin + btnMarginVer + (bH + btnMarginVer)*Y;
        NotInteresNewsButton * btn = [[NotInteresNewsButton alloc]initWithFrame:CGRectMake( bX, bY, bW, bH)];
        [btn setBackgroundImage:btnNormalImg forState:UIControlStateNormal];
        [btn setBackgroundImage:btnSelsctImg forState:UIControlStateSelected];
        [btn setTitle:_titleArray[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(chooseReason:) forControlEvents:UIControlEventTouchUpInside];
        [bgImageView addSubview:btn];
        
        [_btnArray addObject:btn];
    }
}

//根据不同条件，获取背景层图片
-(UIImage *)getBackgroundImage
{
    UIImage * bgImage;
    if (_clickPoint.y > kContentHeight / 2.0) {
        switch (_type) {
            case ButtonTypeImageBig:
                bgImage = IMAGE(@"nointerest_bg4");
                break;
            case ButtonTypeImageSmall:
                bgImage = IMAGE(@"nointerest_bg3");
                break;
            default:
                break;
        }
        
    }else{
        switch (_type) {
            case ButtonTypeImageBig:
                bgImage = IMAGE(@"nointerest_bg2");
                break;
            case ButtonTypeImageSmall:
                bgImage = IMAGE(@"nointerest_bg1");
                break;
            default:
                break;
        }
    }
    return bgImage;
}

/**
 *  确认按钮点击
 */
-(void)sureBtnClick
{
    //获取到选择的理由
    NSMutableArray * reason = [NSMutableArray arrayWithCapacity:0];
    for (NotInteresNewsButton * btn in _btnArray) {
        if (btn.selected) {
            [reason addObject:[btn currentTitle]];
        }
    }
    
    //设置代理进行操作
    if([_delegate respondsToSelector:@selector(sureBtnDidClickWithSelectReason:)]){
        [_delegate sureBtnDidClickWithSelectReason:reason];
    }
    
    //移除
    [self removeViewFromSuperview];
    
}


/**
 *  选择理由
 *
 *  @param btn 按钮自身
 */
-(void)chooseReason:(NotInteresNewsButton *)btn
{
    //改变按钮的选中状态
    btn.selected = !btn.selected;
    
    int count = 0;
    for (NotInteresNewsButton * obj in _btnArray) {
        if (obj.selected) {
            count ++;
        }
    }
    
    //设置理由label的标题
    [self setReasonLabelTitlt:count];
    
    //设置确认按钮的标题
    [self setSureBtnTitle:count];
}

/**
 *  设置理由label的标题
 *
 *  @param count 根据理由数量设置
 */
-(void)setReasonLabelTitlt:(int)count
{
    if (count) {
        NSString * countStr = [NSString stringWithFormat:@"%d",count];
        NSString * title = [NSString stringWithFormat:@"已选%@条理由",countStr];
        NSRange range = [title rangeOfString:countStr];
        NSMutableAttributedString * att = [[NSMutableAttributedString alloc]initWithString:title];
        [att addAttribute:NSForegroundColorAttributeName
                    value:[UIColor redColor]
                    range:range];
        [_reasonLabel setAttributedText:att];
        
    }else{
        NSString * title = @"可选理由，精准屏蔽";
        _reasonLabel.text = title;
    }
}

/**
 *  设置确认按钮的标题
 *
 *  @param shadowClick 根据理由数量设置
 */
-(void)setSureBtnTitle:(int)count
{
    NSString * title = !count ? @"不感兴趣" : @"确定";
    [_sureBtn setTitle:title forState:UIControlStateNormal];
}

/**
 *  遮罩层点击
 */
-(void)shadowClick
{
    //设置代理进行操作
    if ([_delegate respondsToSelector:@selector(shadowControlDidClick)]) {
        [_delegate shadowControlDidClick];
    }
    
    //从父视图移除
    [self removeViewFromSuperview];
    
}

//从父视图移除自己
-(void)removeViewFromSuperview
{
    //动画
    [UIView animateWithDuration:AnimationTime animations:^{
        _bgImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
        _bgImageView.frame = CGRectMake(kContentWidth, _clickPoint.y, CGRectGetWidth(_bgImageView.frame), CGRectGetHeight(_bgImageView.frame));
    } completion:^(BOOL finished) {
        //从父视图移除
        [self removeFromSuperview];
    }];
}

@end

#pragma mark - ****自定义按钮，主要是为了去除高亮状态****

@implementation NotInteresNewsButton

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        self.titleLabel.font = [UIFont systemFontOfSize:11];
    }
    
    return self;
}
//去除高亮状态
-(void)setHighlighted:(BOOL)highlighted
{
    //什么也不做
}

@end
