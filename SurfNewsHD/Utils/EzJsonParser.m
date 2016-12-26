//
//  EzJsonParser.m
//  awsomelib
//
//  Created by Yu Halley on 12-12-30.
//  Copyright (c) 2012年 laoyur. All rights reserved.
//
#import <objc/runtime.h>
#import <Foundation/NSInvocation.h>
#import "EzJsonParser.h"
#import "RuntimeUtil.h"
#import "JSONKit.h"


static NSMutableDictionary* ClassPropertiesCacheDict = nil;


@implementation EzJsonParser(private)

+(NSArray*) propertiesForClass:(Class)class
{
    if(ClassPropertiesCacheDict == nil)
    {
        ClassPropertiesCacheDict = [NSMutableDictionary new];
    }
    
    NSArray* properties = [ClassPropertiesCacheDict objectForKey:class];
    if(properties == nil)
    {
        properties = [RuntimeUtil propertiesForClass:class];
        [ClassPropertiesCacheDict setObject:properties forKey:(id <NSCopying>)class];
    }
    return properties;
}

+(NSDictionary*)convertObjectToDict:(NSObject*) obj
{
    NSArray* properties = [self propertiesForClass:[obj class]];
    NSMutableDictionary* jsonDict = [[NSMutableDictionary alloc] initWithCapacity:[properties count]];
    
    NSString* KeyNamePrefix = @"__KEY_NAME_";
    for (Property* property in properties)
    {
        //假如带有__DO_NOT_SERIALIZE_前缀，表示该property不需要被序列化到json中
        if([property.ivName rangeOfString:@"__DO_NOT_SERIALIZE_"].location != NSNotFound)
            continue;
        
        SEL getter = property.getterSelector;
        NSString* key = nil;
        NSUInteger loc = [property.ivName rangeOfString:KeyNamePrefix].location;
        if(loc == NSNotFound)
        {
            //use propery name as key name
            key = property.name;
        }
        else
        {
            id arr = [property.ivName componentsSeparatedByString:@"$"];
            for (NSString* component in arr)
            {
                if([component hasPrefix:KeyNamePrefix])
                {
                    key = [component substringFromIndex:[KeyNamePrefix length]];
                    break;
                }
            }
        }
        if([property.type length] == 1)
        {
            //premitive types
            char c = [property.type characterAtIndex:0];
            NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[obj methodSignatureForSelector:getter]];
            [invocation setSelector:getter];
            [invocation setTarget:obj];
            
            [invocation invoke];
            NSUInteger len = [[invocation methodSignature] methodReturnLength];
            
            id val = nil;
            void *buffer = (void *)malloc(len);
            [invocation getReturnValue:buffer];
            switch (c) {
                case 'i':   //int
                    val = [NSNumber numberWithInt:*(int*)buffer];
                    break;
                case 'B':   //Boolean
                    val = [NSNumber numberWithBool:*(BOOL*)buffer];
                    break;
                case 'I':   //unsigned int
                    val = [NSNumber numberWithUnsignedInt:*(unsigned int*)buffer];
                    break;
                case 'C':   //unsigned char
                    val = [NSNumber numberWithUnsignedChar:*(unsigned char*)buffer];
                    break;
                case 'c':   //char  //fixme:treat as string ?
                    val = [NSNumber numberWithChar:*(char*)buffer];
                    break;
                case 's':   //short
                    val = [NSNumber numberWithShort:*(short*)buffer];
                    break;
                case 'S':   //unsigned short
                    val = [NSNumber numberWithUnsignedShort:*(unsigned short*)buffer];
                    break;
                case 'l':   //long
                    val = [NSNumber numberWithLong:*(long*)buffer];
                    break;
                case 'L':   //unsigned long
                    val = [NSNumber numberWithUnsignedLong:*(unsigned long*)buffer];
                    break;
                case 'q':   //long long
                    val = [NSNumber numberWithLongLong:*(long long*)buffer];
                    break;
                case 'Q':   //unsigned long long
                    val = [NSNumber numberWithUnsignedLongLong:*(unsigned long long*)buffer];
                    break;
                case 'f':   //float
                    val = [NSNumber numberWithFloat:*(float*)buffer];
                    break;
                case 'd':   //double
                    val = [NSNumber numberWithDouble:*(double*)buffer];
                default:
                    break;
            }
            free(buffer);
            [jsonDict setObject:val forKey:key];
        }
        else if([property.type isEqualToString:@"NSString"]
                || [property.type isEqualToString:@"NSNumber"])
        {
            StartSuppressPerformSelectorLeakWarning
            id val = [obj performSelector:getter];
            EndSuppressPerformSelectorLeakWarning
            if(val)
                [jsonDict setObject:val forKey:key];
            else
                [jsonDict setObject:[NSNull null] forKey:key];

        }
        else if([property.type isEqualToString:@"NSArray"]
                ||[property.type isEqualToString:@"NSMutableArray"])
        {
            StartSuppressPerformSelectorLeakWarning
            NSArray* array = [obj performSelector:getter];
            EndSuppressPerformSelectorLeakWarning
            if(array)
            {
                if([self isThereUnsupportedObjsInArray:array])
                {
                    NSArray* arrayMod = [self convertUnsupportedArray:array];
                    [jsonDict setObject:arrayMod forKey:key];
                }
                else
                {
                    [jsonDict setObject:array forKey:key];
                }
            }
            else
            {
                [jsonDict setObject:[NSNull null] forKey:key];
            }
        }
        else if([property.type isEqualToString:@"NSDictionary"]
                ||[property.type isEqualToString:@"NSMutableDictionary"])
        {
            StartSuppressPerformSelectorLeakWarning
            NSDictionary* dict = [obj performSelector:getter];
            EndSuppressPerformSelectorLeakWarning
            if(dict)
            {
                if([self isThereUnsupportedObjsInDictionary:dict])
                {
                    NSDictionary* dictMod = [self convertUnsupportedDictionary:dict];
                    [jsonDict setObject:dictMod forKey:key];
                }
                else
                {
                    [jsonDict setObject:dict forKey:key];
                }
            }
            else
            {
                [jsonDict setObject:[NSNull null] forKey:key];
            }
        }
        else    //custom obj-c types
        {
            StartSuppressPerformSelectorLeakWarning
            id val = [obj performSelector:getter];
            if(val)
                [jsonDict setObject:[EzJsonParser convertObjectToDict:val] forKey:key];
            else
                [jsonDict setObject:[NSNull null] forKey:key];
            EndSuppressPerformSelectorLeakWarning
        }
    }
    return jsonDict;
}

+(id)convertDict:(NSDictionary*) dict ToObject:(Class) type
{
    NSArray* properties = [self propertiesForClass:type];
    id obj = [type new];
    
    NSString* KeyNamePrefix = @"__KEY_NAME_";
    for (Property* property in properties)
    {
        id prefixArray = [property.ivName componentsSeparatedByString:@"$"];

        NSString* key = nil;
        NSUInteger loc = [property.ivName rangeOfString:KeyNamePrefix].location;
        if(loc == NSNotFound)
        {
            //use propery name as key name
            key = property.name;
        }
        else
        {
            for (NSString* component in prefixArray)
            {
                if([component hasPrefix:KeyNamePrefix])
                {
                    key = [component substringFromIndex:[KeyNamePrefix length]];
                    break;
                }
            }
        }
        
        id val = [dict objectForKey:key];
        if(val != nil)
        {
            NSString* propType = property.type;
            SEL setter = property.setterSelector;
            
            if([propType length] == 1)  //premitive types
            {
                char c = [propType characterAtIndex:0];
                NSMethodSignature* msig = [obj methodSignatureForSelector:setter];
                if(!msig)
                    continue;
                NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:msig];
                [invocation setSelector:setter];
                [invocation setTarget:obj];
                
                switch (c) {
                    case 'i':   //int
                    {
                        if([val isKindOfClass:[NSNumber class]])
                        {
                            int intVal = [(NSNumber*)val intValue];
                            [invocation setArgument:&intVal atIndex:2];
                            [invocation invoke];
                        }
                        //compatible with string
                        else if([val isKindOfClass:[NSString class]])
                        {
                            int intVal = [(NSString*)val intValue];
                            [invocation setArgument:&intVal atIndex:2];
                            [invocation invoke];
                        }
                        break;
                    }
                    case 'B':   //Boolean
                    {
                        if([val isKindOfClass:[NSNumber class]])
                        {
                            BOOL boolVal = [(NSNumber*)val boolValue];
                            [invocation setArgument:&boolVal atIndex:2];
                            [invocation invoke];
                        }
                        break;
                    }
                    case 'I':   //unsigned int
                    {
                        if([val isKindOfClass:[NSNumber class]])
                        {
                            unsigned int uintVal = [(NSNumber*)val unsignedIntValue];
                            [invocation setArgument:&uintVal atIndex:2];
                            [invocation invoke];
                        }
                        //compatible with string
                        else if([val isKindOfClass:[NSString class]])
                        {
                            unsigned int uintVal = [(NSString*)val intValue];
                            [invocation setArgument:&uintVal atIndex:2];
                            [invocation invoke];
                        }
                        break;
                    }
                    case 'C':   //unsigned char //treat as BOOL
                    {
                        if([val isKindOfClass:[NSString class]])
                        {
                            unichar char0 = [(NSString*)val characterAtIndex:0];
                            [invocation setArgument:&char0 atIndex:2];
                            [invocation invoke];
                        }
                        break;
                    }
                    case 'c':   //char  //fixme:treat as string ?
                    {
                        if([val isKindOfClass:[NSNumber class]])
                        {
                            short b = [(NSNumber*)val shortValue];
                            [invocation setArgument:&b atIndex:2];
                            [invocation invoke];
                        }
                        break;
                    }
                    case 's':   //short
                    {
                        if([val isKindOfClass:[NSNumber class]])
                        {
                            short sVal = [(NSNumber*)val shortValue];
                            [invocation setArgument:&sVal atIndex:2];
                            [invocation invoke];
                        }
                        //compatible with string
                        else if([val isKindOfClass:[NSString class]])
                        {
                            short sintVal = [(NSString*)val intValue];
                            [invocation setArgument:&sintVal atIndex:2];
                            [invocation invoke];
                        }
                        break;
                    }
                    case 'S':   //unsigned short
                    {
                        if([val isKindOfClass:[NSNumber class]])
                        {
                            unsigned short usVal = [(NSNumber*)val unsignedShortValue];
                            [invocation setArgument:&usVal atIndex:2];
                            [invocation invoke];
                        }
                        //compatible with string
                        else if([val isKindOfClass:[NSString class]])
                        {
                            unsigned short usVal = [(NSString*)val intValue];
                            [invocation setArgument:&usVal atIndex:2];
                            [invocation invoke];
                        }
                        break;
                    }
                    case 'l':   //long
                    {
                        if([val isKindOfClass:[NSNumber class]])
                        {
                            long lVal = [(NSNumber*)val longValue];
                            [invocation setArgument:&lVal atIndex:2];
                            [invocation invoke];
                        }
                        //compatible with string
                        else if([val isKindOfClass:[NSString class]])
                        {
                            long lVal = (long)[(NSString*)val longLongValue];
                            [invocation setArgument:&lVal atIndex:2];
                            [invocation invoke];
                        }
                        break;
                    }
                    case 'L':   //unsigned long
                    {
                        if([val isKindOfClass:[NSNumber class]])
                        {
                            unsigned long ulVal = [(NSNumber*)val unsignedLongValue];
                            [invocation setArgument:&ulVal atIndex:2];
                            [invocation invoke];
                        }
                        //compatible with string
                        else if([val isKindOfClass:[NSString class]])
                        {
                            unsigned long ulVal = (unsigned long)[(NSString*)val longLongValue];
                            [invocation setArgument:&ulVal atIndex:2];
                            [invocation invoke];
                        }
                        break;
                    }
                    case 'q':   //long long
                    {
                        if([val isKindOfClass:[NSNumber class]])
                        {
                            long long llVal = [(NSNumber*)val longLongValue];
                            [invocation setArgument:&llVal atIndex:2];
                            [invocation invoke];
                        }
                        //compatible with string
                        else if([val isKindOfClass:[NSString class]])
                        {
                            long long llVal = [(NSString*)val longLongValue];
                            [invocation setArgument:&llVal atIndex:2];
                            [invocation invoke];
                        }
                        break;
                    }
                    case 'Q':   //unsigned long long
                    {
                        if([val isKindOfClass:[NSNumber class]])
                        {
                            unsigned long long ullVal = [(NSNumber*)val unsignedLongLongValue];
                            [invocation setArgument:&ullVal atIndex:2];
                            [invocation invoke];
                        }
                        //compatible with string
                        else if([val isKindOfClass:[NSString class]])
                        {
                            unsigned long long ullVal = [(NSString*)val longLongValue];
                            [invocation setArgument:&ullVal atIndex:2];
                            [invocation invoke];
                        }
                        break;
                    }
                    case 'f':   //float
                    {
                        if([val isKindOfClass:[NSNumber class]])
                        {
                            float fVal = [(NSNumber*)val floatValue];
                            [invocation setArgument:&fVal atIndex:2];
                            [invocation invoke];
                        }
                        //compatible with string
                        else if([val isKindOfClass:[NSString class]])
                        {
                            float fVal = [(NSString*)val floatValue];
                            [invocation setArgument:&fVal atIndex:2];
                            [invocation invoke];
                        }
                        break;
                    }
                    case 'd':   //double
                    {
                        if([val isKindOfClass:[NSNumber class]])
                        {
                            double dVal = [(NSNumber*)val doubleValue];
                            [invocation setArgument:&dVal atIndex:2];
                            [invocation invoke];
                        }
                        //compatible with string
                        else if([val isKindOfClass:[NSString class]])
                        {
                            double dVal = [(NSString*)val doubleValue];
                            [invocation setArgument:&dVal atIndex:2];
                            [invocation invoke];
                        }
                        break;
                    }
                    default:
                        break;
                }
            }
            else if([propType isEqualToString:@"NSString"])
            {
                if([val isKindOfClass:[NSString class]])
                {
                    StartSuppressPerformSelectorLeakWarning
                    [obj performSelector:setter withObject:val];
                    EndSuppressPerformSelectorLeakWarning
                }
                //compatible with numbers
                else if([val isKindOfClass:[NSNumber class]])
                {
                    StartSuppressPerformSelectorLeakWarning
                    [obj performSelector:setter withObject:[(NSNumber*)val stringValue]];
                    EndSuppressPerformSelectorLeakWarning
                }
            }
            else if([propType isEqualToString:@"NSNumber"])
            {
                if([val isKindOfClass:[NSNumber class]])
                {
                    StartSuppressPerformSelectorLeakWarning
                    [obj performSelector:setter withObject:val];
                    EndSuppressPerformSelectorLeakWarning
                }
                //compatible with strings
                else if([val isKindOfClass:[NSString class]])
                {
                    StartSuppressPerformSelectorLeakWarning
                    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                    [f setNumberStyle:NSNumberFormatterDecimalStyle];
                    NSNumber * num = [f numberFromString:(NSString*)val];
                    [obj performSelector:setter withObject:num];
                    EndSuppressPerformSelectorLeakWarning
                }
            }
            else if([propType isEqualToString:@"NSArray"]
                    ||[propType isEqualToString:@"NSMutableArray"])
            {
                if([val isKindOfClass:[NSArray class]])
                {
                    //try to test property's iVar name
                    //if looks like
                    //   __ELE_TYPE_TestSubClass
                    //or __ELE_TYPE_0_TestSubClass
                    //or __ELE_TYPE_1_TestSubClass
                    //or __ELE_TYPE_2_TestSubClass
                    //...
                    //or __ELE_TYPE_9_TestSubClass
                    //then we extract 'TestSubClass' as element type
                    
                    NSString* EleTypePrefix = @"__ELE_TYPE_";
                    NSUInteger loc = [property.ivName rangeOfString:EleTypePrefix].location;
                    if(loc == NSNotFound)
                    {
                        StartSuppressPerformSelectorLeakWarning
                        //NOTE：
                        //这里使用[val mutableCopy]是为了让Array在后续使用场景中拥有可修改能力
                        [obj performSelector:setter withObject:[val mutableCopy]];
                        EndSuppressPerformSelectorLeakWarning
                    }
                    else
                    {
                        for (NSString* component in prefixArray)
                        {
                            NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"__ELE_TYPE_(?:\\d_)?(.+)" options:0 error:nil];
                            NSTextCheckingResult* m = [regex firstMatchInString:component options:0 range:NSMakeRange(0, [component length])];
                            if(m != nil)
                            {
                                NSRange rangeOfType = [m rangeAtIndex:1];
                                NSMutableArray* arr = [NSMutableArray new];
                                for (id ele in (NSArray*)val)
                                {
                                    id o = [self convertDict:(NSDictionary*)ele ToObject:NSClassFromString([component substringWithRange:rangeOfType])];
                                    [arr addObject:o];
                                }
                                StartSuppressPerformSelectorLeakWarning
                                [obj performSelector:setter withObject:arr];
                                EndSuppressPerformSelectorLeakWarning
                                break;
                            }
                        }
                    }
                }
            }
            else if([propType isEqualToString:@"NSDictionary"]
                    ||[propType isEqualToString:@"NSMutableDictionary"])
            {
                if([val isKindOfClass:[NSDictionary class]])
                {
                    StartSuppressPerformSelectorLeakWarning
                    
                    //NOTE：
                    //这里使用[val mutableCopy]是为了让Dict在后续使用场景中拥有可修改能力
                    [obj performSelector:setter withObject:[val mutableCopy]];
                    EndSuppressPerformSelectorLeakWarning
                }
            }
            else    //custom obj-c types
            {
                StartSuppressPerformSelectorLeakWarning
                if([val isEqual:[NSNull null]])
                {
                    [obj performSelector:setter withObject:nil];
                }
                else
                {
                    [obj performSelector:setter withObject:[self convertDict:(NSDictionary*)val ToObject:NSClassFromString(propType)]];
                }
                EndSuppressPerformSelectorLeakWarning
            }
        }
    }
    return obj;
}

+(NSArray*) convertUnsupportedArray:(NSArray*) array
{
    NSMutableArray* arr = [NSMutableArray new];
    for (id ele in array)
    {
        if(![self isSupportedType:ele])
        {
            NSDictionary* dict = [self convertObjectToDict:ele];
            [arr addObject:dict];
        }
        else
        {
            [arr addObject:ele];
        }
    }
    return arr;
}

+(NSDictionary*) convertUnsupportedDictionary:(NSDictionary*) dict
{
    NSMutableDictionary* dic = [NSMutableDictionary new];
    for (NSString* key in dict)
    {
        id val = dict[key];
        if([self isSupportedType:val])
        {
            [dic setObject:val forKey:key];
        }
        else
        {
            id valMod = [self convertObjectToDict:val];
            [dic setObject:valMod forKey:key];
        }
    }
    return dic;
}

+(BOOL) isSupportedType:(NSObject*) obj
{
    return [obj isKindOfClass:[NSString class]]
    ||[obj isKindOfClass:[NSNumber class]]
    ||[obj isKindOfClass:[NSArray class]]
    ||[obj isKindOfClass:[NSDictionary class]];
}

+(BOOL)isThereUnsupportedObjsInArray:(NSArray*) array
{
    for (id ele in array)
    {
        if(![self isSupportedType:ele])
            return TRUE;
    }
    return FALSE;
}

+(BOOL)isThereUnsupportedObjsInDictionary:(NSDictionary*) dict
{
    for (NSString* key in dict)
    {
        id val = [dict objectForKey:key];
        if(![self isSupportedType:val])
            return TRUE;
    }
    return FALSE;
}

@end

@implementation EzJsonParser

+(NSString*)serializeObjectWithUtf8Encoding:(NSObject *)obj
{
    if([obj isKindOfClass:[NSArray class]])
    {
        if([self isThereUnsupportedObjsInArray:(NSArray*)obj])
        {
            NSArray* array = [self convertUnsupportedArray:(NSArray*)obj];
            return [array JSONString];
        }
        else
            return [(NSArray*)obj JSONString];
    }
    else if([obj isKindOfClass:[NSDictionary class]])
    {
        if([self isThereUnsupportedObjsInDictionary:(NSDictionary*)obj])
        {
            NSDictionary* dict = [self convertUnsupportedDictionary:(NSDictionary*)obj];
            return [dict JSONString];
        }
        else
            return [(NSDictionary*)obj JSONString];
    }
    else if([obj isKindOfClass:[NSObject class]])
        return [[self convertObjectToDict:obj] JSONString];
    else
        return nil;
}

+(id) deserializeFromJson:(NSString*)json AsType:(Class)type
{
    if(type == [NSArray class]
       || type == [NSDictionary class])
    {
        id obj = [json objectFromJSONString];
        if([obj isKindOfClass:type])
            return obj;
        else
            return nil;
    }
    else if(type == [NSMutableArray class]
            || type == [NSMutableDictionary class])
    {
        id obj = [json mutableObjectFromJSONString];
        if([obj isKindOfClass:type])
            return obj;
        else
            return nil;
    }
    else    //custom objc-type
    {
        id obj = [json objectFromJSONString];
        if(obj)
            return [self convertDict:(NSDictionary*)obj ToObject:type];
        else
            return nil;
    }
}

@end


