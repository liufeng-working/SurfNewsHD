//
//  SNVoteTableCell.m
//  SurfNewsHD
//
//  Created by XuXg on 15/10/28.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "SNVoteTableCell.h"
#import "SNVoteButton.h"
#import "DateUtil.h"
#import "SNThreadViewerController.h"
#import "GTMHTTPFetcher.h"
#import "SurfRequestGenerator.h"
#import "EzJsonParser.h"
#import "DateUtil.h"
#import "VoteMode.h"

//投票cell
@implementation SNVoteTableCell


+(CGFloat)cellHeight:(SNNewsExtensionInfo*)vote
{
    if ([vote isVote])
    {
        return 60+vote.options.count*60;
    }
    else
    {
        return 40+vote.options.count*60;
    }
    
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        myTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 280, 35)];
        myTitleLabel.font = [UIFont systemFontOfSize:12.0f];
        myTitleLabel.numberOfLines=0;
        myTitleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        myTitleLabel.textColor = [UIColor colorWithHexString:@"333333"];
        [self addSubview:myTitleLabel];
        
        _selectArray = [[NSMutableArray alloc]init];
        _resultArray = [[NSMutableArray alloc]init];
        
        
        
        voteView =[[UIView alloc]initWithFrame:CGRectMake(0, 40, 320, 200-60)];
        voteView.hidden = YES;
        [self addSubview:voteView];
        
        voteResuleView =[[UIView alloc]initWithFrame:CGRectMake(0, 40, 320, 200)];
        voteResuleView.hidden = YES;
        [self addSubview:voteResuleView];
        
        
        
        submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [submitButton setTitle:@"投票" forState:UIControlStateNormal];
        [submitButton setTitleColor:[UIColor colorWithHexString:@"d71919"] forState:UIControlStateNormal];
        submitButton.backgroundColor=[UIColor whiteColor];
        [submitButton addTarget:self action:@selector(submitClick) forControlEvents:UIControlEventTouchUpInside];
        
        submitButton.layer.borderWidth = 1.f;
        submitButton.layer.cornerRadius = 2.f;
        submitButton.layer.borderColor = [UIColor colorWithHexValue:0x7f999999].CGColor;
        [self addSubview:submitButton];
        submitButton.hidden = YES;
    }
    return self;
}
-(void)loadDataWithVote:(SNNewsExtensionInfo*)vote
{
    self.myVote = vote;
    for (UIView* view in voteView.subviews) {
        [view removeFromSuperview];
    }
    
    UILabel* timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 60, 20)];
    timeLabel.textColor = [UIColor colorWithHexString:@"999999"];
    timeLabel.font = [UIFont systemFontOfSize:8.0f];
    
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = @"yyyy-MM-dd";
    NSString *showTime =
    [df stringFromDate:[NSDate dateWithTimeIntervalSince1970:[vote.vote_time doubleValue]/1000]];
    
    timeLabel.text = showTime;
    [voteView addSubview:timeLabel];
    
    UILabel* countLabel = [[UILabel alloc]initWithFrame:CGRectMake(150, 0, 120, 20)];
    countLabel.textAlignment = NSTextAlignmentRight;
    countLabel.textColor = [UIColor colorWithHexString:@"999999"];
    countLabel.font = [UIFont systemFontOfSize:8.0f];
    countLabel.text = [NSString stringWithFormat:@"%d人参与",([vote.vote_count intValue])];
    [voteView addSubview:countLabel];
    
    UIImageView* styleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(284, 6.5, 16, 7)];
    if ([vote.vote_type isEqualToNumber:[NSNumber numberWithInt:1]])
    {
        styleImageView.image = [UIImage imageNamed:@"one_type"];
    }
    else
    {
        styleImageView.image = [UIImage imageNamed:@"more_type"];
    }
    [voteView addSubview:styleImageView];
    
    UIView* lineView = [[UIView alloc]init];
    lineView.frame = CGRectMake(20, 20, 280, 1);
    lineView.backgroundColor = [UIColor colorWithHexString:@"e6e6e6"];
    [voteView addSubview:lineView];
    
    NSInteger totalHeight = 0;
    if ([vote isVote])
    {
        totalHeight = 40+vote.options.count*60;
    }
    else
    {
        totalHeight = 40+vote.options.count*60;
    }
    voteView.frame = CGRectMake(0, 40, 320, totalHeight-60);
    voteResuleView.frame = CGRectMake(0, 40, 320, totalHeight-40);
    
    
    
    myTitleLabel.text = vote.vote_title;
    if ([[SurfDbManager sharedInstance] isNewsVote:vote.newsId] == NO)
    {
        NSLog(@"可以投票");
        voteView.hidden = NO;
        voteResuleView.hidden = YES;
        submitButton.frame = CGRectMake(10, voteView.frame.origin.y
                                        +voteView.frame.size.height, 300, 30);
        submitButton.hidden = NO;
        
        for (int i=0; i<vote.options.count; i++)
        {
            SNVoteButton* button = [SNVoteButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = 100+i;
            if ([vote.vote_type isEqualToNumber:[NSNumber numberWithInt:1]])
            {
                button.mySelectImage.image = [UIImage imageNamed:@"one"];
            }
            else
            {
                button.mySelectImage.image = [UIImage imageNamed:@"multi"];
            }
            
            
            
            
            SNVoteInfo* infor = [vote.options objectAtIndex:i];
            button.myTitileLabel.text = infor.content;
            button.myTitileLabel.textColor = [UIColor colorWithHexString:@"666666"];
            button.frame = CGRectMake(10, 20+40*i, 300, 30);
            [voteView addSubview:button];
        }
        
    }
    else
    {
         submitButton.hidden = YES;
        voteView.hidden = YES;
        voteResuleView.hidden = NO;
        NSLog(@"不可以投票");
        [self showResutView:NO];
    }
}
-(void)showResutView:(BOOL)flage
{
   
    for (UIView* view in voteResuleView.subviews) {
        [view removeFromSuperview];
    }
    UILabel* timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 60, 20)];
    timeLabel.textColor = [UIColor colorWithHexString:@"999999"];
    timeLabel.font = [UIFont systemFontOfSize:8.0f];
    NSString *showTime = [DateUtil calcTimeInterval:[self.myVote.vote_time doubleValue]/1000];
    timeLabel.text = showTime;
    [voteResuleView addSubview:timeLabel];
    
    UILabel* countLabel = [[UILabel alloc]initWithFrame:CGRectMake(150, 0, 120, 20)];
    countLabel.textAlignment = NSTextAlignmentRight;
    countLabel.textColor = [UIColor colorWithHexString:@"999999"];
    countLabel.font = [UIFont systemFontOfSize:8.0f];
    if (flage) {
        countLabel.text = [NSString stringWithFormat:@"%d人参与",([self.myVote.vote_count intValue]+1)];
    }
    else
    {
        countLabel.text = [NSString stringWithFormat:@"%d人参与",([self.myVote.vote_count intValue])];
        [self.resultArray removeAllObjects];
    }
    
    [voteResuleView addSubview:countLabel];
    
    UIImageView* styleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(284, 6.5, 16, 7)];
    if ([self.myVote.vote_type isEqualToNumber:[NSNumber numberWithInt:1]])
    {
        styleImageView.image = [UIImage imageNamed:@"one_type"];
    }
    else
    {
        styleImageView.image = [UIImage imageNamed:@"more_type"];
    }
    [voteResuleView addSubview:styleImageView];
    
    UIView* lineView = [[UIView alloc]init];
    lineView.frame = CGRectMake(20, 20, 280, 1);
    lineView.backgroundColor = [UIColor colorWithHexString:@"e6e6e6"];
    [voteResuleView addSubview:lineView];
    
    for (int i=0; i<self.myVote.options.count; i++)
    {
        int selectNum = 0;
        SNVoteInfo* infor = [self.myVote.options objectAtIndex:i];
        for (int j=0; j<self.selectArray.count; j++)
        {
            selectNum = [[self.selectArray objectAtIndex:j] intValue];
        }
        
        if (i == selectNum)
        {
            [self.resultArray addObject:[NSNumber numberWithInt:([infor.count intValue]+1)]];
        }
        else
        {
            [self.resultArray addObject:infor.count];
        }
        
    }
    
    NSArray* colorArray = [NSArray arrayWithObjects:@"febf4f",@"a2cc46",@"e74c6b",@"2ab6e9",@"904efe",@"e92a38", nil];
    int total=0;//除最后一个之外总数
    for (int i=0; i<self.myVote.options.count; i++)
    {
        SNVoteInfo* infor = [self.myVote.options objectAtIndex:i];
        CGSize size = [infor.content surfSizeWithFont:[UIFont systemFontOfSize:10.0f] constrainedToSize:CGSizeMake(300, 30) lineBreakMode:NSLineBreakByWordWrapping];
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(20, 60*i+30, 280, size.height)];
        
        label.textColor = [UIColor colorWithHexString:@"333333"];
        label.font = [UIFont systemFontOfSize:10.0f];
        label.text = infor.content;
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.numberOfLines=0;
        [voteResuleView addSubview:label];
        
        int widhtNum=0;
        if (i==self.myVote.options.count-1) {
            widhtNum = 100-total;
        }
        else
        {
            widhtNum = [self calWidht:[[self.resultArray objectAtIndex:i] intValue] IsLast:NO];
            total += widhtNum;
        }
        
        
        UIView* colorView = [[UIView alloc]init];
        colorView.frame = CGRectMake(20, label.frame.origin.y+label.frame.size.height+10, (280*widhtNum)/100, 15);
        if (i<colorArray.count)
        {
            
            colorView.backgroundColor = [UIColor colorWithHexString:[colorArray objectAtIndex:i]];
        }
        else
        {
            colorView.backgroundColor = [UIColor blackColor];
        }
        [voteResuleView addSubview:colorView];
        
        UILabel* peopleLabel = [[UILabel alloc]initWithFrame:CGRectMake(colorView.frame.origin.x+colorView.frame.size.width, label.frame.origin.y+label.frame.size.height+7, 40, 20)];
        peopleLabel.textAlignment = NSTextAlignmentRight;
        peopleLabel.textColor = [UIColor colorWithHexString:@"999999"];
        peopleLabel.font = [UIFont systemFontOfSize:10.0f];
        peopleLabel.text = [NSString stringWithFormat:@"%d%%",widhtNum];
        [voteResuleView addSubview:peopleLabel];
        
        
    }

}
-(void)submitDataToService
{
//    UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
//    if (userInfo == nil) {
//        
//        [PhoneNotification autoHideWithText:@"您还没有登陆"];
//        return;
//    }
    VoteMode* mode = [VoteMode new];
    mode.coid = [self.myVote.rssId longValue];
    mode.newsId = self.myVote.newsId;
    
    NSMutableArray* idArray = [[NSMutableArray alloc]init];
    for (int i=0; i<self.myVote.options.count; i++) {
        
        int selectNum = 0;
        for (int j=0; j<self.selectArray.count; j++) {
            selectNum = [[self.selectArray objectAtIndex:j] intValue];
        }
        if (selectNum == i)
        {
            SNVoteInfo* infor = [self.myVote.options objectAtIndex:i];
            [idArray addObject:infor.voteId];
        }
    }
    [mode addOlds:idArray];
   
    
    id req = [SurfRequestGenerator submitVote:mode];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error){
        BOOL isSucceed = NO;
        if(!error)
        {
            NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            SurfJsonResponseBase *res = [SurfJsonResponseBase objectWithKeyValues:body];
            isSucceed = [res.res.reCode isEqualToString:@"1"];
            if (isSucceed) {
                NSLog(@"数据提交成功");
                [[SurfDbManager sharedInstance] addNewsVote:self.myVote.newsId];
            }
        }
        
        // TODO:显示刷新失败界面
        [PhoneNotification autoHideWithText:isSucceed?@"投票成功":@"投票失败"];

    }];
}
-(void)submitClick
{
    NSLog(@"提交了");
    if (self.selectArray.count==0) {
        [PhoneNotification autoHideWithText:@"您还没有投票"];
        return;
    }
    submitButton.hidden = YES;
//    [submitButton removeFromSuperview];
    voteView.hidden = YES;
    voteResuleView.hidden = NO;
    
    [self showResutView:YES];
    [self submitDataToService];
}

-(int)calWidht:(int)num IsLast:(BOOL)flage
{
    int total = 0;
    for (int i=0; i<self.resultArray.count; i++)
    {
        int n = [[self.resultArray objectAtIndex:i] intValue];
        total += n ;
    }
    if (flage)
    {
        float f = (total-num)/(float)total;
        int n = f*100;
        return 100-n;
    }
    else
    {
        if (total == 0) {
            return 0;
        }
        return (num*100/total);
    }
    
}
-(void)buttonClick:(UIButton*)btn
{
    NSInteger num = btn.tag-100;
    if ([self.myVote.vote_type isEqualToNumber:[NSNumber numberWithInt:1]])//单选
    {
        [self.selectArray removeAllObjects];
        [self.selectArray addObject:@(num)];
    }
    else
    {
        for (int i=0; i<self.selectArray.count; i++) {
            if (num != [[self.selectArray objectAtIndex:i] intValue]) {
                [self.selectArray addObject:@(num)];
            }
        }
        
    }
    for (int i=0; i<self.myVote.options.count; i++) {
        SNVoteButton* button = (SNVoteButton*)[self viewWithTag:100+i];
        int selectNum = 0;
        for (int j=0; j<self.selectArray.count; j++) {
            selectNum = [[self.selectArray objectAtIndex:j] intValue];
        }
        if (selectNum == i) {
            button.myTitileLabel.textColor = [UIColor colorWithHexString:@"d71919"];
            if ([self.myVote.vote_type isEqualToNumber:[NSNumber numberWithInt:1]])
            {
                button.mySelectImage.image = [UIImage imageNamed:@"one_select"];
            }
            else
            {
                button.mySelectImage.image = [UIImage imageNamed:@"multiSelect"];
            }
        }
        else
        {
            button.myTitileLabel.textColor = [UIColor colorWithHexString:@"333333"];
            if ([self.myVote.vote_type isEqualToNumber:[NSNumber numberWithInt:1]])
            {
                button.mySelectImage.image = [UIImage imageNamed:@"one"];
            }
            else
            {
                button.mySelectImage.image = [UIImage imageNamed:@"multi"];
            }
        }
        
    }
    
}
@end
