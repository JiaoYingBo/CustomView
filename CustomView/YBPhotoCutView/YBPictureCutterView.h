//
//  YBPictureCutterView.h
//  CustomView
//
//  Created by 焦英博 on 2017/6/10.
//  Copyright © 2017年 JYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YBPictureCutterView;
@protocol YBPictureCutterViewDataSource <NSObject>

@required
- (UIImage *)imageForPictureCutterView:(YBPictureCutterView *)cutterView;

@end

@protocol YBPictureCutterViewDelegate <NSObject>

@optional
- (void)pictureCutterView:(YBPictureCutterView *)cutterView didClippedImage:(UIImage *)image;

@end

@interface YBPictureCutterView : UIView

@property (nonatomic, weak) id<YBPictureCutterViewDataSource> dataSource;
@property (nonatomic, weak) id<YBPictureCutterViewDelegate> delegate;

- (void)dismiss;

@end
