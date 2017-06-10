//
//  CustomPictureView.h
//  PhotoCustom
//
//  Created by Mac on 16/6/6.
//  Copyright © 2016年 yb. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YBPhotoCutView;
@protocol YBPhotoCutViewDelegate <NSObject>

- (void)photoCutView:(YBPhotoCutView *)customView shotFrame:(CGRect)frame;

@end

@interface YBPhotoCutView : UIControl

@property (nonatomic, assign) id<YBPhotoCutViewDelegate> delegate;
// 剪切框的frame
@property (nonatomic, assign, readonly) CGRect pictureFrame;
@property (nonatomic, assign) CGFloat minWidth;
@property (nonatomic, assign) CGFloat minHeight;

// frame是总视图大小，picFrame是剪切框大小
- (instancetype)initWithFrame:(CGRect)frame pictureFrame:(CGRect)picFrame;

@end


@interface YBMath : NSObject

// 极坐标
typedef struct{
    double radius;
    double angle;
} YBPolarCoordinate;

// 矩形的四个角坐标
typedef struct{
    CGPoint topLeftPoint;
    CGPoint topRightPoint;
    CGPoint bottomLeftPoint;
    CGPoint bottomRightPoint;
} CornerPoint;

// 矩形的四个边中心点
typedef struct{
    CGPoint top;
    CGPoint bottom;
    CGPoint left;
    CGPoint right;
} DirectionPoint;

// 四个边中心点的矩形
typedef struct{
    CGRect topRect;
    CGRect bottomRect;
    CGRect leftRect;
    CGRect rightRect;
} DirectionRect;

// 直角坐标转极坐标
YBPolarCoordinate decartToPolar(CGPoint center, CGPoint point);
// 根据frame计算矩形四个角的坐标
CornerPoint frameToCornerPoint(CGRect frame);
// 根据矩形四个角计算四条边中心点
DirectionPoint cornerPointToDirection(CornerPoint corner);
// 根据矩形四条边中心点计算中心点的矩形坐标
DirectionRect directionPointToDirectionRect(DirectionPoint drt_point, CGFloat width, CGFloat height);

@end
