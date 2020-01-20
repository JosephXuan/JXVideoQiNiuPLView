//
//  JXVideoQiNiuPLDataCtrl.m
//  JXVideoQiNiuPLView
//
//  Created by JosephXuan on 2020/1/20.
//  Copyright © 2020 JosephXuan. All rights reserved.
//

#import "JXVideoQiNiuPLDataCtrl.h"
#import <PLPlayerKit/PLPlayerKit.h>
@interface JXVideoQiNiuPLDataCtrl ()<
PLPlayerDelegate
>

@end

@implementation JXVideoQiNiuPLDataCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

///赋值
-(void)setUrlModelStr:(NSString *)urlModelStr{
    _urlModelStr = urlModelStr;
}


@end
