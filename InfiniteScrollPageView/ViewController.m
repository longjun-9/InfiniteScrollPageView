//
//  ViewController.m
//  InfiniteScrollPageView
//
//  Created by Longjun on 2017/1/5.
//  Copyright © 2017年 Longjun. All rights reserved.
//

#import "ViewController.h"
#import "InfiniteScrollPageView.h"
#import "CustomContentView.h"

@interface ViewController () <InfiniteScrollPageViewDelegate, InfiniteScrollPageViewDataSource>
@property (weak, nonatomic) IBOutlet InfiniteScrollPageView *scrollPageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.scrollPageView.delegate = self;
    self.scrollPageView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PageContentView *)reusablePageContentViewAtIndex:(NSInteger)index {
    static NSString *const identifier = @"ReusableContentView";
    CustomContentView *contentView = [self.scrollPageView dequeueReusableContentViewWithIdentifier:identifier];
    if (!contentView) {
        contentView = [[CustomContentView alloc] initWithFrame:CGRectZero reuseIdentifier:identifier];
    }

    if (!contentView.label) {
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor whiteColor];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.textAlignment = NSTextAlignmentCenter;
        contentView.label = label;
        [contentView addSubview:label];
        NSDictionary *viewsDic = @{ @"label" : label };
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-80-[label]-80-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDic]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-200-[label]-200-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDic]];
    }
    contentView.label.text = [NSString stringWithFormat:@"page index is %ld", index];
    return contentView;
}

- (NSInteger)numberOfPages {
    return 10;
}

@end
