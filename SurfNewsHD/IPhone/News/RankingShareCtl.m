//
//  RankingShareCtl.m
//  SurfNewsHD
//
//  Created by admin on 14-12-2.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#define shareStyle 6

#import "RankingShareCtl.h"
#import "NSString+Extensions.h"


@interface ShareView_Ranking ()<UITableViewDataSource,UITableViewDelegate> {
    UIFont *_titleFont;
    UIColor *_titleColor;
    NSDictionary *_weixinList;
    UIFont *_weixinFont;
    UIColor *_weixinColor;
    
    UITableView * m_tableview;

}



@end
@implementation ShareView_Ranking


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _title = @"分享方式";
        _titleFont = [UIFont systemFontOfSize:14.0f];
        _titleColor = [UIColor colorWithHexValue:0xffad2f2f];
        
        _weixinList = [NSDictionary dictionaryWithObjectsAndKeys:
                       [UIImage imageNamed:@"weixin"], @"微信",
                       [UIImage imageNamed:@"weixin_friendzone"], @"朋友圈",
                       [UIImage imageNamed:@"sina"],@"新浪",
                       [UIImage imageNamed:@"SMS"], @"短信",
                       nil];
        _weixinFont = [UIFont systemFontOfSize:12.0f];
        _weixinColor = [UIColor colorWithHexValue:kReadTitleColor];
        
        
        CGRect tableR = self.bounds;
        tableR.origin.y = 30.f;
        tableR.size.height -= 30.f;
        
        m_tableview = [[UITableView alloc] initWithFrame:tableR style:UITableViewStylePlain];
        m_tableview.delegate = self;
        m_tableview.dataSource = self;
        [m_tableview setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        m_tableview.separatorColor = [UIColor colorWithHexString:@"e3e2e2"];
        [self addSubview:m_tableview];

        
        
        self.layer.cornerRadius = 5.f;
        self.clipsToBounds = YES;
    }
    return self;
}


-(void)drawRect:(CGRect)rect
{
    float w = CGRectGetWidth(self.bounds);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    // 标题
    CGRect titleR = CGRectMake(0, 10, w, _titleFont.lineHeight);
    [_title surfDrawString:titleR
                  withFont:_titleFont
                 withColor:_titleColor
             lineBreakMode:NSLineBreakByWordWrapping
                 alignment:NSTextAlignmentCenter];
    
//    // 微信
//    float iconW = 40.f;
//    float iconH = 40.f;
//    float iconX = 10.f;
//    float wxNameX = iconX + iconW + 15.f;
//    float weixinH = 50.f;
//    float weixinY = titleR.origin.y + titleR.size.height + 10.f;
//    float iconY = weixinY+(weixinH-iconH)/2;
//    float strY = weixinY + (weixinH- _weixinFont.lineHeight)/2;
//    CGRect iconR = CGRectMake(iconX, iconY, iconW, iconH);
//    CGRect strR = CGRectMake(wxNameX, strY, w-wxNameX, _weixinFont.lineHeight);
//    
//    float lineY = weixinY;
//    UIColor *lineColor = [UIColor colorWithHexValue:0xFFe3e2e2];
//    NSArray *keys = [_weixinList allKeys];
//    CGContextSetLineWidth(context, 1);
//    
//    for (int i=0 ; i<keys.count; ++i) {
//        if(i == 0) {
//            [lineColor setStroke];
//            CGContextMoveToPoint(context, 10, lineY);
//            CGContextAddLineToPoint(context, w-20, lineY);
//            CGContextStrokePath(context);
//        }
//        
//        lineY += weixinH;
//        NSString *k = [keys objectAtIndex:i];
//        // 绘制图片
//        [[_weixinList objectForKey:k] drawInRect:iconR];
//        
//        // 绘制标题
//        [k surfDrawString:strR
//                              withFont:_weixinFont
//                             withColor:_weixinColor
//                         lineBreakMode:NSLineBreakByWordWrapping
//                             alignment:NSTextAlignmentLeft];
//        
//        if (i< [keys count]-1) {
//            [lineColor setStroke];
//            CGContextMoveToPoint(context, 10, lineY);
//            CGContextAddLineToPoint(context, w-20, lineY);
//            CGContextStrokePath(context);
//        }
//        
//        iconR = CGRectOffset(iconR, 0, weixinH);
//        strR = CGRectOffset(strR, 0, weixinH);
//    }
    
    
    UIGraphicsPopContext();
}



#pragma mark TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_weixinList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ShareCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        UIView *bgView = [[UIView alloc] initWithFrame:[cell bounds]];
        bgView.backgroundColor = [UIColor colorWithHexValue:kTableCellSelectedColor];
        cell.selectedBackgroundView = bgView;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    UIImageView *weixinImg  = nil;
    UIImageView *weixin_friendzoneImg = nil;
    UIImageView *sinaImg = nil;
    UIImageView *smsImg = nil;
    CGRect iconR = CGRectMake(15, 10.0f, 30.0f, 30.0f);
    CGRect labR = CGRectMake(60.0f, 10.0f, 60.0f, 30.0f);
    switch (indexPath.row) {
        case 0:
        {
            weixinImg = [[UIImageView alloc] initWithFrame:iconR];
            [weixinImg setImage:[UIImage imageNamed:@"weixin.png"]];
            [cell addSubview:weixinImg];
            UILabel *weixinTxt = [[UILabel alloc] initWithFrame:labR];
            [weixinTxt setText:@"微信"];
            weixinTxt.font = [UIFont systemFontOfSize:12.0f];
            weixinTxt.textColor = [UIColor colorWithHexValue:kReadTitleColor];
            [cell addSubview:weixinTxt];
        }
            break;
        case 1:
        {
            weixin_friendzoneImg = [[UIImageView alloc] initWithFrame:iconR];;
            [weixin_friendzoneImg setImage:[UIImage imageNamed:@"weixin_friendzone.png"]];
            [cell addSubview:weixin_friendzoneImg];
            UILabel *weixin_friendzoneTxt =
            [[UILabel alloc] initWithFrame:labR];
            [weixin_friendzoneTxt setText:@"朋友圈"];
            weixin_friendzoneTxt.font = [UIFont systemFontOfSize:12.0f];
            weixin_friendzoneTxt.textColor = [UIColor colorWithHexValue:kReadTitleColor];
            [cell addSubview:weixin_friendzoneTxt];
        }
            break;
        case 2:
        {
            sinaImg = [[UIImageView alloc] initWithFrame:iconR];
            [sinaImg setImage:[UIImage imageNamed:@"sina.png"]];
            [cell addSubview:sinaImg];
            UILabel *sinaTxt = [[UILabel alloc] initWithFrame:labR];
            [sinaTxt setText:@"新浪微博"];
            sinaTxt.font = [UIFont systemFontOfSize:12.0f];
            sinaTxt.textColor = [UIColor colorWithHexValue:kReadTitleColor];
            [cell addSubview:sinaTxt];
        }
            break;
        case 3:
        {
            smsImg = [[UIImageView alloc] initWithFrame:iconR];;
            [smsImg setImage:[UIImage imageNamed:@"SMS"]];
            [cell addSubview:smsImg];
            UILabel * smsTxt = [[UILabel alloc] initWithFrame:labR];
            [smsTxt setText:@"短信"];
            smsTxt.font = [UIFont systemFontOfSize:12.0f];
            smsTxt.textColor = [UIColor colorWithHexValue:kReadTitleColor];
            [cell addSubview:smsTxt];
        }
            break;
        default:
            break;
            
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger index = indexPath.row + 1000;
    if (index == ItemWeixin){
        if ([_delegate respondsToSelector:@selector(shareMenuSelected:)]) {
            [_delegate shareMenuSelected:ItemWeixin];
        }
    }
    else if(index == ItemWeiXinFriendZone){
        if ([_delegate respondsToSelector:@selector(shareMenuSelected:)]) {
            [_delegate shareMenuSelected:ItemWeiXinFriendZone];
        }
    }
    else if(index == ItemSinaWeibo){
        if ([_delegate respondsToSelector:@selector(shareMenuSelected:)]) {
            [_delegate shareMenuSelected:ItemSinaWeibo];
        }
        
    }
    else if(index == ItemSMS){
        if ([_delegate respondsToSelector:@selector(shareMenuSelected:)]) {
            [_delegate shareMenuSelected:ItemSMS];
        }
        
    }
}


@end



@implementation RankingShareCtl

- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        self.view.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    m_popview = [[UIView alloc] init];
    [m_popview setFrame:CGRectMake(self.view.frame.size.width - 260.0f, self.view.frame.size.height-440, 200.0, self.view.frame.size.height-100)];
    [self.view addSubview:m_popview];
    
    //设置蒙版
    [self initTitle];
    
    // Do any additional setup after loading the view.
}


- (void)initTitle{
    m_title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 32.0f)];
    [m_title setText:@"分享方式"];
    [m_title setTextAlignment:NSTextAlignmentCenter];
    [m_title setFont:[UIFont systemFontOfSize:14.0f]];
    m_title.textColor = [UIColor colorWithHexString:@"ad2f2f"];

    [m_popview addSubview:m_title];
}


@end
