
function getClass(tagName,className) //获得标签名为tagName,类名className的元素
{
    if(document.getElementsByClassName) //支持这个函数
    {        return document.getElementsByClassName(className);
    }
    else
    {       var tags=document.getElementsByTagName(tagName);//获取标签
        var tagArr=[];//用于返回类名为className的元素
        for(var i=0;i < tags.length; i++)
        {
            if(tags[i].class == className)
            {
                tagArr[tagArr.length] = tags[i];//保存满足条件的元素
            }
        }
        return tagArr;
    }
    
}


/**
 *  给图片添加点击事件
 */
function setImageClickFunction() {
    var imgUrls = new Array();
    var imgNodes = getClass("p", "pic");
    
    for (var i=0; i<imgNodes.length; i++) {
        var imgs = imgNodes[i].childNodes;
        for (var j=0; j<imgs.length; j++) {
            if (imgs[j].src !== undefined) {    // 有换行存在
                imgs[j].setAttribute("onClick", "getImg(src)");
                var url = imgs[j].src;
                imgUrls.push(url);
            }
        }
    }
    
    if (imgUrls.length > 0) {
        document.location = "surf://imagearray:" + imgUrls;
    }
}

function getImg(src) {
    var url = src;
    // webView 请求的url
    document.location = "surf://imageurlclick:" + url;
}