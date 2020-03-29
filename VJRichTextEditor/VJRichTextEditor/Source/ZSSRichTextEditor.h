//
//  ZSSRichTextEditorViewController.h
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 11/30/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

/**
 *  The viewController used with ZSSRichTextEditor
 */
@interface ZSSRichTextEditor : UIViewController

typedef void (^callBack)(NSString *html);


/*
 *  WKWebView for writing/editing/displaying the content
 */
@property (nonatomic, strong) WKWebView *editorView;

/**
 *  If the HTML should be formatted to be pretty
 */
@property (nonatomic) BOOL formatHTML;


/**
 * If the sub class recieves text did change events or not
 */
@property (nonatomic) BOOL receiveEditorDidChangeEvents;

/**
 *  The placeholder text to use if there is no editor content
 */
@property (nonatomic, strong) NSString *placeholder;

/**
 *  Sets the HTML for the entire editor
 *
 *  @param html  HTML string to set for the editor
 *
 */
- (void)setHTML:(NSString *)html;

/**
 *  Returns the HTML from the Rich Text Editor
 *
 */
- (void)getHTML:(callBack)block;

/**
 *  Returns the plain text from the Rich Text Editor
 *
 */
- (void)getText:(callBack)block;

/**
 *  Inserts HTML at the caret position
 *
 *  @param html  HTML string to insert
 *
 */
- (void)insertHTML:(NSString *)html;


#pragma mark - vj edit

@property(nonatomic,assign)BOOL vj_hideHTMLTitle;
@property(nonatomic,assign)BOOL vj_hideHTMLAbstract;
@property(nonatomic,assign)BOOL vj_hideColumn;

- (void)vj_getHTMLTitle:(callBack)block;
- (void)vj_getHTMLAbstract:(callBack)block;
-(void)setColumnTextWithText:(NSString *)text;

@end


