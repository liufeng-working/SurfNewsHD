//
//  WeakRefArray.h
//  toolkit for 20d2s
//
//  Created by yuleiming on 13-8-2.
//  Copyright (c) 2013年 laoyur. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WeakRefArray : NSObject
{
    void* magic;
}

//增加元素
-(void)addObject:(id)obj;

//移除元素
-(void)removeObject:(id)obj;

-(void)removeAllObjects;

//返回有效元素的个数
-(NSUInteger)count;

//根据索引获取元素
-(id)objectAtIndex:(NSUInteger)idx;

//是否包含元素
-(BOOL)containsObject:(id)obj;
@end
