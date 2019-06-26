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
    
    [self setHTML:@"这是一个测试"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"HTML" style:UIBarButtonItemStylePlain target:self action:@selector(getHTMLText)];
    
}

- (void)getHTMLText{
    
    NSLog(@"title = %@",[self vj_getHTMLTitle]);
    NSLog(@"absTitle = %@",[self vj_getHTMLAbstract]);
    NSLog(@"html = %@",[self getHTML]);
    NSLog(@"text = %@",[self getText]);
    
}

-(void)didSelectedColumn{
    NSLog(@"选择栏目");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择栏目" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

@end
