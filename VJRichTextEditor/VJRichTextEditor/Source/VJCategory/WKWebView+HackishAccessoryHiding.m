//
//  WKWebView+HackishAccessoryHiding.m
//  VJRichTextEditor
//
//  Created by 侯卫嘉 on 2019/9/29.
//  Copyright © 2019 vj. All rights reserved.
//

#import "WKWebView+HackishAccessoryHiding.h"
#import <objc/runtime.h>


@implementation WKWebView (HackishAccessoryHiding)

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


@end
