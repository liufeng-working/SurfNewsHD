//
//  CollectViewController.m
//  iOSUIFrame
//
//  Created by Jerry Yu on 13-5-22.
//  Copyright (c) 2013年 adways. All rights reserved.
//

#import "CollectViewController.h"
#import "FavsManager.h"
#import "ThreadSummary.h"
#import "SNThreadViewerController.h"
#import "GTMHTTPFetcher.h"
#import "SurfRequestGenerator.h"
#import "EzJsonParser.h"
#import "DateUtil.h"
#import "SNCollectMode.h"





#define SHOWPAGENUM     20
//#define TABLEVIEWFRAME  iPhone5 ? CGRectMake(0, self.StateBarHeight, 320, self.view.frame.size.height-self.StateBarHeight) : CGRectMake(0, self.StateBarHeight, 320, self.view.frame.size.height-self.StateBarHeight - 20)//CGRectMake(0, self.StateBarHeight, 320, self.view.frame.size.height-self.StateBarHeight)

@interface CollectViewController ()

@end

@implementation CollectViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.titleState = PhoneSurfControllerStateTop;
        
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    //    [self initMainView];
    
}

-(void)requestData
{
    UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
    if (userInfo == nil) {
        
        
        return;
    }
    
    
    id req = [SurfRequestGenerator getCollectedList:currentPage];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error){
        if(!error)
        {
            NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            
            
            SNCollectListResponse *res =
            [SNCollectListResponse objectWithKeyValues:body];
            if ([res.res.reCode isEqualToString:@"1"] &&
                [res.news count] > 0) {
                if (res.news.count!=10) {
                    isLast = YES;
                }
                else {
                    isLast = NO;
                }
                for (int i=0; i<res.news.count; i++)
                {
                    [_collectLocationArr addObject:[res.news objectAtIndex:i]];
                }
                
                [myTable reloadData];
            }
        }
        else {
            [PhoneNotification autoHideWithText:@"更新失败"];
        }
    }];
    

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //    [self.navigationController setNavigationBarHidden:NO];
    
    self.title = @"收藏夹";
    
    //    UIBarButtonItem *refleshButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"关闭", nil) style:UIBarButtonItemStylePlain target:self action:@selector(clickCloseBt)];
    //    self.navigationItem.leftBarButtonItem = refleshButton;
    //    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    //    isAll = NO;
    //    collectLocationArr = [NSMutableArray arrayWithCapacity:10];
    //
    //    [collectLocationArr removeAllObjects];
    
    //    [surfTitlelabel setFrame:CGRectMake(100.f, .0f, kContentWidth - 20.f, 57.0f)];
    
//    if (!bgView) {
//        bgView=[[UIView alloc] initWithFrame:CGRectMake(0, self.StateBarHeight, self.view.frame.size.width, self.view.frame.size.height)];
//    }
//    if (![self.view.subviews containsObject:bgView]) {
//        [self.view addSubview:bgView];
//    }
    
    
    self.collectLocationArr = [NSMutableArray arrayWithCapacity:10];
    CGFloat tY = self.StateBarHeight;
    CGFloat tW = CGRectGetWidth(self.view.bounds);
    CGFloat tH =  CGRectGetHeight(self.view.bounds)-tY;
    CGRect tabRect = CGRectMake(0, tY, tW, tH);
    
    myTable = [[UITableView alloc] initWithFrame:tabRect style:UITableViewStylePlain];
    [myTable setDelegate:self];
    [myTable setDataSource:self];
    myTable.separatorColor = [UIColor clearColor];
    [self.view addSubview:myTable];
    
    if (myTable == nil) {
        backImage = [[UIImageView alloc] initWithFrame:CGRectMake(55, 180, 210, 155)];
        UIImage *backimage1 = [UIImage imageNamed:@"collectionEmpty"];
        backImage.image =backimage1;
        [self.view addSubview:backImage];
    }
    [self addHeader];
    [self addFooter];
}

- (void)addHeader
{
    __block CollectViewController *vc = self;
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = myTable;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        // 这里的refreshView其实就是header
        [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:0.5];
        [vc.collectLocationArr removeAllObjects];
        currentPage = 1;
        [vc requestData];
        
        NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
        NSLog(@"%@----刷新完毕", refreshView.class);
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
                NSLog(@"%@----切换到：普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
                NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
                NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
                break;
            default:
                break;
        }
    };
    [header beginRefreshing];
    _header = header;
}
- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    [refreshView endRefreshing];
}

- (void)addFooter
{
    __block CollectViewController *vc = self;
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = myTable;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        if (!isLast)
        {
            currentPage++;
            
            [vc requestData];
        }
        [_footer endRefreshing];
        NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    _footer = footer;
}









#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.collectLocationArr.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* name = @"CollectTableViewCellInder";
    CollectTableViewCell* cell = (CollectTableViewCell*)[myTable dequeueReusableCellWithIdentifier:name];
    if (cell == nil) {
        cell = [[CollectTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:name];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSUInteger index = indexPath.row;
    if (index < _collectLocationArr.count)
    {
        SNCollectSummary *cs = _collectLocationArr[index];
        NSString *showTime =
        [DateUtil calcTimeInterval:[cs.showTime doubleValue]/1000];
        cell.myNameLabel.text = cs.title;
        cell.myTitleLabel.text = cs.source;
        cell.myTimeLabel.text = showTime;
        
    }
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUInteger index = indexPath.row;
    if (index < self.collectLocationArr.count)
    {
        SNCollectSummary *cs = self.collectLocationArr[index];
        ThreadSummary *ts = [cs converThreadSummary];
        SNThreadViewerController* pnc = [[SNThreadViewerController alloc] initWithThread:ts isFromCollect:YES];
        [self presentController:pnc animated:PresentAnimatedStateFromRight];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}



-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row<self.collectLocationArr.count)
    {
//        NSDictionary* dic = [self.collectLocationArr objectAtIndex:indexPath.row];
        SNCollectSummary *cs = _collectLocationArr[indexPath.row];
        
//        NSLog(@"%@",dic);
        //        NSString* showTime = [dic objectForKey:@"showTime"];
        ThreadSummary* mThreadSummary = [ThreadSummary new];
        mThreadSummary.channelId = [cs.coid longValue];
        mThreadSummary.threadId = [cs.newsId longValue];
        mThreadSummary.ctype = [cs.openType longValue];
        
        
        
        id req = [SurfRequestGenerator unSubscribeCollect:mThreadSummary];
        GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
        [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error){
            
            if(!error)
            {
                NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
                SurfJsonResponseBase *res = [SurfJsonResponseBase objectWithKeyValues:body];
                //                isSucceed = [res.res.reCode isEqualToString:@"1"];
                if ([res.res.reCode isEqualToString:@"1"])
                {
                    [PhoneNotification autoHideWithText:@"取消收藏成功"];
                    
                }
                else if ([res.res.reCode isEqualToString:@"2"])
                {
                    
                }
                else if ([res.res.reCode isEqualToString:@"0"])
                {
                    [PhoneNotification autoHideWithText:@"取消收藏失败"];
                }
            }
//            [self.collectLocationArr removeAllObjects];
//            [NSThread sleepForTimeInterval:1.0f];
            [self.collectLocationArr removeObjectAtIndex:indexPath.row];
            [myTable reloadData];
            // TODO:显示刷新失败界面
            //            [PhoneNotification autoHideWithText:isSucceed?@"收藏成功":@"收藏失败"];
        }];

        
        
    }
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


@end
