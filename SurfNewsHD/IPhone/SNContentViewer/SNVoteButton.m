//
//  SNVoteButton.m
//  SurfNewsHD
//
//  Created by duanmu on 15/10/28.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "SNVoteButton.h"

@implementation SNVoteButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//    
//    
//}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _mySelectImage = [[UIImageView alloc]init];
        self.mySelectImage.frame = CGRectMake(10, 10, 20, 15);
        [self addSubview:self.mySelectImage];
        
        _myTitileLabel = [[UILabel alloc]init];
        self.myTitileLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.myTitileLabel.numberOfLines=0;
        self.myTitileLabel.font = [UIFont systemFontOfSize:12.0f];
        self.myTitileLabel.frame = CGRectMake(35, 3, 250, 30);
        [self addSubview:self.myTitileLabel];
    }
    return self;
    
}

@end
