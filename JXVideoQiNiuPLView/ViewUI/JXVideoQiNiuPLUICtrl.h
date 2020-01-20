//
//  JXVideoQiNiuPLUICtrl.h
//  JXVideoQiNiuPLView
//
//  Created by JosephXuan on 2020/1/20.
//  Copyright © 2020 JosephXuan. All rights reserved.
//
//https://www.jianshu.com/p/c921a20b607f
#import <UIKit/UIKit.h>
#import <PLPlayerKit/PLPlayerKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface JXVideoQiNiuPLUICtrl : UIViewController<PLPlayerDelegate>

//播放器
@property (nonatomic, strong) PLPlayer      *player;

//占位图view
@property (nonatomic, strong) UIImageView   *thumbImageView;
//链接
@property (nonatomic, strong) NSURL *url;
//占位图片
@property (nonatomic, strong) UIImage *thumbImage;
//占位图片链接
@property (nonatomic, strong) NSURL *thumbImageURL;
//fromTo
@property (assign, nonatomic) NSInteger fromTo;
//fromID
@property (assign, nonatomic) NSInteger contentId;
//fromId
@property (assign, nonatomic) NSInteger fromId;
//uid
@property (assign, nonatomic) NSInteger userID;
//评论数
@property (assign, nonatomic) NSInteger commentNum;
//点赞数
@property (assign, nonatomic) NSInteger likeNum;
//是否点赞
@property (assign, nonatomic) NSInteger isLike;
//头像
@property (strong, nonatomic) NSURL *headImgUrl;
//昵称
@property (copy, nonatomic) NSString *nickNameStr;
//描述
@property (copy, nonatomic) NSString *descriptionFieldStr;
//是否关注
@property (assign, nonatomic) NSInteger isFollowUser;

//是否启用手指滑动调节音量和亮度, default YES (没有用)
@property (nonatomic, assign) BOOL enableGesture;

@end

NS_ASSUME_NONNULL_END
