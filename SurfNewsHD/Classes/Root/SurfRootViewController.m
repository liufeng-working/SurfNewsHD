//
//  SurfRootViewController.m
//  SurfNewsHD
//
//  Created by apple on 12-11-27.
//  Copyright (c) 2012年 apple. All rights reserved.
//
#import "SurfRootViewController.h"
#import "AppDelegate.h"
@interface SurfRootViewController ()

@end

@implementation SurfRootViewController

@synthesize rightController;
@synthesize leftController;
- (id)init
{
    self = [super init];
    if (self) {
        
        // Custom initialization
        leftController = [[SurfLeftController alloc] init];
        leftController.delegate = self;
        UINavigationController *leftNav = [[UINavigationController alloc] initWithRootViewController:leftController];
        self.masterViewController = leftNav;
        
        rightController = [[SurfRightController alloc] init];
        rightController.rightDelegate = self;
        self.detailViewController = rightController;
        
        [self setDividerStyle:MGSplitViewDividerStylePaneSplitter animated:NO];
        
        willAppear = YES;
        
        subsChannels = [[NSMutableArray alloc] init];
        
        currentIndex = [NSIndexPath indexPathForRow:0  inSection:0];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (willAppear) {
        [super viewWillAppear:animated];
    }else
    {
        willAppear = YES;
    }
    if ([subsChannels count] == 0) {
        [self loadLocalSubsChannels];
    }


}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setSplitPosition:kSplitPositionMin animated:NO];
}
-(void)loadLocalSubsChannels
{
    [subsChannels removeAllObjects];
    
    SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
    [subsChannels addObjectsFromArray:manager.visibleSubsChannels];
    
    [leftController reloadTableView];
    [manager addChannelObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint =  [touch locationInView:self];


}
 */

#pragma mark - SurfLeftControllerDelegate
- (SubsChannel *)scrollViewForChannel:(UIViewController *)controller
                    numberOfIndexPath:(NSIndexPath *)section
{
    NSInteger row = section.row;
    if (row < [subsChannels count]) {
        return subsChannels[row];
    }
    else
    {
        return nil;
    }
}
-(void)splitePosition:(CGFloat)position Animated:(BOOL)animate
{
    [self setSplitPosition:position animated:animate];
}
-(CGFloat)splitePositionInLeft:(UIViewController *)controller
{
    return self.splitPosition;
}
-(NSIndexPath *)currentIndex
{
    return currentIndex;
}
- (NSInteger)numberOfSectionsInLeft:(SurfLeftController *)controller
{
    return 4;
}
- (NSInteger)numberOfRowsInSection:(NSInteger)section
                              left:(SurfLeftController *)controller
{
    if (section == 0)
    {
        return 3;
    }
    else if (section == 1)
    {
        return [subsChannels count];
    }
    else if (section == 2)
    {
        SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
        if ([manager.invisibleSubsChannels count]>0) {
            return 1;
        }else{
            return 0;
        }
        
    }
    else if (section == 3)
    {
        return 1;
    }
    else
    {
        return 0;
    }
    
    
}
- (CGFloat)heightForTableViewInSection:(NSInteger)section
                                  left:(SurfLeftController *)controller
{
    if (section == 0)
    {
        return 50.0f * 3+20.0f;
    }
    else if (section == 1)
    {
        return 50.0f * 7 +20.0f;
    }
    else if (section == 2)
    {
        return 50.0f;
    }
    else if (section == 3)
    {
        return 50.0f;
    }
    else
    {
        return 0.0f;
    }
}
- (CGFloat)numberOfAtIndexPath:(NSIndexPath *)indexPath
                      left:(SurfLeftController *)controller
{
   return 50.0f;
}
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
                           left:(SurfLeftController *)controller
{
    currentIndex = indexPath;
    if (indexPath.section != 1)
    {
        [rightController didSelectRowAtSection:nil :indexPath];
    }
    else
    {
        [rightController didSelectRowAtSection:subsChannels[indexPath.row] :indexPath];
    }

}
- (BOOL)scrollViewCanMoveLeft:(UIViewController *)controller
        numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return NO;
    }
    else if (section == 1)
    {
        return NO;
    }else
    {
        return NO;
    }

}


#pragma mark - SubsChannelChangedObserver
-(void)subsChannelChanged
{
    
    SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
    NSArray *newChannels = manager.visibleSubsChannels;
    if (currentIndex.section == 1) {
        SubsChannel *oldChannel = [subsChannels objectAtIndex:currentIndex.row];
        int index = [newChannels indexOfObject:oldChannel];
        if (index != NSNotFound) {
            currentIndex = [NSIndexPath indexPathForRow:index inSection:1];
        }else{
            currentIndex = [NSIndexPath indexPathForRow:0 inSection:0];
            [rightController didSelectRowAtSection:nil :currentIndex];
        }
    }
    
    [subsChannels removeAllObjects];
    
    
    [subsChannels addObjectsFromArray:newChannels];
    [leftController reloadTableView];

}

#pragma mark -
-(void)setSplitPosition:(float)splitPosition
{

    if ([leftController.navigationController.visibleViewController isKindOfClass:[SurfLeftController class]]) {
        [super setSplitPosition:splitPosition];
    }
    [leftController reloadMaskView];
}
-(void)changedSelectController:(NSIndexPath *)changedIndex
{
    currentIndex = changedIndex;
    [leftController reloadMaskView];
    if (currentIndex.section == 1) {
        SubsChannel *channel = [subsChannels objectAtIndex:currentIndex.row];
        [rightController didSelectRowAtSection:channel :currentIndex];
    }else{
        [rightController didSelectRowAtSection:nil :currentIndex];
    }
    [leftController reloadTableView];
}

@end
