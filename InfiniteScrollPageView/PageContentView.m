//
//  PageContentView.m
//  InfiniteScrollPageView
//
//  Created by Longjun on 2017/1/4.
//  Copyright © 2017年 Longjun. All rights reserved.
//

#import "PageContentView.h"

@interface PageContentView ()
@property (nonatomic, copy, nullable) NSString *reuseIdentifier;
@end

@implementation PageContentView

- (instancetype)initWithFrame:(CGRect)frame reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithFrame:frame];
    if (self) {
        self.reuseIdentifier = reuseIdentifier;
    }
    return self;
}

@end
