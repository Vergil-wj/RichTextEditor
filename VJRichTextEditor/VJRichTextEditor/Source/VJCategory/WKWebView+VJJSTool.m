//
//  WKWebView+VJJSTool.m
//  VJRichTextEditor
//
//  Created by 侯卫嘉 on 2019/9/29.
//  Copyright © 2019 vj. All rights reserved.
//

#import "WKWebView+VJJSTool.h"
#import "WKWebView+HackishAccessoryHiding.h"

@implementation WKWebView (VJJSTool)


#pragma mark - 设置 placeholder
- (void)setPlaceholderTextWith:(NSString *)text {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.setPlaceholder(\"%@\");", text];
    [self evaluateJavaScript:trigger completionHandler:nil];
}

#pragma mark 前进后退
//后退
-(void)undo{
    [self evaluateJavaScript:@"zss_editor.undo();" completionHandler:nil];
}

//前进
-(void)redo{
    [self evaluateJavaScript:@"zss_editor.redo();" completionHandler:nil];
}

#pragma mark - 插入连接
- (void)insertLink:(NSString *)url title:(NSString *)title {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertLink(\"%@\", \"%@\");", url, title];
    [self evaluateJavaScript:trigger completionHandler:nil];
}

- (void)updateLink:(NSString *)url title:(NSString *)title {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.updateLink(\"%@\", \"%@\");", url, title];
    [self evaluateJavaScript:trigger completionHandler:nil];
}

#pragma mark - 加粗
- (void)setBold {
    NSString *trigger = @"zss_editor.setBold();";
    [self evaluateJavaScript:trigger completionHandler:nil];
}

#pragma mark - 下划线
- (void)setUnderline {
    NSString *trigger = @"zss_editor.setUnderline();";
    [self evaluateJavaScript:trigger completionHandler:nil];
}

#pragma mark - 斜体
- (void)setItalic {
    NSString *trigger = @"zss_editor.setItalic();";
    [self evaluateJavaScript:trigger completionHandler:nil];
}
#pragma mark - 设置字体
- (void)heading2 {
    NSString *trigger = @"zss_editor.setHeading('h2');";
    [self evaluateJavaScript:trigger completionHandler:nil];
}

- (void)heading3 {
    NSString *trigger = @"zss_editor.setHeading('h3');";
    [self evaluateJavaScript:trigger completionHandler:nil];
}

- (void)heading4 {
    NSString *trigger = @"zss_editor.setHeading('h4');";
   [self evaluateJavaScript:trigger completionHandler:nil];
}

- (void)setFontSize:(NSString *)size{
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.setFontSize(\"%@\");", size];
    [self evaluateJavaScript:trigger completionHandler:nil];
}

#pragma mark - 对齐方式
- (void)alignLeft {
    NSString *trigger = @"zss_editor.setJustifyLeft();";
    [self evaluateJavaScript:trigger completionHandler:nil];
}

- (void)alignCenter {
    NSString *trigger = @"zss_editor.setJustifyCenter();";
    [self evaluateJavaScript:trigger completionHandler:nil];
}

- (void)alignRight {
    NSString *trigger = @"zss_editor.setJustifyRight();";
    [self evaluateJavaScript:trigger completionHandler:nil];
}

#pragma mark - 无序
- (void)setUnorderedList {
    NSString *trigger = @"zss_editor.setUnorderedList();";
    [self evaluateJavaScript:trigger completionHandler:nil];
}

#pragma mark - 缩进
- (void)setIndent {
    NSString *trigger = @"zss_editor.setIndent();";
    [self evaluateJavaScript:trigger completionHandler:nil];
}

- (void)setOutdent {
    NSString *trigger = @"zss_editor.setOutdent();";
    [self evaluateJavaScript:trigger completionHandler:nil];
}

#pragma mark 插入图片
///准备插入图片
-(void)prepareInsertImage{
    [self evaluateJavaScript:@"zss_editor.prepareInsert();" completionHandler:nil];
}

// 插入 url 图片
- (void)insertImage:(NSString *)url alt:(NSString *)alt{
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertImage(\"%@\", \"%@\");", url, alt];
    [self evaluateJavaScript:trigger completionHandler:nil];
}

//插入本地图片
- (void)insertImageBase64String:(NSString *)imageBase64String alt:(NSString *)alt {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertImageBase64String(\"%@\", \"%@\");", imageBase64String, alt];
    [self evaluateJavaScript:trigger completionHandler:nil];
}

#pragma mark - 聚焦内容
- (void)showKeyboardContent{

    [self allowDisplayingKeyboardWithoutUserAction];
    [self evaluateJavaScript:@"document.getElementById(\"zss_editor_content\").focus()" completionHandler:nil];
}

//退出键盘
- (void)hiddenKeyboard{
    [self evaluateJavaScript:@"document.activeElement.blur()" completionHandler:nil];
}


- (void)setContentHeight:(float)contentHeight {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.contentHeight = %f;", contentHeight];
    [self evaluateJavaScript:trigger completionHandler:nil];
}

- (void)focusTextEditor {
    NSLog(@">>>唤起键盘");
    [self allowDisplayingKeyboardWithoutUserAction];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.focusEditor();"];
    [self evaluateJavaScript:trigger completionHandler:nil];
}

- (void)blurTextEditor {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.blurEditor();"];
    [self evaluateJavaScript:trigger completionHandler:nil];
}

-(void)hideHTMLTitle{
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.vj_hideHTMLTitle();"];
    [self evaluateJavaScript:trigger completionHandler:nil];
}

-(void)hideHTMLAbstract{
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.vj_hideHTMLAbstract();"];
    [self evaluateJavaScript:trigger completionHandler:nil];
}

-(void)hideColumn{
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.vj_hideColumn();"];
    [self evaluateJavaScript:trigger completionHandler:nil];
}

- (void)vj_getHTMLTitle:(callBack)block {
    
    [self evaluateJavaScript:@"zss_editor.vj_getHTMLTitle();" completionHandler:^(id _Nullable html, NSError * _Nullable error) {
        block(html);
    }];
    
}

- (void)vj_getHTMLAbstract:(callBack)block {
    
    [self evaluateJavaScript:@"zss_editor.vj_getHTMLAbstract();" completionHandler:^(id _Nullable html, NSError * _Nullable error) {
        block(html);
    }];
}

-(void)setColumnTextWithText:(NSString *)text{
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.vj_setColumnContent(\"%@\");",text];
    [self evaluateJavaScript:trigger completionHandler:nil];
}

- (void)setFooterHeight:(float)footerHeight {
    
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.setFooterHeight(\"%f\");", footerHeight];
    [self evaluateJavaScript:trigger completionHandler:nil];
    
}

@end
