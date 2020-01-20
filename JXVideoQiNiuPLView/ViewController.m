//
//  ViewController.m
//  JXVideoQiNiuPLView
//
//  Created by JosephXuan on 2019/10/13.
//  Copyright © 2019 JosephXuan. All rights reserved.
//
/// 需要真机
#import "ViewController.h"
#import <Masonry.h>
#import "JXVideoQiNiuPLPageCtrl.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor systemGroupedBackgroundColor];
    [btn setTitle:@"去看短视频" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
        make.width.offset(100);
        make.height.offset(100);
    }];
}
#pragma mark --去看视频
-(void)btnClick:(UIButton *)btn{
    JXVideoQiNiuPLPageCtrl *vc = [[JXVideoQiNiuPLPageCtrl alloc]init];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

@end
