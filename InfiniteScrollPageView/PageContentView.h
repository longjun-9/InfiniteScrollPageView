

//
//  PageContentView.h
//  InfiniteScrollPageView
//
//  Created by Longjun on 2017/1/4.
//  Copyright © 2017年 Longjun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PageContentView : UIView

@property (nonatomic, readonly, copy, nullable) NSString *reuseIdentifier;

- (instancetype)initWithFrame:(CGRect)frame reuseIdentifier:(nullable NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
