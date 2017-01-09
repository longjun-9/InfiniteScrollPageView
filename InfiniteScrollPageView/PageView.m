//
//  PageView.m
//  InfiniteScrollPageView
//
//  Created by vipabc on 2017/1/5.
//  Copyright © 2017年 vipabc. All rights reserved.
//

#import "PageView.h"

@implementation PageView

- (void)setContentView:(PageContentView *)contentView {
    if (_contentView) {
        [_contentView removeFromSuperview];
        [self removeConstraints:self.constraints];
    }
    _contentView = contentView;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:contentView];
    NSDictionary *viewsDic = @{ @"contentView" : contentView };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDic]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDic]];
}

@end
