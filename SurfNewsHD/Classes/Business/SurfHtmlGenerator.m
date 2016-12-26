//
//  SurfHtmlGenerator.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfHtmlGenerator.h"
#import "AppSettings.h"
#import "NSString+Extensions.h"
#import "PathUtil.h"
#import "ThemeMgr.h"
#import "ClientFunctionManager.h"
#import "HtmlUtil.h"
#import "AdvertisementManager.h"
#import "XmlUtils.h"
#import "SubsChannelsManager.h"
#import "RssSourceData.h"
#import "FavsManager.h"


@implementation SurfHtmlGenerator

+ (NSString*)generateWithThread:(ThreadSummary*)thread
{
    BOOL nightMode = [[ThemeMgr sharedInstance] isNightmode];
    NSString* div = [NSString stringWithFormat:@"<div id='loadingdiv'><br/><br/><img id='loadinggif' src='file://%@' style='display: block; margin-left: auto; margin-right: auto;'/><br/><br/><br/><br/></div>",[PathUtil pathOfResourceNamed:nightMode ? @"webview-loading-night.gif" : @"webview-loading-day.gif"]];
    return [self generateWithThread:thread andResolvedContent:div recommendContent:nil];
}
+ (NSString*)generateWithThread:(ThreadSummary*)thread
             andResolvedContent:(NSString*)content
               recommendContent:(NSString*)recommends
{    
    NSMutableString* html = [NSMutableString new];
    
    BOOL nightMode = [AppSettings boolForKey:BOOLKEY_NightMode];

    [html appendString:@"\
     <!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\
     <html xmlns=\"http://www.w3.org/1999/xhtml\">\n\
     <head>\n\
     <meta http-equiv=\"Content-Type\" content=\"application/vnd.wap.xhtml+xml;charset=utf-8\"/>\n\
     <meta name=\"viewport\" content=\"initial-scale=1.0,user-scalable=no, minimum-scale=1.0, maximum-scale=1.0\" />\n\
     <meta name=\"format-detection\" content=\"telephone=no\">\
     <style type=\"text/css\">\n\
     body {\
     -webkit-touch-callout: none;\
     padding: 5px; margin: 0px; background-color:"];
#ifdef ipad
    [html appendString: @"transparent"];
#else
    [html appendString: nightMode ? NightBackgroundColor : DayBackgroundColor];
#endif
    [html appendString:@"; word-wrap: break-word; overflow: auto; overflow-x:hidden; }\n\
     font.progress{color: "BodyFontColor"; text-align:center; }\
     img.center{display: block; margin-left: auto; margin-right: auto;border:1px solid #cccccc;}\
     .marTop-10 { margin-top: -15px }\n\
     .marTop10 { margin-top: 5px }\n\
     .marLeft10 { margin-left: 5px }\n\
     .marRight10 { margin-right: 5px }\n\
     .titleStyle{ color: "];
    [html appendString:(nightMode ? NightTitleColor : DayTitleColor)];
    [html appendString:@"; font-size: 22px; margin:10px 0px; line-height:24px; font-weight: bold}\n\
     .subTitleStyle { color:"];
    [html appendString:SoureFontColor];
    
    if (thread.channelId == 110150) {  //当频道是微精选时,margin-top:0px
        [html appendString:@"; font-size:10px; margin-top:5px; }\n\
         .contentStyle{ margin-top:0px; margin-left:8px; margin-right:8px; color:"];
    } else {
        [html appendString:@"; font-size:10px; margin-top:5px; }\n\
         .contentStyle{ margin-top:20px; margin-left:8px; margin-right:8px; color:"];
    }
    [html appendString:BodyFontColor];
    [html appendString:@"; font-size: "];
    [html appendFormat:@"%f",[AppSettings floatForKey:FLOATKEY_ReaderBodyFontSize]];
    [html appendString:@"px;"];
    [html appendString:@"line-height:"];
    [html appendFormat:@"%f",[AppSettings floatForKey:FLOATKEY_ReaderBodyFontSize] + 8];
    [html appendString:@"px; }\n\
     p{ margin:20px 0px auto 0px; }\n\
     p.copyright{color:#dcdbdb; font-size:10px; margin-bottom:50px}.originalLinkStyle {color:#6b6b6b; font-size:18px; }"];
    [html appendString:@"\
     ul {list-style : none; padding:0 0 0 0px; margin:10px 0px 0px 0px;}\
     li {line-height: 15px;}\
     dt {line-height: 15px; font-size:15px; color:#ce0000;padding-left:0px;}\
     hr {size:5px; color:green}"];
    
    [html appendString:@" li > a {text-decoration:none; font-size: 15px; color:"BodyFontColor";}"];
    
    
    NSString *addBtnBg = [NSString stringWithFormat:@"file://%@", [PathUtil pathOfResourceNamed:@"order_add.png"]];
    NSString *okBg = [NSString stringWithFormat:@"file://%@", [PathUtil pathOfResourceNamed:@"order_ok.png"]];
    [html appendFormat:@"\
     .orderBy{padding:15px;font-family:\"Microsoft Yahei\",helvetica,arial;}\
     .orderBy-box{margin:15px 0;position:relative; box-shadow:0 0 2px #ccc; padding:0.5em; background:#fff;overflow:hidden;}\
     .orderBy-box span{display:block;}\
     .orderBy-box span.sp-img{float:left;padding-right:0.5em;}\
     .orderBy-box span.sp-img img{display:block; width:50px; height:50px;}\
     .orderBy-box span.sp-txt{position:absolute; left:65px;}\
     .orderBy-box span.sp-txt em{display:block; font-style:normal;margin:0px 60px 0px 0px;}\
     .em-tit{font-size:15px; color:#454545;}\
     .em-p{font-size:12px; color:#666; line-height:20px;}\
     .fred{color:#cc0000;}\
     .fbig18{font-size:16px; font-weight:600;}\
     .sp-state{position:absolute; right:0.5em; top:0.5em;width:50px; height:50px; }\
     .orderbtn{display:block; width:50px; height:50px; line-height:50px;background:url('%@') no-repeat center; text-indent:300px;}\
     .orderok{display:block; width:50px; height:50px; line-height:50px;background:url('%@') no-repeat center; text-indent:200px;}",addBtnBg, okBg];
    
    // 正负能量
    [html appendFormat:@"\
     .power-title{margin:5 0; color:#cc0000; padding:1px 0 1px 30px; line-height:30px; background:url('file://%@') no-repeat left center;  background-size:22px 22px;}",
     [PathUtil pathOfResourceNamed:@"hg_ic03.png"]];
    [html appendString:@"\
     .article-power{background:#fff; padding:0px 11px 15px 11px;}\
     .progress-area{width:100%;overflow:hidden;}\
     .pro-good{float:left;}\
     .pro-bad{float:right;}\
     .txt{height:30px;min-width:60px; vertical-align:top; text-align:right; overflow:hidden;}\
     .txt span,.txt em{display:block;}\
     .txt span{display:block;width:auto;padding-top:10px;line-height:20px; font-size:12px; font-weight:600;}\
     .txt em{line-height:26px; text-indent:9999px;width:26px; height:26px;}\
     .pro-good .txt span{float:left; color:#cc0000;}\
     .pro-good .txt em{float:right;margin-right:2px;}\
     .pro-bad .txt span{float:right; color:#352d29;}\
     .pro-bad .txt em{float:left;margin-left:2px;}"];
     
    [html appendFormat:@".pro-bar{height:20px;line-height:20px;border-radius:2px; font-size:12px; color:#fff; text-align:center; overflow:hidden;}\
     .pro-good .pro-bar{background-color:#cc0000; background-image:url('file://%@') no-repeat right center; -webkit-box-sizing:border-box;box-sizing:border-box; margin-right:1px;}\
     .pro-bad .pro-bar{background-color:#352d29;\
     background-image:url('file://%@') no-repeat left center;}",
     [PathUtil pathOfResourceNamed:@"good.png"],
     [PathUtil pathOfResourceNamed:@"bad.png"]];

    [html appendString:@"\
     .article-text{padding:0.5em 0;}\
     .txt1{padding:0.2em 0 0.5em;font-size:10px; line-height:150%; color:#352d29; text-align:center;}"];
    [html appendFormat:@"\
     .good-ic{background:url('file://%@') no-repeat center; background-size:cover;}\
     .bad-ic{background:url('file://%@') no-repeat center; background-size:cover;}\
     .good-news{background:url('file://%@') no-repeat center;background-size:cover;}\
     .bad-news{background:url('file://%@') no-repeat center;background-size:cover;}",
     [PathUtil pathOfResourceNamed:@"good50.png"],
     [PathUtil pathOfResourceNamed:@"bad50.png" ],
     [PathUtil pathOfResourceNamed:@"good_icon.png"],
     [PathUtil pathOfResourceNamed:@"bad_icon.png"]];
    [html appendString:@"\
     .article-link{line-height:30px; text-align:right; overflow:hidden;}\
     .article-link span{float:left; width:auto; font-size:80%; color:#352d29;}\
     .article-link span em{display:inline-block; vertical-align:top; margin:0 4px; width:30px; height:30px;}\
     .kx-link2{display:inline-block; vertical-align:top; font-size:80%; height:30px; line-height:30px; font-weight:600; "];
    [html appendFormat:@"background:url('file://%@') no-repeat right top; background-size:30px 30px; padding-right:34px; color:#cc0000;}",
     [PathUtil pathOfResourceNamed:@"bticon.png"]];


    
    
    [html appendString:@"</style>\n\
    <script type=\"text/javascript\">\n\
    function getStyle(sname){ \
        for (var i = 0; i < document.styleSheets.length; i++) { \
            var rules = document.styleSheets[i].rules;\
            for (var j = 0; j < rules.length; j++) { \
                if (rules[j].selectorText == sname) { \
                    return rules[j].style;\
                }\
            }\
        }\
    }\n\
    function setTitleFontColor(color)\
    {\
        var titleStyle = getStyle('.titleStyle');\
        titleStyle.color=color;\
    }\n\
    function setTitle(title,source,time)\
    {\
        var newsTitle = document.getElementById('newsTitle');\
        newsTitle.innerHTML=title;\
        var newsTime = document.getElementById('newsTime');\
        newsTime.innerHTML=time;\
        var newsSource = document.getElementById('newsSource');\
        newsSource.innerHTML='来源:'+source;\
     }\n\
     function setRecommendSeparatorColor(color)\
     {\
        var recommendHrArray = document.getElementsByName(\"recommendHr\");\
        for(i=0;i<recommendHrArray.length;i++) {\
            recommendHrArray[i].style.borderBottomColor=color;\
        }\
     }\
    function setArticleFontSize(px)\
    {\
      var aStyle = getStyle('.contentStyle');\
      aStyle.fontSize = px + 'px';\
      aStyle.lineHeight = (parseInt(px) + 8) + 'px';\
    }\n\
    function setArticleFontFamily(font)\
    {\
      var aStyle = getStyle('.contentStyle');\
      aStyle.fontFamily = font;\
    }\n\
     function setNightMode(night)\
     {\
        if(night)\
        {\
            document.body.style.backgroundColor='"NightBackgroundColor"';\
            setTitleFontColor('"NightTitleColor"');\
            setRecommendSeparatorColor('"recommendHrBorderColor_night"');\
            var enBg = document.getElementById('energyBg');\
            enBg.style.backgroundColor='black';\
        }\
        else\
        {\
            document.body.style.backgroundColor='"DayBackgroundColor"';\
            setTitleFontColor('"DayTitleColor"');\
            setRecommendSeparatorColor('"recommendHrBorderColor_day"');\
            var enBg = document.getElementById('energyBg');\
            enBg.style.backgroundColor='#fff';\
        }\
        var div = document.getElementById('contentDiv');\
        var node0 = div.childNodes[0];\
        if(node0.id == 'loadingdiv')\
        {\
            var gif = document.getElementById('loadinggif');\
            if(night)\
                gif.src = 'file://"];
#ifdef ipad
    //TODO：ipad暂时无夜间模式
#else
               [html appendString:[PathUtil pathOfResourceNamed:@"webview-loading-night.gif"]];
#endif
               [html appendString:@"';\
            else\
                gif.src = 'file://"];
#ifdef ipad
    //TODO：ipad暂时无夜间模式
#else
               [html appendString:[PathUtil pathOfResourceNamed:@"webview-loading-day.gif"]];
#endif
               [html appendString:@"';\
        }\
    }\
function onImgClick()\
{\
    var img = event.srcElement;\
    var width = img.width;\
    var height = img.height;\
    var imgOffset = getOffset(img);\
    window.open(\""IMAGE_CLICK_PREFIX"\"+ img.src\
     +'?width=' + width +'&height=' + height +'&x='+ imgOffset.left +'&y='+ imgOffset.top+'&imgid='+img.id);\
}\n\
function onViewSourceImgLoad()\
{\
    var img=event.srcElement;\
    img.addEventListener('touchstart', handleViewSourceImgTouchStart, false);\
    img.addEventListener('touchend', handleViewSourceImgTouchEnd, false);\
    img.addEventListener('touchcancel', handleViewSourceImgTouchEnd, false);\
    img.addEventListener('touchleave', handleViewSourceImgTouchEnd, false);\
}\
function handleViewSourceImgTouchStart(evt)\
{\
    var img=evt.target;\
    img.style.backgroundColor='"BodyFontColor"';\
}\
function handleViewSourceImgTouchEnd(evt)\
{\
    var img=evt.target;\
    img.style.backgroundColor='transparent';\
}\
function getOffset( el ) \
{\
    var _x = 0;\
    var _y = 0;\
    while( el && !isNaN( el.offsetLeft ) && !isNaN( el.offsetTop ) ) {\
        _x += el.offsetLeft - el.scrollLeft;\
        _y += el.offsetTop - el.scrollTop;\
        el = el.offsetParent;\
    }\
    return { top: _y, left: _x };\
}\n\
function imgOnLoad(){\
    var img = event.srcElement;"];
    [html appendFormat:@"var width=%f;",ImgTagMaxWidth];
    [html appendString:@"\
    if(img.width > width)\
    {\
        var ratio = img.width / img.height;\
        img.width = width;\
        img.height = width / ratio;\
    }\
}\n\
    function setImgSrc(id,src)\
    {\
        var img = document.getElementById(id);\
        img.src = src;\
    }\n\
    function showImgClickToDownloadDiv(imgId)\
    {\
     var div = document.getElementById(imgId+'_ctd');\
     div.style.display = 'inline';\
    }\
    function setImgClickToDownloadDivFgImg(imgId,imgSrc)\
    {\
     var img = document.getElementById(imgId+'_ctd_fg');\
     img.src = imgSrc;\
    }\
    function hideImgClickToDownloadDiv(imgId)\
    {\
     var div = document.getElementById(imgId+'_ctd');\
     div.style.display = 'none';\
    }\
    function showImgPercentDiv(imgId)\
    {\
        var div = document.getElementById(imgId+'_pct');\
        div.style.display = 'inline';\
    }\n\
    function hideImgPercentDiv(imgId)\
    {\
        var div = document.getElementById(imgId+'_pct');\
        div.style.display = 'none';\
    }\n\
    function setImgPercent(id,pct)\
    {\
        var div = document.getElementById(id+'_pcttxt');\
        div.innerHTML = pct;\
    }\n\
    function setContent(content)\
    {\
      var div = document.getElementById('contentDiv');\
      div.innerHTML = content;\
    }\n\
    function showReloadButton()\
    {\
      var div = document.getElementById('contentDiv');\
     div.innerHTML = \"<div id='reloadButton' class='marRight10 marLeft10 marTop10' ><br/><br/><img style='display: block; margin-left: auto; margin-right: auto;' src='"];
    [html appendFormat:@"file://%@",[PathUtil pathOfResourceNamed:@"webview-reload.png"]];
    [html appendString:@"' onclick='javascript:window.open(\\\""RELOAD_CONTENT_CLICK_PREFIX"\\\")'/>  <br/><br/><br/>  </div>\";\
    }\n\
    function hideReloadButton()\
    {\
      var reloadButton = document.getElementById('reloadButton');\
      reloadButton.style.display = 'none';\
    }\n\
    function showLoadingAnimation(isNight)\
     {\
      var div=document.getElementById('contentDiv');\
      if(isNight)\
        div.innerHTML=\"<div style='text-align:center;'><br/><br/><img src='file://"];
#ifdef ipad
    
#else
    [html appendString:[PathUtil pathOfResourceNamed:@"webview-loading-night.gif"]];
#endif
    [html appendString:@"'/><br/><br/><br/><br/></div>\";\
      else\
        div.innerHTML=\"<div style='text-align:center;'><br/><br/><img src='file://"];
#ifdef ipad
    
#else
    [html appendString:[PathUtil pathOfResourceNamed:@"webview-loading-day.gif"]];
#endif
    [html appendString:@"'/><br/><br/><br/><br/></div>\";\
     }\
    function setRSS(rssName,rssIcon,isSubscribe)\
    {\
        var rss_container = document.getElementById('rss_container');\
        var myRSSName = document.getElementById('rssName');\
        var myRSSImg = document.getElementById('rssIcon');\
        if (rssName == ''){\
            rss_container.style.display='none';\
        }\
        else {\
            rss_container.style.display='block';\
            myRSSName.innerHTML = rssName;\
            myRSSImg.src = rssIcon;\
            changeRSSSubsState(isSubscribe);\
        }\
    }\
    function changeRSSSubsState(isSubscribe)\
    {\
        var myRSSSubscribe = document.getElementById('hasSubscribe');\
        if(isSubscribe){\
            myRSSSubscribe.setAttribute('class', 'orderok');\
        }else{\
            myRSSSubscribe.setAttribute('class', 'orderbtn');\
        }\
    }\
    function hidderPower()\
    {\
        var power_layout = document.getElementById('power_layout');\
        if (power_layout)\
            power_layout.style.display = 'none';\
    }\
    function refreshPower(poPercent,poEnergy,\
        negaPercent,negaEnergy,energyCount,isPositiveEnergy)\
    {\
     var power_layout = document.getElementById('power_layout');\
     var proGoodId = document.getElementById('proGoodId');\
     var positiveEnergy = document.getElementById('positiveEnergy');\
     var positivePercent =  document.getElementById('positivePercent');\
     var proBadId = document.getElementById('proBadId');\
     var negativeEnergy = document.getElementById('negativeEnergy');\
     var negativePercent = document.getElementById(\"negativePercent\");\
     var percent =  document.getElementById(\"percent\");\
     var phrase = document.getElementById('phrase');\
     var count = document.getElementById(\"count\");\
     var word = document.getElementById(\"word\");\
     var energy = document.getElementById(\"energy\");\
     var energyIcon = document.getElementById(\"energy-icon\");\
     power_layout.style.display = 'block';\
     proGoodId.style.width = poPercent + '%';\
     positiveEnergy.innerHTML = poEnergy;\
     positivePercent.innerHTML =poPercent + '%';\
     proBadId.style.width = negaPercent + '%';\
     negativeEnergy.innerHTML = negaEnergy;\
     negativePercent.innerHTML = negaPercent + '%';\
     count.innerHTML = energyCount;\
     if(isPositiveEnergy){\
        percent.innerHTML = poPercent;\
        word.innerHTML = '正';\
        phrase.innerHTML = '满满的都是爱！';\
        energy.setAttribute(\"class\", \"good-ic\");\
        energyIcon.setAttribute(\"class\", \"good-news\");\
     }else{\
        percent.innerHTML = negaPercent;\
        word.innerHTML = '负';\
        phrase.innerHTML = '简直无法忍受了！';\
        energy.setAttribute(\"class\", \"bad-ic\");\
        energyIcon.setAttribute(\"class\", \"bad-news\");\
     }\
     }\
\
    </script>\n\
</head>\n"];
    
    
    [html appendString:@"<body>\n"];
    
    if (thread.channelId == 110150) {  //当频道是微精选时,不显示头部部分

    } else {
        
        //标题第一行
//        BOOL ios7 = IOS7;
//        if(ios7) {
//            [html appendString:@"<div class=\"marRight10 marLeft10 marTop-10\" align=\"left\">\
//             <table width=\"100%\" height=\"5\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\
//             <tr>\
//             <td width=\"1163\" class=\"titleStyle\" align=\"left\">"];
//        } else {
            [html appendString:@"<div class=\"marRight10 marLeft10 marTop10\" align=\"left\">\
             <table width=\"100%\" height=\"5\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\
             <tr>\
             <td width=\"1163\" id=\"newsTitle\" class=\"titleStyle\" align=\"left\">"];
//        }

        
        [html appendString:thread.title];
        [html appendString:@"</td></tr></table>"];
        
        //标题第二行
        NSDateFormatter* df = [NSDateFormatter new];
        [df setDateFormat:@" yyyy-MM-dd H:mm"];
        if ([[FavsManager sharedInstance] isEnergyInTs:thread]) {
            [html appendFormat:
@"<table class=\"subTitleStyle\" cellspacing=\"0\">\
    <tr>\
       <td align=\"center\" width=\"12\" >\
         <img src=\"file://%@\" width=\"12\" height=\"12\" vspace=\"0\" border=\"0\" hspace=\"0\" />\
       </td>\
       <td id=\"newsTime\" width=\"100\" style=\"padding-left:8px;\">%@</td>\
       <td align=\"center\" width=\"12\" >\
        <img src=\"file://%@\" width=\"12\" height=\"12\" vspace=\"0\" border=\"0\" hspace=\"0\" />\
       </td>\
       <td id=\"newsSource\" width=\"80\" style=\"padding-left:8px;\">来源:%@</td>\
       <td align=\"center\" width=\"12\" >\
        <img src=\"file://%@\" width=\"20\" height=\"20\" vspace=\"0\" border=\"0\" hspace=\"0\" />\
    </td>\
  </tr>\
</table>\
             ",[PathUtil pathOfResourceNamed:@"newsTime.png"]
             ,[df stringFromDate:[NSDate dateWithTimeIntervalSince1970:thread.time/1000.0]],
             [PathUtil pathOfResourceNamed:@"newsResource.png"], thread.source,
             [self getEnergyInTs:thread]
             ];
            
            //红色分割线
            [html appendString:@"<hr color=#ce0000 size=1 /></div>"];
        }
        else{
            [html appendFormat: @"<table class=\"subTitleStyle\" cellspacing=\"0\">\
             <tr>\
             <td align=\"center\" width=12 >\
             <img src=\"file://%@\" width=12 height=12 vspace=0 border=0 hspace=0/>\
             </td>\
             <td id=\"newsTime\" width=100 style=\"padding-left:8px;\">%@</td>\
             <td align=\"center\" width=12 >\
             <img src=\"file://%@\" width=12 height=12 vspace=0 border=0 hspace=0/>\
             </td>\
             <td id=\"newsSource\" width=80 style=\"padding-left:8px;\">来源:%@</td>\
             </tr>\
             </table>\
             ",[PathUtil pathOfResourceNamed:@"newsTime.png"]
             ,[df stringFromDate:[NSDate dateWithTimeIntervalSince1970:thread.time/1000.0]],
             [PathUtil pathOfResourceNamed:@"newsResource.png"], thread.source];
            
            //红色分割线
            [html appendString:@"<hr color=#ce0000 size=1 /></div>"];
        }
        
    }

    [html appendString:@"<div id=\"contentDiv\" class=\"contentStyle\">"];
    [html appendString:content];
    [html appendString:@"</div>"];  //contentDiv
    
    
    // 正负能量
    if ([[FavsManager sharedInstance] isEnergyInTs:thread]){
        [html appendString:[self energyHTML:thread isNight:nightMode]];
    }
    
    
    // 活动 + 广告 + rss源推荐 放在一个div标签中 统一称活动标签
    [html appendString:@"<div class=\"activityDiv\">"];
    
    //rss源
    HotChannelRec *rec = [[RssSourceManager sharedInstance] getRandomRssDataWithChannelId:thread.channelId];
    thread.rssId = 0; // 恢复默认值
    if (rec.recimg && rec.recname &&
        thread.channelType == 0 &&
        thread.ctype == 0)
    {
        thread.rssId = rec.recid;
        
        // 检测某个频道是否被订阅
        BOOL isSubscribe = [[SubsChannelsManager sharedInstance] isChannelSubscribed:rec.recid];
        NSString *subscribStr = isSubscribe ? @"orderok" : @"orderbtn";
        NSString *rssClickStr = [NSString stringWithFormat:@"%@?recid=%ld&recname=%@&imgUrl=%@",RSS_Click_PREFIX,rec.recid,rec.recname,rec.recimg];
        NSString *rssSubscribe = [NSString stringWithFormat:@"%@?recid=%ld&recname=%@&imgUrl=%@",RSS_Subscribe_PREFIX,rec.recid,rec.recname,rec.recimg];
        
        [html appendFormat:@"\
         <div id='rss_container' class='orderBy'>\
             <div class='orderBy-box'>\
                 <a style='display:block;height:50px' onclick='javascript:window.open(\"%@\")'>\
                     <span class='sp-img' >\
                        <img id='rssIcon' src='%@'/>\
                     </span>\
                     <span class='sp-txt'>\
                        <em id='rssName' class='em-tit' style='overflow:hidden;text-overflow:ellipsis;'>%@</em>\
                        <em class='em-p'>点击查看</em>\
                     </span>\
                 </a>\
                 <a onclick='javascript:window.open(\"%@\")'>\
                     <span class='sp-state'>\
                        <em id='hasSubscribe' class='%@'></em>\
                     </span>\
                 </a>\
             </div>\
         </div>", rssClickStr, rec.recimg, rec.recname, rssSubscribe, subscribStr];

    }
    
    
    // 添加广告位
    // 2014.5.5 xuxg 添加广告位
    NSArray *adList = [[AdvertisementManager sharedInstance] getAdvertisementOfCoid:thread.channelId];
    if (adList!= nil && [adList count] > 0) {
        
/*
 <div style="margin:0px">
    <a style="margin-bottom:10px;padding-left:10px;font-size:15px;color:#87CEEB;">成人用儿童霜反而会伤皮肤</a><br>
    <a style="margin-bottom:10px;padding-left:10px;font-size:15px;color:#87CEEB;">最常见的诱发头痛的坏习惯</a><br>
    <p>
        <a style="display:block;width:300px;margin:0px 5px 0px 5px;">
            <img align ="center"/>
        </a>
    </p>
 </div>
 */
      
        NSString *text_a_style = @"margin-bottom:10px;padding-left:10px;font-size:15px;color:#87CEEB;";
        [html appendString:@"<div style='margin-top:10px'>"];
        
        for (int i=0; i<[adList count]; ++i) {
            AdvertisementInfo *adInfo = [adList objectAtIndex:i];
            if ([[adInfo type] isEqualToString:@"0"]) {
                // 文字新闻
                // a标签
                NSString *aOnclick = [NSString stringWithFormat:@"javascript:window.open('%@?newsUrl=%@')",Ad_Click_PREFIX, adInfo.newsUrl];
                [html appendFormat:@"<a onclick=\"%@\" style=\"%@\" >%@</a><br>",aOnclick, text_a_style,adInfo.title ];
            }
            else if ([[adInfo type] isEqualToString:@"1"]) {
                // 图片新闻
                // a标签
                NSString *aOnclick = [NSString stringWithFormat:@"javascript:window.open('%@?newsUrl=%@')",Ad_Click_PREFIX, adInfo.newsUrl];
                NSString *imgPath = [NSString stringWithFormat:@"file://%@",[PathUtil pathOfAdvertisementImage:adInfo]];
                [html appendFormat:@"<p><a style='display:block;width:300px;margin:0px 5px 0px 5px;' onclick=\"%@\"><img style='width:inherit' src=\"%@\"/></a></p>",aOnclick,imgPath];
            
            }
        }
        [html appendString:@"</div>"];
    }
    
    [html appendString:@"</div>"];
    
    
    [html appendString:@"<div class=\"marTop10\">\
                        <p align=\"center\" class=\"atitle\">"];
    
    //点击查看原文的图片
    [html appendString:@"<img style='margin-top:20px' onload='onViewSourceImgLoad()' onclick='javascript:window.open(\""SOURCE_URL_CLICK_PREFIX"\")' src='"];
    [html appendFormat:@"file://%@",[PathUtil pathOfResourceNamed:@"webview-view-source-url.png"]];
#ifdef ipad
    [html appendString:@"' width='536' height='54' />"];
    [html appendString:@"</p></div>\
     <p align=\"center\" class=\"copyright\">本文已由冲浪快讯转码以适应iPad客户端阅读</p>\
     </div>\n</div>\n\
     </body>\n\
     </html>"];
#else
    //TODO: iphone版的图片需要重新做
    [html appendString:@"' width='100' height='25' />"];
    [html appendString:@"</p></div>\
     <p align=\"center\" class=\"copyright marTop10\" style=\"margin-top:7px \">本文已由冲浪快讯转码以适应iPhone客户端阅读</p>\
     </div>\n</div>\n\
     </body>\n\
     </html>"];
#endif
   
    return html;
}

/**
 *  正能量HTML数据块
 *
 *  @param thread 帖子信息
 *  @param isN    夜间模式
 *
 *  @return HTML内容
 */
+ (NSString *)energyHTML:(ThreadSummary *)thread isNight:(BOOL)isN
{
    NSString *gbColor = isN ? @"black":@"#fff";
    NSMutableString *enHTML = [NSMutableString new];
    [enHTML appendString:@"\
<div id=\"power_layout\" class=\"power-padding\" style=\"display:none;\">\
     <div class=\"title-class\">\
        <h3 class=\"power-title\">新闻能量</h3>\
     </div>"];
    [enHTML appendFormat:@"\
     <section id=\"energyBg\" class=\"article-power\" style=\"background:%@\">", gbColor];
    [enHTML appendString:@"\
        <a onclick='javascript:window.open(\""SOURCE_URL_CLICK_ENERGY"\")'>\
            <div class=\"progress-area\">\
                <div id=\"proGoodId\" class=\"pro-good\" style=\"max-width:75%;min-width:25%; width:70%;\">\
                    <p class=\"txt\" style=\"margin:0px;\">\
                        <span>+</span>\
                        <span id=\"positiveEnergy\">20</span>\
                        <em class=\"good-news\">量</em>\
                    </p>\
                    <p id=\"positivePercent\" class=\"pro-bar\" style=\"margin:1px;\">25%</p>\
                </div>\
                <div id=\"proBadId\" class=\"pro-bad\" style=\"max-width:75%;min-width:25%;width:30%\">\
                    <p class=\"txt\" style=\"margin:0px;\">\
                        <em class=\"bad-news\">量</em>\
                        <span id=\"negativeEnergy\">199</span>\
                    </p>\
                    <p id=\"negativePercent\" class=\"pro-bar\" style=\"margin:1px;\">75%</p>\
                </div>\
            </div>\
            <div class=\"article-text\">\
                <p class=\"txt1\" style=\"margin:0px;\">\
                    <label id=\"percent\">75</label>%的人对这条新闻释放了\
                    <label id=\"word\">负</label>能量，\
                    <label id=\"phrase\" class=\"fred\">简直无法忍受了!</label>\
                </p>\
            </div>\
            <div class=\"article-link\">\
                <span>总计\
                    <label id=\"count\" class=\"fbig18\">20063</label>人点击了\
                    <em id=\"energy\" class=\"bad-ic\"> </em>\
                </span>\
                <label class=\"kx-link2\">我要表态</label>\
            </div>\
        </a>\
    </section>\
</div>"];
    return enHTML;
}

+ (NSString *)getEnergyInTs:(ThreadSummary *)thread{
    if (!thread) {
        return nil;
    }
    if ([[FavsManager sharedInstance] isEnergyInTs:thread]) {
        if ([[FavsManager sharedInstance] isPositive_energy:thread]) {
            return [PathUtil pathOfResourceNamed:@"positive_energy_News.png"];//
        }
        else {
            return [PathUtil pathOfResourceNamed:@"negative_energy_News.png"];
        }
    }
    
    return nil;
//[PathUtil pathOfResourceNamed:@"newsTime.png"]:[PathUtil pathOfResourceNamed:@"newsResource.png"]
}

#pragma mark - 手机报
+ (NSString*)generateWithNewsData:(PhoneNewsData*)thread andResolvedContent:(NSString*)content
{

    NSMutableString* html = [NSMutableString new];
    BOOL nightMode = [AppSettings boolForKey:BOOLKEY_NightMode];
    
    [html appendString:@"\
     <!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\
     <html xmlns=\"http://www.w3.org/1999/xhtml\">\n\
     <head>\n\
     <meta http-equiv=\"Content-Type\" content=\"application/vnd.wap.xhtml+xml;charset=utf-8\"/>\n\
     <meta name=\"viewport\" content=\"initial-scale=1.0,user-scalable=no, minimum-scale=1.0, maximum-scale=1.0\" />\n\
     <style type=\"text/css\">\n\
     body {\
     padding: 12px;\
     margin: 0px;\
     "];
    //    var fontFamily = AppSettings.GetString(AppSettings.StringReaderBodyFontFamily);
    //    if(fontFamily != AppSettings.ReaderBodyFontFamilyDefault)
    //    {
    //      sb.Append(@";font-family:");
    //      sb.Append(fontFamily);
    //    }
    [html appendString:@";\
     word-wrap: break-word;\
     overflow:auto;\
     overflow-x:hidden;\
     }\n\
     .marTop10 {\
     margin-top: 10px\
     }\n\
     .marLeft10 {\
     margin-left: 10px\
     }\n\
     .marRight10 {\
     margin-right: 10px\
     }\n\
     .titleStyle{\
     color: "];
    [html appendString:(nightMode ? NightTitleColor : DayTitleColor)];
    [html appendString:@";\
     font-size: 30px;\
     margin:10px 0px;\
     line-height:38px;\
     font-weight: bold\
     }\n\
     .subTitleStyle {\
     color: "];
    [html appendString:SoureFontColor];
    [html appendString:@";\
     font-size: 15px;\
     margin-top:0px;\
     }\n\
     .contentStyle{\
     margin-top:25px;\
     color:"];
    [html appendString:BodyFontColor];
    [html appendString:@";\
     font-size: "];
    [html appendFormat:@"%f",[AppSettings floatForKey:FLOATKEY_ReaderBodyFontSize]];
    [html appendString:@"px;"];
    [html appendString:@"line-height:"];
    [html appendFormat:@"%f",[AppSettings floatForKey:FLOATKEY_ReaderBodyFontSize] + 8];
    [html appendString:@"px;\
     }\n\
     .pStyle{\
     margin:24px 0px;\
     }\n\
     .copyrightStyle{\
     color: "];
    [html appendString:BodyFontColor];
    [html appendString:@";\
     font-size: 12px;\
     }\n\
     .originalLinkStyle {color:#6b6b6b"];
    [html appendString:@"; font-size: 18px; }\n\
     .imageBoxStyle{ float:right; width:200px; }\n\
     </style>\n\
     <script type=\"text/javascript\">\n\
     function getStyle(sname)\
     { for (var i = 0; i < document.styleSheets.length; i++) { var rules = document.styleSheets[i].rules; for (var j = 0; j < rules.length; j++) { if (rules[j].selectorText == sname) { return rules[j].style; } } } }\n\
     function setTitleFontColor(color)\
     {\
     var titleStyle = getStyle('.titleStyle');\
     titleStyle.color=color;\
     }\n\
     function setArticleFontSize(px)\
     {\
     var aStyle = getStyle('.contentStyle');\
     aStyle.fontSize = px + 'px';\
     aStyle.lineHeight = (parseInt(px) + 8) + 'px';\
     }\n\
     function setArticleFontFamily(font)\
     {\
     var aStyle = getStyle('.contentStyle');\
     aStyle.fontFamily = font;\
     }\n\
     function onImgClick()\
     {\
     var img = event.srcElement;\
     var width = img.width;\
     var height = img.height;\
     var imgOffset = getOffset(img);\
     window.open(\""IMAGE_CLICK_PREFIX"\"+ img.src\
     +'/&width=' + width +'&height=' + height +'&x='+ imgOffset.left +'&y='+ imgOffset.top+'');\
     }\n\
     function getOffset( el ) {\
     var _x = 0;\
     var _y = 0;\
     while( el && !isNaN( el.offsetLeft ) && !isNaN( el.offsetTop ) ) {\
     _x += el.offsetLeft - el.scrollLeft;\
     _y += el.offsetTop - el.scrollTop;\
     el = el.offsetParent;\
     }\
     return { top: _y, left: _x };\
     }\n\
     function imgOnLoad()\
     {\
     var img = event.srcElement;\
     if(img.width > 600)\
     {\
     var ratio = img.width / img.height;\
     img.width = 600;\
     img.height = 600 / ratio;\
     }\
     }\n\
     function setImgSrc(id,src)\
     {\
     var img = document.getElementById(id);\
     img.src = src;\
     }\n\
     function setContent(content)\
     {\
     var div = document.getElementById('contentDiv');\
     div.innerHTML = content;\
     }\n\
     function showReloadButton()\
     {\
     var div = document.getElementById('contentDiv');\
     div.innerHTML = \"<div id='reloadButton' class='marRight10 marLeft10 marTop10' ><br/><br/><img src='' onclick='javascript:window.open(\\\""RELOAD_CONTENT_CLICK_PREFIX"\\\")'/>  <br/><br/><br/>  </div>\";\
     }\n\
     function hideReloadButton()\
     {\
     var reloadButton = document.getElementById('reloadButton');\
     reloadButton.style.display = 'none';\
     }\n\
     </script>\n"];
    [html appendFormat:@"<link rel='stylesheet' type='text/css' href=\"file://%@\" charset='gb2312'/>",
        [[NSBundle mainBundle] pathForResource:[SurfHtmlGenerator phoneNewsStyle:content]
                                     ofType:@"css"]];
    
     [html appendFormat:@"</head>\n"];
    [html appendString:@"<body style='background-color: transparent'>\n"];
    
    [html appendString:@"<div class=\"marRight10 marLeft10 marTop10\" align=\"left\">\
     <table width=\"100%\" height=\"5\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\
     <tr>\
     <td width=\"1163\" class=\"titleStyle\" align=\"left\">"];
    [html appendString:thread.title];
    [html appendString:@"</td>\
     </tr>\
     </table>\
     <p align=\"left\" class=\"subTitleStyle\">"];
    NSDateFormatter* df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy/MM/dd H:mm:ss "];
    [html appendString:[df stringFromDate:[NSDate dateWithTimeIntervalSince1970:thread.datetime / 1000.0]]];
    [html appendFormat:@"手机报"];
    [html appendString:@"</p>\
     <!--p>&nbsp;</p-->\
     <div id=\"contentDiv\" class=\"contentStyle\">"];
    
    NSArray  * array= [content componentsSeparatedByString:@"body"];
    if ([array count]>1) {
        NSMutableString *bodyText = [NSMutableString stringWithFormat:@"%@",[array objectAtIndex:1]];
        if (bodyText.length >=1) {
            [bodyText deleteCharactersInRange:NSMakeRange(0, 1)];
        }
        content = bodyText;
    }
    if (content) {
        [html appendString:content];
    }
    [html appendString:@"</div>"];
    [html appendString:@"<p align=\"center\" class=\"copyrightStyle\">本文已由冲浪快讯转码以适应iPad客户端阅读</p>\
     </div>\n\
     <div id=\"zoomMeasuringDiv\"> </div>\n\
     <script type=\"text/javascript\" src=\"clyq_android_style.css\"></script>\
     </body>\n\
     </html>"];

    return html;
}
+(NSString *)phoneNewsStyle:(NSString *)content
{
    DJLog(@"%@",content);
    NSRange foundObj=[content rangeOfString:@"mms_android_style" options:NSCaseInsensitiveSearch];
    if(foundObj.length>0) {
        return @"mms_android_style";
    }
    
    foundObj=[content rangeOfString:@"phonenews_android_style" options:NSCaseInsensitiveSearch];
    if(foundObj.length>0) {
        return @"phonenews_android_style";
    }
    
    foundObj=[content rangeOfString:@"mms_style" options:NSCaseInsensitiveSearch];
    if(foundObj.length>0) {
        return @"mms_style";
    }
    
    foundObj=[content rangeOfString:@"clyq_android_style" options:NSCaseInsensitiveSearch];
    if(foundObj.length>0) {
        return @"clyq_android_style";
    }
    
    foundObj=[content rangeOfString:@"sms_style" options:NSCaseInsensitiveSearch];
    if(foundObj.length>0) {
        return @"sms_style";
    }
    return @"mms_android_style";    

}
//+ (NSString*)generateWithThread:(ThreadSummary*)thread andResolvedContentFilePath:(NSString*)path
//{
//    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    NSString* recommends = [XmlUtils recommendOfFirstNode:content];
//    return [self generateWithThread:thread andResolvedContent:content recommendContent:recommends];
//}




@end
