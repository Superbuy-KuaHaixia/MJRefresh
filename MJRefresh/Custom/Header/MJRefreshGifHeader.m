//
//  MJRefreshGifHeader.m
//  MJRefreshExample
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "MJRefreshGifHeader.h"

@interface MJGifView : UIView
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;
@end
@implementation MJGifView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    self.startAngle = self.endAngle = 3 * M_PI_2;
    self.endAngle += self.progress * 2 * M_PI;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 2.0);
    CGContextSetRGBStrokeColor(ctx, 153.0/255, 153.0/255, 153.0/255, 1.0);
    CGFloat centerX = 0, centerY = 0, radius = 0;
    if (self.subviews.count) {
        UIView *view = self.subviews[0];
        radius = 15;
        centerX = view.mj_w - radius;
        centerY = view.mj_h * 0.5 - radius * 0.5 + 8;
    }
    CGContextAddArc(ctx, centerX, centerY, radius, self.startAngle, self.endAngle, 0);
    CGContextStrokePath(ctx);
    self.startAngle = self.endAngle;
}
@end

@interface MJRefreshGifHeader()
{
    __unsafe_unretained UIImageView *_gifView;
}
/** 所有状态对应的动画图片 */
@property (strong, nonatomic) NSMutableDictionary *stateImages;
/** 所有状态对应的动画时间 */
@property (strong, nonatomic) NSMutableDictionary *stateDurations;
@end

@implementation MJRefreshGifHeader
#pragma mark - 懒加载
- (UIImageView *)gifView
{
    if (!_gifView) {
        CGFloat width = [UIScreen mainScreen].bounds.size.height;
        MJGifView *gifView = [[MJGifView alloc] initWithFrame:CGRectMake(0, MJRefreshHeaderViewOffsetY, width, MJRefreshHeaderHeight - MJRefreshHeaderViewOffsetY)];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, gifView.mj_w, gifView.mj_h)];
        [gifView addSubview:(_gifView = imgView)];
        [self addSubview:gifView];
    } 
    return _gifView;
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    [super scrollViewContentOffsetDidChange:change];
    if (self.state == MJRefreshStateIdle && self.pullingPercent <= 1.0) {
        if ([self.gifView.superview isKindOfClass:[MJGifView class]]) {
            MJGifView *view = (MJGifView *)self.gifView.superview;
            view.progress = self.pullingPercent;
            [view setNeedsDisplay];
        }
    }
    if (self.state == MJRefreshStateRefreshing && self.pullingPercent >= 1.0) {
        if ([self.gifView.superview isKindOfClass:[MJGifView class]]) {
            MJGifView *view = (MJGifView *)self.gifView.superview;
            view.progress = 0;
            [view setNeedsDisplay];
        }
    }
}

- (NSMutableDictionary *)stateImages
{ 
    if (!_stateImages) { 
        self.stateImages = [NSMutableDictionary dictionary]; 
    } 
    return _stateImages; 
}

- (NSMutableDictionary *)stateDurations 
{ 
    if (!_stateDurations) { 
        self.stateDurations = [NSMutableDictionary dictionary]; 
    } 
    return _stateDurations; 
}

- (UILabel *)backLabel
{
    if (!_backLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 42)];
        label.font = [UIFont systemFontOfSize:20];
        label.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [self localizedStringForKey:MJRefreshHeaderBackgroundText];
        [self addSubview:(_backLabel = label)];
    }
    return _backLabel;
}

#pragma mark - 公共方法
- (void)setImages:(NSArray *)images duration:(NSTimeInterval)duration forState:(MJRefreshState)state 
{ 
    if (images == nil) return; 
    
    self.stateImages[@(state)] = images; 
    self.stateDurations[@(state)] = @(duration); 
    
    /* 根据图片设置控件的高度 */ 
    UIImage *image = [images firstObject]; 
    if (image.size.height > self.mj_h) { 
        self.mj_h = image.size.height; 
    } 
}

- (void)setImages:(NSArray *)images forState:(MJRefreshState)state 
{ 
    [self setImages:images duration:images.count * 0.1 forState:state]; 
}

#pragma mark - 实现父类的方法
- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
    NSArray *images = self.stateImages[@(MJRefreshStateIdle)];
    if (self.state != MJRefreshStateIdle || images.count == 0) return;
    // 停止动画
    [self.gifView stopAnimating];
    // 设置当前需要显示的图片
    NSUInteger index =  images.count * pullingPercent;
    if (index >= images.count) index = images.count - 1;
    self.gifView.image = images[index];
}

- (void)placeSubviews
{
    [super placeSubviews];
    BOOL noConstrainsOnStatusLabel = self.stateLabel.constraints.count == 0;
    if (noConstrainsOnStatusLabel) {
        CGRect frame = self.stateLabel.frame;
        self.stateLabel.frame = CGRectMake(frame.origin.x, frame.origin.y + MJRefreshHeaderViewOffsetY, frame.size.width, MJRefreshHeaderHeight - MJRefreshHeaderViewOffsetY);
    }
    if (self.gifView.constraints.count) return;
    self.gifView.frame = CGRectMake(0, 0, self.mj_w, MJRefreshHeaderHeight - MJRefreshHeaderViewOffsetY);
    if (self.stateLabel.hidden && self.lastUpdatedTimeLabel.hidden) {
        self.gifView.contentMode = UIViewContentModeCenter;
    } else {
        self.gifView.contentMode = UIViewContentModeRight;
        self.gifView.mj_w = self.mj_w * 0.5 - 30;
        self.stateLabel.textAlignment = NSTextAlignmentLeft;
        self.stateLabel.mj_x = self.gifView.x + self.gifView.mj_w + 10;
    }
    
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    
    // 根据状态做事情
    if (state == MJRefreshStatePulling || state == MJRefreshStateRefreshing) {
        NSArray *images = self.stateImages[@(state)];
        if (images.count == 0) return;
        
        [self.gifView stopAnimating];
        if (images.count == 1) { // 单张图片
            self.gifView.image = [images lastObject];
        } else { // 多张图片
            self.gifView.animationImages = images;
            self.gifView.animationDuration = [self.stateDurations[@(state)] doubleValue];
            [self.gifView startAnimating];
        }
    } else if (state == MJRefreshStateIdle) {
        [self.gifView stopAnimating];
    }
    [self placeSubviews];
}
@end
