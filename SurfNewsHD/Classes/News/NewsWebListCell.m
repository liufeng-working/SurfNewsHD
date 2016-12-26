//
//  NewsWebListCell.m
//  SurfNewsHD
//
//  Created by apple on 13-3-4.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "NewsWebListCell.h"
@implementation NewsWebListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0f,
                                                               12.0f,
                                                               232.0f- 24.0f,
                                                               43.0f)];
        titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.numberOfLines = 2;
        titleLabel.textColor = [UIColor colorWithHexString:@"9d9696"];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:titleLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0f,
                                                              CGRectGetMaxY(titleLabel.frame) +12.0f,
                                                              232.0f- 24.0f,
                                                              17.0f)];
        timeLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        timeLabel.textColor = [UIColor colorWithHexString:@"8c8d8e"];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:timeLabel];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setSummary:(ThreadSummary *)summary
        withState:(NewsWebListCellState)state
{
    if (summary.time == 0)
    {
        timeLabel.text = @"";
    }
    else
    {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:summary.time/1000];
        NSDateFormatter *df = [NSDateFormatter new];
        df.dateFormat = @"yyyy-MM-dd";
        NSString *dateString = [df stringFromDate:date];
        timeLabel.text = dateString;
        
    }
    titleLabel.text = summary.title;
    if (state == NewsWebListCellCurrent)
    {
        titleLabel.textColor = [UIColor colorWithHexString:@"9d9696"];
        timeLabel.textColor = [UIColor colorWithHexString:@"9d9696"];
    }
    else if (state == NewsWebListCellReaded)
    {
        titleLabel.textColor = [UIColor colorWithHexString:@"9d9696"];
        timeLabel.textColor = [UIColor colorWithHexString:@"9d9696"];
    }
    else if (state == NewsWebListCellNoReading)
    {
        titleLabel.textColor = [UIColor blackColor];
        timeLabel.textColor = [UIColor colorWithHexString:@"8c8d8e"];
    }
}
-(void)setNewsData:(PhoneNewsData *)newsData
         withState:(NewsWebListCellState)state
{
    if (newsData.datetime == 0)
    {
        timeLabel.text = @"";
    }
    else
    {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:newsData.datetime/1000];
        NSDateFormatter *df = [NSDateFormatter new];
        df.dateFormat = @"yyyy-MM-dd";
        NSString *dateString = [df stringFromDate:date];
        timeLabel.text = dateString;
        
    }
    titleLabel.text = newsData.title;
    if (state == NewsWebListCellCurrent)
    {
        titleLabel.textColor = [UIColor colorWithHexString:@"9d9696"];
        timeLabel.textColor = [UIColor colorWithHexString:@"9d9696"];
    }
    else
    {
        titleLabel.textColor = [UIColor blackColor];
        timeLabel.textColor = [UIColor colorWithHexString:@"8c8d8e"];
    }

}
@end
