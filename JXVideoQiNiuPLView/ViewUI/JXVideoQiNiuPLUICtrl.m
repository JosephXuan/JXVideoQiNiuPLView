//
//  JXVideoQiNiuPLUICtrl.m
//  JXVideoQiNiuPLView
//
//  Created by JosephXuan on 2020/1/20.
//  Copyright © 2020 JosephXuan. All rights reserved.
//

#import "JXVideoQiNiuPLUICtrl.h"
#import <Masonry.h>
#import "UIColor+Hex.h"
//iPhone X: 1125px x 2436px >>       375 * 812
//iPhone XR：828px x 1792px >>       414 * 896
//iPhone XS Max: 1242px x 2688px >>  414 * 896

#define IS_IPhoneX_All ([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896)

#define kTabBarHeight (IS_IPhoneX_All?83:49)

#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define ScreenWidth [UIScreen mainScreen].bounds.size.width

//点赞imgviewtag
#define LIKE_BEFORE_TAP_ACTION 1000
#define LIKE_AFTER_TAP_ACTION 2000

#define RGBA(r,g,b,a)       [UIColor colorWithRed:(r)/255.f \
green:(g)/255.f \
blue:(b)/255.f \
alpha:(a)]

#define ColorThemeRed RGBA(241.0, 47.0, 84.0, 1.0)

@interface JXVideoQiNiuPLUICtrl ()<CAAnimationDelegate,UIGestureRecognizerDelegate>
//顶部触摸View
@property (strong, nonatomic) UIView *topTapView;

//头像图片
@property (strong, nonatomic) UIImageView *headImgView;
//关注图片
@property (strong, nonatomic) UIImageView *focusImgView;

//点赞View
@property (strong, nonatomic) UIView *likeView;
//点赞之前
@property (nonatomic, strong) UIImageView *likeBeforeImgView;
//点赞之后
@property (nonatomic, strong) UIImageView *likeAfterImgView;
//点赞数
@property (strong, nonatomic) UILabel *likeNumLab;

//评论
@property (strong, nonatomic) UIImageView *commentImgView;
//评论数
@property (strong, nonatomic) UILabel *commentNumLab;

//发布
@property (strong, nonatomic) UIImageView *publishImgView;

//昵称
@property (strong, nonatomic) UILabel *nickNameYYLab;
//描述 显示三行 可以点击放大
@property (strong, nonatomic) UILabel *desYYLab;

//暂停按钮
@property (nonatomic, strong) UIImageView *pauseIconImgView;

//是否消失  no：没有消失
@property (nonatomic, assign) BOOL isDisapper;

//上次点击时间
@property (nonatomic, assign) NSTimeInterval    lastTapTime;
//上次点击位置
@property (nonatomic, assign) CGPoint lastTapPoint;

//缓冲画面
@property (nonatomic, strong) UIVisualEffectView *effectView;

//缓冲指示view
@property (strong, nonatomic) UIView *playerStatusBarView;


@end

@implementation JXVideoQiNiuPLUICtrl

- (void)viewDidDisappear:(BOOL)animated {
    self.isDisapper = YES;
   // [self.player stop];
    if ([self.player isPlaying]) {
        
        [self.player pause];
        [self showPauseViewAnim:1.0f];
    }
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isDisapper = NO;
//    if (![self.player isPlaying]) {
//        [self.player play];
//    }
    if (![self.player isPlaying]) {
        [self.player resume];
        [self showPauseViewAnim:0.0f];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    NSLog(@"即将出现???");

    [super viewWillAppear:animated];
    if (self.isDisapper == YES) {
        //已经显示 即将出现
       //不走方法的~~~
    }
   
    
}
-(void)viewWillDisappear:(BOOL)animated{
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    
    [self setUpCustomView];
    self.lastTapTime=0;
}

#pragma mark --设置UI
-(void)setUpCustomView{
    
   // 先执行 的set方法 在 执行的init
   // DEFOTHERPLACEIMG
    /*
     */
    self.thumbImageView = [[UIImageView alloc] init];
    self.thumbImageView.image = [UIImage imageNamed:@"lodding"];
    self.thumbImageView.clipsToBounds = YES;
    self.thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
    if (self.thumbImageURL) {
//        [self.thumbImageView sd_setImageWithURL:self.thumbImageURL placeholderImage:self.thumbImageView.image];
    }
    if (self.thumbImage) {
        self.thumbImageView.image = self.thumbImage;
    }
    
    [self.view addSubview:self.thumbImageView];
    
    [self.thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    //
    //UIBlurEffectStyleLight
    UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    [self.thumbImageView addSubview:_effectView];
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.thumbImageView);
    }];
    
    [self.thumbImageView addSubview:self.playerStatusBarView];
    
    self.playerStatusBarView.frame=CGRectMake(0, ScreenHeight-kTabBarHeight-0.5, 1.0f, 0.5);
    [self.playerStatusBarView setHidden:YES];
    
    
    
    //设置播放器
    [self setupPlayer];
    
   
    //顶部触摸View
    [self.view addSubview:self.topTapView];
    [self.topTapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleOrMoreTapAction:)];
    singleTap.delegate=self;
    [self.topTapView addGestureRecognizer:singleTap];
    
     UIView *topView=self.topTapView;
    
    //暂停按钮
    [topView addSubview:self.pauseIconImgView];
    self.pauseIconImgView.image = [UIImage imageNamed:@"icon_play_pause_video"];
    self.pauseIconImgView.contentMode = UIViewContentModeCenter;
    self.pauseIconImgView.layer.zPosition = 3;
    self.pauseIconImgView.hidden = YES;
    [self.pauseIconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
        
        make.width.height.mas_equalTo(100);
    }];
    
    
    //描述 显示三行 可以点击放大
    _desYYLab=[[UILabel alloc]init];
    [topView addSubview:_desYYLab];
    [_desYYLab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.offset(-kTabBarHeight-5);
        make.left.offset(15);
        make.width.mas_lessThanOrEqualTo(ScreenWidth/5*3);
    }];
    _desYYLab.textColor = [UIColor colorWithWhite:1 alpha:0.8];
    _desYYLab.font = [UIFont systemFontOfSize:14.0f];
    _desYYLab.numberOfLines=3;
    if (self.descriptionFieldStr.length>0) {
        
        _desYYLab.text = self.descriptionFieldStr;
        
    }else{
        
        _desYYLab.text = @"这个人很懒，什么都没有留下~";
        
    }
    UIButton *desBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [_desYYLab addSubview:desBtn];
    [desBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.offset(0);
    }];
    [desBtn addTarget:self action:@selector(desTextClick:) forControlEvents:UIControlEventTouchUpInside];
    
//    _desYYLab.textTapAction = ^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
//
//        if ([weakSelf.descriptionFieldStr isNotEmpty]) {
//
//
//        }
//
//    };
    
    
    
    //昵称
    _nickNameYYLab = [[UILabel alloc]init];
    [topView addSubview:_nickNameYYLab];
    [_nickNameYYLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.desYYLab.mas_top).offset(-5);
        make.left.equalTo(self.desYYLab.mas_left).offset(0);
    }];
    _nickNameYYLab.textColor = [UIColor whiteColor];
    _nickNameYYLab.font = [UIFont systemFontOfSize:19];
   
    if(self.nickNameStr.length > 0){
        
        [_nickNameYYLab setText:[NSString stringWithFormat:@"@%@", self.nickNameStr]];
    }else{
        
        [_nickNameYYLab setText:[NSString stringWithFormat:@"@%@", @""]];
        
    }
    
    //分享
    [topView addSubview:self.publishImgView];
    [self.publishImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.nickNameYYLab.mas_top).offset(-30);
        make.right.equalTo(topView.mas_right).offset(-20);
        make.width.mas_equalTo(26);
        make.height.mas_equalTo(26);
        
    }];
    /*
    self.publishImgView.transform = CGAffineTransformMakeRotation(M_PI/4);
    self.publishImgView.contentMode = UIViewContentModeCenter;
    
    //icon_home_share
    self.publishImgView.image = [UIImage imageNamed:@"guanbi--xia_discount_send"];
    */
    
     self.publishImgView.image = [UIImage imageNamed:@"icon_home_share_video"];
    self.publishImgView.userInteractionEnabled = YES;
    
    
    //self.publishImgView.tag = SHARE_TAP_ACTION;
    [self.publishImgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePublishGesture:)]];
    
    //评论
    [topView addSubview:self.commentImgView];
    [self.commentImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.publishImgView.mas_top).inset(28);
        make.right.equalTo(topView.mas_right).inset(10);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(45);
    }];
    self.commentImgView.contentMode = UIViewContentModeCenter;
    self.commentImgView.image = [UIImage imageNamed:@"icon_home_comment_video"];
    self.commentImgView.userInteractionEnabled = YES;
    //commentImgView.tag = COMMENT_TAP_ACTION;
    [self.commentImgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCommentGesture:)]];
    //评论数
    [topView addSubview:self.commentNumLab];
    [self.commentNumLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.commentImgView.mas_bottom);
        make.centerX.equalTo(self.commentImgView.mas_centerX);
    }];
    self.commentNumLab.textAlignment=NSTextAlignmentCenter;
    //self.commentNumLab.text=@"0";
    self.commentNumLab.textColor = [UIColor whiteColor];
    self.commentNumLab.font = [UIFont systemFontOfSize:12];
    
    
    //点赞View
    [topView addSubview:self.likeView];
    [self.likeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.commentImgView.mas_top).inset(25);
        make.right.equalTo(topView.mas_right).inset(10);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(45);
    }];
    
    //点赞之前
    [self.likeView addSubview:self.likeBeforeImgView];
    [self.likeBeforeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.offset(0);
        make.top.offset(0);
        make.width.offset(50);
        make.height.offset(45);
    }];
    self.likeBeforeImgView.contentMode = UIViewContentModeCenter;
    self.likeBeforeImgView.image = [UIImage imageNamed:@"icon_home_like_before_video"];
    self.likeBeforeImgView.userInteractionEnabled = YES;
    self.likeBeforeImgView.tag = LIKE_BEFORE_TAP_ACTION;
    [self.likeBeforeImgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLikeGesture:)]];
    //点赞之后
    [self.likeView addSubview:self.likeAfterImgView];
    self.likeAfterImgView.contentMode = UIViewContentModeCenter;
    self.likeAfterImgView.image = [UIImage imageNamed:@"icon_home_like_after_video"];
    self.likeAfterImgView.userInteractionEnabled = YES;
   self.likeAfterImgView.tag = LIKE_AFTER_TAP_ACTION;
    [self.likeAfterImgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLikeGesture:)]];
    [self.likeAfterImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.top.offset(0);
        make.width.offset(50);
        make.height.offset(45);
    }];
  //  self.likeAfterImgView.hidden=YES;
    
    //点赞数
    [topView addSubview:self.likeNumLab];
    [self.likeNumLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.likeView.mas_bottom);
        make.centerX.equalTo(self.likeView.mas_centerX);
    }];
   // self.likeNumLab.text = @"0";
    self.likeNumLab.textColor = [UIColor whiteColor];
    self.likeNumLab.font = [UIFont systemFontOfSize:12];
    
    
   
    //头像图片
    CGFloat headImgRadius = 25;
    [topView addSubview:self.headImgView];
    [self.headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.likeView.mas_top).inset(35);
        make.right.equalTo(topView.mas_right).inset(10);
        make.width.height.mas_equalTo(headImgRadius*2);
        
    }];
    //self.headImgView.image = [UIImage imageNamed:@"lodding"];
    self.headImgView.layer.cornerRadius = headImgRadius;
    self.headImgView.layer.borderColor = [UIColor colorWithHexString:@"#ffffff"].CGColor;
    self.headImgView.layer.borderWidth = 1;
    self.headImgView.layer.masksToBounds=YES;
    self.headImgView.userInteractionEnabled=YES;
    self.headImgView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *taps = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImgDidClicked)];
    [self.headImgView addGestureRecognizer:taps];
   // [self.headImgView zy_cornerRadiusRoundingRect];
    
    //关注图片
    [topView addSubview:self.focusImgView];
    [self.focusImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headImgView);
        make.centerY.equalTo(self.headImgView.mas_bottom);
        make.width.height.mas_equalTo(24);
    }];
    
    self.focusImgView.layer.cornerRadius = 24/2;
    self.focusImgView.layer.backgroundColor = [UIColor redColor].CGColor;
    self.focusImgView.image = [UIImage imageNamed:@"icon_personal_add_little"];
    self.focusImgView.contentMode = UIViewContentModeCenter;
    self.focusImgView.userInteractionEnabled = YES;
    [self.focusImgView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusBeginAnimation:)]];
   
    
    
   
}
- (void) setupPlayer {
    
    NSLog(@"播放地址: %@", _url.absoluteString);
    
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    PLPlayFormat format = kPLPLAY_FORMAT_UnKnown;
    NSString *urlString = _url.absoluteString.lowercaseString;
    if ([urlString hasSuffix:@"mp4"]) {
        format = kPLPLAY_FORMAT_MP4;
    } else if ([urlString hasPrefix:@"rtmp:"]) {
        format = kPLPLAY_FORMAT_FLV;
    } else if ([urlString hasSuffix:@".mp3"]) {
        format = kPLPLAY_FORMAT_MP3;
    } else if ([urlString hasSuffix:@".m3u8"]) {
        format = kPLPLAY_FORMAT_M3U8;
    }
    [option setOptionValue:@(format) forKey:PLPlayerOptionKeyVideoPreferFormat];
    [option setOptionValue:@(kPLLogNone) forKey:PLPlayerOptionKeyLogLevel];
    
    NSLog(@"实际来的地址>>>%@",_url);
    
    self.player = [PLPlayer playerWithURL:_url option:option];
    [self.view insertSubview:self.player.playerView atIndex:0];
    [self.player.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.player.delegateQueue = dispatch_get_main_queue();
    self.player.playerView.contentMode = UIViewContentModeScaleAspectFit;
    self.player.delegate = self;
    self.player.loopPlay = YES;
    
}
#pragma mark --赋值
- (void)setThumbImage:(UIImage *)thumbImage {
    _thumbImage = thumbImage;
    self.thumbImageView.image = thumbImage;
}

- (void)setThumbImageURL:(NSURL *)thumbImageURL {
    _thumbImageURL = thumbImageURL;
   // [self.thumbImageView sd_setImageWithURL:thumbImageURL placeholderImage:self.thumbImageView.image];
}

- (void)setUrl:(NSURL *)url {
    if ([_url.absoluteString isEqualToString:url.absoluteString]) return;
    _url = url;
    
    if (self.player) {
        //停止
        [self stop];
        //设置播放器
        [self setupPlayer];
        //播放
        [self.player play];
    }
}
-(void)setCommentNum:(NSInteger)commentNum{
    _commentNum=commentNum;
    NSString *commentNumStr=[self formatCount:self.commentNum];
    self.commentNumLab.text=commentNumStr;
}
-(void)setLikeNum:(NSInteger)likeNum{
    _likeNum=likeNum;
    //点赞数
    NSString *likeNumStr=[self formatCount:likeNum];
    
    [self.likeNumLab setText:likeNumStr];
}
//头像
-(void)setHeadImgUrl:(NSURL *)headImgUrl{
    _headImgUrl=headImgUrl;
    
 //   [self.headImgView sd_setImageWithURL:headImgUrl placeholderImage:[UIImage new]];
   // [self.headImgView zy_cornerRadiusRoundingRect];
}

//昵称
-(void)setNickNameStr:(NSString *)nickNameStr{
    _nickNameStr=nickNameStr;
    
    NSLog(@"昵称>>%@",nickNameStr);
  
    
}
//描述
-(void)setDescriptionFieldStr:(NSString *)descriptionFieldStr{
    _descriptionFieldStr=descriptionFieldStr;
    
}
-(void)setIsFollowUser:(NSInteger)isFollowUser{
    _isFollowUser=isFollowUser;
    //关注
    if (self.isFollowUser>0) {
        
        //已关注
        self.focusImgView.hidden=YES;
        
    }else{
        
        
        //未关注
        self.focusImgView.hidden=NO;
    }
}
-(void)setIsLike:(NSInteger)isLike{
    _isLike=isLike;
    if(isLike==1){
        //已点赞
        // _favorite.favoriteBefore.image=[UIImage imageNamed:@"icon_home_like_after_video"];
        //[self.favorite startLikeAnim:YES];
        self.likeBeforeImgView.hidden=YES;
        self.likeAfterImgView.hidden=NO;
        
//        self.likeAfterImgView.alpha = 0.0f;
//        self.likeAfterImgView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(-M_PI/3*2), 0.5f, 0.5f);
//
//        self.likeBeforeImgView.alpha = 0.0f;
//        self.likeAfterImgView.alpha = 1.0f;
//        self.likeAfterImgView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(0), 1.0f, 1.0f);
//
//        self.likeBeforeImgView.alpha = 1.0f;
        self.likeBeforeImgView.userInteractionEnabled = YES;
       self.likeAfterImgView.userInteractionEnabled = YES;
    }else{
        self.likeBeforeImgView.hidden=NO;
        self.likeAfterImgView.hidden=YES;
        //未点赞
        self.likeBeforeImgView.userInteractionEnabled=YES;
        self.likeAfterImgView.userInteractionEnabled=YES;
    }
    
}


#pragma mark -- 停止播放器
- (void)stop {
    [self.player stop];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}
#pragma mark --单击/连续点击时间
- (void)singleOrMoreTapAction:(UITapGestureRecognizer*)gesture {
    //UIGestureRecognizer
    //
    //点赞
    //获取点击坐标，用于设置爱心显示位置
    CGPoint point = [gesture locationInView:self.topTapView];
    //获取当前时间
    NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
    //判断当前点击时间与上次点击时间的时间间隔
    if(time - self.lastTapTime > 0.25f) {
        //推迟0.25秒执行单击方法
        [self performSelector:@selector(singleTapAction) withObject:nil afterDelay:0.25f];
    }else {
       //多次点击
        /*
        if (![UserModel isLogIn]){
            //如果没有登录
            [UserModel unLogin];
            return ;
        }
         */
        //取消执行单击方法
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTapAction) object: nil];
        //执行连击显示爱心的方法
        [self showLikeViewAnim:point oldPoint:self.lastTapPoint];
        
    }
    //更新上一次点击位置
    self.lastTapPoint = point;
    //更新上一次点击时间
    self.lastTapTime =  time;
    
}
//执行连击显示爱心的方法
- (void)showLikeViewAnim:(CGPoint)newPoint oldPoint:(CGPoint)oldPoint {
    //[self goToLikeClick];
    UIImageView *likeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_home_like_after_video"]];
    CGFloat k = ((oldPoint.y - newPoint.y)/(oldPoint.x - newPoint.x));
    k = fabs(k) < 0.5 ? k : (k > 0 ? 0.5f : -0.5f);
    CGFloat angle = M_PI_4 * -k;
    likeImageView.frame = CGRectMake(newPoint.x, newPoint.y, 80, 80);
    likeImageView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(angle), 0.8f, 1.8f);
    [self.topTapView addSubview:likeImageView];
    [UIView animateWithDuration:0.2f
                          delay:0.0f
         usingSpringWithDamping:0.5f
          initialSpringVelocity:1.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         likeImageView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(angle), 1.0f, 1.0f);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5f
                                               delay:0.5f
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              likeImageView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(angle), 3.0f, 3.0f);
                                              likeImageView.alpha = 0.0f;
                                          }
                                          completion:^(BOOL finished) {
                                              [likeImageView removeFromSuperview];
                                          }];
                         if(self.isLike==0){
                            // [self startLikeAnim:YES];
                            // self.isLike=1;
                             [self goToLikeClick];
                         }
                         
                     }];
}
#pragma mark --单击播放停止
-(void)singleTapAction{
  
    
    if ([self.player isPlaying]) {
        
        [self.player pause];
        [self showPauseViewAnim:1.0f];
    } else {
       
        [self.player resume];
        [self showPauseViewAnim:0.0f];
        
    }
    
    
}
//暂停播放动画
- (void)showPauseViewAnim:(CGFloat)rate {
    if(rate == 0) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             self.pauseIconImgView.alpha = 0.0f;
                         } completion:^(BOOL finished) {
                             [self.pauseIconImgView setHidden:YES];
                         }];
    }else {
        [self.pauseIconImgView setHidden:NO];
        self.pauseIconImgView.transform = CGAffineTransformMakeScale(1.8f, 1.8f);
        self.pauseIconImgView.alpha = 1.0f;
        [UIView animateWithDuration:0.25f delay:0
                            options:UIViewAnimationOptionCurveEaseIn animations:^{
                                self.pauseIconImgView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                            } completion:^(BOOL finished) {
                            }];
    }
}
#pragma mark --点击头像
-(void)headImgDidClicked{

    //
    //头像_点击
   
    /*
    JSTalentDeCtrl *vc=[[JSTalentDeCtrl alloc]init];
    NSString *userIDStr=[NSString stringWithFormat:@"%ld",(long)self.userID];
    vc.uidStr=userIDStr;
    Tools *tools=[[Tools alloc]init];
    UIViewController *currentVC=[tools getCurrentCtrl];
    // [self dismiss];
    [currentVC.navigationController pushViewController:vc animated:YES];
     */
    
}
#pragma mark --点击关注

- (void)focusBeginAnimation:(UITapGestureRecognizer *)sender{
    //page_video_play_list
    //event_attention_user_click
    //JSServersEventTools *eventClickTools
    [self goToUpLoadAttent];
}
//关注接口
-(void)goToUpLoadAttent{
    
    NSLog(@"关注/取消成功");
    //self.headView.talentDeModel=self.talentDeModel;
    // [self getContentCareList];
    //  [self getContentFollowList];
    [self goToAttentAnimation];
}
//关注的动画
-(void)goToAttentAnimation{
    //旋转动画
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.delegate = self;
    animationGroup.duration = 1.25f;
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    [scaleAnim setValues:@[
                           [NSNumber numberWithFloat:1.0f],
                           [NSNumber numberWithFloat:1.2f],
                           [NSNumber numberWithFloat:1.2f],
                           [NSNumber numberWithFloat:1.2f],
                           [NSNumber numberWithFloat:1.2f],
                           [NSNumber numberWithFloat:1.2f],
                           [NSNumber numberWithFloat:1.2f],
                           [NSNumber numberWithFloat:0.0f]]];
    
    CAKeyframeAnimation *rotationAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    [rotationAnim setValues:@[
                              [NSNumber numberWithFloat:-1.5f*M_PI],
                              [NSNumber numberWithFloat:0.0f],
                              [NSNumber numberWithFloat:0.0f],
                              [NSNumber numberWithFloat:0.0f]]];
    
    CAKeyframeAnimation * opacityAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    [opacityAnim setValues:@[
                             [NSNumber numberWithFloat:0.8f],
                             [NSNumber numberWithFloat:1.0f],
                             [NSNumber numberWithFloat:1.0f]]];
    
    [animationGroup setAnimations:@[scaleAnim,
                                    rotationAnim,
                                    opacityAnim]];
    [self.focusImgView.layer addAnimation:animationGroup forKey:nil];
}
#pragma mark --CAAnimation 代理（关注动画）
- (void)animationDidStart:(CAAnimation *)anim {
    self.focusImgView.userInteractionEnabled = NO;
    self.focusImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.focusImgView.layer.backgroundColor = [UIColor redColor].CGColor;
    //关注
    self.focusImgView.image = [UIImage imageNamed:@"iconSignDone"];
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.focusImgView.userInteractionEnabled = YES;
    self.focusImgView.contentMode = UIViewContentModeCenter;
    [self.focusImgView setHidden:YES];
}

#pragma mark --点击点赞
- (void)handleLikeGesture:(UITapGestureRecognizer *)sender {
   // LIKE_BEFORE_TAP_ACTION
    //
    //点赞_点击
    [self goToLikeClick];
}
//掉接口去点赞
-(void)goToLikeClick{
    
    static int i = 0;
    i++;
    if (i%2 == 0) {//如果是偶数
        self.likeNum =  self.likeNum+1;
        [self startLikeAnim:YES];
        self.isLike = 1;
        
    }else{
        self.likeNum =  self.likeNum-1;
        self.isLike = 0;
        // self.favorite.favoriteBefore.image=[UIImage imageNamed:@"icon_home_like_before_video"];
        //    self.favorite.favoriteAfter.image=[UIImage imageNamed:@"icon_home_like_before_video"];
        [self startLikeAnim:NO];
        self.isLike = 0;
    }
    NSString *likeNumStr = [self formatCount:self.likeNum];
    
    [self.likeNumLab setText:likeNumStr];

    
}
//单击点赞动画
-(void)startLikeAnim:(BOOL)isLike {
    
    self.likeBeforeImgView.userInteractionEnabled = NO;
    self.likeAfterImgView.userInteractionEnabled = NO;
    if(isLike) {
        CGFloat length = 30;
        CGFloat duration = 0.5;
        for(int i=0;i<6;i++) {
            CAShapeLayer *layer = [[CAShapeLayer alloc]init];
            layer.position =  self.likeBeforeImgView.center;
            layer.fillColor = ColorThemeRed.CGColor;
            
            UIBezierPath *startPath = [UIBezierPath bezierPath];
            [startPath moveToPoint:CGPointMake(-2, -length)];
            [startPath addLineToPoint:CGPointMake(2, -length)];
            [startPath addLineToPoint:CGPointMake(0, 0)];
            
            UIBezierPath *endPath = [UIBezierPath bezierPath];
            [endPath moveToPoint:CGPointMake(-2, -length)];
            [endPath addLineToPoint:CGPointMake(2, -length)];
            [endPath addLineToPoint:CGPointMake(0, -length)];
            
            layer.path = startPath.CGPath;
            layer.transform = CATransform3DMakeRotation(M_PI / 3.0f * i, 0.0, 0.0, 1.0);
            [self.likeView.layer addSublayer:layer];
            
            CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
            group.removedOnCompletion = NO;
            group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            group.fillMode = kCAFillModeForwards;
            group.duration = duration;
            
            CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            scaleAnim.fromValue = @(0.0);
            scaleAnim.toValue = @(1.0);
            scaleAnim.duration = duration * 0.2f;
            
            CABasicAnimation *pathAnim = [CABasicAnimation animationWithKeyPath:@"path"];
            pathAnim.fromValue = (__bridge id)layer.path;
            pathAnim.toValue = (__bridge id)endPath.CGPath;
            pathAnim.beginTime = duration * 0.2f;
            pathAnim.duration = duration * 0.8f;
            
            [group setAnimations:@[scaleAnim, pathAnim]];
            [layer addAnimation:group forKey:nil];
        }
        [self.likeAfterImgView setHidden:NO];
        self.likeAfterImgView.alpha = 0.0f;
        self.likeAfterImgView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(-M_PI/3*2), 0.5f, 0.5f);
        [UIView animateWithDuration:0.4f
                              delay:0.2f
             usingSpringWithDamping:0.6f
              initialSpringVelocity:0.8f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.likeBeforeImgView.alpha = 0.0f;
                             self.likeAfterImgView.alpha = 1.0f;
                             self.likeAfterImgView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(0), 1.0f, 1.0f);
                         }
                         completion:^(BOOL finished) {
                             self.likeBeforeImgView.alpha = 1.0f;
                             self.likeBeforeImgView.userInteractionEnabled = YES;
                             self.likeAfterImgView.userInteractionEnabled = YES;
                         }];
    }else {
        
        self.likeAfterImgView.alpha = 1.0f;
        self.likeAfterImgView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(0), 1.0f, 1.0f);
        [UIView animateWithDuration:0.35f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.likeAfterImgView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(-M_PI_4), 0.1f, 0.1f);
                         }
                         completion:^(BOOL finished) {
                             [self.likeAfterImgView setHidden:YES];
                             self.likeBeforeImgView.userInteractionEnabled = YES;
                             self.likeAfterImgView.userInteractionEnabled = YES;
                         }];
    }
}

#pragma mark --点击评论
- (void)handleCommentGesture:(UITapGestureRecognizer *)sender {
    /*
    if (![UserModel isLogIn]){
        //如果没有登录
        [UserModel unLogin];
        
        return ;
    }
     */
    //
   /*
    NSString *fromToStr=[NSString stringWithFormat:@"%ld",(long)self.fromTo];
    NSString *fromIDStr=[NSString stringWithFormat:@"%ld",(long)self.contentId];
    
    JSBigVideoCommentDeView *view=[[JSBigVideoCommentDeView alloc]initWithAwemeId:fromIDStr withFromToStr:fromToStr];
    view.delegate=self;
    // view.fromToStr=fromToStr;
    // view.formIDStr=fromIDStr;
    [view show];
    */
}
#pragma mark --点击分享
- (void)handlePublishGesture:(UITapGestureRecognizer *)sender {
   
    /*
    if (![UserModel isLogIn]){
        
        //如果没有登录
        [UserModel unLogin];
        
        return ;
    }
    */
    
    //
   
    
   /*
    JSShareCustomView *view=[[JSShareCustomView alloc]init];
    view.delegate=self;
    // view.fromToStr=fromToStr;
    // view.formIDStr=fromIDStr;
    [view show];
    */
    

    /*
    NSLog(@"去发布");
    JSPublishVideosCtrl *vc=[[JSPublishVideosCtrl alloc]init];
    BaseNavigationViewController *nav=[[BaseNavigationViewController alloc]initWithRootViewController:vc];
    Tools *tools=[[Tools alloc]init];
    UIViewController *currentvc=[tools getCurrentCtrl];
    [currentvc presentViewController:nav animated:YES completion:nil];
     */
    
}
#pragma mark--点击某一个分享（QQ微信）
-(void)successOfClickShreView:(UICollectionView *)View didSelectItemAtIndexPath:(NSIndexPath *)indexPath withMuArr:(NSMutableArray *)muArr{
    if(indexPath.row==0){
        //微信
        [self clickDownLoadWithIndex:0];
    }
    if(indexPath.row==1){
        //qq
        [self clickDownLoadWithIndex:1];
    }
    if(indexPath.row==2){
        //朋友圈
        [self clickDownLoadWithIndex:2];
    }
    if(indexPath.row==3){
        //qq空间
        
        [self clickDownLoadWithIndex:3];
    }
    
    
}
#pragma mark --下载视频操作

-(void)clickDownLoadWithIndex:(NSInteger)index{
    
    /*  */
    
    NSString *urlstr = [NSString stringWithFormat:@"%@",_url.absoluteString];
    NSLog(@"视频下载的url>>%@",urlstr);
    
   // SVHUD_NO_Stop(@"下载中")
    urlstr = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlstr];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //要保存的沙盒路径
     NSString  *fullPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, _url.absoluteString.lastPathComponent];
    NSLog(@"要保存的沙盒路径>>%@",fullPath);
    /*
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"video/mpeg",@"video/mp4",@"audio/mp3",nil];//可下载@"text/json", @"text/javascript",@"text/html",@"video/mpeg",@"video/mp4",@"audio/mp3"等
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLRequest *request1 = [NSURLRequest requestWithURL:url];//在线路径
    
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request1 progress:^(NSProgress *downloadProgress) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{   //下载过程中由多个线程返回downloadProgress，无法给progress赋值进度，所以要选出主线程
            //            downloadView.observedProgress = downloadProgress;
           NSUInteger progress= downloadProgress.fractionCompleted*100;
           // NSString *progressStr=[NSString stringWithFormat:@"%ld%%",progress];
           // NSLog(@"进度>>%f>>>%ld%%",downloadProgress.fractionCompleted,progress);
           // progressStr
            [SVProgressHUD showProgress:downloadProgress.fractionCompleted status:@"下载中"];
           
           // SVHUD_PROGRESS(<#progress#>, @"下载中");
        }];
    } destination:^NSURL *(NSURL *targetPath,NSURLResponse *response) {
        NSString *path_sandox =NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES)[0];
        NSLog(@"path_sandox:%@",path_sandox);
        NSString *path = [path_sandox stringByAppendingPathComponent:response.suggestedFilename];
        NSLog(@"path:%@",path);
        
        return [NSURL fileURLWithPath:fullPath];
    } completionHandler:^(NSURLResponse *_Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if(error){
             SVHUD_Stop;
             NSLog(@"下载失败");
        }else{
          
            NSLog(@"下载完成");
            //PHPhotoLibrary
            [self saveVideoWithUrl:fullPath withIndex:index];
            //                dispatch_sync(dispatch_get_main_queue(), ^{
            //
            //                });
            [[TZImageManager manager] requestAuthorizationWithCompletion:^{
                NSLog(@"获取了加载权限");
                //[self saveVideoWithUrl:fullPath];
            }];
            
        }
    }];
    [task resume];
     */
    
}

-(void)saveVideoWithUrl:(NSString *)downUrlString withIndex:(NSInteger)index{
    
   /*
    PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
    if (photoAuthorStatus == PHAuthorizationStatusRestricted ||
        photoAuthorStatus == PHAuthorizationStatusDenied ) {
     //photoAuthorStatus == PHAuthorizationStatusNotDetermined
        // 无相册权限 做一个友好的提示 已拒绝
        SVHUD_Stop;
        [RHAlertView showAlertWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机中允许访问相册" cancel:^{
            
        } confirm:^{
            
             NSURL *privacyUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
             //  NSURL *privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"];
             if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
             [[UIApplication sharedApplication] openURL:privacyUrl];
             } else {
             
             [RHAlertView showAlertWithTitle:@"抱歉" message:@"无法跳转到隐私设置页面，请手动前往设置页面，谢谢" cancel:^{
             
             } confirm:^{
             
             }];
             
             }
           
            
        }];
        
    }else{
        //有相册权限
        if (downUrlString) {
            
            NSURL *url = [NSURL URLWithString:downUrlString];
            
            BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([url path]);
            
            if (compatible)
            {
                
                //保存相册核心代码
                
                UISaveVideoAtPathToSavedPhotosAlbum([url path], self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
            }else{
                SVHUD_Stop;
                
                NSLog(@"无法保存到视频相册");
                
            }
        }
    }
    */
}

- (void) savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    
  //  SVHUD_Stop;
    if (error) {
        
        NSLog(@"保存视频失败%@", error.localizedDescription);
       // [self showHintMiddle:@"视频保存失败"];
     //   SVHUD_HINT(@"保存失败")
        
    }
    else {
        
        NSLog(@"保存视频成功");
//        SVHUD_SUCCESS(@"保存成功")
        [self alertWarm];
        
    }
    
}
#pragma mark--提示框 与微信中从相册选择发送给好友
-(void)alertWarm{
    /*
    [RHAlertView showAlertWithTitle:@"温馨提示" message:@"跳转到微信/QQ中从相册选择发送给好友" cancel:^{
        
    } confirm:^{
        
        if (self.index==0) {
            //微信
            NSURL * wxUrl = [NSURL URLWithString:@"weixin://"];
            BOOL canOpenwx = [[UIApplication sharedApplication] canOpenURL:wxUrl];
            //先判断是否能打开该url
            if (canOpenwx)
            {   //打开微信
                [[UIApplication sharedApplication] openURL:wxUrl];
            }
            
        }
        if (self.index==1) {
            //QQ
            NSURL * qqUrl =[NSURL URLWithString:@"mqq://"];
            BOOL canOpenqq = [[UIApplication sharedApplication] canOpenURL:qqUrl];
            //先判断是否能打开该url
            if (canOpenqq)
            {   //打开qq
                [[UIApplication sharedApplication] openURL:qqUrl];
            }
        }
        if (self.index==2) {
            //朋友圈
            NSURL * wxUrl = [NSURL URLWithString:@"weixin://"];
            BOOL canOpenwx = [[UIApplication sharedApplication] canOpenURL:wxUrl];
            //先判断是否能打开该url
            if (canOpenwx)
            {   //打开微信
                [[UIApplication sharedApplication] openURL:wxUrl];
            }
        }
        if (self.index==3) {
            //QQ空间
            NSURL * qqUrl =[NSURL URLWithString:@"mqq://"];
            BOOL canOpenqq = [[UIApplication sharedApplication] canOpenURL:qqUrl];
            //先判断是否能打开该url
            if (canOpenqq)
            {   //打开qq
                [[UIApplication sharedApplication] openURL:qqUrl];
            }
        }
        
    }];
    
    */
}
/**
 使用GPUImage加载水印
 
 @param vedioPath 视频路径
 @param img 水印图片
 @param coverImg 水印图片二
 @param question 字符串水印
 @param fileName 生成之后的视频名字
 */
-(void)saveVedioPath:(NSURL*)vedioPath WithWaterImg:(UIImage*)img WithCoverImage:(UIImage*)coverImg WithQustion:(NSString*)question WithFileName:(NSString*)fileName{
    //第三方添加水印 GPUImage
    // 滤镜
    //    filter = [[GPUImageDissolveBlendFilter alloc] init];
    //    [(GPUImageDissolveBlendFilter *)filter setMix:0.0f];
    //也可以使用透明滤镜
    //    filter = [[GPUImageAlphaBlendFilter alloc] init];
    //    //mix即为叠加后的透明度,这里就直接写1.0了
    //    [(GPUImageDissolveBlendFilter *)filter setMix:1.0f];
    
    /*
   GPUImageNormalBlendFilter * filter = [[GPUImageNormalBlendFilter alloc] init];
    
    
    
    
    NSURL *sampleURL  = vedioPath;
    AVAsset *asset = [AVAsset assetWithURL:sampleURL];
    CGSize size = asset.naturalSize;

   GPUImageMovie *  movieFile = [[GPUImageMovie alloc] initWithAsset:asset];
    movieFile.playAtActualSpeed = NO;
    
    // 文字水印
    UILabel *label = [[UILabel alloc] init];
    label.text = question;
    label.font = [UIFont systemFontOfSize:30];
    label.textColor = [UIColor whiteColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label sizeToFit];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 18.0f;
    [label setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [label setFrame:CGRectMake(50, 100, label.frame.size.width+20, label.frame.size.height)];
    
    //图片水印
    UIImage *coverImage1 = [img copy];
    UIImageView *coverImageView1 = [[UIImageView alloc] initWithImage:coverImage1];
    [coverImageView1 setFrame:CGRectMake(0, 100, 210, 50)];
    
    //第二个图片水印
    UIImage *coverImage2 = [coverImg copy];
    UIImageView *coverImageView2 = [[UIImageView alloc] initWithImage:coverImage2];
    [coverImageView2 setFrame:CGRectMake(270, 100, 210, 50)];
    
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    subView.backgroundColor = [UIColor clearColor];
    
    [subView addSubview:coverImageView1];
    [subView addSubview:coverImageView2];
    [subView addSubview:label];
    
    
    GPUImageUIElement *uielement = [[GPUImageUIElement alloc] initWithView:subView];
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.mp4",fileName]];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720.0, 1280.0)];
    
    GPUImageFilter* progressFilter = [[GPUImageFilter alloc] init];
    [progressFilter addTarget:filter];
    [movieFile addTarget:progressFilter];
    [uielement addTarget:filter];
    movieWriter.shouldPassthroughAudio = YES;
    //    movieFile.playAtActualSpeed = true;
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] > 0){
        movieFile.audioEncodingTarget = movieWriter;
    } else {//no audio
        movieFile.audioEncodingTarget = nil;
    }
    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    // 显示到界面
    [filter addTarget:movieWriter];
    
    [movieWriter startRecording];
    [movieFile startProcessing];
    
    //    dlink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    //    [dlink setFrameInterval:15];
    //    [dlink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    //    [dlink setPaused:NO];
    
    __weak typeof(self) weakSelf = self;
    //渲染
    [progressFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        //水印可以移动
        CGRect frame = coverImageView1.frame;
        frame.origin.x += 1;
        frame.origin.y += 1;
        coverImageView1.frame = frame;
        //第5秒之后隐藏coverImageView2
        if (time.value/time.timescale>=5.0) {
            [coverImageView2 removeFromSuperview];
        }
        [uielement update];
        
    }];
    //保存相册
    [movieWriter setCompletionBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf->filter removeTarget:strongSelf->movieWriter];
            [strongSelf->movieWriter finishRecording];
            __block PHObjectPlaceholder *placeholder;
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToMovie))
            {
                NSError *error;
                [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                    PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:movieURL];
                    placeholder = [createAssetRequest placeholderForCreatedAsset];
                } error:&error];
                if (error) {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",error]];
                }
                else{
                    [SVProgressHUD showSuccessWithStatus:@"视频已经保存到相册"];
                }
            }
        });
    }];
*/
}


#pragma mark --连击点赞动画

#pragma mark --缓冲底部state动画
-(void)startLoadingPlayItemAnim:(BOOL)isStart {
    if (isStart) {
        self.playerStatusBarView.backgroundColor = [UIColor whiteColor];
        [self.playerStatusBarView setHidden:NO];
        [self.playerStatusBarView.layer removeAllAnimations];
        
        CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc]init];
        animationGroup.duration = 0.5;
        animationGroup.beginTime = CACurrentMediaTime() + 0.5;
        animationGroup.repeatCount = MAXFLOAT;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CABasicAnimation * scaleAnimation = [CABasicAnimation animation];
        scaleAnimation.keyPath = @"transform.scale.x";
        scaleAnimation.fromValue = @(1.0f);
        scaleAnimation.toValue = @(1.0f * ScreenWidth);
        
        CABasicAnimation * alphaAnimation = [CABasicAnimation animation];
        alphaAnimation.keyPath = @"opacity";
        alphaAnimation.fromValue = @(1.0f);
        alphaAnimation.toValue = @(0.5f);
        [animationGroup setAnimations:@[scaleAnimation, alphaAnimation]];
        [self.playerStatusBarView.layer addAnimation:animationGroup forKey:nil];
    } else {
        self.playerStatusBarView.backgroundColor=[UIColor clearColor];
        [self.playerStatusBarView.layer removeAllAnimations];
        [self.playerStatusBarView setHidden:YES];
        
    }
    
}

#pragma mark--评论View的代理
//评论成功的回调
-(void)onClickCommentUpdateSuceess{
    
    self.commentNum =  self.commentNum+1;
    NSString *commentNumStr=[self formatCount:self.commentNum];
    [self.commentNumLab setText:commentNumStr];
}
- (NSString *)formatCount:(NSInteger)count {
    if(count < 10000) {
        return [NSString stringWithFormat:@"%ld",(long)count];
    }else {
        return [NSString stringWithFormat:@"%.1fw",count/10000.0f];
    }
}

#pragma mark - PLPlayerDelegate 播放器的代理

- (void)playerWillBeginBackgroundTask:(PLPlayer *)player {
}

- (void)playerWillEndBackgroundTask:(PLPlayer *)player {
}

- (void)player:(PLPlayer *)player statusDidChange:(PLPlayerStatus)state
{
    
    if (self.isDisapper==YES) {
      //单击暂停的情况
        //[self stop];
        [self.player pause];
       // [self hideWaiting];
        return;
    }
    
    if (state == PLPlayerStatusPlaying ||
        state == PLPlayerStatusPaused ||
        state == PLPlayerStatusStopped ||
        state == PLPlayerStatusError ||
        state == PLPlayerStatusUnknow ||
        state == PLPlayerStatusCompleted) {
       // [self hideWaiting];
        //开始缓冲动画
       [self startLoadingPlayItemAnim:YES];
    } else if (state == PLPlayerStatusPreparing ||
               state == PLPlayerStatusReady ||
               state == PLPlayerStatusCaching) {
       // [self showWaiting];
        //开始缓冲动画
        [self startLoadingPlayItemAnim:YES];
    } else if (state == PLPlayerStateAutoReconnecting) {
       // [self showWaiting];
        //开始缓冲动画
        [self startLoadingPlayItemAnim:YES];
    }
}

- (void)player:(PLPlayer *)player stoppedWithError:(NSError *)error
{
   // [self hideWaiting];
    
    [self startLoadingPlayItemAnim:NO];
    NSString *info = error.userInfo[@"NSLocalizedDescription"];
    NSLog(@"stoppedWithError的报错 >>>%@",info);
   // [self.view showTip:info];
}

- (void)player:(nonnull PLPlayer *)player willRenderFrame:(nullable CVPixelBufferRef)frame pts:(int64_t)pts sarNumerator:(int)sarNumerator sarDenominator:(int)sarDenominator {
//    dispatch_main_async_safe(^{
//        if (![UIApplication sharedApplication].isIdleTimerDisabled) {
//            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
//        }
//    });
    if (![UIApplication sharedApplication].isIdleTimerDisabled) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    
}

- (AudioBufferList *)player:(PLPlayer *)player willAudioRenderBuffer:(AudioBufferList *)audioBufferList asbd:(AudioStreamBasicDescription)audioStreamDescription pts:(int64_t)pts sampleFormat:(PLPlayerAVSampleFormat)sampleFormat{
    return audioBufferList;
}

- (void)player:(nonnull PLPlayer *)player firstRender:(PLPlayerFirstRenderType)firstRenderType {
    if (PLPlayerFirstRenderTypeVideo == firstRenderType) {
        //结束动画
      //  [self startLoadingPlayItemAnim:NO];
        //隐藏
        self.thumbImageView.hidden = YES;
        
    }
}

- (void)player:(nonnull PLPlayer *)player SEIData:(nullable NSData *)SEIData {
    
}

- (void)player:(PLPlayer *)player codecError:(NSError *)error {
    
    NSString *info = error.userInfo[@"NSLocalizedDescription"];
    NSLog(@"codecError的报错 >>>%@",info);
   // [self.view showTip:info];
    
   // [self hideWaiting];
}

- (void)player:(PLPlayer *)player loadedTimeRange:(CMTimeRange)timeRange {}


#pragma mark --tap文字放大
-(void)desTextClick:(UIButton *)btn{
    /*
    JSClickToBigShowTextCtrl *vc=[[JSClickToBigShowTextCtrl alloc]init];
    //self.allTrainModel.attributedTextDeTail;
    vc.titleStr=self.descriptionFieldStr;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.providesPresentationContextTransitionStyle = YES;
    vc.definesPresentationContext = YES;
    vc.isCustom=1;
    vc.titleColor=[UIColor colorWithHexString:@"#ffffff"alpha:1];
    vc.baseViewColor=[UIColor colorWithHexString:@"#333333" alpha:0.3];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:vc animated:YES completion:nil];
     */
}


//顶部触摸View
- (UIView *)topTapView{
    if (!_topTapView){
        _topTapView = [[UIView alloc]init];
    }
    return _topTapView;
}
//头像图片
- (UIImageView *)headImgView{
    if (!_headImgView){
        _headImgView = [[UIImageView alloc]init];
    }
    return _headImgView;
}
//关注图片
- (UIImageView *)focusImgView{
    if (!_focusImgView){
        _focusImgView = [[UIImageView alloc]init];
    }
    return _focusImgView;
}

//点赞View
- (UIView *)likeView{
    if (!_likeView){
        _likeView = [[UIView alloc]init];
    }
    return _likeView;
}
//点赞之前
- (UIImageView *)likeBeforeImgView{
    if (!_likeBeforeImgView){
        _likeBeforeImgView = [[UIImageView alloc]init];
    }
    return _likeBeforeImgView;
}
//点赞之后
- (UIImageView *)likeAfterImgView{
    if (!_likeAfterImgView){
        _likeAfterImgView = [[UIImageView alloc]init];
    }
    return _likeAfterImgView;
}
- (UILabel *)likeNumLab{
    if (!_likeNumLab){
        _likeNumLab = [[UILabel alloc]init];
    }
    return _likeNumLab;
}
//评论
- (UIImageView *)commentImgView{
    if (!_commentImgView){
        _commentImgView = [[UIImageView alloc]init];
    }
    return _commentImgView;
}
- (UILabel *)commentNumLab{
    if (!_commentNumLab){
        _commentNumLab = [[UILabel alloc]init];
    }
    return _commentNumLab;
}
//发布
- (UIImageView *)publishImgView{
    if (!_publishImgView){
        _publishImgView = [[UIImageView alloc]init];
    }
    return _publishImgView;
}
//暂停按钮
- (UIImageView *)pauseIconImgView{
    if (!_pauseIconImgView){
        _pauseIconImgView = [[UIImageView alloc]init];
    }
    return _pauseIconImgView;
}
//缓冲指示view
- (UIView *)playerStatusBarView{
    if (!_playerStatusBarView){
        _playerStatusBarView = [[UIView alloc]init];
    }
    return _playerStatusBarView;
}

@end
