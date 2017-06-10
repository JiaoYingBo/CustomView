//
//  YBPictureCutterView.m
//  CustomView
//
//  Created by 焦英博 on 2017/6/10.
//  Copyright © 2017年 JYB. All rights reserved.
//

#import "YBPictureCutterView.h"
#import "YBPhotoCutView.h"

@interface YBPictureCutterView ()<YBPhotoCutViewDelegate>

@property (nonatomic, strong) YBPhotoCutView *cutView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, assign) CGRect cutFrame;
@property (nonatomic, strong) UIImage *image;

@end

@implementation YBPictureCutterView

#pragma mark - life cycle

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self addSubview:self.imgView];
    [self addSubview:self.cutView];
}

#pragma mark - public method

- (void)dismiss {
    [self removeFromSuperview];
}

#pragma mark - YBPhotoCutView delegate

- (void)photoCutView:(YBPhotoCutView *)customView shotFrame:(CGRect)frame {
    self.cutFrame = frame;
    [self delegateInvocation];
}

- (void)delegateInvocation {
    if ([self.delegate respondsToSelector:@selector(pictureCutterView:didClippedImage:)]) {
        UIImage *image = [self cutImage];
        if (image) {
            [self.delegate pictureCutterView:self didClippedImage:image];
        }
    }
}

#pragma mark - 图片剪裁

- (UIImage *)cutImage {
    if (self.cutFrame.size.height == 0) {
        return nil;
    }
    double scale = self.imgView.image.size.width / self.imgView.frame.size.width;
    CGFloat x = self.cutFrame.origin.x *scale;
    CGFloat y = self.cutFrame.origin.y *scale;
    CGFloat w = self.cutFrame.size.width *scale;
    CGFloat h = self.cutFrame.size.height *scale;
    CGRect cropRect = CGRectMake(x, y, w, h);
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.imgView.image CGImage], cropRect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    self.cutFrame = CGRectZero;
    return img;
}

#pragma mark - lazy load

- (YBPhotoCutView *)cutView {
    self.cutFrame = CGRectMake(self.bounds.size.width/4, self.bounds.size.height/4, self.bounds.size.width/2, self.bounds.size.height/2);
    if (!_cutView) {
        _cutView = [[YBPhotoCutView alloc] initWithFrame:self.bounds pictureFrame:self.cutFrame];
        _cutView.delegate = self;
        [self delegateInvocation];
    }
    return _cutView;
}

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.frame = self.bounds;
    }
    _imgView.image = self.image;
    return _imgView;
}

- (UIImage *)image {
    return [self.dataSource imageForPictureCutterView:self];
}

@end
