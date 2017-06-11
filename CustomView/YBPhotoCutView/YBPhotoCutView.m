//
//  CustomPictureView.m
//  PhotoCustom
//
//  Created by Mac on 16/6/6.
//  Copyright © 2016年 yb. All rights reserved.
//

#import "YBPhotoCutView.h"

// 四个角的触摸范围半径
static CGFloat const touchRadius = 20.0;
// 四个角
typedef NS_ENUM(NSInteger,CornerIndex) {
    TopLeft = 0,
    TopRight,
    BottomLeft,
    BottomRight
};
// 四条边
typedef NS_ENUM(NSUInteger, DirectionIndex) {
    Top = 0,
    Bottom,
    Left,
    Right
};

@implementation YBPhotoCutView {
    // 记录上次的触摸点以计算偏移量
    CGPoint _touchedPoint;
    // YES缩放模式（NO拖动模式）
    BOOL _zooming;
    // 拖动缩放的点
    CornerIndex _zoomingIndex;
    // 拖动缩放的边
    DirectionIndex _zoomingDirection;
    // 截图框四个角的坐标
    CornerPoint _cornerPoint;
    // 四条边中心点
    DirectionPoint _directionPoint;
}

- (instancetype)initWithFrame:(CGRect)frame pictureFrame:(CGRect)picFrame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.pictureFrame = picFrame;
        _minHeight = 60.0;
        _minWidth = 60.0;
        _zooming = NO;
        _zoomingDirection = -1;
    }
    return self;
}

- (void)setPictureFrame:(CGRect)pictureFrame {
    _pictureFrame = pictureFrame;
    _cornerPoint = frameToCornerPoint(self.pictureFrame);
    _directionPoint = cornerPointToDirection(_cornerPoint);
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:self];
    _touchedPoint = touchPoint;
    
    // 判断点击的是否是四条边
    DirectionRect rect = directionPointToDirectionRect(_directionPoint, 30, 25);
    if (CGRectContainsPoint(rect.topRect, touchPoint)) {
        _zoomingDirection = Top;
        _zooming = YES;
        return YES;
    }
    if (CGRectContainsPoint(rect.bottomRect, touchPoint)) {
        _zoomingDirection = Bottom;
        _zooming = YES;
        return YES;
    }
    if (CGRectContainsPoint(rect.leftRect, touchPoint)) {
        _zoomingDirection = Left;
        _zooming = YES;
        return YES;
    }
    if (CGRectContainsPoint(rect.rightRect, touchPoint)) {
        _zoomingDirection = Right;
        _zooming = YES;
        return YES;
    }
    
    // 遍历四个角的坐标，判断是否点击的是四个角
    for (NSInteger i = 0; i < 4; i ++) {
        CGFloat roundX = i%2 * self.pictureFrame.size.width + self.pictureFrame.origin.x;
        CGFloat roundY = i/2 * self.pictureFrame.size.height + self.pictureFrame.origin.y;
        
        // 如果在四个角为圆心的圆周内
        if ([self touchInCircleWithPoint:touchPoint circleCenter:CGPointMake(roundX, roundY)]) {
            // 缩放模式
            _zooming = YES;
            // 记录所点的角
            _zoomingIndex = i;
            
            return YES;
        }
    }
    if (CGRectContainsPoint(self.pictureFrame, touchPoint)) {
        // 拖动模式
        return YES;
    }
    return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:self];
    
    if (_zooming) {
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
        
        // 四条边缩放
        CGFloat offsetX = touchPoint.x - _touchedPoint.x;
        CGFloat offsetY = touchPoint.y - _touchedPoint.y;
        CGRect preFrame = self.pictureFrame;
        
        if (_zoomingDirection == Top) {
            if (preFrame.size.height-offsetY <= self.minHeight) {
                offsetY = preFrame.size.height - self.minHeight;
            }
            self.pictureFrame = CGRectMake(preFrame.origin.x, preFrame.origin.y+offsetY, preFrame.size.width, preFrame.size.height-offsetY);
            [self setNeedsDisplay];
            _touchedPoint = touchPoint;
            return YES;
        } else if (_zoomingDirection == Bottom) {
            if (preFrame.size.height+offsetY <= self.minHeight) {
                offsetY = self.minHeight - preFrame.size.height;
            }
            self.pictureFrame = CGRectMake(preFrame.origin.x, preFrame.origin.y, preFrame.size.width, preFrame.size.height+offsetY);
            [self setNeedsDisplay];
            _touchedPoint = touchPoint;
            return YES;
        } else if (_zoomingDirection == Left) {
            if (preFrame.size.width-offsetX <= self.minWidth) {
                offsetX = preFrame.size.width - self.minWidth;
            }
            self.pictureFrame = CGRectMake(preFrame.origin.x+offsetX, preFrame.origin.y, preFrame.size.width-offsetX, preFrame.size.height);
            [self setNeedsDisplay];
            _touchedPoint = touchPoint;
            return YES;
        } else if (_zoomingDirection == Right) {
            if (preFrame.size.width+offsetX <= self.minWidth) {
                offsetX = self.minWidth - preFrame.size.width;
            }
            self.pictureFrame = CGRectMake(preFrame.origin.x, preFrame.origin.y, preFrame.size.width+offsetX, preFrame.size.height);
            [self setNeedsDisplay];
            _touchedPoint = touchPoint;
            return YES;
        }
        // 四个角缩放
        CGPoint diagonalPoint;
        CGPoint cornerPoint;
        switch (_zoomingIndex) {
            case TopLeft:
            {
                diagonalPoint = _cornerPoint.bottomRightPoint;
                cornerPoint = _cornerPoint.topLeftPoint;
            }
                break;
            case TopRight:
            {
                diagonalPoint = _cornerPoint.bottomLeftPoint;
                cornerPoint = _cornerPoint.topRightPoint;
            }
                break;
            case BottomLeft:
            {
                diagonalPoint = _cornerPoint.topRightPoint;
                cornerPoint = _cornerPoint.bottomLeftPoint;
            }
                break;
            case BottomRight:
            {
                diagonalPoint = _cornerPoint.topLeftPoint;
                cornerPoint = _cornerPoint.bottomRightPoint;
            }
                break;
                
            default:
                break;
        }
        self.pictureFrame = [self pointToFrame:touchPoint cornerPoint:cornerPoint diagonalPoint:diagonalPoint zoomingIndex:_zoomingIndex];
        
    } else {
        // X和Y方向上的偏移量
        CGFloat offsetX = touchPoint.x - _touchedPoint.x;
        CGFloat offsetY = touchPoint.y - _touchedPoint.y;
        
        CGRect rect = self.pictureFrame;
        rect.origin.x += offsetX;
        rect.origin.y += offsetY;
        
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
    
    _touchedPoint = touchPoint;
    [self setNeedsDisplay];
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    // 代理回调
    if ([self.delegate respondsToSelector:@selector(photoCutView:shotFrame:)]) {
        [self.delegate photoCutView:self shotFrame:self.pictureFrame];
    }
    // 还原数据
    _touchedPoint = CGPointZero;
    _zooming = NO;
    _zoomingDirection = -1;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    // 还原数据
    _touchedPoint = CGPointZero;
    _zooming = NO;
    _zoomingDirection = -1;
}

// 根据触摸点，计算这个矩形的frame
- (CGRect)pointToFrame:(CGPoint)touching cornerPoint:(CGPoint)corner diagonalPoint:(CGPoint)diagonalPoint zoomingIndex:(CornerIndex)index {
    CGFloat width,height;
    CGPoint origin;
    
    CGFloat offsetX = touching.x - _touchedPoint.x;
    CGFloat offsetY = touching.y - _touchedPoint.y;
    
    switch (index) {
        case TopLeft:
        {
            origin = CGPointMake(corner.x + offsetX, corner.y + offsetY);
            width = diagonalPoint.x - corner.x - offsetX;
            height = diagonalPoint.y - corner.y - offsetY;
            if (width < self.minWidth) {
                width = self.minWidth;
                origin.x = diagonalPoint.x-self.minWidth;
            }
            if (height < self.minHeight) {
                height = self.minHeight;
                origin.y = diagonalPoint.y-self.minHeight;
            }
        }
            break;
        case TopRight:
        {
            origin = CGPointMake(diagonalPoint.x, corner.y + offsetY);
            width = corner.x + offsetX - diagonalPoint.x;
            height = diagonalPoint.y - corner.y - offsetY;
            if (width < self.minWidth) {
                width = self.minWidth;
                origin.x = diagonalPoint.x;
            }
            if (height < self.minHeight) {
                height = self.minHeight;
                origin.y = diagonalPoint.y - self.minHeight;
            }
        }
            break;
        case BottomLeft:
        {
            origin = CGPointMake(corner.x + offsetX, diagonalPoint.y);
            width = diagonalPoint.x - corner.x - offsetX;
            height = corner.y + offsetY - diagonalPoint.y;
            if (width < self.minWidth) {
                width = self.minWidth;
                origin.x = diagonalPoint.x-self.minWidth;
            }
            if (height < self.minHeight) {
                height = self.minHeight;
                origin.y = diagonalPoint.y;
            }
        }
            break;
        case BottomRight:
        {
            origin = diagonalPoint;
            width = corner.x + offsetX - diagonalPoint.x;
            height = corner.y + offsetY - diagonalPoint.y;
            if (width < self.minWidth) {
                width = self.minWidth;
                origin.x = diagonalPoint.x;
            }
            if (height < self.minHeight) {
                height = self.minHeight;
                origin.y = diagonalPoint.y;
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

// 判断touchPoint是否在以circleCenter为圆心、半径为touchRadius的圆内
- (BOOL)touchInCircleWithPoint:(CGPoint)touchPoint circleCenter:(CGPoint)circleCenter{
    YBPolarCoordinate polar = decartToPolar(circleCenter, touchPoint);
    if(polar.radius >= touchRadius) return NO;
    else return YES;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 蒙版层
    [[UIColor colorWithWhite:0.0 alpha:0.3] setFill];
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
    CGContextAddRect(ctx, CGRectMake(_cornerPoint.topLeftPoint.x-edge_3, _cornerPoint.topLeftPoint.y-edge_3, edge_20, edge_3));
    CGContextFillPath(ctx);
    CGContextAddRect(ctx, CGRectMake(_cornerPoint.topLeftPoint.x-edge_3, _cornerPoint.topLeftPoint.y-edge_3, edge_3, edge_20));
    CGContextFillPath(ctx);
    // 左下
    CGContextAddRect(ctx, CGRectMake(_cornerPoint.bottomLeftPoint.x-edge_3, _cornerPoint.bottomLeftPoint.y, edge_20, edge_3));
    CGContextFillPath(ctx);
    CGContextAddRect(ctx, CGRectMake(_cornerPoint.bottomLeftPoint.x-edge_3, _cornerPoint.bottomLeftPoint.y-edge_20+edge_3, edge_3, edge_20));
    CGContextFillPath(ctx);
    // 右上
    CGContextAddRect(ctx, CGRectMake(_cornerPoint.topRightPoint.x-edge_20+edge_3, _cornerPoint.topRightPoint.y-edge_3, edge_20, edge_3));
    CGContextFillPath(ctx);
    CGContextAddRect(ctx, CGRectMake(_cornerPoint.topRightPoint.x, _cornerPoint.topRightPoint.y-edge_3, edge_3, edge_20));
    CGContextFillPath(ctx);
    // 右下
    CGContextAddRect(ctx, CGRectMake(_cornerPoint.topRightPoint.x-edge_20+edge_3, _cornerPoint.bottomRightPoint.y, edge_20, edge_3));
    CGContextFillPath(ctx);
    CGContextAddRect(ctx, CGRectMake(_cornerPoint.bottomRightPoint.x, _cornerPoint.bottomRightPoint.y-edge_20+edge_3, edge_3, edge_20));
    CGContextFillPath(ctx);
    
    CGFloat direction_30 = 30;
    DirectionRect frame = directionPointToDirectionRect(_directionPoint, direction_30, edge_3);
    // 上
    CGContextAddRect(ctx, frame.topRect);
    CGContextFillPath(ctx);
    // 下
    CGContextAddRect(ctx, frame.bottomRect);
    CGContextFillPath(ctx);
    // 左
    CGContextAddRect(ctx, frame.leftRect);
    CGContextFillPath(ctx);
    // 右
    CGContextAddRect(ctx, frame.rightRect);
    CGContextFillPath(ctx);
    
    CGFloat height_1 = 1/[UIScreen mainScreen].scale;
    // 横一
    CGContextAddRect(ctx, CGRectMake((int)_cornerPoint.topLeftPoint.x, (int)(_cornerPoint.bottomLeftPoint.y-(_cornerPoint.bottomLeftPoint.y-_cornerPoint.topLeftPoint.y)/3*2), _cornerPoint.topRightPoint.x-_cornerPoint.topLeftPoint.x, height_1));
    CGContextFillPath(ctx);
    // 横二
    CGContextAddRect(ctx, CGRectMake((int)_cornerPoint.topLeftPoint.x, (int)(_cornerPoint.bottomLeftPoint.y-(_cornerPoint.bottomLeftPoint.y-_cornerPoint.topLeftPoint.y)/3), _cornerPoint.topRightPoint.x-_cornerPoint.topLeftPoint.x, height_1));
    CGContextFillPath(ctx);
    // 竖一
    CGContextAddRect(ctx, CGRectMake((int)(_cornerPoint.topRightPoint.x-(_cornerPoint.topRightPoint.x-_cornerPoint.topLeftPoint.x)/3*2), (int)_cornerPoint.topRightPoint.y, height_1, _cornerPoint.bottomLeftPoint.y-_cornerPoint.topLeftPoint.y));
    CGContextFillPath(ctx);
    // 竖二
    CGContextAddRect(ctx, CGRectMake((int)(_cornerPoint.topRightPoint.x-(_cornerPoint.topRightPoint.x-_cornerPoint.topLeftPoint.x)/3), (int)_cornerPoint.topRightPoint.y, height_1, _cornerPoint.bottomLeftPoint.y-_cornerPoint.topLeftPoint.y));
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
    
    corner.topLeftPoint = frame.origin;
    corner.topRightPoint = CGPointMake(frame.origin.x+frame.size.width, frame.origin.y);
    corner.bottomLeftPoint = CGPointMake(frame.origin.x, frame.origin.y+frame.size.height);
    corner.bottomRightPoint = CGPointMake(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height);
    
    return corner;
}

DirectionPoint cornerPointToDirection(CornerPoint corner) {
    DirectionPoint direction;
    
    direction.top = CGPointMake(corner.topRightPoint.x-(corner.topRightPoint.x-corner.topLeftPoint.x)/2, corner.topRightPoint.y);
    direction.bottom = CGPointMake(corner.topRightPoint.x-(corner.topRightPoint.x-corner.topLeftPoint.x)/2, corner.bottomRightPoint.y);
    direction.left = CGPointMake(corner.topLeftPoint.x, corner.bottomLeftPoint.y-(corner.bottomLeftPoint.y-corner.topLeftPoint.y)/2);
    direction.right = CGPointMake(corner.topRightPoint.x, corner.bottomLeftPoint.y-(corner.bottomLeftPoint.y-corner.topLeftPoint.y)/2);
    
    return direction;
}

// 宽高是水平方向的，如果是竖直方向则宽高反过来
DirectionRect directionPointToDirectionRect(DirectionPoint drt_point, CGFloat width, CGFloat height) {
    DirectionRect rect;
    
    rect.topRect = CGRectMake(drt_point.top.x-width/2, drt_point.top.y-height, width, height);
    rect.bottomRect = CGRectMake(drt_point.bottom.x-width/2, drt_point.bottom.y, width, height);
    rect.leftRect = CGRectMake(drt_point.left.x-height, drt_point.left.y-width/2, height, width);
    rect.rightRect = CGRectMake(drt_point.right.x, drt_point.right.y-width/2, height, width);
    
    return rect;
}

@end
