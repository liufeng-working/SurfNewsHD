//
//  NSString+UrlEncoding.h
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ContentSize)

- (CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW;

- (CGSize)sizeWithFont:(UIFont *)font;

@end

@interface NSString (UrlEncoding)

//utf8 encoding by default
-(NSString*) urlEncodedString;
-(NSString*) urlEncodedGbkString;

//utf8 encoding by default
-(NSString*) urlDecodedString;

@end

@interface NSString (OtherExtentions)

//从逻辑上判断是否相等
//nil和空串等同
+(BOOL) isString:(NSString*)s1 logicallEqualsToString:(NSString*)s2;

//返回完全形式的url(追加http://)
-(NSString*) completeUrl;

-(NSString*) trim;

-(NSString*) trimLeft;

-(NSUInteger) indexOfString:(NSString*)str;

-(NSUInteger) lastIndexOfString:(NSString*)str;

-(BOOL) contains:(NSString*)str;
-(BOOL) containsCasInsensitive:(NSString*)str;

-(BOOL) isEqualToStringCaseInsensitive:(NSString *)aString;

-(BOOL) hasPrefixCaseInsensitive:(NSString*)prefix;
-(BOOL) hasSuffixCaseInsensitive:(NSString *)suffix;

-(BOOL) isEmptyOrBlank;

-(NSStringEncoding) convertToStringEncoding;

//comment from yuleiming:
//此函数名有歧义，到底是【中国移动】手机号
//还是中国的手机号？
//看其实现，貌似是后者
-(BOOL) isChinaMobileNumber;

//----------版本号比较----------
//支持1.0.3、1.2.3.4等各种形式的相互比较
-(BOOL) isVersionLowerThan:(NSString*)version;
-(BOOL) isVersionLowerThanOrEqualsTo:(NSString*)version;
-(BOOL) isVersionEqualsTo:(NSString*)version;
-(BOOL) isVersionHigherThan:(NSString*)version;
-(BOOL) isVersionHigherThanOrEqualsTo:(NSString*)version;

//将字节数转化为用户友好的字符串表达
//例：10.25MB、3.05kB
+(NSString*) readableStringWithBytes:(long long)bytes;


// 是否包含表情符号
- (BOOL)isContainsEmoji;


-(void)surfDrawAtPoint:(CGPoint)p withFont:(UIFont*)font;


-(void)surfDrawString:(CGRect)rect
             withFont:(UIFont *)font
            withColor:(UIColor *)color
        lineBreakMode:(NSLineBreakMode)lineBreakMode
            alignment:(NSTextAlignment)alignment;

-(void)surfDrawString:(CGRect)rect
             withFont:(UIFont *)font
            withColor:(UIColor *)color
        lineBreakMode:(NSLineBreakMode)lineBreakMode
            alignment:(NSTextAlignment)alignment
      fontLineSpacing:(CGFloat)lineSpacing;


-(CGSize)surfSizeWithFont:(UIFont *)font
        constrainedToSize:(CGSize)size
            lineBreakMode:(NSLineBreakMode)lineBreakMode;

-(CGSize)surfSizeWithFont:(UIFont *)font
        constrainedToSize:(CGSize)size
            lineBreakMode:(NSLineBreakMode)lineBreakMode
          fontLineSpacing:(CGFloat)lineSpacing;

// 验证手机号
- (BOOL)validateMobile;

//中文转化为拼音（驼峰法则，首字母是大写的）
-(NSString *)chineseChangeToLetter;
//获取字符串的首字母
-(NSString *)getFitstLetter;

@end


//htmlencoding
//源码来自gtm
@interface NSString (HtmlEncoding)

/// Get a string where internal characters that need escaping for HTML are escaped
//
///  For example, '&' become '&amp;'. This will only cover characters from table
///  A.2.2 of http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
///  which is what you want for a unicode encoded webpage. If you have a ascii
///  or non-encoded webpage, please use stringByEscapingAsciiHTML which will
///  encode all characters.
///
/// For obvious reasons this call is only safe once.
//
//  Returns:
//    Autoreleased NSString
//
- (NSString *)stringByEscapingForHTML;

/// Get a string where internal characters that need escaping for HTML are escaped
//
///  For example, '&' become '&amp;'
///  All non-mapped characters (unicode that don't have a &keyword; mapping)
///  will be converted to the appropriate &#xxx; value. If your webpage is
///  unicode encoded (UTF16 or UTF8) use stringByEscapingHTML instead as it is
///  faster, and produces less bloated and more readable HTML (as long as you
///  are using a unicode compliant HTML reader).
///
/// For obvious reasons this call is only safe once.
//
//  Returns:
//    Autoreleased NSString
//
- (NSString *)stringByEscapingForAsciiHTML;

/// Get a string where internal characters that are escaped for HTML are unescaped
//
///  For example, '&amp;' becomes '&'
///  Handles &#32; and &#x32; cases as well
///
//  Returns:
//    Autoreleased NSString
//
- (NSString *)stringByUnescapingFromHTML;

@end