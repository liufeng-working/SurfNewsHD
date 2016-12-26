//
//  NewsWebListCell.h
//  SurfNewsHD
//
//  Created by apple on 13-3-4.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThreadSummary.h"
#import "PhoneNewsData.h"

typedef enum {
    NewsWebListCellCurrent = 0,
    NewsWebListCellReaded = 1,
    NewsWebListCellNoReading = 2
} NewsWebListCellState;
@interface NewsWebListCell : UITableViewCell
{
    UILabel *titleLabel;
    UILabel *timeLabel;
}
-(void)setSummary:(ThreadSummary *)summary withState:(NewsWebListCellState)state;
-(void)setNewsData:(PhoneNewsData *)newsData
         withState:(NewsWebListCellState)state;
@end
