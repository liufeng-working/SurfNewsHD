//
//  SurfRightController.m
//  SurfNewsHD
//
//  Created by apple on 13-1-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//
#ifdef ipad
#import "SurfRightController.h"
#import "GTMHTTPFetcher.h"
#import "XmlResolve.h"
#import "LoginController.h"
#import "CloudRootController.h"
@interface SurfRightController ()

@end

@implementation SurfRightController
@synthesize rightDelegate;
@synthesize loginController;
#define kMaxControllerNumber 10

#define kHotNSIndexPath           [NSIndexPath indexPathForRow:0 inSection:0]
#define kCloudNSIndexPath         [NSIndexPath indexPathForRow:1 inSection:0]
#define kNewestNSIndexPath        [NSIndexPath indexPathForRow:2 inSection:0]
#define kSubscribeNSIndexPath     [NSIndexPath indexPathForRow:0 inSection:3]
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        subscribeArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self hideTabBar:YES];
    [self selectHotViewController];
    
    
    UIPanGestureRecognizer * tapGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(btnLong:)];
    tapGR.delegate = self;
    [self.view addGestureRecognizer: tapGR];
}
- (void)selectHotViewController
{
    [self didSelectRowAtSection:nil :kHotNSIndexPath];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}
- (void)myFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)retrievedData error:(NSError *)error
{
    if (error != nil) {
        int status = [error code];
        DJLog(@"error____%d",status);
    } else {
        NSString *string = [[NSString alloc ]initWithData:data encoding:NSUTF8StringEncoding];
        
        string = [XmlUtils contentOfFirstNodeNamed:@"content" inXml:string];
        
/*
        
        XmlResolve *xml = [[XmlResolve alloc] init];
        XmlNode *node = [xml getObject:@"content" xmlData:retrievedData];
        DJLog(@"%@",[node getXmlString ]);
*/        
        UIWebView *web = [[UIWebView alloc] initWithFrame:self.view.frame];
        [web loadHTMLString:string baseURL:nil];
        [self.view addSubview:web];
    }
}
#pragma mark - Controllers排序
-(void)sortControllers
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [self.viewControllers sortedArrayUsingDescriptors:sortDescriptors];
    self.viewControllers = sortedArray;
}
#pragma mark -
- (void)didSelectRowAtSection:(SubsChannel *)channel :(NSIndexPath *)indexPath
{
    BOOL ispopToRootViewController = YES;
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:self.viewControllers];
    int section = indexPath.section;
    int row = indexPath.row;
    if (kHotNSIndexPath.section == section && kHotNSIndexPath.row == row)
    {
        if (!hotController)
        {
            hotController = [[HotRootController alloc] init];
            UINavigationController *navController = [[UINavigationController alloc]
                                                     initWithRootViewController:hotController];
            [array addObject:navController];
            self.viewControllers = array;
        }
        else{
            [hotController viewDidAppear:YES];
        
        }
        self.selectedViewController = hotController.navigationController;
    }
    else if (kCloudNSIndexPath.section == section && kCloudNSIndexPath.row == row)
    {
        if (!loginController)
        {
            loginController = [[LoginController alloc] init];
            UINavigationController *navController = [[UINavigationController alloc]
                                                     initWithRootViewController:loginController];
            [array addObject:navController];
            self.viewControllers = array;
        }
        self.selectedViewController = loginController.navigationController;
        ispopToRootViewController = YES;

    }
    else if (kNewestNSIndexPath.section == section && kNewestNSIndexPath.row == row)
    {
        if (!newestController)
        {
            newestController = [[NewestRootController alloc] init];
            UINavigationController *navController = [[UINavigationController alloc]
                                                     initWithRootViewController:newestController];
            [array addObject:navController];
            self.viewControllers = array;
        }
        self.selectedViewController = newestController.navigationController;
    }
    else if (kSubscribeNSIndexPath.section == section && kSubscribeNSIndexPath.row == row)
    {
        if (!subscribeRootController)
        {
            subscribeRootController = [[SubscribeCenterController alloc] init];
            UINavigationController *navController = [[UINavigationController alloc]
                                                     initWithRootViewController:subscribeRootController];
            [array addObject:navController];
            self.viewControllers = array;
        }
        else
        {
            [subscribeRootController loadCategories];
        }
        self.selectedViewController = subscribeRootController.navigationController;
    
    }else{
        SubscribeViewController *viewController = [self containSubscrib:channel];
        if (viewController)
        {
            [subscribeArr removeObject:viewController];
            [subscribeArr addObject:viewController];
            self.selectedViewController = viewController.navigationController;
        }
        else
        {
            [self newContainSubscrib:channel];
        }
    }
    if (ispopToRootViewController) {
        [(UINavigationController *)self.selectedViewController popToRootViewControllerAnimated:NO];        
    }

}
-(SubscribeViewController *)containSubscrib:(SubsChannel *)channel
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"subscribeID LIKE [cd] %@",[NSString stringWithFormat:@"%ld",channel.channelId]];
    NSArray *newArray =  [subscribeArr filteredArrayUsingPredicate:predicate];
    DJLog(@"new count %d %ld",[newArray count],channel.channelId);
    if ([newArray count]> 0) {
        return [newArray objectAtIndex:0];
    }else{
        return nil;
    }
}
-(void)newContainSubscrib:(SubsChannel *)channel
{
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:self.viewControllers];

    if ([subscribeArr count] >= kMaxControllerNumber)
    {
        SubscribeViewController *viewController =[subscribeArr objectAtIndex:0];
        [array removeObject:viewController.navigationController];
        [subscribeArr removeObject:viewController];        
    }
    SubscribeViewController *viewController = [[SubscribeViewController alloc] init];
    viewController.title = channel.name;
    viewController.subsChannel = channel;
    [subscribeArr addObject:viewController];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [array addObject:navController];
    self.viewControllers = array;
    self.selectedViewController = navController;

}

- (void) hideTabBar:(BOOL) hidden{    
    for(UIView *view in self.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            if (hidden) {
                DJLog(@"rect1: %@", NSStringFromCGRect(view.frame));
                [view setFrame:CGRectMake(view.frame.origin.x, 975+49, view.frame.size.width, view.frame.size.height)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, 975, view.frame.size.width, view.frame.size.height)];
            }
        }
        else
        {
            if (hidden) {
                DJLog(@"rect1: %@", NSStringFromCGRect(view.frame));
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 975+49)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 975)];
            }
        }
    }
}

-(void)btnLong:(UIPanGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView: self.view];
    float position = [self.rightDelegate splitePositionInLeft:self];
    if ([sender state] == UIGestureRecognizerStateBegan)
    {
        canMove = NO;
        startX = point.x;
    }
    else if ([sender state] == UIGestureRecognizerStateChanged )
    {
        if (point.x >= position || canMove) {
            canMove = YES;
            if (point.x-startX+position < kSplitPositionMin)
            {
                [self.rightDelegate splitePosition:kSplitPositionMin Animated:NO];
            }else
            {
                [self.rightDelegate splitePosition:point.x-startX+position Animated:NO];
            }
        }
    }
    else if ([sender state] == UIGestureRecognizerStateCancelled ||[sender state] == UIGestureRecognizerStateEnded)
    {
        canMove = NO;
        if (position - kSplitPositionMin < (kSplitPositionMax -kSplitPositionMin)/2)
        {
            [self.rightDelegate splitePosition:kSplitPositionMin Animated:YES];
        }
        else if(style != MGSplitDividerBeganStyleMax)
        {
            if (position - kSplitPositionMax > (kSplitPositionLeftMax -kSplitPositionMax)/3)
            {
                [self.rightDelegate splitePosition:kSplitPositionLeftMax Animated:YES];
            }else
            {
                [self.rightDelegate splitePosition:kSplitPositionMax Animated:YES];
            }
            
        }else
        {
            if (position - kSplitPositionMax < (kSplitPositionLeftMax -kSplitPositionMax)/3*2)
            {
                [self.rightDelegate splitePosition:kSplitPositionMin Animated:YES];
            }else
            {
                [self.rightDelegate splitePosition:kSplitPositionLeftMax Animated:YES];
            }
        }
    }}
@end
#endif