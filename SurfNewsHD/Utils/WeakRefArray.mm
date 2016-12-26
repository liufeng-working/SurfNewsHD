//
//  WeakRefArray.mm
//  toolkit for 20d2s
//
//  Created by yuleiming on 13-8-2.
//  Copyright (c) 2013年 laoyur. All rights reserved.
//

#import "WeakRefArray.h"

#include <vector>
using namespace std;


@implementation WeakRefArray

-(void)dealloc
{
    delete (vector<__weak id>*)magic;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        magic = new vector<__weak id>();
    }
    return self;
}

-(void)addObject:(id)obj
{
    vector<__weak id>* refs = (vector<__weak id>*)magic;
    refs->push_back(obj);
}

-(void)removeObject:(id)obj
{
    vector<__weak id>* refs = (vector<__weak id>*)magic;
    
    vector<__weak id>::iterator it = refs->begin();
    for( ; it != refs->end();)
    {
        if (*it == obj)
        {
            it = refs->erase(it);
            return;
        }
        else
        {
            ++it;
        }
    }
    
}
-(void)removeAllObjects
{
    vector<__weak id>* refs = (vector<__weak id>*)magic;
    refs->clear();
}

-(NSUInteger)count
{
    vector<__weak id>* refs = (vector<__weak id>*)magic;
    NSUInteger c = 0;
    for(id obj : *refs)
    {
        if (obj)
        {
            c++;
        }
    }
    
    //干掉失效的元素
    NSInteger invalidCount = (NSInteger)(refs->size()) - c;
    while (invalidCount)
    {
        while (true)
        {
            id o = refs->back();
            if(!o)
            {
                refs->pop_back();
                invalidCount--;
                break;
            }
        }
    }

    return c;
}
-(id)objectAtIndex:(NSUInteger)idx
{
    vector<__weak id>* refs = (vector<__weak id>*)magic;
    return refs->at(idx);
}

//是否包含元素
-(BOOL)containsObject:(id)obj{
    NSUInteger count = self.count;
    vector<__weak id>* refs = (vector<__weak id>*)magic;
    for (NSInteger i=0; i<count; ++i) {
        if (refs->at(i) == obj) {
            return YES;
        }
    }
    return NO;
}
@end
