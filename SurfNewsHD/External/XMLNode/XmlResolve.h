//
//  XmlResolve.h
//  XML Fun
//
//  Created by mac os on 11-10-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlNode.h"


@interface XmlResolve : NSObject <NSXMLParserDelegate>{
    
}
@property (nonatomic, retain) NSString *objName;
@property (nonatomic, retain) NSString *tempString;
@property (nonatomic, retain) NSMutableArray *namelist;
@property (nonatomic, retain) NSMutableArray *valuelist;
@property (nonatomic, retain) NSMutableArray *attributeList;
@property BOOL begin;
@property int objectCount;
@property BOOL returnObj;
@property(nonatomic,retain)NSMutableArray *tempList;

@property(nonatomic,retain)XmlNode *object;
@property (nonatomic, retain) NSMutableArray *objects;

-(XmlNode *)getObject:(NSString *)elName xmlData:(NSData *)xmlData;
-(NSMutableArray *)getList:(NSString *)elName xmlData:(NSData *)xmlData;

@end

