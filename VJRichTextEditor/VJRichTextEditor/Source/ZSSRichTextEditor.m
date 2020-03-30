//
//  ZSSRichTextEditorViewController.m
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 11/30/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//


#import "ZSSRichTextEditor.h"
#import "KWEditorBar.h"
#import "KWFontStyleBar.h"
#import "WKWebView+VJJSTool.h"
#import "WKWebView+HackishAccessoryHiding.h"
#import "NSString+VJUUID.h"


#define pDeviceWidth [UIScreen mainScreen].bounds.size.width
#define pDeviceHeight [UIScreen mainScreen].bounds.size.height
//状态栏高度
#define pStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
//导航栏高度
#define pNavigationHeight self.navigationController.navigationBar.frame.size.height
//tabbar 高度
#define pTabbarHeight self.tabBarController.tabBar.frame.size.height

#define COLOR(r,g,b,a) ([UIColor colorWithRed:(float)r/255.f green:(float)g/255.f blue:(float)b/255.f alpha:a])

@import JavaScriptCore;


@interface ZSSRichTextEditor ()<KWEditorBarDelegate,KWFontStyleBarDelegate,WKNavigationDelegate,WKUIDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,WKScriptMessageHandler>

/*
 *  BOOL for holding if the resources are loaded or not
 */
@property (nonatomic) BOOL resourcesLoaded;

/*
 *  Alert View used when inserting links/images
 */
@property (nonatomic, strong) UIAlertView *alertView;

/*
 *  NSString holding the html
 */
@property (nonatomic, strong) NSString *internalHTML;


/*
 *  BOOL for if the editor is loaded or not
 */
@property (nonatomic) BOOL editorLoaded;

/*
 *  Image Picker for selecting photos from users photo library
 */
@property (nonatomic, strong) UIImagePickerController *imagePicker;

/*
 *  Method for getting a version of the html without quotes
 */
- (NSString *)removeQuotesFromHTML:(NSString *)html;

/*
 *  Method for getting a tidied version of the html
 */
- (void)tidyHTML:(NSString *)html complete:(callBack)block;

@property (nonatomic,strong) KWEditorBar *toolBarView;
@property (nonatomic,strong) KWFontStyleBar *fontBar;

@property(nonatomic,copy)NSString *vj_columnText;


@end

/*
 
 ZSSRichTextEditor
 
 */
@implementation ZSSRichTextEditor

#pragma mark - liftcycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.formatHTML = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self initConfig];
    
    [self addNotification];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.editorView.configuration.userContentController addScriptMessageHandler:self name:@"column"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self.editorView.configuration.userContentController removeScriptMessageHandlerForName:@"column"];
    
}


-(void)dealloc{
    [self removeNotification];
    
    @try {
        [self.toolBarView removeObserver:self forKeyPath:@"transform"];
    } @catch (NSException *exception)
    {
        NSLog(@"Exception: %@", exception);
    } @finally {
        // Added to show finally works as well
    }
}

#pragma mark -editorbarDelegate
- (void)editorBar:(KWEditorBar *)editorBar didClickIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{//键盘唤醒与隐藏
            if (self.toolBarView.transform.ty < 0) {
                [self.editorView hiddenKeyboard];
            }else{
                [self.editorView focusTextEditor];
            }
        }
            break;
        case 1:{//后退
            [self.editorView undo];
        }
            break;
        case 2:{//前进
            [self.editorView redo];
        }
            break;
        case 3:{//字体
            editorBar.fontButton.selected = !editorBar.fontButton.selected;
            if (editorBar.fontButton.selected) {
                [self.view addSubview:self.fontBar];
            }else{
                [self.fontBar removeFromSuperview];
            }
        }
            break;
        case 4:{//超连接
            [self insertLink];
        }
            break;
        case 5:{//图片
            [self insertImage];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - fontbardelegate
- (void)fontBar:(KWFontStyleBar *)fontBar didClickBtn:(UIButton *)button{
    if (self.toolBarView.transform.ty>=0) {
        [self.editorView showKeyboardContent];
    }
    switch (button.tag) {
        case 0:{
            //粗体
            [self.editorView setBold];
        }
            break;
        case 1:{//下划线
            [self.editorView setUnderline];
        }
            break;
        case 2:{//斜体
            [self.editorView setItalic];
        }
            break;
        case 3:{//14号字体
            [self.editorView setFontSize:@"2"];
        }
            break;
        case 4:{//16号字体
            [self.editorView setFontSize:@"3"];
        }
            break;
        case 5:{//18号字体
            [self.editorView setFontSize:@"4"];
        }
            break;
        case 6:{//左对齐
            [self.editorView alignLeft];
        }
            break;
        case 7:{//居中对齐
            [self.editorView alignCenter];
        }
            break;
        case 8:{//右对齐
            [self.editorView alignRight];
        }
            break;
        case 9:{//无序
            [self.editorView setUnorderedList];
        }
            break;
        case 10:{
            //缩进
            button.selected = !button.selected;
            if (button.selected) {
                [self.editorView setIndent];
            }else{
                [self.editorView setOutdent];
            }
        }
            break;
        case 11:{
            
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - KWFontStyleBarDelegate
- (void)fontBarResetNormalFontSize{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.editorView setFontSize:@"3"];
    });
}

#pragma mark - notification
-(void)addNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter]removeObserver:self];;
}

#pragma mark - keyboard
- (void)keyBoardWillChangeFrame:(NSNotification*)notification{
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];    
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if (frame.origin.y == pDeviceHeight) {
        
        [UIView animateWithDuration:duration animations:^{
            self.toolBarView.transform =  CGAffineTransformIdentity;
            self.toolBarView.keyboardButton.selected = NO;
            
            static int a = 0;
            if (a != 0) {
                [self.editorView hiddenKeyboard];
            }
            a++;
            
        }];
    }else{
        
        float height = pDeviceHeight-pStatusBarHeight-pNavigationHeight-self.toolBarView.frame.size.height-frame.size.height;
        [self.editorView setContentHeight: height];
        
        
        
        [UIView animateWithDuration:duration animations:^{
            self.toolBarView.transform = CGAffineTransformMakeTranslation(0, -frame.size.height);
            self.toolBarView.keyboardButton.selected = YES;
        }];
    }
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{

    if([keyPath isEqualToString:@"transform"]){
        
        CGRect fontBarFrame = self.fontBar.frame;
        fontBarFrame.origin.y = CGRectGetMaxY(self.toolBarView.frame)- KWFontBar_Height - KWEditorBar_Height;
        self.fontBar.frame = fontBarFrame;
    }else if([keyPath isEqualToString:@"URL"]){
        NSString *urlString = self.editorView.URL.absoluteString;
        NSLog(@"URL------%@",urlString);
        [self handleEvent:urlString];
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//处理键盘工具条显示与隐藏
- (void)handleEvent:(NSString *)urlString{
    
    if ([urlString hasPrefix:@"state-title://"] || [urlString hasPrefix:@"state-abstract-title://"]) {
        self.fontBar.hidden = YES;
        self.toolBarView.hidden = YES;
    }else if([urlString rangeOfString:@"callback://0/"].location != NSNotFound){
        self.fontBar.hidden = NO;
        self.toolBarView.hidden = NO;
        //更新 toolbar
        NSString *className = [urlString stringByReplacingOccurrencesOfString:@"callback://0/" withString:@""];
        [self.fontBar updateFontBarWithButtonName:className];
    }
    
}

#pragma mark - Editor Interaction

- (void)setPlaceholderText {
    if (self.placeholder != NULL && [self.placeholder length] != 0) {
        [self.editorView setPlaceholderTextWith:self.placeholder];
    }
}

- (void)setHTML:(NSString *)html {
    
    self.internalHTML = html;
    
    if (self.editorLoaded) {
        [self updateHTML];
    }
    
}

- (void)updateHTML {
    NSString *html = self.internalHTML;
    //    self.sourceView.text = html;
    NSString *cleanedHTML = [self removeQuotesFromHTML:html];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.setHTML(\"%@\");", cleanedHTML];
    [self.editorView evaluateJavaScript:trigger completionHandler:nil];

}

- (void)getHTML:(callBack)block {
    
    [self.editorView evaluateJavaScript:@"zss_editor.getHTML();" completionHandler:^(id _Nullable html, NSError * _Nullable error) {
        
        
        if (error != NULL) {
            NSLog(@"HTML Parsing Error: %@", error);
        }
               
        
        html = [self removeQuotesFromHTML:html];
        
        [self tidyHTML:html complete:^(NSString *html) {
            block(html);
        }];
        
    }];
    
}

- (void)insertHTML:(NSString *)html {
    
    NSString *cleanedHTML = [self removeQuotesFromHTML:html];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertHTML(\"%@\");", cleanedHTML];
    [self.editorView evaluateJavaScript:trigger completionHandler:nil];
}

- (void)getText:(callBack)block {
    
    [self.editorView evaluateJavaScript:@"zss_editor.getText();" completionHandler:^(id _Nullable html, NSError * _Nullable error) {
        
        block(html);
    }];
    }

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)removeFormat {
    NSString *trigger = @"zss_editor.removeFormating();";
    [self.editorView evaluateJavaScript:trigger completionHandler:nil];
}


#pragma mark - 插入链接
- (void)insertLink {
    
    if (self.toolBarView.transform.ty >= 0) {
        [self.editorView focusTextEditor];
    }
    [self.editorView prepareInsertImage];
    [self showInsertLinkDialogWithLink:nil title:nil];
}


- (void)showInsertLinkDialogWithLink:(NSString *)url title:(NSString *)title {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"插入链接" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"URL (必填)";
        if (url) {
            textField.text = url;
        }
        textField.rightViewMode = UITextFieldViewModeAlways;
        textField.clearButtonMode = UITextFieldViewModeAlways;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"名称";
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.secureTextEntry = NO;
        if (title) {
            textField.text = title;
        }
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UITextField *linkURL = [alertController.textFields objectAtIndex:0];
        UITextField *title = [alertController.textFields objectAtIndex:1];
        [self.editorView insertLink:linkURL.text title:title.text];
        
//      [self.editorView focusTextEditor];
    }]];
    [self presentViewController:alertController animated:YES completion:NULL];
    
}

#pragma mark - 插入图片

-(void)insertImage{
    
    
    [self.editorView prepareInsertImage];
    
    
    UIAlertController *con = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *device = [UIAlertAction actionWithTitle:@"本地相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self insertImageFromDevice];
        }];
    }];
    UIAlertAction *url = [UIAlertAction actionWithTitle:@"网络相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self insertImageFromUrl];
        }];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [con addAction:device];
    [con addAction:url];
    [con addAction:cancel];
    [self presentViewController:con animated:YES completion:nil];
    
}

- (void)insertImageFromDevice {
    
    [self setUpImagePicker];
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

-(void)insertImageFromUrl{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"插入图片链接" message:nil preferredStyle:UIAlertControllerStyleAlert];
       
       [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
           textField.placeholder = @"URL (必填)";
           textField.rightViewMode = UITextFieldViewModeAlways;
           textField.clearButtonMode = UITextFieldViewModeAlways;
       }];
       [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
           textField.placeholder = @"名称";
           textField.clearButtonMode = UITextFieldViewModeAlways;
           textField.secureTextEntry = NO;
       }];
       
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UITextField *linkURL = [alertController.textFields objectAtIndex:0];
        UITextField *title = [alertController.textFields objectAtIndex:1];
        
        
        
        if (self.toolBarView.transform.ty >= 0) {
            [self.editorView focusTextEditor];
        }
        
        [self.editorView prepareInsertImage];
        [self.editorView insertImage:linkURL.text alt:title.text];
        
    }]];
    [self presentViewController:alertController animated:YES completion:NULL];
    
    
}

- (void)updateImage:(NSString *)url alt:(NSString *)alt {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.updateImage(\"%@\", \"%@\");", url, alt];
    [self.editorView evaluateJavaScript:trigger completionHandler:nil];
}

#pragma mark - Image Picker Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info{
    
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage]?:info[UIImagePickerControllerOriginalImage];
    
    //Scale the image
    CGSize targetSize = CGSizeMake(selectedImage.size.width * 0.5, selectedImage.size.height * 0.5);
    UIGraphicsBeginImageContext(targetSize);
    [selectedImage drawInRect:CGRectMake(0,0,targetSize.width,targetSize.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *scaledImageData = UIImageJPEGRepresentation(scaledImage, 0.8);
    
    //Encode the image data as a base64 string
    NSString *imageBase64String = [scaledImageData base64EncodedStringWithOptions:0];
    
    if (self.toolBarView.transform.ty >= 0) {
        [self.editorView focusTextEditor];
    }
    
    [self.editorView prepareInsertImage];
    [self.editorView insertImageBase64String:imageBase64String alt:@""];
//    [Utils showGlobleHud:nil];
//    [NetworkRequest mediaUploadImage:selectedImage complete:^(NSDictionary *resp, NSError *err) {
//        [Utils hideGlobleHud];
//        if (err) {
//            return ;
//        }
//        
//        if (resp[@"url"]) {
//            [self insertImage:resp[@"url"] alt:nil];
//            [self.editorView focusTextEditor];
//        }
//        
//    }];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{

    decisionHandler(WKNavigationActionPolicyAllow);
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    
    
    self.editorLoaded = YES;

    if (!self.internalHTML) {
        self.internalHTML = @"";
    }
    [self updateHTML];
    
    if(self.placeholder) {
        [self setPlaceholderText];
    }
    
    
    if (self.vj_columnText) {
        [self setColumnTextWithText:self.vj_columnText];
    }
    
    if (self.vj_hideHTMLTitle) {
        [self.editorView hideHTMLTitle];
    }
    
    if (self.vj_hideHTMLAbstract) {
        [self.editorView hideHTMLAbstract];
    }
    
    if (self.vj_hideColumn) {
        [self.editorView hideColumn];
    }


}

#pragma mark - WKUIDelegate
// 显示一个按钮。点击后调用completionHandler回调
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        completionHandler();
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 显示两个按钮，通过completionHandler回调判断用户点击的确定还是取消按钮
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

// 显示一个带有输入框和一个确定按钮的，通过completionHandler回调用户输入的内容
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler(alertController.textFields.lastObject.text);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    NSLog(@"name  = %@",message.name);
    //在这里截取H5调用的本地方法
    if ([message.name isEqualToString:@"column"]){
        [self didSelectedColumn];
    }
}

-(void)didSelectedColumn{
    //需要重写
}

#pragma mark - methods

- (NSString *)removeQuotesFromHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"“" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"”" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];
    return html;
}


- (void)tidyHTML:(NSString *)html complete:(callBack)block{
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@"<br />"];
    html = [html stringByReplacingOccurrencesOfString:@"<hr>" withString:@"<hr />"];
    if (self.formatHTML) {
        NSString *str = [NSString stringWithFormat:@"style_html(\"%@\");", html];
        [self.editorView evaluateJavaScript:str completionHandler:^(id _Nullable returnHtml, NSError * _Nullable error) {
            
            block(returnHtml);
            
        }];
        
        
    }
}

- (NSString *)stringByDecodingURLFormat:(NSString *)string {
    NSString *result = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

#pragma mark - vj edit
- (void)vj_getHTMLTitle:(callBack)block {
    
    [self.editorView vj_getHTMLTitle:^(NSString * _Nonnull html) {
        block(html);
    }];
}

- (void)vj_getHTMLAbstract:(callBack)block{
    return [self.editorView vj_getHTMLAbstract:^(NSString * _Nonnull html) {
        block(html);
    }];
}

-(void)setColumnTextWithText:(NSString *)text{
    self.vj_columnText = text;
    [self.editorView setColumnTextWithText:text];
}


#pragma mark - setter

-(void)initConfig{
    
    [self.view addSubview:self.editorView];
    
    //Load Resources
    if (!self.resourcesLoaded) {
        [self loadResources];
    }
    
    [self.view addSubview:self.toolBarView];
    self.toolBarView.delegate = self;
    [self.toolBarView addObserver:self forKeyPath:@"transform" options:
     NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
}

-(WKWebView *)editorView{
    if (!_editorView) {
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
        WKUserContentController *userCon = [[WKUserContentController alloc]init];
        config.userContentController = userCon;
        _editorView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, pDeviceWidth, self.view.frame.size.height-KWEditorBar_Height) configuration:config];
        [userCon addScriptMessageHandler:self name:@"column"];
        _editorView.navigationDelegate = self;
        _editorView.UIDelegate = self;
        _editorView.hidesInputAccessoryView = YES;
        _editorView.scrollView.bounces = NO;
        _editorView.backgroundColor = [UIColor whiteColor];
        [_editorView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];

    }
    return _editorView;
}

- (KWEditorBar *)toolBarView{
    if (!_toolBarView) {
        _toolBarView = [KWEditorBar editorBar];
        _toolBarView.frame = CGRectMake(0,self.view.frame.size.height - KWEditorBar_Height, self.view.frame.size.width, KWEditorBar_Height);
        _toolBarView.backgroundColor = COLOR(237, 237, 237, 1);
    }
    return _toolBarView;
}

- (KWFontStyleBar *)fontBar{
    if (!_fontBar) {
        _fontBar = [[KWFontStyleBar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.toolBarView.frame) - KWFontBar_Height - KWEditorBar_Height, self.view.frame.size.width, KWFontBar_Height)];
        _fontBar.delegate = self;
        [_fontBar.heading2Item setSelected:YES];
        
    }
    return _fontBar;
}

#pragma mark 图片选择器

- (void)setUpImagePicker {
    
    if (!self.imagePicker) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//        self.imagePicker.allowsEditing = YES;
    }
    
}

- (void)loadResources {
    
    //Create a string with the contents of editor.html
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"editor" ofType:@"html"];
    NSData *htmlData = [NSData dataWithContentsOfFile:filePath];
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    
    //Add jQuery.js to the html file
    NSString *jquery = [[NSBundle mainBundle] pathForResource:@"jQuery" ofType:@"js"];
    NSString *jqueryString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:jquery] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!-- jQuery -->" withString:jqueryString];
    
    //Add JSBeautifier.js to the html file
    NSString *beautifier = [[NSBundle mainBundle] pathForResource:@"JSBeautifier" ofType:@"js"];
    NSString *beautifierString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:beautifier] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!-- jsbeautifier -->" withString:beautifierString];
    
    //Add ZSSRichTextEditor.js to the html file
    NSString *source = [[NSBundle mainBundle] pathForResource:@"ZSSRichTextEditor" ofType:@"js"];
    NSString *jsString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:source] encoding:NSUTF8StringEncoding];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!--editor-->" withString:jsString];
    
    
    NSString *basePath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:basePath];
    [self.editorView loadHTMLString:htmlString baseURL:baseURL];
    
    self.resourcesLoaded = YES;
}

@end
