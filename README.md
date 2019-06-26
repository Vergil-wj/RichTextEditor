# RichTextEditor
基于ZSSRichTextEditor，并参考WGEditor的UI,对其进行大量修改。

[ZSSRichTextEditor](https://github.com/nnhubbard/ZSSRichTextEditor) 是一款基于 webView 的富文本编辑器。由于项目需要，本着学习态度在[ZSSRichTextEditor](https://github.com/nnhubbard/ZSSRichTextEditor)基础上借用下这位同学的项目[WGEditor](https://github.com/study123456/WGEditor-mobile) 的 UI，进行了修改。我的项目地址：[https://github.com/Vergil-wj/RichTextEditor](https://github.com/Vergil-wj/RichTextEditor)

## 富文本编辑器设计的知识点

### Objective-C 语言调用 JavaScript 语言

通过UIWebView的 `- (nullable NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;`的方法来实现的。这样我们就可以实现文字的加粗、下划线、斜体等等一切我们想要的样式。

详见我的项目中 **UIWebView+VJJSTool.m** 文件。

### JavaScript语言调用Objective-C语言

两种方式，都是在 UIWebView 的 delegate 中操作；

第一种：拦截 URL

ZSSRichTextEditor.js：

```
if (artContent == document.activeElement) {
        window.location = "callback://0/"+items.join(',');
}
```

ZSSRichTextEditor.m：


```
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *urlString = [[request URL] absoluteString];
    NSLog(@"urlString = %@",urlString);
    
    [self handleEvent:urlString];
    
    return YES;
}
```

通过 url 判断，进行下一步操作。

第二种：点击网页按钮进行交互

导入系统库JavaScriptCore

```
#import <JavaScriptCore/JavaScriptCore.h>
```

editor.html:

```
<script>
    var div = document.getElementById('vj_column');
    div.addEventListener('click', test);
        
    function test(e) {
      方法名("栏目");
     }
</script>
```

ZSSRichTextEditor.m:

```
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    JSContext *ctx = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    ctx[@"方法名"] = ^() {
        //执行我们想要的操作 
    };
}
```

### 输入文字时，插入符号位置计算

ZSSRichTextEditor.js

```
zss_editor.updateOffset = function() {}

zss_editor.calculateEditorHeightWithCaretPosition = function() {}

```

### 新增标题与副标题

editor.html

```
<div id="vj_title">
     <input id="vj_article_title" maxlength="70" type="text" placeholder="请输入标题">
</div>
<div id="vj_abstract-title">
    <input id="vj_article_abstract" maxlength="35" type="text" placeholder="请输入文章摘要">
</div>
```

详细代码请看项目 [https://github.com/Vergil-wj/RichTextEditor](https://github.com/Vergil-wj/RichTextEditor)

参考资料：

[ZSSRichTextEditor](https://github.com/nnhubbard/ZSSRichTextEditor)

[WGEditor](https://github.com/study123456/WGEditor-mobile)





