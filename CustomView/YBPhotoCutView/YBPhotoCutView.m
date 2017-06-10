//
//  CustomPictureView.m
//  PhotoCustom
//
//  Created by Mac on 16/6/6.
//  Copyright © 2016年 yb. All rights reserved.
//

#import "YBPhotoCutView.h"

// 四个角的触摸范围半径
#define TouchRadius 20.0

// 剪切框的四个角
typedef NS_ENUM(NSInteger,CornerIndex) {
    TopLeft = 0,
    TopRight,
    BottomLeft,
    BottomRight
};

@implementation YBPhotoCutView {
    // 记录上次的触摸点以计算偏移量
    CGPoint touchedPoint;
    // YES缩放模式（NO拖动模式）
    BOOL zooming;
    // 拖动缩放的点
    CornerIndex zoomingIndex;
    // 截图框四个角的坐标
    CornerPoint cornerPoint;
}

// picFrame:截图框的frame
- (instancetype)initWithFrame:(CGRect)frame pictureFrame:(CGRect)picFrame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.pictureFrame = picFrame;
        _minHeight = 60.0;
        _minWidth = 60.0;
        zooming = NO;
    }
    return self;
}

- (void)setPictureFrame:(CGRect)pictureFrame {
    _pictureFrame = pictureFrame;
    cornerPoint = frameToCornerPoint(self.pictureFrame);
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:self];
    
    // 遍历四个角的坐标，判断是否点击的是四个角
    for (NSInteger i = 0; i < 4; i ++) {
        CGFloat roundX = i%2 * self.pictureFrame.size.width + self.pictureFrame.origin.x;
        CGFloat roundY = i/2 * self.pictureFrame.size.height + self.pictureFrame.origin.y;
        
        // 如果在四个角为圆心的圆周内
        if ([self touchInCircleWithPoint:touchPoint circleCenter:CGPointMake(roundX, roundY)]) {
            // 缩放模式
            zooming = YES;
            // 记录所点的角
            zoomingIndex = i;
            touchedPoint = touchPoint;
            
            return YES;
        }
    }
    if (CGRectContainsPoint(self.pictureFrame, touchPoint)) {
        // 拖动模式
        touchedPoint = touchPoint;
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:self];
    
    if (zooming) {
        // 让剪切框不超过self.bounds的范围
        if (touchPoint.x < 0) {
            touchPoint.x = 0;
        }
        if (touchPoint.y < 0) {
            touchPoint.y = 0;
        }
        if (touchPoint.x > CGRectGetMaxX(self.bounds)) {
            touchPoint.x = CGRectGetMaxX(self.bounds);
        }
        if (touchPoint.y > CGRectGetMaxY(self.bounds)) {
            touchPoint.y = CGRectGetMaxY(self.bounds);
        }
        CGPoint staticPoint;
        switch (zoomingIndex) {
            case TopLeft:
            {
                staticPoint = cornerPoint.BottomRightPoint;
            }
                break;
            case TopRight:
            {
                staticPoint = cornerPoint.BottomLeftPoint;
            }
                break;
            case BottomLeft:
            {
                staticPoint = cornerPoint.TopRightPoint;
            }
                break;
            case BottomRight:
            {
                staticPoint = cornerPoint.TopLeftPoint;
            }
                break;
                
            default:
                break;
        }
        self.pictureFrame = [self pointToFrame:touchPoint staticPoint:staticPoint zoomingIndex:zoomingIndex];
        
    } else {
        // X和Y方向上的偏移量
        CGFloat moveX = touchPoint.x - touchedPoint.x;
        CGFloat moveY = touchPoint.y - touchedPoint.y;
        
        CGRect rect = self.pictureFrame;
        rect.origin.x += moveX;
        rect.origin.y += moveY;
        
        // 让剪切框不超过self.bounds的范围
        if (rect.origin.x < 0) {
            rect.origin.x = 0;
        }
        if (rect.origin.y < 0) {
            rect.origin.y = 0;
        }
        if (CGRectGetMaxX(rect) > self.bounds.size.width) {
            rect.origin.x = self.bounds.size.width - self.pictureFrame.size.width;
        }
        if (CGRectGetMaxY(rect) > self.bounds.size.height) {
            rect.origin.y = self.bounds.size.height - self.pictureFrame.size.height;
        }
        self.pictureFrame = rect;
    }
    
    touchedPoint = touchPoint;
    [self setNeedsDisplay];
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    // 代理回调
    if ([self.delegate respondsToSelector:@selector(photoCutView:shotFrame:)]) {
        [self.delegate photoCutView:self shotFrame:self.pictureFrame];
    }
    // 还原数据
    touchedPoint = CGPointZero;
    zooming = NO;
}

// 根据矩形的两个对角点，计算这个矩形的frame
- (CGRect)pointToFrame:(CGPoint)touching staticPoint:(CGPoint)staticPoint zoomingIndex:(NSInteger)index {
    CGFloat width,height;
    CGPoint origin;
    
    switch (index) {
        case TopLeft:
        {
            origin = touching;
            width = staticPoint.x-touching.x;
            height = staticPoint.y-touching.y;
            if (width < self.minWidth) {
                width = self.minWidth;
                origin.x = staticPoint.x-self.minWidth;
            }
            if (height < self.minHeight) {
                height = self.minHeight;
                origin.y = staticPoint.y-self.minHeight;
            }
        }
            break;
        case TopRight:
        {
            origin = CGPointMake(staticPoint.x, touching.y);
            width = touching.x-staticPoint.x;
            height = staticPoint.y-touching.y;
            if (width < self.minWidth) {
                width = self.minWidth;
                origin.x = staticPoint.x;
            }
            if (height < self.minHeight) {
                height = self.minHeight;
                origin.y = staticPoint.y-self.minHeight;
            }
        }
            break;
        case BottomLeft:
        {
            origin = CGPointMake(touching.x, staticPoint.y);
            width = staticPoint.x-touching.x;
            height = touching.y-staticPoint.y;
            if (width < self.minWidth) {
                width = self.minWidth;
                origin.x = staticPoint.x-self.minWidth;
            }
            if (height < self.minHeight) {
                height = self.minHeight;
                origin.y = staticPoint.y;
            }
        }
            break;
        case BottomRight:
        {
            origin = staticPoint;
            width = touching.x-staticPoint.x;
            height = touching.y-staticPoint.y;
            if (width < self.minWidth) {
                width = self.minWidth;
                origin.x = staticPoint.x;
            }
            if (height < self.minHeight) {
                height = self.minHeight;
                origin.y = staticPoint.y;
            }
        }
            break;
            
        default:
        {
            width = 0;
            height = 0;
        }
            break;
    }
    
    CGRect rect = CGRectMake(origin.x, origin.y, width, height);
    
    return rect;
}

// 判断touchPoint是否在以circleCenter为圆心、半径为TouchRadius的圆内
- (BOOL)touchInCircleWithPoint:(CGPoint)touchPoint circleCenter:(CGPoint)circleCenter{
    YBPolarCoordinate polar = decartToPolar(circleCenter, touchPoint);
    if(polar.radius >= TouchRadius) return NO;
    else return YES;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 蒙版层
    [[UIColor colorWithWhite:0.0 alpha:0.5] setFill];
    CGContextFillRect(ctx, self.bounds);
    CGContextClearRect(ctx, self.pictureFrame);
    
    // 矩形框
    [[UIColor whiteColor] setStroke];
    CGContextAddRect(ctx, self.pictureFrame);
    CGContextStrokePath(ctx);
    
    CGFloat edge_3 = 3;
    CGFloat edge_20 = 20;
    
    [[UIColor whiteColor] setFill];
    // 左上
    CGContextAddRect(ctx, CGRectMake(cornerPoint.TopLeftPoint.x-edge_3, cornerPoint.TopLeftPoint.y-edge_3, edge_20, edge_3));
    CGContextFillPath(ctx);
    CGContextAddRect(ctx, CGRectMake(cornerPoint.TopLeftPoint.x-edge_3, cornerPoint.TopLeftPoint.y-edge_3, edge_3, edge_20));
    CGContextFillPath(ctx);
    // 左下
    CGContextAddRect(ctx, CGRectMake(cornerPoint.BottomLeftPoint.x-edge_3, cornerPoint.BottomLeftPoint.y, edge_20, edge_3));
    CGContextFillPath(ctx);
    CGContextAddRect(ctx, CGRectMake(cornerPoint.BottomLeftPoint.x-edge_3, cornerPoint.BottomLeftPoint.y-edge_20+edge_3, edge_3, edge_20));
    CGContextFillPath(ctx);
    // 右上
    CGContextAddRect(ctx, CGRectMake(cornerPoint.TopRightPoint.x-edge_20+edge_3, cornerPoint.TopRightPoint.y-edge_3, edge_20, edge_3));
    CGContextFillPath(ctx);
    CGContextAddRect(ctx, CGRectMake(cornerPoint.TopRightPoint.x, cornerPoint.TopRightPoint.y-edge_3, edge_3, edge_20));
    CGContextFillPath(ctx);
    // 右下
    CGContextAddRect(ctx, CGRectMake(cornerPoint.TopRightPoint.x-edge_20+edge_3, cornerPoint.BottomRightPoint.y, edge_20, edge_3));
    CGContextFillPath(ctx);
    CGContextAddRect(ctx, CGRectMake(cornerPoint.BottomRightPoint.x, cornerPoint.BottomRightPoint.y-edge_20+edge_3, edge_3, edge_20));
    CGContextFillPath(ctx);
    
    CGFloat direction_30 = 30;
    // 上
    CGContextAddRect(ctx, CGRectMake(cornerPoint.TopRightPoint.x-(cornerPoint.TopRightPoint.x-cornerPoint.TopLeftPoint.x)/2-direction_30/2, cornerPoint.TopLeftPoint.y-edge_3, direction_30, edge_3));
    CGContextFillPath(ctx);
    // 下
    CGContextAddRect(ctx, CGRectMake(cornerPoint.TopRightPoint.x-(cornerPoint.TopRightPoint.x-cornerPoint.TopLeftPoint.x)/2-direction_30/2, cornerPoint.BottomLeftPoint.y, direction_30, edge_3));
    CGContextFillPath(ctx);
    // 左
    CGContextAddRect(ctx, CGRectMake(cornerPoint.TopLeftPoint.x-edge_3, cornerPoint.BottomLeftPoint.y-(cornerPoint.BottomLeftPoint.y-cornerPoint.TopLeftPoint.y)/2-direction_30/2, edge_3, direction_30));
    CGContextFillPath(ctx);
    // 右
    CGContextAddRect(ctx, CGRectMake(cornerPoint.TopRightPoint.x, cornerPoint.BottomRightPoint.y-(cornerPoint.BottomRightPoint.y-cornerPoint.TopRightPoint.y)/2-direction_30/2, edge_3, direction_30));
    CGContextFillPath(ctx);
}

@end


@implementation YBMath

// 直角坐标转极坐标
YBPolarCoordinate decartToPolar(CGPoint center, CGPoint point){
    double x = point.x - center.x;
    double y = point.y - center.y;
    
    YBPolarCoordinate polar;
    polar.radius = sqrt(pow(x, 2.0) + pow(y, 2.0));
    polar.angle = acos(x/(sqrt(pow(x, 2.0) + pow(y, 2.0))));
    if(y < 0) polar.angle = 2 * M_PI - polar.angle;
    return polar;
}

// 根据frame计算矩形四个角的坐标
CornerPoint frameToCornerPoint(CGRect frame) {
    CornerPoint corner;
    
    corner.TopLeftPoint = frame.origin;
    corner.TopRightPoint = CGPointMake(frame.origin.x+frame.size.width, frame.origin.y);
    corner.BottomLeftPoint = CGPointMake(frame.origin.x, frame.origin.y+frame.size.height);
    corner.BottomRightPoint = CGPointMake(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height);
    
    return corner;
}

@end
