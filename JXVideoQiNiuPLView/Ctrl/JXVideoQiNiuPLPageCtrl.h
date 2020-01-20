//
//  JXVideoQiNiuPLPageCtrl.h
//  JXVideoQiNiuPLView
//
//  Created by JosephXuan on 2020/1/20.
//  Copyright © 2020 JosephXuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXVideoQiNiuPLPageCtrl : UIPageViewController<UIPageViewControllerDelegate,UIPageViewControllerDataSource>

//contentIDStr
@property (strong, nonatomic) NSString *contentIDStr;
@property (assign, nonatomic) NSInteger fromTo;
//刷新控制器
- (void)reloadController;
//
- (void)onUIApplication:(BOOL)active;
//使用这个方法是 竖向滑动
// 不使用 横向滑动（翻页）
+(JXVideoQiNiuPLPageCtrl *)initWithCustom;


@end

NS_ASSUME_NONNULL_END
