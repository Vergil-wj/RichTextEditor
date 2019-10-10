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

- (void)removeInputAccessoryViewFromWKWebView:(WKWebView *)webView;

-(void)allowDisplayingKeyboardWithoutUserAction;

@end

NS_ASSUME_NONNULL_END
