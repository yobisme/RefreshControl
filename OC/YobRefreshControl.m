//
//  YobRefreshControl.m
//  XQJ
//
//  Created by Macx on 2016/1/14.
//  Copyright © 2016年 Macx. All rights reserved.
//

#import "YobRefreshControl.h"
CGFloat RefreshControlHeight = 50;

typedef enum : NSUInteger {
    YobRefreshControlTypenormal,
    YobRefreshControlTypepulling,
    YobRefreshControlTyperefreshing
} YobRefreshControlType;

@interface YobRefreshControl ()

@property (nonatomic,strong)UIScrollView * currentScrollView;
@property (nonatomic,assign)YobRefreshControlType refreshType;
@property (nonatomic,strong)UIImageView *pullDownImageView;
@property (nonatomic,strong)UILabel * messageLabel;
@property (nonatomic,strong)UIActivityIndicatorView *indicatorView;

@end

@implementation YobRefreshControl

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    UIImageView *pullDownImageView = [[UIImageView alloc] init];
    pullDownImageView.image = [UIImage imageNamed:@"v2_pullRefresh1"];
    [self addSubview:pullDownImageView];
    _pullDownImageView= pullDownImageView;
    
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *messageLabel = [UILabel new];
    messageLabel.font = [UIFont systemFontOfSize:12];
    messageLabel.text = @"下拉刷新";
    messageLabel.textColor = [UIColor grayColor];
    [self addSubview:messageLabel];
    _messageLabel = messageLabel;
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:indicatorView];
    _indicatorView = indicatorView;
    
    pullDownImageView.translatesAutoresizingMaskIntoConstraints = NO;
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:pullDownImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
     [self addConstraint:[NSLayoutConstraint constraintWithItem:pullDownImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:-35]];
    
     [self addConstraint:[NSLayoutConstraint constraintWithItem:messageLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:pullDownImageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
     [self addConstraint:[NSLayoutConstraint constraintWithItem:messageLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:pullDownImageView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
     [self addConstraint:[NSLayoutConstraint constraintWithItem:indicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:pullDownImageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
     [self addConstraint:[NSLayoutConstraint constraintWithItem:indicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:pullDownImageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

}

- (void)setRefreshType:(YobRefreshControlType)refreshType
{
    _refreshType = refreshType;
    
    switch (refreshType) {
        case YobRefreshControlTypenormal:
        {
            self.pullDownImageView.hidden = NO;
            [_indicatorView stopAnimating];
            _messageLabel.text = @"下拉刷新";
            [UIView animateWithDuration:0.25 animations:^{
                //刷新的动画图片
                self.pullDownImageView.image = [UIImage imageNamed:@"v2_pullRefresh1"];
            } completion:^(BOOL finished) {
              if(refreshType == YobRefreshControlTyperefreshing)
              {
                  [UIView animateWithDuration:0.25 animations:^{
                      UIEdgeInsets edgeInset = self.currentScrollView.contentInset;
                      edgeInset.top -= RefreshControlHeight;
                      self.currentScrollView.contentInset = edgeInset;
                  }];
              }
            }];
            
        }
            break;
            case YobRefreshControlTypepulling:
        {
            [UIView animateWithDuration:0.25 animations:^{
                //默认图片
               self.pullDownImageView.image = [UIImage imageNamed:@"v2_pullRefresh2"];
            }];
            self.messageLabel.text = @"松手就刷新";
        }
            break;
        case YobRefreshControlTyperefreshing:
        {
            self.pullDownImageView.hidden = YES;
            [self.indicatorView startAnimating];
            _messageLabel.text = @"正在刷新...";
            [UIView animateWithDuration:0.25 animations:^{
                UIEdgeInsets edgeInset = self.currentScrollView.contentInset;
                edgeInset.top += RefreshControlHeight;
                self.currentScrollView.contentInset = edgeInset;
            }];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
            break;
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ([newSuperview isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *scrollView = (UIScrollView *)newSuperview;
        
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        
        CGRect tempRect = self.frame;
        tempRect.size.width = scrollView.frame.size.width;
        tempRect.size.height = RefreshControlHeight;
        tempRect.origin.y = -RefreshControlHeight;
        self.frame = tempRect;
        
        _currentScrollView = scrollView;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    CGFloat contentOffsetY = _currentScrollView.contentOffset.y;
    
    if ([self.currentScrollView isDragging])
    {
        CGFloat limitMaxY = -(_currentScrollView.contentInset.top + RefreshControlHeight);
        
        if (contentOffsetY < limitMaxY && self.refreshType == YobRefreshControlTypenormal) {
           
            self.refreshType = YobRefreshControlTypepulling;
            
        } else if (contentOffsetY >= limitMaxY && self.refreshType == YobRefreshControlTypepulling) {
            
            self.refreshType = YobRefreshControlTypenormal;
        }
    }else
    {
        if (self.refreshType == YobRefreshControlTypepulling) {
            
            self.refreshType = YobRefreshControlTyperefreshing;
        }
    }
    
}

- (void)endRefreshing
{
    self.refreshType = YobRefreshControlTypenormal;
}

- (void)dealloc
{
    
}

@end
