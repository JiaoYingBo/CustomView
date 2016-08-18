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
@property (nonatomic, assign) CGRect pictureFrame;
@property (nonatomic, assign) CGFloat minWidth;
@property (nonatomic, assign) CGFloat minHeight;

// frame是总视图大小，centerFrame是剪切框大小
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
    CGPoint TopLeftPoint;
    CGPoint TopRightPoint;
    CGPoint BottomLeftPoint;
    CGPoint BottomRightPoint;
} CornerPoint;

// 直角坐标转极坐标
YBPolarCoordinate decartToPolar(CGPoint center, CGPoint point);
// 根据frame计算矩形四个角的坐标
CornerPoint frameToCornerPoint(CGRect frame);

@end