/*!
 *
 * ZSSRichTextEditor v0.5.2
 * http://www.zedsaid.com
 *
 * Copyright 2014 Zed Said Studio LLC
 *
 */

var zss_editor = {};

// If we are using iOS or desktop
zss_editor.isUsingiOS = true;

// If the user is draging
zss_editor.isDragging = false;

// The current selection
zss_editor.currentSelection;

// The current editing image
zss_editor.currentEditingImage;

// The current editing link
zss_editor.currentEditingLink;

// The objects that are enabled
zss_editor.enabledItems = {};

// Height of content window, will be set by viewController
zss_editor.contentHeight = 244;

// Sets to true when extra footer gap shows and requires to hide
zss_editor.updateScrollOffset = false;


zss_editor.touchbegin = false;

/**
 * The initializer function that must be called onLoad
 */
zss_editor.init = function() {
    
    
    $('#zss_editor_content').on('touchend', function(e) {
        zss_editor.enabledEditingItems(e);
        //                                var clicked = $(e.target);
        //                                if (!clicked.hasClass('zs_active')) {
        //                                $('img').removeClass('zs_active');
        //                                }
    });
    
    $("#zss_editor_content").focus(function(){
        zss_editor.touchbegin = true;
    });
    
    $(document).on('selectionchange',function(e){
        zss_editor.calculateEditorHeightWithCaretPosition();
        //                   zss_editor.setScrollPosition();
        zss_editor.enabledEditingItems(e);
    });
    
    
    //    $(window).on('touchmove', function(e) {
    //                 zss_editor.isDragging = true;
    //                 zss_editor.updateScrollOffset = true;
    ////                 zss_editor.setScrollPosition();
    //                 zss_editor.enabledEditingItems(e);
    //                 });
    //    $(window).on('touchstart', function(e) {
    //                 zss_editor.isDragging = false;
    //                 });
    //    $(window).on('touchend', function(e) {
    //                 if (!zss_editor.isDragging && (e.target.id == "zss_editor_footer"||e.target.nodeName.toLowerCase() == "html")) {
    //                     zss_editor.calculateEditorHeightWithCaretPosition();
    //                 zss_editor.focusEditor();
    //                 }
    //                 });
    
}

zss_editor.calculateEditorHeightWithCaretPosition = function() {
    
    var artContent = document.getElementById('zss_editor_content');
    
    if (artContent == document.activeElement) {
        
        //行高
        var lineHeight = 28;
        
        //栏目\标题\摘要高度
        var col = document.getElementById("vj_column").offsetHeight;
        var tit = document.getElementById("vj_title").offsetHeight;
        var absTit = document.getElementById("vj_abstract-title").offsetHeight;
        var initHeight = col + tit + absTit;
        
        //光标位置为
        var c = zss_editor.getCaretYPosition()+initHeight+ lineHeight;
        
        //滚动条滚动距离,刚开为0;
        var offsetY;
        if (document.documentElement && document.documentElement.scrollTop) {
            offsetY = document.documentElement.scrollTop;
        } else if (document.body) {
            offsetY = document.body.scrollTop;
        }
        
        //返回文档在窗口垂直方向滚动的像素。
        //        var newPos = window.pageYOffset;
        
        //contentHeight
        var height = zss_editor.contentHeight;
        
        if(c >= height) { //光标位置 > contentHeight
            
            var a = offsetY + height - c;
            
            if(a>0 && a<lineHeight){
                var pos = c - height + lineHeight;
                window.scrollTo(0, pos);
            }else if(c >= offsetY + height){
                var pos = c - height + lineHeight;
                window.scrollTo(0, pos);
            }else{
                if(zss_editor.touchbegin == true){
                    
                    zss_editor.touchbegin = false;
                    
                    var pos = c - height + lineHeight;
                    window.scrollTo(0, pos);
                }
            }
            
        }
        
        
    }
}

// This will show up in the XCode console as we are able to push this into an NSLog.
zss_editor.debug = function(msg) {
    //    window.location = 'debug://'+msg;
}


zss_editor.setScrollPosition = function() {
    var position = window.pageYOffset;
    //    window.location = 'scroll://'+position;
}


zss_editor.setPlaceholder = function(placeholder) {
    
    var editor = $('#zss_editor_content');
    
    //set placeHolder
    editor.attr("placeholder",placeholder);
    
    //set focus
    editor.focusout(function(){
        var element = $(this);
        if (!element.text().trim().length) {
            element.empty();
        }
    });
    
}

zss_editor.setFooterHeight = function(footerHeight) {
    var footer = $('#zss_editor_footer');
    footer.height(footerHeight + 'px');
}

zss_editor.getCaretYPosition = function() {
    var sel = window.getSelection();
    // Next line is comented to prevent deselecting selection. It looks like work but if there are any issues will appear then uconmment it as well as code above.
    //sel.collapseToStart();
    var range = sel.getRangeAt(0);
    var span = document.createElement('span');// something happening here preventing selection of elements
    range.collapse(false);
    range.insertNode(span);
    var topPosition = span.offsetTop;
    span.parentNode.removeChild(span);
    return topPosition;
}



zss_editor.backuprange = function(){
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    
    zss_editor.currentSelection = {"startContainer": range.startContainer, "startOffset":range.startOffset,"endContainer":range.endContainer, "endOffset":range.endOffset};
}

zss_editor.testRange = function(){
    
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    
    return range.endOffset;
}


zss_editor.restorerange = function(){
    var selection = window.getSelection(); //光标所在位置
    selection.removeAllRanges(); //该方法用于将用户当前选取的所有内容设定为非选取状态
    var range = document.createRange();
    range.setStart(zss_editor.currentSelection.startContainer, zss_editor.currentSelection.startOffset);
    range.setEnd(zss_editor.currentSelection.endContainer, zss_editor.currentSelection.endOffset);
    selection.addRange(range);
}

zss_editor.getSelectedNode = function() {
    var node,selection;
    if (window.getSelection) {
        selection = getSelection();
        node = selection.anchorNode;
    }
    if (!node && document.selection) {
        selection = document.selection
        var range = selection.getRangeAt ? selection.getRangeAt(0) : selection.createRange();
        node = range.commonAncestorContainer ? range.commonAncestorContainer :
        range.parentElement ? range.parentElement() : range.item(0);
    }
    if (node) {
        return (node.nodeName == "#text" ? node.parentNode : node);
    }
};



zss_editor.setBold = function() {
    document.execCommand('bold', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setItalic = function() {
    document.execCommand('italic', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setSubscript = function() {
    document.execCommand('subscript', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setSuperscript = function() {
    document.execCommand('superscript', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setStrikeThrough = function() {
    document.execCommand('strikeThrough', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setUnderline = function() {
    document.execCommand('underline', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setBlockquote = function() {
    document.execCommand('formatBlock', false, '<blockquote>');
    zss_editor.enabledEditingItems();
}

zss_editor.removeFormating = function() {
    document.execCommand('removeFormat', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setHorizontalRule = function() {
    document.execCommand('insertHorizontalRule', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setFontSize = function(fontSize){
    document.execCommand("fontSize", false, fontSize);
    zss_editor.enabledEditingItems();
}

zss_editor.setHeading = function(heading) {
    var current_selection = $(zss_editor.getSelectedNode());
    var t = current_selection.prop("tagName").toLowerCase();
    var is_heading = (t == 'h1' || t == 'h2' || t == 'h3' || t == 'h4' || t == 'h5' || t == 'h6');
    if (is_heading && heading == t) {
        var c = current_selection.html();
        current_selection.replaceWith(c);
    } else {
        document.execCommand('formatBlock', false, '<'+heading+'>');
    }
    
    zss_editor.enabledEditingItems();
}

zss_editor.setParagraph = function() {
    var current_selection = $(zss_editor.getSelectedNode());
    var t = current_selection.prop("tagName").toLowerCase();
    var is_paragraph = (t == 'p');
    if (is_paragraph) {
        var c = current_selection.html();
        current_selection.replaceWith(c);
    } else {
        document.execCommand('formatBlock', false, '<p>');
    }
    
    zss_editor.enabledEditingItems();
}

// Need way to remove formatBlock
console.log('WARNING: We need a way to remove formatBlock items');

zss_editor.undo = function() {
    document.execCommand('undo', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.redo = function() {
    document.execCommand('redo', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setOrderedList = function() {
    document.execCommand('insertOrderedList', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setUnorderedList = function() {
    document.execCommand('insertUnorderedList', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setJustifyCenter = function() {
    document.execCommand('justifyCenter', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setJustifyFull = function() {
    document.execCommand('justifyFull', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setJustifyLeft = function() {
    document.execCommand('justifyLeft', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setJustifyRight = function() {
    document.execCommand('justifyRight', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setIndent = function() {
    document.execCommand('indent', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setOutdent = function() {
    document.execCommand('outdent', false, null);
    zss_editor.enabledEditingItems();
}

zss_editor.setFontFamily = function(fontFamily) {
    
    zss_editor.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand("fontName", false, fontFamily);
    document.execCommand("styleWithCSS", null, false);
    zss_editor.enabledEditingItems();
    
}

zss_editor.setTextColor = function(color) {
    
    zss_editor.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('foreColor', false, color);
    document.execCommand("styleWithCSS", null, false);
    zss_editor.enabledEditingItems();
    // document.execCommand("removeFormat", false, "foreColor"); // Removes just foreColor
    
}

zss_editor.setBackgroundColor = function(color) {
    zss_editor.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('hiliteColor', false, color);
    document.execCommand("styleWithCSS", null, false);
    zss_editor.enabledEditingItems();
}

// Needs addClass method

zss_editor.insertLink = function(url, title) {
    
    zss_editor.restorerange();
    var sel = document.getSelection();
    console.log(sel);
    if (sel.toString().length != 0) {
        if (sel.rangeCount) {
            
            var el = document.createElement("a");
            el.setAttribute("href", url);
            el.setAttribute("title", title);
            
            var range = sel.getRangeAt(0).cloneRange();
            range.surroundContents(el);
            sel.removeAllRanges();
            sel.addRange(range);
        }
    }
    else
    {
        document.execCommand("insertHTML",false,"<a href='"+url+"'>"+title+"</a>");
    }
    
    zss_editor.enabledEditingItems();
}

zss_editor.updateLink = function(url, title) {
    
    zss_editor.restorerange();
    
    if (zss_editor.currentEditingLink) {
        var c = zss_editor.currentEditingLink;
        c.attr('href', url);
        c.attr('title', title);
    }
    zss_editor.enabledEditingItems();
    
}//end

zss_editor.updateImage = function(url, alt) {
    
    zss_editor.restorerange();
    
    if (zss_editor.currentEditingImage) {
        var c = zss_editor.currentEditingImage;
        c.attr('src', url);
        c.attr('alt', alt);
    }
    zss_editor.enabledEditingItems();
    
}//end

zss_editor.updateImageBase64String = function(imageBase64String, alt) {
    
    zss_editor.restorerange();
    
    if (zss_editor.currentEditingImage) {
        var c = zss_editor.currentEditingImage;
        var src = 'data:image/jpeg;base64,' + imageBase64String;
        c.attr('src', src);
        c.attr('alt', alt);
    }
    zss_editor.enabledEditingItems();
    
}//end


zss_editor.unlink = function() {
    
    if (zss_editor.currentEditingLink) {
        var c = zss_editor.currentEditingLink;
        c.contents().unwrap();
    }
    zss_editor.enabledEditingItems();
}

zss_editor.quickLink = function() {
    
    var sel = document.getSelection();
    var link_url = "";
    var test = new String(sel);
    var mailregexp = new RegExp("^(.+)(\@)(.+)$", "gi");
    if (test.search(mailregexp) == -1) {
        checkhttplink = new RegExp("^http\:\/\/", "gi");
        if (test.search(checkhttplink) == -1) {
            checkanchorlink = new RegExp("^\#", "gi");
            if (test.search(checkanchorlink) == -1) {
                link_url = "http://" + sel;
            } else {
                link_url = sel;
            }
        } else {
            link_url = sel;
        }
    } else {
        checkmaillink = new RegExp("^mailto\:", "gi");
        if (test.search(checkmaillink) == -1) {
            link_url = "mailto:" + sel;
        } else {
            link_url = sel;
        }
    }
    
    var html_code = '<a href="' + link_url + '">' + sel + '</a>';
    zss_editor.insertHTML(html_code);
    
}

zss_editor.prepareInsert = function() {
    zss_editor.backuprange();
}

//先创建一个<span></span>标签
//延迟1s等待动态增加的标签<span>加入到DOM中,再向其中新增图片
//为什么不直接创建<img> 标签并指定src呢? 因为图片显示不出来,不知道什么原因
zss_editor.priInsertImage = function(){
    zss_editor.restorerange();
    var html = '<span id="imageSpan"></span>';
    zss_editor.insertHTML(html);
    zss_editor.enabledEditingItems();
}

//插入url图片
zss_editor.insertImage = function(url, alt) {
    var img = document.createElement('img');//创建一个标签
    img.setAttribute('src',url);//给标签定义src链接
    img.setAttribute('alt',alt);//给标签定义alt
    document.getElementById('imageSpan').appendChild(img);//放到指定的id里
    
    zss_editor.deletInsertImageSpan();//删除插入url图片时创建的<span></span>标签
}

//删除插入url图片时创建的<span></span>标签
zss_editor.deletInsertImageSpan = function(){
    var html = $('#imageSpan').html();
    $('#imageSpan').before(html);
    $('#imageSpan').remove();
}

zss_editor.insertImageBase64String = function(imageBase64String, alt) {
    zss_editor.restorerange();
    var html = '<img src="data:image/jpeg;base64,'+imageBase64String+'" alt="'+alt+'" />';
    zss_editor.insertHTML(html);
    zss_editor.enabledEditingItems();
}

zss_editor.setHTML = function(html) {
    var editor = $('#zss_editor_content');
    editor.html(html);
}

zss_editor.insertHTML = function(html) {
    document.execCommand('insertHTML', false, html);
    zss_editor.enabledEditingItems();
}



zss_editor.getHTML = function() {
    
    // Images
    var img = $('img');
    if (img.length != 0) {
        $('img').removeClass('zs_active');
        $('img').each(function(index, e) {
            var image = $(this);
            var zs_class = image.attr('class');
            if (typeof(zs_class) != "undefined") {
                if (zs_class == '') {
                    image.removeAttr('class');
                }
            }
        });
    }
    
    // Blockquote
    var bq = $('blockquote');
    if (bq.length != 0) {
        bq.each(function() {
            var b = $(this);
            if (b.css('border').indexOf('none') != -1) {
                b.css({'border': ''});
            }
            if (b.css('padding').indexOf('0px') != -1) {
                b.css({'padding': ''});
            }
        });
    }
    
    // Get the contents
    var h = document.getElementById("zss_editor_content").innerHTML;
    
    return h;
}

zss_editor.getText = function() {
    return $('#zss_editor_content').text();
}

zss_editor.isCommandEnabled = function(commandName) {
    return document.queryCommandState(commandName);
}

zss_editor.enabledEditingItems = function(e) {
    
    var items = [];
    
    var fontSizeblock = document.queryCommandValue('fontSize');
    if (fontSizeblock.length > 0) {
        items.push(fontSizeblock);
    }
    
    if (zss_editor.isCommandEnabled('bold')) {
        items.push('bold');
    }
    if (zss_editor.isCommandEnabled('italic')) {
        items.push('italic');
    }
    if (zss_editor.isCommandEnabled('subscript')) {
        items.push('subscript');
    }
    if (zss_editor.isCommandEnabled('superscript')) {
        items.push('superscript');
    }
    if (zss_editor.isCommandEnabled('strikeThrough')) {
        items.push('strikeThrough');
    }
    if (zss_editor.isCommandEnabled('underline')) {
        items.push('underline');
    }
    if (zss_editor.isCommandEnabled('insertOrderedList')) {
        items.push('orderedList');
    }
    if (zss_editor.isCommandEnabled('insertUnorderedList')) {
        items.push('unorderedList');
    }
    if (zss_editor.isCommandEnabled('justifyCenter')) {
        items.push('justifyCenter');
    }
    if (zss_editor.isCommandEnabled('justifyFull')) {
        items.push('justifyFull');
    }
    if (zss_editor.isCommandEnabled('justifyLeft')) {
        items.push('justifyLeft');
    }
    if (zss_editor.isCommandEnabled('justifyRight')) {
        items.push('justifyRight');
    }
    if (zss_editor.isCommandEnabled('insertHorizontalRule')) {
        items.push('horizontalRule');
    }
    var formatBlock = document.queryCommandValue('formatBlock');
    if (formatBlock.length > 0) {
        items.push(formatBlock);
    }
    // Images
    //    $('img').bind('touchstart', function(e) {
    //                  $('img').removeClass('zs_active');
    //                  $(this).addClass('zs_active');
    //                  });
    
    // Use jQuery to figure out those that are not supported
    if (typeof(e) != "undefined") {
        
        // The target element
        var s = zss_editor.getSelectedNode();
        var t = $(s);
        var nodeName = e.target.nodeName.toLowerCase();
        
        // Background Color
        var bgColor = t.css('backgroundColor');
        if (bgColor.length != 0 && bgColor != 'rgba(0, 0, 0, 0)' && bgColor != 'rgb(0, 0, 0)' && bgColor != 'transparent') {
            items.push('backgroundColor');
        }
        // Text Color
        var textColor = t.css('color');
        if (textColor.length != 0 && textColor != 'rgba(0, 0, 0, 0)' && textColor != 'rgb(0, 0, 0)' && textColor != 'transparent') {
            items.push('textColor');
        }
        
        //Fonts
        var font = t.css('font-family');
        if (font.length != 0 && font != 'Arial, Helvetica, sans-serif') {
            items.push('fonts');
        }
        
        // Link
        if (nodeName == 'a') {
            zss_editor.currentEditingLink = t;
            var title = t.attr('title');
            items.push('link:'+t.attr('href'));
            if (t.attr('title') !== undefined) {
                items.push('link-title:'+t.attr('title'));
            }
            
        } else {
            zss_editor.currentEditingLink = null;
        }
        // Blockquote
        if (nodeName == 'blockquote') {
            items.push('indent');
        }
        // Image
        if (nodeName == 'img') {
            zss_editor.currentEditingImage = t;
            items.push('image:'+t.attr('src'));
            if (t.attr('alt') !== undefined) {
                items.push('image-alt:'+t.attr('alt'));
            }
            
        } else {
            zss_editor.currentEditingImage = null;
        }
        
    }
    
    
    
    var arttitle = document.getElementById('vj_article_title');
    var artAbsTitle = document.getElementById('vj_article_abstract');
    var artContent = document.getElementById('zss_editor_content');
    
    if (arttitle == document.activeElement) {
        window.location = "state-title://"+items.join(',');
    }
    
    if (artAbsTitle == document.activeElement) {
        window.location = "state-abstract-title://"+items.join(',');
    }
    
    if (artContent == document.activeElement) {
        window.location = "callback://0/"+items.join(',');
    }
    
}

zss_editor.focusEditor = function() {
    
    var editor = $('#zss_editor_content');
    var range = document.createRange();
    range.selectNodeContents(editor.get(0));
    range.collapse(false);
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    editor.focus();
}

zss_editor.blurEditor = function() {
    $('#zss_editor_content').blur();
}

zss_editor.setCustomCSS = function(customCSS) {
    
    document.getElementsByTagName('style')[0].innerHTML=customCSS;
    
    //set focus
    /*editor.focusout(function(){
     var element = $(this);
     if (!element.text().trim().length) {
     element.empty();
     }
     });*/
    
    
    
}

// vj edit
zss_editor.vj_getHTMLTitle = function() {
    var h = document.getElementById("vj_article_title").value;
    return h;
}

zss_editor.vj_getHTMLAbstract = function() {
    var h = document.getElementById("vj_article_abstract").value;
    return h;
}

zss_editor.vj_hideHTMLTitle = function() {
    document.getElementById("vj_title").style.display="none";
}

zss_editor.vj_hideHTMLAbstract = function() {
    document.getElementById("vj_abstract-title").style.display="none";
}

zss_editor.vj_hideColumn = function() {
    document.getElementById("vj_column").style.display="none";
}

zss_editor.vj_setColumnContent = function(text) {
    var editor = $('#vj_column_content');
    editor.text(text);
}






//end
