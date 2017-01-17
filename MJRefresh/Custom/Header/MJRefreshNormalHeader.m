//
//  MJRefreshNormalHeader.m
//  MJRefreshExample
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "MJRefreshNormalHeader.h"

@interface MJRefreshNormalHeader()
@property (weak, nonatomic) UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) UILabel *labelText;
@end

@implementation MJRefreshNormalHeader

#pragma mark - 重写父类的方法
- (void)prepare
{
    [super prepare];
    
    // 添加label
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0];
    label.font = [UIFont boldSystemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [self localizedStringForKey:MJRefreshHeaderIdleText];
    [self addSubview:label];
    self.labelText = label;
    
    // loading
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:loading];
    self.loadingView = loading;
    
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    self.labelText.frame = CGRectMake(0, 0, self.mj_w, self.mj_h);
    self.loadingView.center = self.labelText.center;
    
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    
    switch (state) {
        case MJRefreshStateIdle:
            self.labelText.hidden = NO;
            self.loadingView.hidden = YES;
            [self.loadingView stopAnimating];
            break;
        case MJRefreshStatePulling:
            self.labelText.hidden = YES;
            self.loadingView.hidden = NO;
            break;
        case MJRefreshStateRefreshing:
            self.labelText.hidden = YES;
            self.loadingView.hidden = NO;
            [self.loadingView startAnimating];
            break;
        default:
            break;
    }

}
@end
