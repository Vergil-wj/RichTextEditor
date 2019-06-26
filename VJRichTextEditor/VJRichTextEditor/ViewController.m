//
//  ViewController.m
//  VJRichTextEditor
//
//  Created by 侯卫嘉 on 2019/6/26.
//  Copyright © 2019 vj. All rights reserved.
//

#import "ViewController.h"
#import "RichTextEditorDemo.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 100, 60);
    [btn setTitle:@"测试" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor cyanColor];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

-(void)btnAction{
    RichTextEditorDemo *vc = [[RichTextEditorDemo alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
