//
//  RichTextEditorDemo.m
//  VJRichTextEditor
//
//  Created by 侯卫嘉 on 2019/6/26.
//  Copyright © 2019 vj. All rights reserved.
//

#import "RichTextEditorDemo.h"

@implementation RichTextEditorDemo

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self setHTML:@"这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这是一个测试这"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"HTML" style:UIBarButtonItemStylePlain target:self action:@selector(getHTMLText)];
    
}

- (void)getHTMLText{
    
    [self vj_getHTMLTitle:^(NSString *html) {
        NSLog(@"title = %@",html);
    }];
    
    [self vj_getHTMLAbstract:^(NSString *html) {
       
        NSLog(@"abstract = %@",html);
    }];
    
   
    [self getHTML:^(NSString *html) {
        NSLog(@"html = %@",html);
    }];
    
    
    [self getText:^(NSString *html) {
        NSLog(@"text = %@",html);
    }];
    
    
}

-(void)didSelectedColumn{
    
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择栏目" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confim = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setColumnTextWithText:@"栏目"];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self setColumnTextWithText:@""];
    }];
    [alert addAction:confim];
    [alert addAction:cancel];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

@end
