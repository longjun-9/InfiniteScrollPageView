//
//  InfiniteScrollPageView.h
//  InfiniteScrollPageView
//
//  Created by vipabc on 2016/12/29.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol InfiniteScrollPageViewDelegate <NSObject>

@required
- (PageContentView *)reusablePageContentViewAtIndex:(NSInteger)index;

@end

@protocol InfiniteScrollPageViewDataSource <NSObject>

@required
- (NSInteger)numberOfPages;

@end

@interface InfiniteScrollPageView : UIView
@property (nonatomic, weak) id<InfiniteScrollPageViewDelegate> delegate;
@property (nonatomic, weak) id<InfiniteScrollPageViewDataSource> dataSource;

- (nullable __kindof PageContentView *)dequeueReusableContentViewWithIdentifier:(NSString *)identifier;
@end

NS_ASSUME_NONNULL_END
