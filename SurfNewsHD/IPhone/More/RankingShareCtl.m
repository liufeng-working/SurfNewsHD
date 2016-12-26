//
//  RankingShareCtl.m
//  SurfNewsHD
//
//  Created by admin on 14-12-2.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#define shareStyle 6

#import "RankingShareCtl.h"

@interface RankingShareCtl ()

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
    [m_popview setFrame:CGRectMake(60.0, 60.0f+100.0, 200.0, 285.0)];
    [self.view addSubview:m_popview];
    
    //设置蒙版
    [self initTableView];
    
    [self initTitle];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initTitle{
    m_title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 32.0f)];
    [m_title setText:@"分享方式"];
    m_title.textAlignment = UITextAlignmentCenter;
    [m_title setFont:[UIFont systemFontOfSize:14.0f]];
    m_title.textColor = [UIColor hexChangeFloat:@"ad2f2f"];

    [m_popview addSubview:m_title];
}

- (void)initTableView{

    if (m_tableview == nil){
        
        m_tableview = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 285.0f) style:UITableViewStyleGrouped];
        m_tableview.delegate = self;
        m_tableview.dataSource = self;
        m_tableview.backgroundView = nil;
        [m_tableview setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        m_tableview.separatorColor = [UIColor hexChangeFloat:@"e3e2e2"];
        m_tableview.scrollEnabled = NO;
        [m_popview addSubview:m_tableview];
    }

}

#pragma mark TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return shareStyle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"RankingShareCell";
    UITableViewCell * cell = [m_tableview dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        UIView *bgView = [[UIView alloc] initWithFrame:[cell bounds]];
        bgView.backgroundColor = [UIColor hexChangeColor:kTableCellSelectedColor];
        bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cell.selectedBackgroundView = bgView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIImageView *weixinImg  = nil;
    UIImageView *weixin_friendzoneImg = nil;
    UIImageView *sinaImg = nil;
    UIImageView *tencentImg = nil;
    UIImageView *smsImg = nil;

    switch (indexPath.row) {
        case 0:
            {
                weixinImg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10.0f, 30.0f, 30.0f)];
                [weixinImg setImage:[UIImage imageNamed:@"weixin.png"]];
                [cell addSubview:weixinImg];
                UILabel *weixinTxt = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 10.0f, 60.0f, 30.0f)];
                [weixinTxt setText:@"微信"];
                weixinTxt.font = [UIFont systemFontOfSize:12.0f];
                weixinTxt.textColor = [[ThemeMgr sharedInstance]isNightmode]?[UIColor whiteColor]:[UIColor hexChangeColor:kReadTitleColor];;
                [cell addSubview:weixinTxt];
            }
            break;
        case 1:
            {
                weixin_friendzoneImg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10.0f, 30.0f, 30.0f)];;
                [weixin_friendzoneImg setImage:[UIImage imageNamed:@"weixin_friendzone.png"]];
                [cell addSubview:weixin_friendzoneImg];
                UILabel *weixin_friendzoneTxt = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 10.0f, 60.0f, 30.0f)];
                [weixin_friendzoneTxt setText:@"朋友圈"];
                weixin_friendzoneTxt.font = [UIFont systemFontOfSize:12.0f];
                weixin_friendzoneTxt.textColor = [[ThemeMgr sharedInstance]isNightmode]?[UIColor whiteColor]:[UIColor hexChangeColor:kReadTitleColor];;
                [cell addSubview:weixin_friendzoneTxt];
            }
            break;
        case 2:
            {
                sinaImg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10.0f, 30.0f, 30.0f)];;
                [sinaImg setImage:[UIImage imageNamed:@"sina.png"]];
                [cell addSubview:sinaImg];
                UILabel *sinaTxt = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 10.0f, 60.0f, 30.0f)];
                [sinaTxt setText:@"新浪微博"];
                sinaTxt.font = [UIFont systemFontOfSize:12.0f];
                sinaTxt.textColor = [[ThemeMgr sharedInstance]isNightmode]?[UIColor whiteColor]:[UIColor hexChangeColor:kReadTitleColor];;
                [cell addSubview:sinaTxt];
            }
            break;
        case 3:
            {
                tencentImg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10.0f, 30.0f, 30.0f)];;
                [tencentImg setImage:[UIImage imageNamed:@"tencent.png"]];
                [cell addSubview:tencentImg];
                UILabel *tencentTxt = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 10.0f, 60.0f, 30.0f)];
                [tencentTxt setText:@"腾讯微博"];
                tencentTxt.font = [UIFont systemFontOfSize:12.0f];
                tencentTxt.textColor = [[ThemeMgr sharedInstance]isNightmode]?[UIColor whiteColor]:[UIColor hexChangeColor:kReadTitleColor];;
                [cell addSubview:tencentTxt];
            }
            break;
        case 4:
            {
                smsImg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10.0f, 30.0f, 30.0f)];;
                [smsImg setImage:[UIImage imageNamed:@"SMS.png"]];
                [cell addSubview:smsImg];
                UILabel * smsTxt = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 10.0f, 60.0f, 30.0f)];
                [smsTxt setText:@"短信"];
                smsTxt.font = [UIFont systemFontOfSize:12.0f];
                smsTxt.textColor = [[ThemeMgr sharedInstance]isNightmode]?[UIColor whiteColor]:[UIColor hexChangeColor:kReadTitleColor];;
                [cell addSubview:smsTxt];
            }
             break;
        default:
             break;
    
    }
//    [cell applyTheme:isNightMode];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int index = indexPath.row + 1000;
    if (index == ItemWeixin){
        if ([_delegate respondsToSelector:@selector(shareMenuSelected:)]) {
            [_delegate shareMenuSelected:ItemWeixin];
        }
    }
    else if(index == WeiXinFriendZone){
        if ([_delegate respondsToSelector:@selector(shareMenuSelected:)]) {
            [_delegate shareMenuSelected:WeiXinFriendZone];
        }
    }
    else if(index == ItemSinaWeibo){
        if ([_delegate respondsToSelector:@selector(shareMenuSelected:)]) {
            [_delegate shareMenuSelected:ItemSinaWeibo];
        }
        
    }
    else if(index == ItemTencentWeibo){
        if ([_delegate respondsToSelector:@selector(shareMenuSelected:)]) {
            [_delegate shareMenuSelected:ItemTencentWeibo];
        }
    }
    else if(index == ItemSMS){
        if ([_delegate respondsToSelector:@selector(shareMenuSelected:)]) {
            [_delegate shareMenuSelected:ItemSMS];
        }
        
    }
}

#pragma mark Touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches]anyObject];
    if ([touch view] == self.view) {
        CGPoint tp =  [touch locationInView:self.view];
        CGRect rect = [m_popview bounds];
        if (CGRectContainsPoint(rect, tp)) {
        }
        else{
            if([_delegate respondsToSelector:@selector(dissmissViewCtl)]){
                [_delegate dissmissViewCtl];
            }
        }
    }
}

#pragma mark Share

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
