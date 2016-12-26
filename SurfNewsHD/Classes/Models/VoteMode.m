//
//  VoteMode.m
//  SurfNewsHD
//
//  Created by duanmu on 15/10/28.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "VoteMode.h"

@implementation VoteMode


@synthesize newsId = __KEY_NAME_id;

-(id)init{
    self = [super init];
    if (self) {
        _oldList = [NSMutableArray arrayWithCapacity:3];
    }
    return self;
}


-(void)addOlds:(NSArray*)olds
{
    if ([olds count] > 0) {
        [_oldList addObjectsFromArray:olds];
        [self converOldStr];
    }
}
-(void)removeOlds:(NSArray*)olds
{
    if ([olds count] >0) {
        [_oldList removeObjectsInArray:olds];
        [self converOldStr];
    }
}

-(void)converOldStr
{
    _oids = [_oldList componentsJoinedByString:@","];
}
@end
