//
//  XmlNode.h
//  XML Fun
//
//  Created by mac os on 11-10-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XmlNode : NSObject {
    
}
@property(nonatomic,retain)NSMutableDictionary *attributes;
@property(nonatomic,retain)NSMutableArray *childs;
@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)NSString *value;
@property BOOL haveChilds;
@property BOOL haveAttribute;
@property(nonatomic,retain)NSMutableString *xmlString;

-(void)addAttribute:(NSDictionary *)att;
-(void)addChild:(XmlNode *)node;
-(NSString *)getXmlString;
-(NSString *)getNodeValue:(NSString *)nodeName;
-(NSString *)getAttributeValue:(NSString *)attName;

@end
