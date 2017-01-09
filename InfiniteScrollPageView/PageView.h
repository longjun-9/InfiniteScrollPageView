//
//  PageView.h
//  InfiniteScrollPageView
//
//  Created by vipabc on 2017/1/5.
//  Copyright © 2017年 vipabc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentView.h"

@interface PageView : UIView
@property (nonatomic, strong, readwrite) PageContentView *contentView;
@property (nonatomic, assign, readwrite) NSInteger index;
@end
