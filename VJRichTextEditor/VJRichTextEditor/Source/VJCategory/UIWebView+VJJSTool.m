//
//  UIWebView+VJJSTool.m
//  ZSSRichTextEditor
//
//  Created by 侯卫嘉 on 2019/6/19.
//  Copyright © 2019 Zed Said Studio. All rights reserved.
//

#import "UIWebView+VJJSTool.h"

@implementation UIWebView (VJJSTool)

#pragma mark - 设置 placeholder
- (void)setPlaceholderTextWith:(NSString *)text {
    NSString *js = [NSString stringWithFormat:@"zss_editor.setPlaceholder(\"%@\");", text];
    [self stringByEvaluatingJavaScriptFromString:js];
}

#pragma mark 前进后退
//后退
-(void)undo{
    [self stringByEvaluatingJavaScriptFromString:@"zss_editor.undo();"];
}

//前进
-(void)redo{
    [self stringByEvaluatingJavaScriptFromString:@"zss_editor.redo();"];
}

#pragma mark - 插入连接
- (void)insertLink:(NSString *)url title:(NSString *)title {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertLink(\"%@\", \"%@\");", url, title];
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)updateLink:(NSString *)url title:(NSString *)title {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.updateLink(\"%@\", \"%@\");", url, title];
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

#pragma mark - 加粗
- (void)setBold {
    NSString *trigger = @"zss_editor.setBold();";
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

#pragma mark - 下划线
- (void)setUnderline {
    NSString *trigger = @"zss_editor.setUnderline();";
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

#pragma mark - 斜体
- (void)setItalic {
    NSString *trigger = @"zss_editor.setItalic();";
    [self stringByEvaluatingJavaScriptFromString:trigger];
}
#pragma mark - 设置字体
- (void)heading2 {
    NSString *trigger = @"zss_editor.setHeading('h2');";
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading3 {
    NSString *trigger = @"zss_editor.setHeading('h3');";
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading4 {
    NSString *trigger = @"zss_editor.setHeading('h4');";
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setFontSize:(NSString *)size{
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.setFontSize(\"%@\");", size];
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

#pragma mark - 对齐方式
- (void)alignLeft {
    NSString *trigger = @"zss_editor.setJustifyLeft();";
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)alignCenter {
    NSString *trigger = @"zss_editor.setJustifyCenter();";
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)alignRight {
    NSString *trigger = @"zss_editor.setJustifyRight();";
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

#pragma mark - 无序
- (void)setUnorderedList {
    NSString *trigger = @"zss_editor.setUnorderedList();";
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

#pragma mark - 缩进
- (void)setIndent {
    NSString *trigger = @"zss_editor.setIndent();";
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setOutdent {
    NSString *trigger = @"zss_editor.setOutdent();";
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

#pragma mark 插入图片
///准备插入图片
-(void)prepareInsertImage{
    [self stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
}

// 插入 url 图片
- (void)insertImage:(NSString *)url alt:(NSString *)alt{
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertImage(\"%@\", \"%@\");", url, alt];
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

//插入本地图片
- (void)insertImageBase64String:(NSString *)imageBase64String alt:(NSString *)alt {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertImageBase64String(\"%@\", \"%@\");", imageBase64String, alt];
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

#pragma mark - 聚焦内容
- (void)showKeyboardContent{
    self.keyboardDisplayRequiresUserAction = NO;
    [self stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"zss_editor_content\").focus()"];
}

//退出键盘
- (void)hiddenKeyboard{
    [self stringByEvaluatingJavaScriptFromString:@"document.activeElement.blur()"];
}


- (void)setContentHeight:(float)contentHeight {
    NSString *js = [NSString stringWithFormat:@"zss_editor.contentHeight = %f;", contentHeight];
    [self stringByEvaluatingJavaScriptFromString:js];
}

- (void)focusTextEditor {
    self.keyboardDisplayRequiresUserAction = NO;
    NSString *js = [NSString stringWithFormat:@"zss_editor.focusEditor();"];
    [self stringByEvaluatingJavaScriptFromString:js];
}

- (void)blurTextEditor {
    NSString *js = [NSString stringWithFormat:@"zss_editor.blurEditor();"];
    [self stringByEvaluatingJavaScriptFromString:js];
}

-(void)hideHTMLTitle{
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.vj_hideHTMLTitle();"];
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

-(void)hideHTMLAbstract{
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.vj_hideHTMLAbstract();"];
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

-(void)hideColumn{
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.vj_hideColumn();"];
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

- (NSString *)vj_getHTMLTitle {
    NSString *html = [self stringByEvaluatingJavaScriptFromString:@"zss_editor.vj_getHTMLTitle();"];
    return html;
}

- (NSString *)vj_getHTMLAbstract {
    NSString *html = [self stringByEvaluatingJavaScriptFromString:@"zss_editor.vj_getHTMLAbstract();"];
    return html;
}

-(void)setColumnTextWithText:(NSString *)text{
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.vj_setColumnContent(\"%@\");",text];
    [self stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setFooterHeight:(float)footerHeight {
    
    //Call the setFooterHeight javascript method
    NSString *js = [NSString stringWithFormat:@"zss_editor.setFooterHeight(\"%f\");", footerHeight];
    [self stringByEvaluatingJavaScriptFromString:js];
    
}


@end
