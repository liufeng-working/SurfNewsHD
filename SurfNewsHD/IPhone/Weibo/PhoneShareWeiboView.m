//
//  PhoneShareWeiboView.m
//  SurfNewsHD
//
//  Created by XuXg on 15/1/12.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "PhoneShareWeiboView.h"
#import "PhoneWeiboController.h"

#define kWeiboHeight 50.f
#define kWeiboWidth  200.f
#define kTitleHeight 40.f
#define kNameHeight  30.f
#define lineNum      4


@interface PhoneShareButton()

@property(nonatomic,strong)UIImageView * iconImage;
@property(nonatomic,strong)UILabel * titleLabel;

@end

@implementation PhoneShareButton

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat iH = 47.f;
        CGFloat iX = (self.bounds.size.width - iH) / 2.f;
        CGFloat iY = (kWeiboHeight-iH)/2.f;
        CGRect iR = CGRectMake(iX, iY, iH, iH);
        UIImageView * iconImage=[[UIImageView alloc]initWithFrame:iR];
        _iconImage = iconImage;
        [self addSubview:iconImage];
        
        CGFloat tX = 0.f;
        CGFloat tY = kWeiboHeight;
        CGFloat tW = self.bounds.size.width;
        CGFloat tH = kNameHeight;
        UILabel * titleLab=[[UILabel alloc]initWithFrame:CGRectMake(tX, tY, tW, tH)];
        _titleLabel = titleLab;
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLab];
    }
    return self;
}

//set方法，给图标和名字 赋值
-(void)setWeiboInfo:(WeiboInfo *)weiboInfo
{
    _weiboInfo = weiboInfo;
    _iconImage.image = weiboInfo.weiboIcon;
    _titleLabel.text = weiboInfo.title;
}

//点击了某个按钮
-(void)btnClick:(UIControl *)sender
{
    if ([_buttonDelegate respondsToSelector:@selector(btnClickWithType:)]) {
        [_buttonDelegate btnClickWithType:sender.tag];
    }
}

@end

@interface PhoneShareBgView()
{
    CGFloat _cH; //删除按钮的高度
}

@end

@implementation PhoneShareBgView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //删除按钮的坐标
        UIImage * cancelImg = [UIImage imageNamed:@"share_cancel"];
        //增大点击区域
        CGFloat cW = cancelImg.size.width * 2.f;
        CGFloat cH = cancelImg.size.height + 10.f;
        _cH = cH;
        CGFloat cX = self.bounds.size.width - cW;
        CGFloat cY = 0.f;
        CGRect cR = CGRectMake(cX, cY, cW, cH);
        
        //增加背景view的高度
        CGRect rect = frame;
        rect.size.height += cH;
        rect.origin.y -= cH;
        self.frame = rect;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth = 1.f;
        self.layer.borderColor = [UIColor grayColor].CGColor;
        
        //删除按钮
        UIButton * canBtn = [[UIButton alloc]initWithFrame:cR];
        [canBtn setImage:cancelImg forState:UIControlStateNormal];
        [canBtn addTarget:self action:@selector(cancelBtnClcik) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:canBtn];
    }
    return self;
}

-(void)setWeiBoInfoList:(NSArray *)weiBoInfoList
{
    _weiBoInfoList = weiBoInfoList;
    
    for (NSInteger i=0; i<weiBoInfoList.count; i++) {
        
        WeiboInfo * info = weiBoInfoList[i];
        NSInteger X = i%lineNum;
        NSInteger Y = i/lineNum;
        CGFloat bW = self.bounds.size.width / (CGFloat)lineNum;
        CGFloat bH = kWeiboHeight + kNameHeight;
        CGFloat bX = X * bW;
        CGFloat bY = Y * bH + _cH;
        CGRect bR = CGRectMake(bX, bY, bW, bH);
        PhoneShareButton * btn = [[PhoneShareButton alloc]initWithFrame:bR];
        btn.tag = i;
        btn.weiboInfo = info;
        btn.buttonDelegate = self;
        [self addSubview:btn];
    }
}

#pragma mark - ****PhoneShareButtonDelegate****
-(void)btnClickWithType:(NSInteger)index
{
    if ([_bgViewDelegate respondsToSelector:@selector(selectWeiboTypeWithIndex:)]) {
        [_bgViewDelegate selectWeiboTypeWithIndex:index];
    }
}

//修改view的背景色
-(void)setBackGroundColor:(UIColor *)backGroundColor
{
    _backGroundColor = backGroundColor;
    self.backGroundColor = backGroundColor;
}

//删除按钮点击事件
-(void)cancelBtnClcik
{
    [self.superview removeFromSuperview];
}

@end

@implementation WeiboInfo

-(id)initWithWeiboType:(WeiboType)type
{
    self = [super init];
    if(!self)return nil;
    
    _weiboType = type;
    if (_weiboType == kWeixin) {
        _title = @"微信";
        _weiboIcon = [UIImage imageNamed:@"weixin"];
    }
    else if(_weiboType == kWeiXinFriendZone){
        _title = @"朋友圈";
        _weiboIcon = [UIImage imageNamed:@"weixin_friendzone"];
    }
    else if(_weiboType == kSinaWeibo){
        _title = @"新浪微博";
        _weiboIcon = [UIImage imageNamed:@"sina"];
    }
    else if (_weiboType == kQQFriend){
        _title = @"QQ好友";
        _weiboIcon = [UIImage imageNamed:@"QQ_friend"];
    }
    else if (_weiboType == kQZone){
        _title = @"QQ空间";
        _weiboIcon = [UIImage imageNamed:@"QQ_zone"];
    }
    else if(_weiboType == kSMS){
        _title = @"短信";
        _weiboIcon = [UIImage imageNamed:@"SMS"];
    }
    else if(_weiboType == kPasteboard){
        _title = @"复制链接";
        _weiboIcon = [UIImage imageNamed:@"wb_pasteboard"];
    }
    else if(_weiboType == kMore){
        _title = @"更多";
        _weiboIcon = [UIImage imageNamed:@"more"];
    }
    return self;
}
@end

@interface PhoneShareWeiboView ()
<UITableViewDelegate,UITableViewDataSource>{
    
    WeiboType _weiboType;
    NSMutableArray *_weiboInfoList;
    
    // 背景
    __weak UIControl *_weiboBGView;
}

@end


@interface PhoneShareWeiboView()
{
    PhoneShareBgView * _bgView;
}

@end
@implementation PhoneShareWeiboView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    _weiboInfoList = [NSMutableArray array];
    
    _weiboViewBgColor = [UIColor colorWithWhite:0.f alpha:0.5f];
    UIControl *bgV = [[UIControl alloc] initWithFrame:self.bounds];
    [bgV setBackgroundColor:_weiboViewBgColor];
    [bgV addTarget:self action:@selector(bgClick:)
  forControlEvents:UIControlEventTouchUpInside];
    _weiboBGView = bgV;
    [self addSubview:bgV];
    
    return self;
}

-(void)setWeiboViewBgColor:(UIColor *)weiboViewBgColor
{
    _weiboViewBgColor = weiboViewBgColor;
    [_weiboBGView setBackgroundColor:weiboViewBgColor];
}

-(void)weiboModel:(WeiboViewLayoutModel)model
        weiboType:(WeiboType)type
{
    if (type == 0)
        return;
    
    _weiboType = type;
    float weiboHeight = kTitleHeight; // 标题高度
    [_weiboInfoList removeAllObjects];// 删除微博信息
    
    // 从新生成微博信息
    NSInteger bit = 1;
    while (type >= bit)
    {
        if (type & bit)
        {
            weiboHeight += kWeiboHeight;
            WeiboInfo *info = [[WeiboInfo alloc] initWithWeiboType:bit];
            [_weiboInfoList addObject:info];
        }
        bit <<=1;
    }
    
    
    if (model == kWeiboView_Center) {
        
        CGRect lR = CGRectMake(0, 0, kWeiboWidth, kTitleHeight);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:lR];
        [titleLabel setText:@"分享方式"];
        [titleLabel setFont:[UIFont systemFontOfSize:20.0f]];
        [titleLabel setTextColor:[UIColor colorWithHexValue:0xffad2f2f]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        
        CGRect r = CGRectMake(0, 0, kWeiboWidth, weiboHeight);
        UITableView *table = [[UITableView alloc] initWithFrame:r style:UITableViewStylePlain];
        table.showsVerticalScrollIndicator = NO;
        table.showsHorizontalScrollIndicator = NO;
        table.scrollEnabled = NO; // 不让滚动
        table.delegate = self;
        table.dataSource = self;
        CGPoint center = self.center;
//        center.y -= 30.f;
        table.center = center;
        table.tableHeaderView = titleLabel;
        table.tableFooterView = [[UIView alloc] init];
        table.layer.cornerRadius = 4.f;
        table.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8f, 0.8f);
        [self addSubview:table];

        
        [table reloadData];
        
        // 显示动画
        [UIView animateWithDuration:0.1f animations:^{
            table.transform = CGAffineTransformIdentity;
        }];
    }else if (model == kWeiboView_Bottom){
        if(_weiboInfoList.count <= 0) return;
        //背景的view
        CGFloat vX = 0.f;
        CGFloat vW = self.bounds.size.width;
        CGFloat vH = ((_weiboInfoList.count - 1) / lineNum + 1) * (kWeiboHeight + kNameHeight);
        CGFloat vY = self.bounds.size.height - vH;
        CGRect vR = CGRectMake(vX, vY, vW, vW);
        _bgView = [[PhoneShareBgView alloc]initWithFrame:vR];
        _bgView.weiBoInfoList = _weiboInfoList;
        _bgView.bgViewDelegate = self;
        _bgView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8f, 0.8f);
        [self addSubview:_bgView];
        
        // 显示动画
        [UIView animateWithDuration:0.1f animations:^{
            _bgView.transform = CGAffineTransformIdentity;
        }];
    }
}

#pragma mark - ****PhoneShareBgViewDelegate****
-(void)selectWeiboTypeWithIndex:(NSInteger)index
{
    [self sendShareInfoWithIndex:index withView:_bgView];
}

-(void)bgClick:(id)sender
{
    [self removeFromSuperview];
}


#pragma mark UITableViewDelegate
// 点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger rowIndex = indexPath.row;
    [self sendShareInfoWithIndex:rowIndex withView:tableView];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kWeiboHeight;
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [_weiboInfoList count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"weibo"];
    
    {
        WeiboInfo *info = [_weiboInfoList objectAtIndex:row];
       
        CGFloat imgH = kWeiboHeight * 2 / 3;
        CGFloat imgX = 10.f;
        CGFloat imgY = (kWeiboHeight-imgH)/2.f;
        CGRect imgR = CGRectMake(imgX, imgY, imgH, imgH);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:imgR];
        [imgView setImage:info.weiboIcon];
        [[cell contentView] addSubview:imgView];
        [[cell textLabel] setText:info.title];
        [[cell textLabel] setTextAlignment:NSTextAlignmentCenter];
        
    }
    return cell;
}

-(void)sendShareInfoWithIndex:(NSInteger)index withView:(id)view
{
    WeiboInfo * weibo = _weiboInfoList[index];
    PhoneWeiboController *weiboVc =
    [view findUserObject:[PhoneWeiboController class]];
    SEL shareWeibo = NSSelectorFromString(@"shareWeiboWithNum:");
    if ([weiboVc respondsToSelector:shareWeibo]) {
        NSNumber * weiboNum = [NSNumber numberWithInteger:(NSInteger)weibo.weiboType];
        StartSuppressPerformSelectorLeakWarning
        [weiboVc performSelector:shareWeibo withObject:weiboNum];
        EndSuppressPerformSelectorLeakWarning
    }
}

@end
