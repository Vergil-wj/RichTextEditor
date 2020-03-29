//
//  WKWebView+HackishAccessoryHiding.h
//  VJRichTextEditor
//
//  Created by 侯卫嘉 on 2019/9/29.
//  Copyright © 2019 vj. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (HackishAccessoryHiding)

/**
 去掉键盘自带的工具条
 */
@property (nonatomic, assign) BOOL hidesInputAccessoryView;

/**
 web页面获取焦点时弹出键盘
 */
-(void)allowDisplayingKeyboardWithoutUserAction;

@end

NS_ASSUME_NONNULL_END
