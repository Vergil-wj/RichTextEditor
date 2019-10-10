//
//  WKWebView+VJJSTool.h
//  VJRichTextEditor
//
//  Created by 侯卫嘉 on 2019/9/29.
//  Copyright © 2019 vj. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (VJJSTool)

typedef void (^callBack)(NSString *html);

///设置 placeholder
- (void)setPlaceholderTextWith:(NSString *)text;

///后退
- (void)undo;
///前进
- (void)redo;

///插入链接
- (void)insertLink:(NSString *)url title:(NSString *)title;
///跟新链接
- (void)updateLink:(NSString *)url title:(NSString *)title;
///加粗
- (void)setBold;
///下划线
- (void)setUnderline;
///斜体
- (void)setItalic;

///设置字体
- (void)heading2;

- (void)heading3;

- (void)heading4;

- (void)setFontSize:(NSString *)size;

///对齐方式
- (void)alignLeft;

- (void)alignCenter;

- (void)alignRight;

///无序
- (void)setUnorderedList;

///缩进
- (void)setIndent;

- (void)setOutdent;


///准备插入图片
-(void)prepareInsertImage;
///插入 url 图片
- (void)insertImage:(NSString *)url alt:(NSString *)alt;
///插入本地图片
- (void)insertImageBase64String:(NSString *)imageBase64String alt:(NSString *)alt;

///聚焦内容
- (void)showKeyboardContent;
///退出键盘
- (void)hiddenKeyboard;

- (void)setContentHeight:(float)contentHeight;

- (void)focusTextEditor;
- (void)blurTextEditor;

-(void)hideHTMLTitle;

-(void)hideHTMLAbstract;

-(void)hideColumn;

- (void)vj_getHTMLTitle:(callBack)block;

- (void)vj_getHTMLAbstract:(callBack)block;

-(void)setColumnTextWithText:(NSString *)text;

- (void)setFooterHeight:(float)footerHeight;

@end

NS_ASSUME_NONNULL_END
