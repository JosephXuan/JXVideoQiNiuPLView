//
//  JXVideoQiNiuPLPageCtrl.m
//  JXVideoQiNiuPLView
//
//  Created by JosephXuan on 2020/1/20.
//  Copyright © 2020 JosephXuan. All rights reserved.
//

#import "JXVideoQiNiuPLPageCtrl.h"
#import "JXVideoQiNiuPLDataCtrl.h"///数据
#import "UIColor+Hex.h"///

@interface JXVideoQiNiuPLPageCtrl ()
///数据源
@property (nonatomic, strong) NSMutableArray *mediaArray;
///滚动index下标
@property (nonatomic, assign) NSInteger index;
//数据
@property (nonatomic, strong) JXVideoQiNiuPLDataCtrl *shortPlayerVC;

//分页数据
@property (assign, nonatomic) NSInteger pageIndex;

@end

@implementation JXVideoQiNiuPLPageCtrl
- (NSMutableArray *)mediaArray{
    if (!_mediaArray){
        _mediaArray = [NSMutableArray array];
    }
    return _mediaArray;
}


- (void)onUIApplication:(BOOL)active {
    if (self.shortPlayerVC) {
        self.shortPlayerVC.player.enableRender = active;
        
    }
}
//使用这个方法是 竖向滑动
// 不使用 横向滑动（翻页）
+(JXVideoQiNiuPLPageCtrl *)initWithCustom{
    JXVideoQiNiuPLPageCtrl *shortController = [[JXVideoQiNiuPLPageCtrl alloc] initWithTransitionStyle:(UIPageViewControllerTransitionStyleScroll) navigationOrientation:(UIPageViewControllerNavigationOrientationVertical) options:@{UIPageViewControllerOptionInterPageSpacingKey:@(0)}];
    return shortController;

}
//-(void)viewWillAppear:(BOOL)animated{
//    // 会重写控制器
//    //造成做错误 在UI层可以c再次请求数据进行更改
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.pageIndex=1;
    self.view.backgroundColor = [UIColor colorWithHexString:@"#26272a"];
    [self addNavCustom];
    
    
    for (UIView *subView in self.view.subviews ) {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)subView;
            scrollView.delaysContentTouches = NO;
        }
    }
    self.delegate       = self;
    self.dataSource     = self;
    //请求数据
     [self getPlayList];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)clickReloadButton {
   // [self.emptyController hideReloadButton];
    [self getPlayList];
}
#pragma mark --请求视频的数据
- (void)getPlayList {
    
    __weak typeof(self) wself = self;
    if(self.index==self.mediaArray.count-1){
        
        self.pageIndex += 1;
        
    }else{
        
        self.pageIndex = 1;
        
    }
    
    NSArray *listArr = @[@"http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4",@"http://vfx.mtime.cn/Video/2019/03/21/mp4/190321153853126488.mp4",@"http://vfx.mtime.cn/Video/2019/03/19/mp4/190319222227698228.mp4",@"http://vfx.mtime.cn/Video/2019/03/19/mp4/190319212559089721.mp4",@"http://vfx.mtime.cn/Video/2019/03/18/mp4/190318231014076505.mp4",@"http://vfx.mtime.cn/Video/2019/03/09/mp4/190309153658147087.mp4",@"http://vfx.mtime.cn/Video/2019/03/12/mp4/190312083533415853.mp4",@"http://vfx.mtime.cn/Video/2019/03/12/mp4/190312143927981075.mp4",@"http://vfx.mtime.cn/Video/2019/03/13/mp4/190313094901111138.mp4"];
    
    if (self.pageIndex==1) {
        [self.mediaArray removeAllObjects];
    }
    
    if (listArr.count>0) {
        for (NSString *urlStr in listArr) {
            [self.mediaArray addObject:urlStr];
        }
    }
       
      [wself reloadController];
    
   
}

- (void)reloadController {
    
    if (self.mediaArray.count) {
        
        JXVideoQiNiuPLDataCtrl* playerController = [[JXVideoQiNiuPLDataCtrl alloc] init];
        if (self.index < self.mediaArray.count) {
            playerController.urlModelStr = [self.mediaArray objectAtIndex:self.index];
        } else {
            playerController.urlModelStr = [self.mediaArray firstObject];
            self.index = 0;
        }
        
        self.shortPlayerVC = playerController;
        [self setViewControllers:@[playerController] direction:(UIPageViewControllerNavigationDirectionForward) animated:NO completion:^(BOOL finished) {
        }];
    } else {
        NSLog(@"空数据创建一个空的Ctrl");
    }
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    if (![viewController isKindOfClass:[JXVideoQiNiuPLDataCtrl class]]) return nil;
    
    NSInteger index = [self.mediaArray indexOfObject:[(JXVideoQiNiuPLDataCtrl *)viewController urlModelStr]];
    if (NSNotFound == index) return nil;
    
    index --;
    //-1
    if (index < 0) return nil;
    
    JXVideoQiNiuPLDataCtrl* playerController = [[JXVideoQiNiuPLDataCtrl alloc] init];
    playerController.urlModelStr = [self.mediaArray objectAtIndex:index];
    self.index = index;
    
    return playerController;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    
    if (![viewController isKindOfClass:[JXVideoQiNiuPLDataCtrl class]]) return nil;
    
    NSInteger index = [self.mediaArray indexOfObject:[(JXVideoQiNiuPLDataCtrl *)viewController urlModelStr]];
    if (NSNotFound == index) return nil;
    
    NSLog(@"滑动第几个>>>%ld",index);
    if(index==self.mediaArray.count-1){
        NSLog(@"滑动最后一个");
        [self getPlayList];
    }
    index ++;
    
    
    if (self.mediaArray.count > index) {
        JXVideoQiNiuPLDataCtrl* playerController = [[JXVideoQiNiuPLDataCtrl alloc] init];
        playerController.urlModelStr = [self.mediaArray objectAtIndex:index];
        self.index = index;
        return playerController;
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    NSLog(@"????动画完成");
    
}


-(void)addNavCustom{
    [self imgNewNavigationForCustom];
   
  
    
    UIButton *leftBtn= [self itemWithTarget:self action:@selector(backBtnClick:) nomalImage:[UIImage imageNamed:@"fanhui-bai-42"] higeLightedImage:[UIImage imageNamed:@"fanhui-bai-42"] imageEdgeInsets:UIEdgeInsetsZero];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    /*
     */
    
}
-(void)backBtnClick:(UIButton *)btn{
    
    if (self.presentingViewController && self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
//导航透明 但未隐藏
-(void)imgNewNavigationForCustom{
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = YES;
}
//设置返回按钮
-(UIButton *)itemWithTarget:(id)target
                     action:(SEL)action
                 nomalImage:(UIImage *)nomalImage
           higeLightedImage:(UIImage *)higeLightedImage
            imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    // button.backgroundColor=[UIColor greenColor];
    [button setImage:[nomalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    if (higeLightedImage) {
        [button setImage:higeLightedImage forState:UIControlStateHighlighted];
    }
    [button sizeToFit];
    
    if (button.bounds.size.width < 40) {
        CGFloat width = 40 / button.bounds.size.height * button.bounds.size.width;
        button.bounds = CGRectMake(0, 0, width, 40);
    }
    
    if (button.bounds.size.height > 40) {
        CGFloat height = 40 / button.bounds.size.width * button.bounds.size.height;
        button.bounds = CGRectMake(0, 0, 40, height);
    }
    
    button.imageEdgeInsets = imageEdgeInsets;
    
    return button;
    
}

@end
