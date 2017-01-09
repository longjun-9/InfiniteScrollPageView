//
//  InfiniteScrollPageView.m
//  InfiniteScrollPageView
//
//  Created by Longjun on 2016/12/29.
//  Copyright © 2016年 Longjun. All rights reserved.
//

#import "InfiniteScrollPageView.h"

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif

typedef NS_ENUM(NSUInteger, UIPanGestureRecognizerDirection) {
    UIPanGestureRecognizerDirectionUndefined,
    UIPanGestureRecognizerDirectionUp,
    UIPanGestureRecognizerDirectionDown,
    UIPanGestureRecognizerDirectionLeft,
    UIPanGestureRecognizerDirectionRight
};

@interface InfiniteScrollPageView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableArray *reusableContentViewQueue;

@property (nonatomic, strong) PageView *topView;
@property (nonatomic, strong) PageView *bottomView;

@property (nonatomic, assign) NSInteger indexOfDidLoadPage; // 该index用来记录上一次在屏幕中间完整显示的page的index
@property (nonatomic, assign) NSInteger indexOfWillAppearPage; // 该index用来记录即将出现的page的index
@property (nonatomic, assign) NSInteger pageCount;
@end

@implementation InfiniteScrollPageView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[PageView alloc] init];
    }
    return _topView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[PageView alloc] init];
    }
    return _bottomView;
}

- (void)setDelegate:(id<InfiniteScrollPageViewDelegate>)delegate {
    _delegate = delegate;
    [self loadFirstPage];
}

- (void)setDataSource:(id<InfiniteScrollPageViewDataSource>)dataSource {
    _dataSource = dataSource;
    self.pageCount = [_dataSource numberOfPages];
}

- (void)setup {
    [self setupData];
    [self setupView];
    [self addPanGesture];
}

- (void)setupData {
    self.indexOfDidLoadPage = 0;     // 首次加载第0页
    self.indexOfWillAppearPage = -1; // -1表示还没有要出现的页
    self.reusableContentViewQueue = [NSMutableArray array];
    if (self.dataSource) {
        self.pageCount = [self.dataSource numberOfPages];
    }
}

- (void)setupView {
    self.bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    self.topView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.bottomView];
    [self addSubview:self.topView];
    NSDictionary *viewsDic = @{ @"topView" : self.topView, @"bottomView" : self.bottomView };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDic]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDic]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDic]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[bottomView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDic]];
}

- (void)addPanGesture {
    UIPanGestureRecognizer *panRecognizer =
        [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panRecognizer];
    panRecognizer.delegate = self;
}

- (void)loadFirstPage {
    [self showContentViewOnPage:self.topView withIndex:self.indexOfDidLoadPage];
}

//

/**
 将ContentView显示在对应的pageView上, 其中包含出栈(在delegate中)

 @param pageView 要显示的页
 @param index 需要显示的页的index
 */
- (void)showContentViewOnPage:(PageView *)pageView withIndex:(NSInteger)index {
    if (self.delegate) {
        PageContentView *contentView = [self.delegate reusablePageContentViewAtIndex:index];
        pageView.index = index;
        pageView.contentView = contentView;
    }
}

- (void)enqueueReusableContentView:(PageContentView *)contentView {
    if (contentView) {
        [self.reusableContentViewQueue addObject:contentView];
    }
    DLog(@"After Enqueue, reusableContentViewQueue.count = %ld", self.reusableContentViewQueue.count);
}

- (nullable __kindof PageContentView *)dequeueReusableContentViewWithIdentifier:(NSString *)identifier {
    PageContentView *contentView = nil;
    if (self.reusableContentViewQueue.count > 0) {
        NSInteger destIndex = -1;
        for (NSInteger i = 0; i < self.reusableContentViewQueue.count; i++) {
            PageContentView *view = (PageContentView *) self.reusableContentViewQueue[i];
            if ([view.reuseIdentifier isEqualToString:identifier]) {
                contentView = view;
                destIndex = i;
                break;
            }
        }
        // 出栈
        [self.reusableContentViewQueue removeObjectAtIndex:destIndex];
    }
    DLog(@"After Dequeue, reusableContentViewQueue.count = %ld", self.reusableContentViewQueue.count);
    return contentView;
}

/**
 根据滑动的方向获取即将出现的page的index

 @param direction 滑动的方向
 @return 即将出现的page的index
 */
- (NSInteger)getIndexOfWillShowPageWithPanDirection:(UIPanGestureRecognizerDirection)direction {
    NSInteger index = -1;
    if (self.pageCount > 0) {
        switch (direction) {
            case UIPanGestureRecognizerDirectionLeft: {
                index = self.indexOfDidLoadPage + 1;
                if (index >= self.pageCount) {
                    index = index % self.pageCount;
                }

            } break;
            case UIPanGestureRecognizerDirectionRight: {
                index = self.indexOfDidLoadPage;
                if (0 == index) {
                    index = self.pageCount;
                }
                index--;
            } break;

            default:
                break;
        }
    }
    return index;
}

- (void)pageWillAppearWithPanDirection:(UIPanGestureRecognizerDirection)direction {
    self.indexOfWillAppearPage = [self getIndexOfWillShowPageWithPanDirection:direction];
    if (-1 == self.indexOfWillAppearPage) {
        self.indexOfWillAppearPage = 0;
    }
    // 加载新页
    [self showContentViewOnPage:self.bottomView withIndex:self.indexOfWillAppearPage];
}

- (void)pageWillDisappearWithFramesChangedCallback:(void (^)())callback {
    if (callback) {
        callback();
    }
    // 需要入栈
    [self enqueueReusableContentView:self.bottomView.contentView];
}

/**
 新的页已经加载,此时修改indexOfDidLoadPage的值
 */
- (void)pageDidLoadWithFramesChangedCallback:(void (^)())callback {
    // topView和bottomView互换
    PageView *view = self.topView;
    self.topView = self.bottomView;
    self.bottomView = view;

    // 改变层级关系
    [self bringSubviewToFront:self.topView];

    // 互换之后,修改indexOfDidLoadPage的值
    self.indexOfDidLoadPage = self.indexOfWillAppearPage;
    // frame改变的回调
    if (callback) {
        callback();
    }

    // 需要入栈
    [self enqueueReusableContentView:self.bottomView.contentView];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    CGRect topViewRect = self.topView.frame;
    CGRect bottomViewRect = self.bottomView.frame;
    CGPoint deltaPoint = [recognizer translationInView:self];
    DLog(@"gesture translatedPoint  is %@", NSStringFromCGPoint(deltaPoint));
    // 滑动手势结束
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled ||
        recognizer.state == UIGestureRecognizerStateFailed) {
        if (topViewRect.origin.x > 0) {
            // 右滑
            if (topViewRect.origin.x >= topViewRect.size.width / 8) {
                // 翻一页
                // 动画过程的目地frame
                topViewRect.origin.x = bottomViewRect.size.width;
                bottomViewRect.origin.x = 0;

                [UIView animateWithDuration:0.2
                    animations:^{
                        self.topView.frame = topViewRect;
                        self.bottomView.frame = bottomViewRect;
                    }
                    completion:^(BOOL finished) {
                        [self pageDidLoadWithFramesChangedCallback:^{
                            // 将新的bottomView隐藏到topView后面
                            CGRect rect = self.bottomView.frame;
                            rect.origin.x = self.topView.frame.origin.x;
                            self.bottomView.frame = rect;
                        }];
                    }];

            } else {
                // 复原
                // 动画过程的目地frame
                topViewRect.origin.x = 0;
                bottomViewRect.origin.x = -bottomViewRect.size.width;
                [UIView animateWithDuration:0.2
                    animations:^{
                        self.topView.frame = topViewRect;
                        self.bottomView.frame = bottomViewRect;
                    }
                    completion:^(BOOL finished) {
                        [self pageWillDisappearWithFramesChangedCallback:^{
                            // 让bottomView回到topView后面(层级关系不变)
                            CGRect rect = self.bottomView.frame;
                            rect.origin.x = self.topView.frame.origin.x;
                            self.bottomView.frame = rect;
                        }];
                    }];
            }
        } else if (topViewRect.origin.x < 0) {
            // 左滑
            if (-topViewRect.origin.x >= topViewRect.size.width / 8) {
                //  翻一页
                // 动画过程的目地frame
                topViewRect.origin.x = -topViewRect.size.width;
                bottomViewRect.origin.x = 0;

                [UIView animateWithDuration:0.2
                    animations:^{
                        self.topView.frame = topViewRect;
                        self.bottomView.frame = bottomViewRect;
                    }
                    completion:^(BOOL finished) {
                        [self pageDidLoadWithFramesChangedCallback:^{
                            // 将新的bottomView隐藏到topView后面
                            CGRect rect = self.bottomView.frame;
                            rect.origin.x = self.topView.frame.origin.x;
                            self.bottomView.frame = rect;
                        }];

                    }];
            } else {
                // 复原
                // 动画过程的目地frame
                topViewRect.origin.x = 0;
                bottomViewRect.origin.x = topViewRect.size.width;
                [UIView animateWithDuration:0.2
                    animations:^{
                        self.topView.frame = topViewRect;
                        self.bottomView.frame = bottomViewRect;
                    }
                    completion:^(BOOL finished) {
                        [self pageWillDisappearWithFramesChangedCallback:^{
                            // 让bottomView回到topView后面(层级关系不变)
                            CGRect rect = self.bottomView.frame;
                            rect.origin.x = self.topView.frame.origin.x;
                            self.bottomView.frame = rect;
                        }];

                    }];
            }

        } else {
            DLog("没有移动");
        }

    } else {
        // 刚开始移动时bottomView初始位置校正
        if (0 == topViewRect.origin.x) {
            DLog(@"校正Bottom View~~~~");
            UIPanGestureRecognizerDirection direction = UIPanGestureRecognizerDirectionUndefined;
            BOOL needLoadPage = NO;
            if (deltaPoint.x < 0) {
                // 左滑
                // 从右侧出来
                bottomViewRect.origin.x = topViewRect.size.width;
                direction = UIPanGestureRecognizerDirectionLeft;
                needLoadPage = YES;
            } else if (deltaPoint.x > 0) {
                // 右滑
                // 从左侧出来
                bottomViewRect.origin.x = -bottomViewRect.size.width;
                direction = UIPanGestureRecognizerDirectionRight;
                needLoadPage = YES;
            } else {
                DLog("没有检测到移动");
            }

            if (needLoadPage) {
                [self pageWillAppearWithPanDirection:direction];
            }
        }

        topViewRect.origin.x += deltaPoint.x;
        bottomViewRect.origin.x += deltaPoint.x;

        // topView位置校正
        if (fabs(topViewRect.origin.x) > topViewRect.size.width) {
            UIPanGestureRecognizerDirection direction = UIPanGestureRecognizerDirectionUndefined;
            if (topViewRect.origin.x > topViewRect.size.width) {
                // 调整为出现在bottomView的左边
                // 从左侧出来,所以是右移
                topViewRect.origin.x = bottomViewRect.origin.x - topViewRect.size.width;
                direction = UIPanGestureRecognizerDirectionRight;
            } else if (topViewRect.origin.x < -topViewRect.size.width) {
                // 调整为出现在bottomView的右边
                // 从右侧出来,所以是左移
                topViewRect.origin.x = bottomViewRect.origin.x + bottomViewRect.size.width;
                direction = UIPanGestureRecognizerDirectionLeft;
            } else {
                DLog(@"出错了!!!");
            }
            // 需要先入栈后出栈
            [self pageDidLoadWithFramesChangedCallback:nil];
            [self pageWillAppearWithPanDirection:direction];
        }
        // bottomView位置校正
        else if (fabs(bottomViewRect.origin.x) > bottomViewRect.size.width) {
            UIPanGestureRecognizerDirection direction = UIPanGestureRecognizerDirectionUndefined;
            if (bottomViewRect.origin.x > bottomViewRect.size.width) {
                // 调整为出现在topView的左边
                // 从左侧出来,所以是右移
                bottomViewRect.origin.x = topViewRect.origin.x - bottomViewRect.size.width;
                direction = UIPanGestureRecognizerDirectionRight;
            } else if (bottomViewRect.origin.x < -bottomViewRect.size.width) {
                // 调整为出现在topView的右边
                // 从右侧出来,所以是左移
                bottomViewRect.origin.x = topViewRect.origin.x + topViewRect.size.width;
                direction = UIPanGestureRecognizerDirectionLeft;
            } else {
                DLog(@"出错了!!!");
            }
            // 需要先入栈后出栈
            [self pageWillDisappearWithFramesChangedCallback:nil];
            [self pageWillAppearWithPanDirection:direction];
        }
        else {
            DLog(@"不需要校正位置~~");
            
        }
        self.topView.frame = topViewRect;
        self.bottomView.frame = bottomViewRect;

    }
    
    //初始化sender中的坐标位置。如果不初始化，移动坐标会一直积累起来。
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
}


@end
