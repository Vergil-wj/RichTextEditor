## RichTextEditor

iOS 13 之后不再支持 UIWebView,所以将之前一篇文章[iOS 富文本编辑器-UIWebView](https://www.jianshu.com/p/5efb2d8dc3da)中 UIWebView 替换为 WKWebView。以下为更换到 WKWebView 的一些知识点。

## 富文本编辑器设计的知识点

### Objective-C 语言调用 JavaScript 语言

通过WKWebView的 `- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;`的方法来实现的。这样我们就可以实现文字的加粗、下划线、斜体等等一切我们想要的样式。

详见我的项目中 [WKWebView+VJJSTool](https://github.com/Vergil-wj/RichTextEditor) 文件。

### JavaScript 语言调用 Objective-C 语言

第一步：我们需要在WKWebView创建的过程中初始化添加`ScriptMessageHandler`

```
WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *userController = [[WKUserContentController alloc] init];
        configuration.userContentController = userController;
        _mainWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, KMainWidth, KMainHeight) configuration:configuration];
        [userController addScriptMessageHandler:self name:@"currentCookies"];
```

然后实现代理方法.监听JS的回调.

```
//JS调用的OC回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    if ([message.name isEqualToString:@"jsMethod"]) {
        //
    }
}
```

然后在Html文件中添加点击方法.

```
<div id="button_div" onclick="buttonDivAction()">
      点击调用OC方法
</div>
```

紧接着.在js文件中实现点击事件.这时候要注意的是ScriptMessageHandler的名称要与上面定义的一致.

```
function buttonDivAction() {
    window.webkit.messageHandlers. jsMethod.postMessage({
        "body": "buttonActionMessage"
    });
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

### 去掉键盘自带的工具条

WKWebView+HackishAccessoryHiding.m

```
- (void)removeInputAccessoryViewFromWKWebView:(WKWebView *)webView {
    UIView *targetView;

    for (UIView *view in webView.scrollView.subviews) {
        if([[view.class description] hasPrefix:@"WKContent"]) {
            targetView = view;
        }
    }

    if (!targetView) {
        return;
    }

    NSString *noInputAccessoryViewClassName = [NSString stringWithFormat:@"%@_NoInputAccessoryView", targetView.class.superclass];
    Class newClass = NSClassFromString(noInputAccessoryViewClassName);

    if(newClass == nil) {
        newClass = objc_allocateClassPair(targetView.class, [noInputAccessoryViewClassName cStringUsingEncoding:NSASCIIStringEncoding], 0);
        if(!newClass) {
            return;
        }

        Method method = class_getInstanceMethod([self class], @selector(inputAccessoryView));

        class_addMethod(newClass, @selector(inputAccessoryView), method_getImplementation(method), method_getTypeEncoding(method));

        objc_registerClassPair(newClass);
    }

    object_setClass(targetView, newClass);
}

- (id)inputAccessoryView {
    return nil;
}
```

### 自动弹出键盘

实现和 UIWebView 中 keyboardDisplayRequiresUserAction 相同功能。即在 web 页面 focus 获得焦点状态下弹出键盘，UIWebView 中 keyboardDisplayRequiresUserAction 设置为 NO 就可以实现，但是WKWebView 中没有此属性，可以通过以下方式实现：

WKWebView+HackishAccessoryHiding.m

```
-(void)allowDisplayingKeyboardWithoutUserAction {
    Class class = NSClassFromString(@"WKContentView");
        NSOperatingSystemVersion iOS_11_3_0 = (NSOperatingSystemVersion){11, 3, 0};
        NSOperatingSystemVersion iOS_12_2_0 = (NSOperatingSystemVersion){12, 2, 0};
        NSOperatingSystemVersion iOS_13_0_0 = (NSOperatingSystemVersion){13, 0, 0};
        char * methodSignature = "_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:";

        if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_13_0_0]) {
            methodSignature = "_elementDidFocus:userIsInteracting:blurPreviousNode:activityStateChanges:userObject:";
        } else if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_12_2_0]) {
            methodSignature = "_elementDidFocus:userIsInteracting:blurPreviousNode:changingActivityState:userObject:";
        }

        if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_11_3_0]) {
            SEL selector = sel_getUid(methodSignature);
            Method method = class_getInstanceMethod(class, selector);
            IMP original = method_getImplementation(method);
            IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, BOOL arg3, id arg4) {
                ((void (*)(id, SEL, void*, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3, arg4);
            });
            method_setImplementation(method, override);
        } else {
            SEL selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:");
            Method method = class_getInstanceMethod(class, selector);
            IMP original = method_getImplementation(method);
            IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, id arg3) {
                ((void (*)(id, SEL, void*, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3);
            });
            method_setImplementation(method, override);
        }

}
```

详细代码请看项目 [https://github.com/Vergil-wj/RichTextEditor](https://github.com/Vergil-wj/RichTextEditor)

参考资料：

[ZSSRichTextEditor](https://github.com/nnhubbard/ZSSRichTextEditor)

[WGEditor](https://github.com/study123456/WGEditor-mobile)

[浅谈WKWebView使用、JS的交互](https://www.jianshu.com/p/48a34b20fcd1)



