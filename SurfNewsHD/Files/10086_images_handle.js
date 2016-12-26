
/**
 *  给图片添加点击事件
 */
function setImageClickFunction() {
    var imgs = document.getElementsByTagName("img");
    var imgUrls = new Array();
    for (var i=0; i<imgs.length-2; i++) {
        
        var src = imgs[i].src;
        imgs[i].setAttribute("onClick", "getImg(src)");
        
        //        document.location = src;
        imgUrls[i] = src;
    }
    if (imgUrls.length > 0) { // 不加这个页面会加载错误
        document.location = "surf://imagearray:" + imgUrls;
    }
}

function getImg(src) {
    var url = src;
    // webView 请求的url
    document.location = "surf://imageurlclick:" + url;
}