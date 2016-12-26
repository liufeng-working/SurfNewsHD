//
//  SNPNEView.m
//  SurfNewsHD
//
//  Created by XuXg on 14/11/24.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "SNPNEView.h"
#import "SurfDbManager.h"
#import "SurfJsonRequestBase.h"
#import "UserManager.h"
#import "Encrypt.h"
#import "NSString+Extensions.h"


@class CustomCircleBtn;


@implementation EnergyDataRequest

- (id)initWithThreadSummary:(ThreadSummary *)td andEnergyScore:(long)energyScore
{
    self = [super init];
    if (self) {
        self.newsid = td.threadId;
        self.energy = energyScore;
        self.type = td.type;
        self.clientType = 0;
    }
    return self;
}
@end


@interface SNPNEView ()
{
    NSArray *_nSpeakText;
    NSArray *_pSpeakText;
    long _state;            // 0：没有提交状态。  1 已经提交过正负能量。
    BOOL _isPositive;        // 是否是正能量
    
    
    // 正负能量按钮
    CustomCircleBtn *_pBtn;
    CustomCircleBtn *_nBtn;
    BOOL _isShareOrCommit;
    
    long _pClickCount;      //正能量 点击总数
    long _nClickCount;      //负能量 点击总数
    
    float _pClickIncrease;   //正能量 每次点击的增加量
    float _nClickIncrease;   //负能量 每次点击的增加量
    
    float _curClickVal;     // 当前进度条搞定增加的百分值
    NSInteger _energyScore;      // 点击分数
    NSDate *_lastClickTime;
    long _clickVal;
    
    
    // 点击提示文字
    UIView *_speakViews;
    UILabel *_speakLabel1;
    UILabel *_speakLabel2;
    UILabel *_speakLabel3;
    BOOL _isShowSpeak;
    
    
    // 显示分享
    BOOL _isShowShare;
    UILabel *_shareTitle1;
    UILabel *_shareTitle2;
    UIButton *_continueBtn;
    UIButton *_commitBtn;
    UIButton *_shareBtn;
    UIImageView *_guideImg; // 引导图片
    UIImageView *_arrowImg; // 箭头图片
    
    // 定时显示分享界面
    NSTimer *_showShareTimer;
    
    
    __weak ThreadSummary *_thread;
    
    float _btnY;
}




@end

@implementation SNPNEView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    
    [self initData];
    return self;
}


-(void)initData
{
    _nSpeakText = [NSArray arrayWithObjects:
                   //轻度
                    @"我开始方了！",
                    @"天了噜！",
                    @"果取关！",
                    @"也是蛮拼的！",
                    @"what are you 弄啥嘞！",
                    @"一脸大写的懵逼！",
                    @"真是无处安放的尴尬啊！",
                    @"get不到！",
                    @"囧！",
                    @"宝宝心里苦啊！",
                    @"我去写张卷子冷静一下！",
                    //中度
                    @"神烦！",
                    @"吓死宝宝了！",
                    @"你在搞siao吗？",
                    @"好污！！！",
                    @"你脸大！",
                    @"装逼我给九十九！",
                    @"不作死就不会死！",
                    @"累觉不爱！",
                    @"我的内心几乎是崩溃的！",
                    @"我可以说脏话吗？",
                    @"卧槽！",
                    //重度
                    @"你咋不上天呢？",
                    @"你过来我保证不打死你！",
                    @"汝甚屌，令尊知否？",
                    @"常将冷眼观螃蟹，看你横行到及时？",
                    @"人不要脸，天下无敌！",
                    @"天生属核桃的，欠捶！",
                    @"丫有病吧！！！",
                    @"M L G B",
                     nil];
    
    
    _pSpeakText = [NSArray arrayWithObjects:
                   //轻度
                    @"猴赛雷！",
                    @"猴嗨森！",
                    @"么么哒！",
                    @"不明觉厉！",
                    @"蛮拼的！",
                    @"画面太美，不忍直视！",
                    @"脑洞大开！",
                    @"高大上！",
                    @"有bigger！",
                    //中度
                    @"喜大普奔！",
                    @"碉堡了！",
                    @"怒赞！",
                    @"满分！",
                    @"牛掰！",
                    @"内牛满面！",
                    @"热泪盈眶！",
                    @"且看且珍惜！",
                    @"我好崇拜你哦！",
                    @"干得漂亮！",
                    //重度
                    @"感人肺腑啊！",
                    @"太治愈了！",
                    @"世界充满爱…！",
                    @"正义的力量！",
                    @"感动，泪奔ing！",
                   nil];
    
    
    _pClickCount = _pSpeakText.count*5;
    _nClickCount = _nSpeakText.count*5;
    _pClickIncrease = 1.0/_pClickCount;
    _nClickIncrease = 1.0/_nClickCount;
    self.backgroundColor = [UIColor clearColor];
   
    
    // 正负能量按钮
    float centerX = kContentWidth/2.f;
    _btnY = kContentHeight - (kContentHeight-400);
    _pBtn = [CustomCircleBtn circleButton:YES point:CGPointZero];
    float offX = CGRectGetWidth(_pBtn.bounds)/2.f+5;
    _pBtn.center = CGPointMake(centerX-offX, _btnY);
    [_pBtn addTarget:self
             action:@selector(positiveButtonClick:)
   forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_pBtn];
    
    _nBtn = [CustomCircleBtn circleButton:NO point:CGPointZero];
    _nBtn.center = CGPointMake(centerX+offX, _btnY);
    [_nBtn addTarget:self
             action:@selector(negativeButtonClick:)
   forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_nBtn];
    
    
    // 关闭按钮
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"close_energy"]
                        forState:UIControlStateNormal];
    [closeBtn setFrame:CGRectMake(kContentWidth-60.f, _btnY-360, 30, 30)];
    [closeBtn addTarget:self action:@selector(colseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBtn];
    
    [self initSpeakData];
    [self initShareData];
}

-(void)initSpeakData
{
    CGRect r1 = CGRectMake(0, _btnY - 200, kContentWidth, 40);
    CGRect r2 = CGRectOffset(r1, 0, -40);
    CGRect r3 = CGRectOffset(r2, 0, -40);
    UIColor *c = [UIColor whiteColor];
    _speakLabel1 = [[UILabel alloc]initWithFrame:r1];
    _speakLabel2 = [[UILabel alloc]initWithFrame:r2];
    _speakLabel3 = [[UILabel alloc]initWithFrame:r3];
    
    _speakLabel1.textColor = c;
    _speakLabel2.textColor = c;
    _speakLabel3.textColor = c;
    
    _speakLabel1.hidden = YES;
    _speakLabel2.hidden = YES;
    _speakLabel3.hidden = YES;
    
    _speakLabel1.backgroundColor = [UIColor clearColor];
    _speakLabel2.backgroundColor = [UIColor clearColor];
    _speakLabel3.backgroundColor = [UIColor clearColor];
    
    _speakLabel1.textAlignment = NSTextAlignmentCenter;
    _speakLabel2.textAlignment = NSTextAlignmentCenter;
    _speakLabel3.textAlignment = NSTextAlignmentCenter;
    
    _speakViews = [[UIView alloc] initWithFrame:self.bounds];
    [_speakViews setBackgroundColor:[UIColor clearColor]];
    [_speakViews setUserInteractionEnabled:NO];
    [_speakViews addSubview:_speakLabel1];
    [_speakViews addSubview:_speakLabel2];
    [_speakViews addSubview:_speakLabel3];
    
    [self addSubview:_speakViews];
}

-(void)initShareData
{
    _isShowShare = NO;
    UIFont *titleF = [UIFont systemFontOfSize:28];
    UIFont *continueF = [UIFont systemFontOfSize:20];
    CGRect titleR = CGRectMake(0, _nBtn.center.y-300, kContentWidth, titleF.lineHeight);
    CGRect titleR2 = CGRectOffset(titleR, 0, titleF.lineHeight+5);
    _shareTitle1 = [[UILabel alloc] initWithFrame:titleR];
    _shareTitle1.font = titleF;
    _shareTitle1.textColor = [UIColor whiteColor];
    _shareTitle1.text = @"你向这条新闻发出了";
    [_shareTitle1 setTextAlignment:NSTextAlignmentCenter];
    _shareTitle1.backgroundColor = [UIColor clearColor];
    [self addSubview:_shareTitle1];
    
    
    _shareTitle2 = [[UILabel alloc] initWithFrame:titleR2];
    _shareTitle2.font = titleF;
    _shareTitle2.textColor = [UIColor whiteColor];
    [_shareTitle2 setTextAlignment:NSTextAlignmentCenter];
    _shareTitle2.backgroundColor = [UIColor clearColor];
    [self addSubview:_shareTitle2];
    
    
    NSString *continueStr = @"我要继续发正能量>>";
    CGSize continueSize = [continueStr surfSizeWithFont:continueF constrainedToSize:CGSizeMake(NSIntegerMax, continueF.lineHeight) lineBreakMode:NSLineBreakByWordWrapping];
    CGRect continueR = CGRectMake((kContentWidth-continueSize.width)/2,
                                  titleR2.origin.y + titleR2.size.height,
                                  continueSize.width, continueSize.height);
    _continueBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_continueBtn setTitle:continueStr forState:UIControlStateNormal];
    [_continueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_continueBtn setFrame:continueR];
    [_continueBtn addTarget:self
                     action:@selector(continueBtnClick:)
           forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_continueBtn];
    
   
    float btnW = 100.f;
    float btnH = 30.f;
    float btnSpace = 20.f;
    float btnX = (kContentWidth -btnW-btnW-btnSpace)/2;
    float btnY = continueR.origin.y + continueR.size.height + 20.f;
    CGRect commitR = CGRectMake(btnX, btnY, btnW, btnH);
    _commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [_commitBtn setBackgroundColor:[UIColor grayColor]];
    [_commitBtn setFrame:commitR];
    [_commitBtn addTarget:self
                   action:@selector(commitBtnClick:)
         forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_commitBtn];
   
    
    _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareBtn setTitle:@"分享" forState:UIControlStateNormal];
    [_shareBtn setBackgroundColor:[UIColor redColor]];;
    [_shareBtn setFrame:CGRectOffset(commitR, btnW+btnSpace, 0)];
    [_shareBtn addTarget:self
                  action:@selector(shareBtnClick:)
        forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_shareBtn];
    
    // 引导
    float imgBaseY = _pBtn.center.y;
    float imgBaseX = kContentWidth/2;
    UIImage *textImg = [UIImage imageNamed:@"c_text"];
    UIImage *arrowImg = [UIImage imageNamed:@"c_arrow"];
    _guideImg = [[UIImageView alloc] initWithImage:textImg];
    _guideImg.frame = CGRectMake(0, 0, textImg.size.width*3/2,
                                 textImg.size.height*3/2);
    _guideImg.center = CGPointMake(imgBaseX+100 ,imgBaseY-30);
    [self addSubview:_guideImg];
    
    _arrowImg = [[UIImageView alloc] initWithImage:arrowImg];
    _arrowImg.center = CGPointMake(imgBaseX+50 ,imgBaseY-25);
    [self addSubview:_arrowImg];
    
    
    // 定时器
    _showShareTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showShareTimerMethod:) userInfo:nil repeats:YES];
    [_showShareTimer setFireDate:[NSDate distantFuture]];
    
    
    [self showShareView:NO];
}

-(void)loadingWithThread:(ThreadSummary*)thread
{
    if (!thread || ![thread is_energy]) {
        return;
    }

    _state = 0;
    _thread = thread;
    SurfDbManager *db = [SurfDbManager sharedInstance];
    _energyScore = [db energyScore:thread];
    _isShareOrCommit = (_energyScore != 0);
    _thread.energyScore = _energyScore;
    
    // 已经发表过能量
    if (_isShareOrCommit) {
        if(_energyScore < 0) {
            _energyScore = labs(_energyScore);
            _state = 2;
            _isPositive = NO;
            _curClickVal = 1.f;
            _clickVal = _nClickCount-1;
            
            [self moveEnergyBtn:_isPositive];
            [_nBtn stopAction];
            [_nBtn setUserInteractionEnabled:NO];
            
            [_speakViews setHidden:YES];
            [self showShareView:YES];
        }
        else if (_energyScore > 0){
            _state = 1;
            _isPositive = YES;
            _clickVal = _pClickCount-1;
            _curClickVal = 1.f;
            
            [self moveEnergyBtn:_isPositive];
            [_pBtn stopAction];
            [_pBtn setUserInteractionEnabled:NO];
            
            [_speakViews setHidden:YES];
            [self showShareView:YES];
        }
    }
}



-(void)positiveButtonClick:(id)sender
{
    if (_state == 0) {
        _state = 1;
        _isPositive = YES;
        _lastClickTime = [NSDate date];
        [self moveEnergyBtn:_isPositive];
        [self setNeedsDisplay];
    }
    else if (_state == 1) {
        if (_clickVal < _pClickCount-1) {
            ++_clickVal;
            _curClickVal+=_pClickIncrease;
            [self computeEnergyScore];
            [self updateSpeakText:YES];
            [self setNeedsDisplay];
            
            if (_isShowShare) {
                [self showShareView:NO];
                [_speakViews setHidden:NO];
            }
            [self startShowShareTimer];
        }
        else {
            [_pBtn stopAction];
            [_pBtn setUserInteractionEnabled:NO];

        
            // todo 显示分享界面
            [_speakViews setHidden:YES];
            [self showShareView:YES];
        }
    }
}

-(void)moveEnergyBtn:(BOOL)isP
{
    if (isP) {
        CGPoint p = [_pBtn center];
        p.x = kContentWidth/2;
        _pBtn.center = p;
        
        [_nBtn clearResource];
        [_nBtn removeFromSuperview];
    }
    else {
        CGPoint p = [_nBtn center];
        p.x = kContentWidth/2;
        _nBtn.center = p;
        
        [_pBtn clearResource];
        [_pBtn removeFromSuperview];
    }
}


// 负能量按钮点击事件
-(void)negativeButtonClick:(id)sender
{
    if (_state == 0) {
        _state = 2;
        _isPositive = NO;
        _lastClickTime = [NSDate date];
        [self moveEnergyBtn:_isPositive];
        [self setNeedsDisplay];
    }
    else if (_state == 2) {
        if (_clickVal < _nClickCount-1) {
            ++_clickVal;
            _curClickVal+=_nClickIncrease;
            [self computeEnergyScore];
            [self updateSpeakText:NO];
            [self setNeedsDisplay];
            
            if (_isShowShare) {
                [self showShareView:NO];
                [_speakViews setHidden:NO];
            }
            [self startShowShareTimer];
            
        }
        else {
            [_nBtn stopAction];
            [_nBtn setUserInteractionEnabled:NO];
            
            // todo 显示分享界面
            [_speakViews setHidden:YES];
            [self showShareView:YES];
        }
    }
}

-(void)colseButtonClick:(id)sender
{
    if ([_delegate respondsToSelector:@selector(closeEnergyView:)]) {
        [_delegate closeEnergyView:0];
    }
}
// 分享继续按钮点击
-(void)continueBtnClick:(id)sender
{
    [self showShareView:NO];
    [_speakViews setHidden:NO];
    [self startShowShareTimer];
}
// 提交按钮
-(void)commitBtnClick:(id)sender
{
    [self commitEnergyScore:YES];
    
    NSInteger es = _isPositive ? _energyScore: -_energyScore;
    if (_isShareOrCommit) {
        es = 0;
        [PhoneNotification autoHideWithText:@"您已提交，感谢您的支持"];
    }
    if ([_delegate respondsToSelector:@selector(closeEnergyView:)]) {
        [_delegate closeEnergyView:es];
    }
}

// 保存正负能量值到数据库
-(void)saveEnergyScoreToDb
{
    if (_thread) {
        SurfDbManager *dbM = [SurfDbManager sharedInstance];
        NSInteger value = _isPositive ? _energyScore: -_energyScore;
        [dbM saveEnergyScore:_thread energyScore:(int)value];
    }
}

//发送能量值到服务端
- (void)sendEnergyHttp:(long)energyScore and:(void(^)(BOOL success))handler
{
    if (_thread){
        NSURLRequest *request=[SurfRequestGenerator getEnergyRequestWith:_thread andEnergyScore:energyScore];
        _httpFecther = [GTMHTTPFetcher fetcherWithRequest:request];
        [_httpFecther beginFetchWithCompletionHandler:^(NSData *data, NSError *error){
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            [[NSURLCache sharedURLCache] setDiskCapacity:0];
            [[NSURLCache sharedURLCache] setMemoryCapacity:0];
            
//            if (!error){
//                NSStringEncoding encoding = [[[_httpFecther response] textEncodingName] convertToStringEncoding];
//                NSString* body = [[NSString alloc] initWithData:data encoding:encoding];
//                DJLog(@"body: %@", body);
//            }
            
            if (handler) {
                handler(!error);
            }
        }];
    }
}

// 分享按钮
-(void)shareBtnClick:(id)sender
{
    long es = [self commitEnergyScore:NO];
    if ([_delegate respondsToSelector:@selector(shareEnergy:)]) {
        [_delegate shareEnergy:es];
    }
}

// 保存正负能量值和统计能量值
-(long)commitEnergyScore:(BOOL)isCommitBtn
{
    NSInteger es = _isPositive ? _energyScore: -_energyScore;
    if (!_isShareOrCommit) {
        _thread.energyScore = es;
        [self sendEnergyHttp:es and:^(BOOL success) {
            if (success) {
                _isShareOrCommit = YES;
                [self saveEnergyScoreToDb];
                if(isCommitBtn){
                    [PhoneNotification autoHideWithText:@"已提交成功，感谢您的支持"];
                }
            }
            else{
                // 数据恢复
                _thread.energyScore = 0;
                if(isCommitBtn){
                    [PhoneNotification autoHideWithText:@"能量爆仓了，请重试"];
                }
            }
        }];
    }
    return es;
}


-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextSaveGState(context);
    
    // 绘制半透明背景
    [[UIColor colorWithWhite:0.f alpha:0.6] setFill];
    CGContextFillRect(context, rect);
    
    if (_state == 0)
        [self drawNormal:context];
    else {
        BOOL isP = _state == 1;
        if (_curClickVal == 0) {
            [self drawTipText:context isPositive:isP];
        }
        else {
            // 正能量值
            [self drawEnergyVale:context];
        }
        [self drawEnergyProgressBar:context isPositive:isP];
    }
    
    CGContextRestoreGState(context);
    UIGraphicsPopContext();
}

-(void)drawNormal:(CGContextRef)context
{
    NSString *title = @"点击  '正'  或  '负' ";
    NSString *content = @"看新闻，我有我脾气！";
    UIFont *font = [UIFont systemFontOfSize:28.f];
    float lineH = ceilf(font.lineHeight);

    CGRect titleR = CGRectMake(0.f, 180.f, kContentWidth, lineH);
    CGRect contentR = CGRectOffset(titleR, 0, 50.f);
    [title surfDrawString:titleR
                 withFont:font
                withColor:[UIColor whiteColor]
            lineBreakMode:NSLineBreakByWordWrapping
                alignment:NSTextAlignmentCenter];
    
    [content surfDrawString:contentR
                   withFont:font
                  withColor:[UIColor whiteColor]
              lineBreakMode:NSLineBreakByWordWrapping
                  alignment:NSTextAlignmentCenter];
}

-(void)drawTipText:(CGContextRef)context isPositive:(BOOL)isP
{
    NSString *tipText = isP?@"这新闻太正能量了！猛戳加\"正\"":@"这新闻太负能量了！猛戳加\"负\"";
    UIFont *tipFont = [UIFont systemFontOfSize:15];
    CGRect tipR = CGRectMake(0, _btnY-180, kContentWidth, tipFont.lineHeight);
    
    [tipText surfDrawString:tipR
                   withFont:tipFont
                  withColor:[UIColor whiteColor]
              lineBreakMode:NSLineBreakByCharWrapping
                  alignment:NSTextAlignmentCenter];
}

// 能量进度条
-(void)drawEnergyProgressBar:(CGContextRef)context
                  isPositive:(BOOL)isP
{
    float halfW = kContentWidth/2.f;
    float epbW = 10.f;
    float epbH = _curClickVal>0?_curClickVal*50.f:1.f;
    float halfEPBW = epbW / 2.f;
    float pY1 = _btnY-50;
    float pX1 = halfW - halfEPBW;
    
    UIColor *epbColor = [UIColor redColor];
    if(!isP){
        if ([ThemeMgr sharedInstance].isNightmode) {
            epbColor = [UIColor grayColor];
        }
        else {
            epbColor = [UIColor blackColor];
        }
    }
    
    CGRect epbR = CGRectMake(pX1, pY1- epbH, epbW, epbH);
    CGPathRef rectPath = CGPathCreateWithRect(epbR, nil);
    CGContextBeginPath( context );
    CGContextAddPath( context, rectPath );
    CGPathRelease(rectPath);
    CGContextClosePath( context );
    [epbColor setFill];
    CGContextDrawPath(context, kCGPathFill);
}

-(void)drawEnergyVale:(CGContextRef)context
{
    long w = 100;
    NSString *valueStr = [NSString stringWithFormat:@"+ %@",@(_energyScore)];
    UIFont *font = [UIFont systemFontOfSize:18];
    CGRect rect = CGRectMake((kContentWidth-w)/2,
                             _btnY-130,
                             w, font.lineHeight);
    [valueStr surfDrawString:rect
                    withFont:font
                   withColor:[UIColor redColor]
               lineBreakMode:NSLineBreakByWordWrapping
                   alignment:NSTextAlignmentCenter];
}


// 计算能量分数
-(void)computeEnergyScore
{
    NSDate *curDate = [NSDate date];
    NSTimeInterval interval = [curDate timeIntervalSinceDate:_lastClickTime]*1000;
    _lastClickTime = curDate;
    long addScore = (int)( interval<=700 ? (-13.1/60*interval+140+(130/6)) : (9+(arc4random()%2)*6) );
    _energyScore += addScore;
}

-(void)updateSpeakText:(BOOL)isP
{
    long idx = (_clickVal-1) / 5;
    long fIdx = (_clickVal-1) % 5;
    NSString *speakText;
    UIFont *f = [UIFont systemFontOfSize:15+5*fIdx];
    if (isP) {
        speakText = [_pSpeakText objectAtIndex:idx];
    }
    else {
        speakText = [_nSpeakText objectAtIndex:idx];
    }

    
    long textIdx = idx%3;
    if(textIdx==0 ){
        if (fIdx == 0) {
            CGPoint p = _speakLabel1.center;
            p.y += 50.f;
            _speakLabel1.center = p;
            _speakLabel1.hidden = NO;
            [self speakTextBeginAnimate:_speakLabel1];
        }
        else {
            _speakLabel3.alpha -= 0.3f;
            if (_speakLabel3.alpha <= 0) {
                _speakLabel3.alpha = 1.f;
                _speakLabel3.hidden = YES;
            }
        }
        _speakLabel1.font = f;
        _speakLabel1.text = speakText;
    }
    else if(textIdx==1){
        if (fIdx == 0) {
            CGPoint p = _speakLabel2.center;
            p.y += 50.f;
            _speakLabel2.center = p;
            _speakLabel2.hidden = NO;
            [self speakTextBeginAnimate:_speakLabel2];
        }
        else {
            _speakLabel1.alpha -= 0.3f;
            if (_speakLabel1.alpha <= 0) {
                _speakLabel1.alpha = 1.f;
                _speakLabel1.hidden = YES;
            }
        }
        _speakLabel2.font = f;
        _speakLabel2.text = speakText;
    }
    else if(textIdx==2){
        if (fIdx == 0) {
            CGPoint p = _speakLabel3.center;
            p.y += 50.f;
            _speakLabel3.center = p;
            _speakLabel3.hidden = NO;
            [self speakTextBeginAnimate:_speakLabel3];
        }
        else {
            _speakLabel2.alpha -= 0.3f;
            if (_speakLabel2.alpha <= 0) {
                _speakLabel2.alpha = 1.f;
                _speakLabel2.hidden = YES;
            }
        }
        _speakLabel3.font = f;
        _speakLabel3.text = speakText;
    }
}

// 表述文字开始动画
-(void)speakTextBeginAnimate:(UIView*)view
{
    view.alpha = 0.3f;
    [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.center = CGPointMake(view.center.x, view.center.y-50);
        view.alpha = 1.f;
    } completion:^(BOOL finished) {
        
    }];
}


-(void)showShareView:(BOOL)isShow
{
    // 分享
    _isShowShare = isShow;
    NSString *titleStr;
    NSString *continueStr;
    if(_isPositive){
        continueStr = @"我要继续发正能量>>";
        titleStr = [NSString stringWithFormat:@"%@正能量",@(_energyScore)];
    }
    else {
        continueStr = @"我要继续发负能量>>";
        titleStr = [NSString stringWithFormat:@"%@负能量",@(_energyScore)];
    }
    
    [_shareTitle2 setText:titleStr];
    [_shareTitle1 setHidden:!_isShowShare];
    [_shareTitle2 setHidden:!_isShowShare];
    [_commitBtn setHidden:!_isShowShare];
    [_shareBtn setHidden:!_isShowShare];
    
    BOOL isHidder = _isShowShare?((_clickVal==(_isPositive?_pClickCount:_nClickCount)-1)?YES:NO):YES;
    [_continueBtn setHidden:isHidder];
    [_arrowImg setHidden:isHidder];
    [_guideImg setHidden:isHidder];
    [_continueBtn setTitle:continueStr forState:UIControlStateNormal];
}


// 显示分享界面的定时器
-(void)showShareTimerMethod:(id)sender
{
    if (!_isShowShare) {
        [_speakViews setHidden:YES];
        [self showShareView:YES];
    }
    
    if (!_arrowImg.isHidden) {
        [UIView animateWithDuration:0.1f delay:0.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            CGPoint p = _arrowImg.center;
            p.x -= 10;
            p.y += 5;
            _arrowImg.center = p;
        } completion:^(BOOL finished) {
            CGPoint p = _arrowImg.center;
            p.x += 10;
            p.y -= 5;
            _arrowImg.center = p;
        }];
    }
}

-(void)startShowShareTimer
{
    NSDate *d = [[NSDate date] dateByAddingTimeInterval:2];
    [_showShareTimer setFireDate:d];
}

-(void)stopShowShareTime
{
    [_showShareTimer setFireDate:[NSDate distantFuture]];
}


-(void)clearResource
{
    if ([_showShareTimer isValid]) {
        [_showShareTimer invalidate];
    }
    _showShareTimer = nil;
    
    [_pBtn clearResource];
    [_nBtn clearResource];
}
@end


@interface CustomCircleBtn(){
    
    UIImageView *_animatedView;
    NSTimer *_timer;    // 定时器
    BOOL _timerIsStop;
}


@end



@implementation CustomCircleBtn

+(id)circleButton:(BOOL)isPositive point:(CGPoint)p
{
    UIImage *bgImg = isPositive ? [UIImage imageNamed:@"btn_red_1"] :
    [UIImage imageNamed:@"btn_black_1"];
    UIImage *bgHLImg = isPositive ? [UIImage imageNamed:@"btn_red_2"] :
    [UIImage imageNamed:@"btn_black_2"];


    // 创建按钮
    CustomCircleBtn *btn = [CustomCircleBtn buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(p.x, p.y, bgImg.size.width+20, bgImg.size.height+20);
    [btn setBackgroundImage:bgImg forState:UIControlStateNormal];
    [btn setBackgroundImage:bgHLImg forState:UIControlStateHighlighted];
    [btn initAnimated];
    [btn stateAction];
    return btn;
}





-(void)initAnimated
{
    UIImage *animation1 = [UIImage imageNamed:@"wave_1"];
    UIImage *animation2 = [UIImage imageNamed:@"wave_2"];
    UIImage *animation3 = [UIImage imageNamed:@"wave_3"];
    NSArray *myImages = [NSArray arrayWithObjects:
                         animation1, animation2, animation3,nil];
    
    
    // sircle 动画1
    float imgsW = animation1.size.width+20;
    float imgsH = animation1.size.height+20;
    float imgsX = -(imgsW - CGRectGetWidth(self.bounds))/2;
    float imgsY = -(imgsH - CGRectGetHeight(self.bounds))/2;
    CGRect imgsR = CGRectMake(imgsX, imgsY, imgsW, imgsH);
    _animatedView = [[UIImageView alloc] initWithFrame:imgsR];
    _animatedView.animationImages = myImages;
    _animatedView.animationDuration = 0.25;       // 浏览整个图片一次所用的时间
    _animatedView.animationRepeatCount = 3;        // 动画重复次数, 0:表示无限
    [self addSubview:_animatedView];
}


// 开始，暂停 动画
-(void)stateAction
{
    if (!_timer){
        _timerIsStop = NO;
        _timer = [NSTimer scheduledTimerWithTimeInterval:3.f target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    }
    else
    {
        _timerIsStop = NO;
        [_timer setFireDate:[NSDate date]];
    }
}
-(void)stopAction;
{
    _timerIsStop = YES;
    [_timer setFireDate:[NSDate distantFuture]];
}

-(BOOL)isStop
{
    return _timerIsStop;
}
-(void)timerFired:(NSTimer*)timer
{
    if (![_animatedView isAnimating]) {
        [_animatedView startAnimating];
    }
}


// 释放资源在不用的时候
-(void)clearResource
{
    // 释放定时器
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
    
    // 关闭动画
    [_animatedView stopAnimating];
    _animatedView = nil;
}
@end


