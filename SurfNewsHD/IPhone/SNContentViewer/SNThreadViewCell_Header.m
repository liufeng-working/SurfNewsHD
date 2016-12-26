//
//  SNThreadViewCell_Header.m
//  SurfNewsHD
//
//  Created by XuXg on 15/9/1.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "SNThreadViewCell_Header.h"
#import "NSString+Extensions.h"



#define kSeparator_Red_Width 70.f

@implementation SNThreadViewCell_Header

-(id)initWithStyle:(UITableViewCellStyle)style
   reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        _titleColor = [UIColor colorWithHexValue:0xFFd71919];
        
    }
    return self;
}

-(void)drawContentView:(CGRect)rect highlighted:(BOOL)highlighted
{
    
    
    
    
}

@end
