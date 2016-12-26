//
//  TriplePeriodicalView.m
//  SurfNewsHD
//
//  Created by SYZ on 13-5-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "TriplePeriodicalView.h"
#import "ImageUtil.h"

//原来是一行三本期刊视图,后来改为一行两本,所以这里的类名开头为Triple
@implementation TriplePeriodicalView
    
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        periodical1 = [[CoverImageControl alloc] initWithCoverBigSize:YES];
        periodical1.tag = 1;
        periodical1.frame = CGRectMake(20.0f, 5.0f, ImageWidth, ImageHeight);
        [periodical1 addTarget:self
                        action:@selector(periodicalClicked:)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:periodical1];
        
        periodical2 = [[CoverImageControl alloc] initWithCoverBigSize:YES];
        periodical2.tag = 2;
        periodical2.frame = CGRectMake(30.0f + ImageWidth, 5.0f, ImageWidth, ImageHeight);
        [periodical2 addTarget:self
                        action:@selector(periodicalClicked:)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:periodical2];
    }
    return self;
}

- (void)loadData:(NSArray *)array
{
    _periodicalArray = array;
    
    if (_periodicalArray == nil || [_periodicalArray count] == 0) {
        periodical1.hidden = NO;
        periodical2.hidden = NO;
        [periodical1 loadData:nil];
        [periodical2 loadData:nil];
    } else if (_periodicalArray.count == 1) {
        periodical1.hidden = NO;
        periodical2.hidden = YES;
        [periodical1 loadData:_periodicalArray[0]];
        [periodical2 loadData:nil];
    } else if (_periodicalArray.count >= 2) {
        periodical1.hidden = NO;
        periodical2.hidden = NO;
        [periodical1 loadData:_periodicalArray[0]];
        [periodical2 loadData:_periodicalArray[1]];
    }
}

- (void)periodicalClicked:(id)sender
{
    switch ([sender tag]) {
        case 1:
            if (_periodicalArray.count < 1) {
                break;
            }
            [_delegate periodicalClicled:[_periodicalArray objectAtIndex:0]];
            break;
            
        case 2:
            if (_periodicalArray.count < 2) {
                break;
            }
            [_delegate periodicalClicled:[_periodicalArray objectAtIndex:1]];
            break;
            
        default:
            break;
    }
}

@end
