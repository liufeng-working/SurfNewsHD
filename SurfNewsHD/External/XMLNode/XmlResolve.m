//
//  XmlResolve.m
//  XML Fun
//
//  Created by mac os on 11-10-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "XmlResolve.h"
#import "XmlNode.h"


@implementation XmlResolve

@synthesize objName;
@synthesize tempString;
@synthesize namelist;
@synthesize valuelist;
@synthesize attributeList;
@synthesize begin;
@synthesize objectCount;
@synthesize returnObj;
@synthesize tempList;
@synthesize object;
@synthesize objects;

- (void)dealloc
{
    [objName release];
    [tempString release];
    [namelist release];
    [valuelist release];
    [attributeList release];
    [tempList release];
    //[object release];
    [objects release];
    [super dealloc];
}

-(XmlNode *)getObject:(NSString *)elName xmlData:(NSData *)xmlData
{
    returnObj = YES;
    self.objName = elName;
    NSXMLParser *xmlRead = [[NSXMLParser alloc] initWithData:xmlData];
    self.tempList = [[[NSMutableArray alloc]init]autorelease];
    self.objects = [[[NSMutableArray alloc]init]autorelease];
    [xmlRead setDelegate:self];
    [xmlRead parse];
    [xmlRead release];
    if (object!=nil) {
        return object;
    }
    return nil;

}

-(NSMutableArray *)getList:(NSString *)elName xmlData:(NSData *)xmlData
{
    returnObj = NO;
    self.objName = elName;
    NSXMLParser *xmlRead = [[NSXMLParser alloc] initWithData:xmlData];
    self.tempList = [[[NSMutableArray alloc]init]autorelease];
    self.objects = [[[NSMutableArray alloc]init]autorelease];
    [xmlRead setDelegate:self];
    [xmlRead parse];
    [xmlRead release];
    if ((int)[objects count]>0) {
        return objects;
    }
    return nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (begin) {
        //NSLog(@"string=%@",string);
        NSString *text = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (text==nil||[text isEqualToString:@""]||[text isEqualToString:@"\n"]) {
            
        }else{
            //NSLog(@"%@",text);
            if ((int)[tempList count]>0) {
                XmlNode *last = [tempList objectAtIndex:[tempList count]-1];
                last.value = text;
            }            
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (begin) {
        //NSLog(@"elementName2=%@",elementName);
        if ((int)[tempList count]>0) {
            [tempList removeObjectAtIndex:[tempList count]-1];
        }
        if ([elementName isEqualToString:objName]) {
            begin = NO;
        }
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:objName]) {
        begin = YES;
    }
    if (begin) {
        //NSLog(@"elementName1=%@",elementName);
        XmlNode *node = [[[XmlNode alloc]init]autorelease];
        node.name = elementName;
        [node addAttribute:attributeDict];
        
        if ((int)[tempList count]>0) {
            XmlNode *last = [tempList objectAtIndex:[tempList count]-1];
            if (last!=node) {
                //NSLog(@" add -begin- last=%@,node=%@",last.name,node.name);
                [last addChild:node];
                //NSLog(@" add -end- last=%@,node=%@",last.name,node.name);
            }
        }
        if (returnObj&&object==nil) {
            object = node;
        }else{
            if ([elementName isEqualToString:objName])
                [objects addObject:node];
        }        
        
        [tempList addObject:node];
    }
}


@end
