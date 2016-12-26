//
//  SNJokeLayout.m
//  SurfNewsHD
//
//  Created by Tianyao on 16/2/2.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "SNJokeLayout.h"

@implementation SNJokeLayout

- (void)setJoke:(ThreadSummary *)joke {
    if (_joke != joke) {
        _joke = joke;
        [self layout];
    }
}

- (void)layout {
    [self reset];
    
    NSString *text = _joke.content;
    
    CGFloat textX = kJCellLeftPadding;
    CGFloat textY = kJCellTopPadding;
    CGFloat textW = kJContentWidth;
    CGSize textSize = [text sizeWithFont:SNJokeCellContentFont maxW:textW];
    CGFloat textH = textSize.height;

    _textF = (CGRect){{textX, textY}, {textW, textH}};
    
    _height = CGRectGetMaxY(_textF) + kJActionsViewHeight + 11.5f + 13.5f;
}

- (void)reset {
    _textF = CGRectZero;
    _height = 0;
}

@end
