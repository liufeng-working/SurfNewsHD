 //
//  NewsCommentCell.m
//  SurfNewsHD
//
//  Created by XuXg on 15/6/3.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "NewsCommentCell.h"
#import "NSString+Extensions.h"
#import "DateUtil.h"
#import "UIView+NightMode.h"
#import "NewsCommentManager.h"
#import "NSString+Extensions.h"
#import "UIButton+Block.h"
#import "DispatchUtil.h"


// 昵称文字颜色
#define kNickNameColor(isN) [UIColor colorWithHexValue:isN?0xffffffff:0xFF34393D]
#define kContentFontSize 12
#define kBoundChanged @"frame"


@interface NewsCommentCell () {
    
    __weak CALayer      *_headPic;              // 头像
    __weak CATextLayer  *_nickLayer;            // 昵称控件
    __weak CALayer      *_releaseTimeLayer;     // 评论发布时间控件
    __weak CATextLayer  *_releaseTimeStrLayer;  // 发布时间文字控件
    __weak CALayer      *_releaseLocationLayer; // 发布位置控件
    __weak CATextLayer  *_releaseLocationStrLayer; // 发布位置文字控件
    
    
    __weak CALayer      *_approvingLayer;          // 审核状态
    __weak UIButton     *_praiseBtn;                // 点赞按钮
    
    // 评论内容
    __weak UILabel      *_commentContent;
    
    
    
    // 辅助属性
    CGFloat _scale;
    CGFloat _contentX;
    UIFont *_smallFont;
    UIColor *_smallColor;
    UIColor *_separatorColor; // 分割线颜色
    
    // 顶部分割线
    __weak CALayer *_topLineLayer;
    __weak CAShapeLayer *_bottomLineLayer;
}



@end


@implementation NewsCommentCell

-(void)dealloc
{
    [self.contentView removeObserver:self forKeyPath:kBoundChanged];
}
-(id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;
    
    _contentX = 10 + 40 + 10;
    _isShowPraiseButton = YES;
    _scale = [[UIScreen mainScreen] scale];
    _smallFont = [UIFont systemFontOfSize:10];
    _smallColor = [UIColor colorWithHexValue:0xFF999292];
    _separatorColor = [UIColor colorWithHexValue:0xFFe3e2e2];
    
    // 添加一个属性观察者，来初始化分割线
    [self.contentView addObserver:self
           forKeyPath:kBoundChanged
              options:NSKeyValueObservingOptionNew
              context:nil];

    
    [self buildHeadCtrl];               // 构建头像控件
    [self buildNickLayer];              // 创建昵称控件
    [self buildCommentCreatTimeCtrl];   // 创建评论时间控件
    [self buildReleaseLocation];        // 评论位置信息
    [self buildCommnetContent];         // 评论内容

    BOOL isN = [[ThemeMgr sharedInstance] isNightmode];
    [self viewNightModeChanged:isN];
    
    [[self selectedBackgroundView] setHidden:YES];
    self.backgroundView = [UIView new];
    [[self backgroundView] setHidden:YES];
    return self;
}

-(void)loadCommentData:(CommentBase*)comment
        isFirstComment:(BOOL)firstComment;
{
    _commentData = comment;
    NewsCommentManager *commentMgr = [NewsCommentManager sharedInstance];
    
    // 头像
    UIView *content = self.contentView;
    CGFloat w = CGRectGetWidth(content.bounds);
    _headPic.contents = (id)[commentMgr defaultHeadIcon].CGImage;
    [commentMgr getCommentHeadIcon:comment
     headIcon:^(CommentBase *comment, UIImage *headIcon) {
        if (comment && comment.commentId == _commentData.commentId) {
            _headPic.contents = (id)headIcon.CGImage;
            [_headPic setNeedsLayout];
        }
     }];
    
    
    // 昵称
    NSString *nickName_str = @"冲浪快讯客户端网友";
    if (comment.nickname && ![comment.nickname isEmptyOrBlank]) {
        nickName_str = comment.nickname;
    }
    _nickLayer.string = nickName_str;

    
    // 发布时间图片 + 时间
    NSString *releaseStr = [DateUtil calcTimeInterval:comment.createtime/1000];
    if (!releaseStr || [releaseStr isEmptyOrBlank]) {
        [_releaseTimeLayer setHidden:YES];
        _releaseTimeStrLayer.string = nil;
    }
    else{
        [_releaseTimeLayer setHidden:NO];
        _releaseTimeStrLayer.string = releaseStr;
    }
    
    
    // 发布地点
    if ([comment.location length] > 0) {
        [_releaseLocationLayer setHidden:NO];
        _releaseLocationStrLayer.string = comment.location;// 定位
    }
    else {
        [_releaseLocationLayer setHidden:YES];
        _releaseLocationStrLayer.string = nil;
    }
    
    
    // 当前状体,点赞或未点赞 // 0待审核，1审核通过，2驳回
    [self uploadPraiseCtrl:comment];
    
    
    // 发布内容
    CGFloat cX = _contentX, cY = 50;
    NSString *desContent = [comment.content trim];
    if (desContent && ![desContent isEmptyOrBlank]) {
        [_commentContent setHidden:NO];
        CGFloat contentW = w-cX - 10.f;
        _commentContent.text = desContent;
        CGSize commentSize =
        [_commentContent sizeThatFits:CGSizeMake(contentW, 0)];
        _commentContent.frame = CGRectMake(cX, cY, commentSize.width, commentSize.height);
    }
    else{
        [_commentContent setHidden:YES];
    }
    
    
    // 顶部分割线
    if (firstComment){
        [self buildTopLine];
    }
    else {
        [_topLineLayer removeFromSuperlayer];
    }
}

/**
 *  刷新点赞控件
 */
-(void)refreshPraiseControl
{
    [self uploadPraiseCtrl:_commentData];
}

/**
 *  计算新闻评论cell高度
 *
 *  @param comment 评论信息
 *
 *  @return cell 高度
 */
+(NSInteger)calcCellHeight:(CommentBase*)comment
{
    NSString *content = [[comment content] trim];
    if (!content || [content isEmptyOrBlank]) {
        return 50.f; // 如果没有参数，给个默认值
    }
    
    static UILabel *label = nil;
    if (!label) {
        label = [UILabel new];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:kContentFontSize];
    }
    
    CGFloat width = kContentWidth - 10 - 40 - 10 - 10;
    label.text = content;
    CGFloat contentH = [label sizeThatFits:CGSizeMake(width, 0)].height;
    return 50 + contentH + 10;
}





- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark 私有函数

/**
 *  构建头像控件
 */
-(void)buildHeadCtrl
{
    if (!_headPic) {
        CGFloat headY = 10.f;
        CGFloat headX = 10.f;
        UIImage *headImg = [[NewsCommentManager sharedInstance] defaultHeadIcon];
        CGFloat headW = 40;
        CGFloat headH = 40;
        CALayer *hp = [CALayer layer];
        _headPic = hp;
        hp.contents = (id)headImg.CGImage;
        hp.contentsScale = _scale;
        hp.frame = CGRectMake(headX, headY, headW, headH);
        [self.contentView.layer addSublayer:hp];
    }
}

/**
 *  创建昵称控件
 */
-(void)buildNickLayer
{
    if (!_nickLayer) {
        // 昵称
        CGFloat nY = 15;
        CGFloat nX = _contentX;
        CGFloat nW = 120.f;
        CGFloat nH = 14.f;
        UIFont *nF = [UIFont systemFontOfSize:12.f];
        CATextLayer *nickN = [CATextLayer layer];
        _nickLayer = nickN;
        nickN.fontSize = nF.pointSize;
        nickN.font = (__bridge CFTypeRef)nF.fontName;
        nickN.contentsScale = _scale;
        nickN.frame = CGRectMake(nX, nY, nW, nH);
        [self.contentView.layer addSublayer:nickN];
    }
}


-(void)buildCommentCreatTimeCtrl
{
    // 发布时间图片 + 时间
    if (!_releaseTimeLayer) {
        CGFloat tW, tH;
        CGFloat tX = _contentX, tY = 15 + 13 + 5;
        
        
        CALayer *releaseTimeLayer = [CALayer layer];
        _releaseTimeLayer = releaseTimeLayer;
        releaseTimeLayer.contentsScale = _scale;
        [self.contentView.layer addSublayer:releaseTimeLayer];
        {
            // 时间图片
            UIImage *tImg = [UIImage imageNamed:@"time"];
            tW = tImg.size.width;
            tH = tImg.size.height;
            CALayer *timeImageLayer = [CALayer layer];
            timeImageLayer.contents = (id)tImg.CGImage;
            timeImageLayer.contentsScale = _scale;
            timeImageLayer.frame = CGRectMake(0, 0, tW, tH);
            [releaseTimeLayer addSublayer:timeImageLayer];
        
            
            // 时间文字样式
            CGFloat tsW = 90.f;
            CGFloat tsH = [_smallFont lineHeight];
            CGFloat tsX = tImg.size.width+4;
            CGFloat tsY = (tImg.size.height-tsH)/2;
            CATextLayer *timeTextLayer = [CATextLayer layer];
            _releaseTimeStrLayer = timeTextLayer;
            timeTextLayer.frame =CGRectMake(tsX, tsY, tsW, tsH);
            timeTextLayer.font = (__bridge CFTypeRef)_smallFont.fontName;
            timeTextLayer.fontSize = _smallFont.pointSize;
            timeTextLayer.contentsScale = _scale;
            [releaseTimeLayer addSublayer:timeTextLayer];
            
            tW += tsW;
            tH = tH > tsH ? tH : tsH;
        }
        releaseTimeLayer.frame =CGRectMake(tX, tY, tW, tH);
    }
}


// 发布地点控件
-(void)buildReleaseLocation
{
    if(_releaseLocationLayer)
        return;
    
    CGFloat lW, lH;
    CGFloat lX = _contentX + 120, lY = 15 + 13 + 5;
    CALayer *locationContainer = [CALayer layer];
    _releaseLocationLayer = locationContainer;
    locationContainer.contentsScale = _scale;
    [self.contentView.layer addSublayer:locationContainer];
    
    
    // 地点icon
    UIImage *lImg = [UIImage imageNamed:@"c_location"];
    CGFloat lIconW = lImg.size.width;
    CGFloat lIconH = lImg.size.height;
    CALayer *lIcon = [CALayer layer];
    lIcon.contents = (id)lImg.CGImage;
    lIcon.contentsScale = _scale;
    lIcon.frame = CGRectMake(0, 0, lIconW, lImg.size.height);
    [locationContainer addSublayer:lIcon];
    
    
    // 地点位置
    CGFloat lsH = [_smallFont lineHeight];
    CGFloat lsW = 90.f;
    CGFloat lsX = lImg.size.width+4;
    CGFloat lsY = (lIconH -lsH) / 2;
    CATextLayer *loctionText = [CATextLayer layer];
    _releaseLocationStrLayer = loctionText;
    loctionText.frame =CGRectMake(lsX, lsY, lsW, lsH);
    loctionText.font = (__bridge CFTypeRef)_smallFont.fontName;
    loctionText.fontSize = _smallFont.pointSize;
    loctionText.contentsScale = _scale;
    [locationContainer addSublayer:loctionText];
 
    lW = lsX + lsW;
    lH = lIconH > lsH ? lIconH : lsH;
    locationContainer.frame = CGRectMake(lX, lY, lW, lH);
}

/**
 *  加载点赞控件数据，没有控件就自己创建相应控件
 *
 *  @param comment 评论数据
 */
-(void)uploadPraiseCtrl:(CommentBase*)comment
{
    CGFloat cW = CGRectGetWidth(self.contentView.bounds);
    // 0待审核，1审核通过，2驳回
    if (0 == comment.status ) {
        if (!_approvingLayer) {
            // 1 待审核
            UIImage *approvingIcon = [UIImage imageNamed:@"c_approving"];
            CGFloat aW = approvingIcon.size.width;
            CGFloat aH = approvingIcon.size.height;
            CALayer *approve = [CALayer layer];
            _approvingLayer = approve;
            approve.contentsScale = _scale;
            approve.contentsGravity = kCAGravityLeft;
            approve.contents = (id)approvingIcon.CGImage;
            
            [self.contentView.layer addSublayer:approve];
            
            // 审核中
            NSString *str = @"审核中";
            UIFont *pFont = [UIFont boldSystemFontOfSize:9];
            CGSize s = SN_TEXTSIZE(str, pFont);
            CATextLayer *approvingStr = [CATextLayer layer];
            approvingStr.string = str;
            approvingStr.foregroundColor = [UIColor redColor].CGColor;
            approvingStr.font = (__bridge CFTypeRef)pFont.fontName;
            approvingStr.fontSize = [pFont pointSize];
            approvingStr.contentsScale=_scale;
            approvingStr.frame = CGRectMake(aW+1, (aH-s.height)/2, s.width, s.height);
            [approve addSublayer:approvingStr];
            approve.frame = CGRectMake(0, 0, aW + s.width+1, aH);
        }
        
        // 设置坐标
        CGFloat aY = 10;
        CGFloat aW = CGRectGetWidth(_approvingLayer.frame);
        CGFloat aH = CGRectGetHeight(_approvingLayer.frame);
        CGFloat aX = cW - aW - 10.f;
        _approvingLayer.frame = CGRectMake(aX, aY, aW, aH);
        
        [_approvingLayer setHidden:NO];
        
        // 点赞状态隐藏
        [_praiseBtn setHidden:YES];
    }
    else if (1 == comment.status)
    {
        UIFont *pFont = [UIFont boldSystemFontOfSize:9];
        if (!_praiseBtn && _isShowPraiseButton) {
            BOOL isN = [ThemeMgr sharedInstance].isNightmode;
            UIButton *praiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _praiseBtn = praiseBtn;
            praiseBtn.layer.cornerRadius = 10.f;
            praiseBtn.titleLabel.font = pFont;
            [praiseBtn setTitleColor:kNickNameColor(isN)
                            forState:UIControlStateNormal];
            praiseBtn.titleEdgeInsets = UIEdgeInsetsMake(2,-28,0,0);
            [praiseBtn addTarget:self action:@selector(praiseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            // 设置button扩大点击区域
            [praiseBtn setEnlargeEdgeWithTop:10.f right:10 bottom:10 left:10];
            [self.contentView addSubview:praiseBtn];
  
            // 按钮背景
            UIImage *tempBg = [UIImage imageNamed:isN?@"c_praise_btn_bg_n":@"c_praise_btn_bg"];
            UIImage *stretchBg =
            [tempBg resizableImageWithCapInsets:UIEdgeInsetsMake(0,5,0,5)
                                   resizingMode:UIImageResizingModeStretch];
            [praiseBtn setBackgroundImage:stretchBg
                                 forState:UIControlStateNormal];
        }
        
        // 设置图片
        NewsCommentManager* commentMgr =
        [NewsCommentManager sharedInstance];
        BOOL isP = [commentMgr isPraise:comment];
        [_praiseBtn setEnabled:YES];
        UIImage *pimg = [UIImage imageNamed:isP?@"support_5":@"support_0"];
        [_praiseBtn setImage:pimg forState:UIControlStateNormal];

        // TODO: 数据初始化
        NSString *praiseStr;
        if ([comment isKindOfClass:[NewComment class]]) {
            NSNumber *upNum = [NSNumber numberWithInteger:((NewComment*)comment).up];
            praiseStr = [NSString stringWithFormat:@"%@", upNum];
        }
        else if([comment isKindOfClass:[HotComment class]]){
            NSNumber *upNum = [NSNumber numberWithInteger:((HotComment*)comment).up];
            praiseStr = [NSString stringWithFormat:@"%@", upNum];
        };
        [_praiseBtn setTitle:praiseStr forState:UIControlStateNormal];
        

        
        // 设置绘制区域
        CGSize fontSize = SN_TEXTSIZE(praiseStr,pFont);
        CGFloat pW = [_praiseBtn imageForState:UIControlStateNormal].size.width  + fontSize.width + 10.f;
        CGFloat pH = [_praiseBtn backgroundImageForState:UIControlStateNormal].size.height;
        CGFloat pX = cW - pW - 10.f, pY = 10.f;
        _praiseBtn.frame = CGRectMake(pX, pY, pW, pH);
        _praiseBtn.imageEdgeInsets = UIEdgeInsetsMake(-6.5,fontSize.width+8,0,2);
 
        [_praiseBtn setEnabled:!isP];
        [_approvingLayer setHidden:YES];
        [_praiseBtn setHidden:NO];
    }
    else if (2 == comment.status) {
        
    }

}

-(void)buildCommnetContent
{
    if (!_commentContent) {
        UIFont *contentFont = [UIFont systemFontOfSize:kContentFontSize];
        UILabel *content = [UILabel new];
        _commentContent = content;
        content.font = contentFont;
        content.numberOfLines = 0;
        content.textColor = [UIColor colorWithHexValue:0xFF34393D];
        content.userInteractionEnabled = NO;
        content.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:content];
    }
}

-(void)buildTopLine
{
    // 绘制顶部分割线
    if (!_topLineLayer) {
        CGFloat w = CGRectGetWidth(self.contentView.bounds);
        CALayer *topLine = [CALayer layer];
        _topLineLayer = topLine;
        topLine.frame = CGRectMake(0.f, -0.5f, w, 0.5f);
        topLine.masksToBounds = YES;
        topLine.backgroundColor = _separatorColor.CGColor;
        [self.contentView.layer addSublayer:topLine];
    }
}

-(void)buildBottomLine
{
    if (!_bottomLineLayer) {
        // 绘制底部分割线
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        _bottomLineLayer = shapeLayer;
        [shapeLayer setMasksToBounds:YES];
        [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
        
            
        // 设置虚线的宽度
        [shapeLayer setLineWidth:.5f];
        [shapeLayer setLineJoin:kCALineJoinRound];
            
        // 3=线的宽度 1=每条线的间距
        if (_isDots) {
            [shapeLayer setLineDashPattern:
            [NSArray arrayWithObjects:@(3),@(1),nil]];
        }

        [self.contentView.layer addSublayer:shapeLayer];
        
    }

    UIColor *lineColor = [UIColor colorWithHexValue:0xffeeeeee];
    [_bottomLineLayer setStrokeColor:lineColor.CGColor];
    
    
    // Setup the path
    CGFloat w = CGRectGetWidth(self.contentView.bounds);
    CGFloat h = CGRectGetHeight(self.contentView.bounds);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,NULL, 0, 0);
    CGPathAddLineToPoint(path,NULL, w, 0);
    [_bottomLineLayer setPath:path];
    CGPathRelease(path);

    if (_isDots) {
        _bottomLineLayer.frame = CGRectMake(_dotsEdge, h-0.5f, w-_dotsEdge-_dotsEdge, 0.5f);
    }
    else {
        _bottomLineLayer.frame = CGRectMake(0.f, h-0.5f, w, 0.5f);
    }

}

-(void)viewNightModeChanged:(BOOL)isNight
{
    UIColor *color = kNickNameColor(isNight);
    _nickLayer.foregroundColor = color.CGColor;
    _releaseTimeStrLayer.foregroundColor = _smallColor.CGColor;
    _releaseLocationStrLayer.foregroundColor = _smallColor.CGColor;
    _commentContent.textColor = color;
    [_praiseBtn setTitleColor:color forState:UIControlStateNormal];
}

// 点赞按钮
-(void)praiseBtnClick:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    [btn setEnabled:NO];
    
    

    // 发送点赞请求
    NewsCommentManager* commentMgr =
    [NewsCommentManager sharedInstance];
    [commentMgr commitCommentAttitude:_commentData withCompletionHandler:^(NewsCommentPraiseResult *result) {
        
        if (result.userInfo != _commentData) {
            return ;
        }
        
        if (result.isSucceed) {
            _commentData.attitude = 1;
            NSUInteger upPlus = result.increment;
            
            
            //给按钮中的图片增加一个动画
            if(upPlus > 0){
                NSMutableArray * supportArray=[NSMutableArray arrayWithCapacity:0];
                for (NSInteger i=0; i<6; i++)
                {
                    NSString * nameStr=[NSString stringWithFormat:@"support_%@",@(i)];
                    UIImage * supportImage=[UIImage imageNamed:nameStr];
                    [supportArray addObject:supportImage];
                }
                btn.imageView.animationImages=supportArray;
                btn.imageView.animationDuration=0.6;
                btn.imageView.animationRepeatCount=1;
                [btn.imageView startAnimating];
            }

            [DispatchUtil dispatch:^{
                btn.imageView.animationImages = nil;
                [btn.imageView.layer removeAllAnimations];
                
                // 添加赞里面有个特殊处理，回调updatePraise，动画执行完成在进行
                [commentMgr addPraise:_commentData
                      praiseIncrement:upPlus];
            } after:0.7];

        }
        else{
            [btn setEnabled:YES];
            [PhoneNotification autoHideWithText:@"点赞失败"];
        }
    }];
}


/**
 *  创建一个点赞动画
 */
/*
-(void)buildPraiseAnimation:(UIButton*)btn
{
    //创建CAKeyframeAnimation
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"imageView.animationImages"];
    animation.duration = 1;
    animation.delegate = self;
    
    //存放图片的数组
    NSMutableArray *images = [NSMutableArray array];
    for(NSUInteger i = 0;i < 6 ;i++) {
        
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"support_%@",@(i)]];
        [images addObject:img];
    }
    
    animation.values = images;
    [btn.layer addAnimation:animation forKey:@"praiseAnimation"];
}

//
-(void)animationDidStop:(CAAnimation *)theAnimation
               finished:(BOOL)flag
{
    
    //    if ([theAnimation isKindOfClass:[CAKeyframeAnimation class]]) {
    //        CAKeyframeAnimation *ka = (CAKeyframeAnimation*)theAnimation;
    //        if ([[ka keyPath] isEqualToString:@"Praise"]) {
    NSUInteger pc = 0;
    NewsCommentManager* commentMgr =
    [NewsCommentManager sharedInstance];
    if ([_commentData isKindOfClass:[HotComment class]]) {
        pc = ((HotComment*)_commentData).up + 1;
    }
    else if([_commentData isKindOfClass:[NewComment class]]){
        pc = ((NewComment*)_commentData).up + 1;
    }
    
    [commentMgr addPraise:_commentData praiseCount:pc];
}
*/

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:kBoundChanged]) {
        if (_topLineLayer) {
            CGFloat w = CGRectGetWidth(self.contentView.bounds);
            _topLineLayer.frame = CGRectMake(0.f, -0.5f, w, 0.5f);
        }
        
        // 修正底部分割线的坐标
        [self buildBottomLine];
        
        // 修正点赞等UI坐标
        [self uploadPraiseCtrl:_commentData];
        
    }
}

-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (IOS7) {
        return [super hitTest:point withEvent:event];
    }
    else {
        if (1 == _commentData.status) {
            if(CGRectContainsPoint([_praiseBtn enlargeFrame], point))
                return _praiseBtn;
        }
    }
    return nil;
}


@end
