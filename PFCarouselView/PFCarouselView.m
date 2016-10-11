//
//  PFCarouselView.m
//  PFCarousel
//
//  Created by wuyuchen on 9/23/16.
//  Copyright © 2016 One. All rights reserved.
//

#import "PFCarouselView.h"



#pragma mark - PFCarouselImageView

typedef void(^PFCarouselImageViewTap)();

@interface PFCarouselImageView : UIImageView

@property (nonatomic, copy) PFCarouselImageViewTap tapBlock;

@property (nonatomic, assign) BOOL enable;

@end

@implementation PFCarouselImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self p_begin];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self p_begin];
    }
    
    return self;
}

- (void)p_begin
{
    self.userInteractionEnabled = YES;
    self.enable = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(action_tap)];
    [self addGestureRecognizer:tap];

}

- (void)action_tap
{
    if (!self.enable) {
        return;
    }
    
    if (self.tapBlock) {
        
        self.tapBlock();
    }
}

@end



#pragma mark - PFCarouselItem

@implementation PFCarouselItem


@end



#pragma mark - PFTimerBlockSupport(Category)

@interface NSTimer (PFTimerBlockSupport)

+ (NSTimer *)PF_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                       repeats:(BOOL)repeats
                                         block:(void (^)())block;

@end

@implementation NSTimer (PFTimerBlockSupport)

+ (NSTimer *)PF_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                       repeats:(BOOL)repeats
                                         block:(void (^)())block
{
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(PF_blockInvoke:)
                                       userInfo:[block copy]
                                        repeats:repeats];
}

+ (void)PF_blockInvoke:(NSTimer *)timer
{
    void (^block)() = timer.userInfo;
    
    if (block) {
        block();
    }
}

@end



#pragma mark - PFCarouselView

static const NSTimeInterval defaultTime = 2;


#define kWidth  CGRectGetWidth(_scrollView.frame)
#define kHeight CGRectGetHeight(_scrollView.frame)

@interface PFCarouselView () <UIScrollViewDelegate>
{
    NSArray * _items;
    
    NSMutableArray * _imageViewItems;
    
    NSTimer * _timer;
    
    NSTimeInterval _coolDownTime;
    
    UIScrollView  * __weak _scrollView;
    UIPageControl * __weak _pageControl;
    
    PFCarouselViewBlock _block;
    
}

@end

@implementation PFCarouselView

- (void)dealloc
{
    [_timer invalidate];
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero items:nil coolDownTime:defaultTime];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame items:nil coolDownTime:defaultTime];
}

+ (instancetype)carouselViewWithFrame:(CGRect)frame Items:(NSArray *)items coolDownTime:(NSTimeInterval)timeInterval
{
    return [[self alloc] initWithFrame:frame items:items coolDownTime:timeInterval];
}

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items coolDownTime:(NSTimeInterval)coolDownTime
{
    if (self = [super initWithFrame:frame]) {
        
        _coolDownTime = coolDownTime == 0 ? defaultTime : coolDownTime;
        
        [self p_begin];
        
        [self setItems:items];
        
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self p_begin];
    }
    
    return self;
}

#pragma mark - private

- (void)p_begin
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.alwaysBounceVertical = NO;
    scrollView.delegate = self;
    [self addSubview:scrollView];
    _scrollView = scrollView;
    
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
    pageControl.currentPage = 0;
    pageControl.userInteractionEnabled = NO;
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
    [self addSubview:pageControl];
    _pageControl = pageControl;
    
    
}


- (void)p_insertPageWithItemIndex:(NSInteger)index
{
    PFCarouselItem *item = _items[index];
    
    PFCarouselImageView *view = [PFCarouselImageView new];
    
    
    // You can change the code here...
    view.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:item.URLString ofType:@"jpg"]];
    
    __weak PFCarouselView *weakSelf = self;
    
    view.tapBlock = ^{
      
        [weakSelf p_handleBlockWithIndex:index];
    };
    
    
    [_scrollView addSubview:view];
    [_imageViewItems addObject:view];
}


- (void)p_handleBlockWithIndex:(NSInteger)index
{
    if (_block) {
        _block(_items[index], index);
    }

}

- (void)p_pageNext
{
    
    CGFloat currentOffsetX = _scrollView.contentOffset.x;
    
    if (currentOffsetX >= (_imageViewItems.count - 1) * kWidth) {
        
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        
        [_scrollView setContentOffset:CGPointMake(kWidth, 0) animated:YES];
        
    }
    else {
        [_scrollView setContentOffset:CGPointMake(currentOffsetX + kWidth, 0) animated:YES];
    }
}

- (void)p_pagePrevious
{
    CGFloat currentOffsetX = _scrollView.contentOffset.x;
    
    if (currentOffsetX < 0) {
        
        [_scrollView setContentOffset:CGPointMake(kWidth * (_imageViewItems.count - 1), 0) animated:NO];
        
        [_scrollView setContentOffset:CGPointMake(kWidth * (_imageViewItems.count - 2), 0) animated:YES];

    }
    else {
        
        [_scrollView setContentOffset:CGPointMake(currentOffsetX - kWidth, 0) animated:YES];

    }
}

- (void)p_startTimer
{
    if (_items.count <= 1) {
        return;
    }
    
    
    if (!_timer) {
        
        __weak PFCarouselView * weakSelf = self;
        
        _timer = [NSTimer PF_scheduledTimerWithTimeInterval:_coolDownTime repeats:YES block:^() {
            
            PFCarouselView * strongSelf = weakSelf;
            
            [strongSelf action_scroll];
        }];
    }
}

#pragma mark - setter

- (void)setItems:(NSArray *)items
{
    if (!items || items.count == 0) {
        return;
    }
    _items = nil;
    _items = [items copy];
    
    _scrollView.bounces = _items.count > 1;
    _pageControl.numberOfPages = _items.count;
    
    if (!_imageViewItems) {
        
        _imageViewItems = [NSMutableArray array];

    }
    else {
        
        [_imageViewItems makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_imageViewItems removeAllObjects];
    }
    
    NSInteger count = _items.count;
    
    for (int i = 0; i < count; i++) {
        
        [self p_insertPageWithItemIndex:i];
        
    }
    
    if (_items.count > 1) {
        
        // A image for infinite scroll
        
        [self p_insertPageWithItemIndex:0];
    }
    
    [self layoutSubviews];
}

- (void)setCurrentPageControlColor:(UIColor *)currentPageControlColor
{
    _currentPageControlColor = currentPageControlColor;
    _pageControl.currentPageIndicatorTintColor = currentPageControlColor;
}

- (void)setPFCarouselViewBlock:(PFCarouselViewBlock)block
{
    _block = [block copy];
}


#pragma mark - action

- (void)action_scroll
{
    [self p_pageNext];
}


#pragma mark - inhert

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _scrollView.frame  = self.bounds;
    _scrollView.contentSize = CGSizeMake(_imageViewItems.count * kWidth, kHeight);
    _pageControl.frame = CGRectMake(0, kHeight - 30, kWidth, 30);
    
    if (!_imageViewItems || _imageViewItems.count == 0) {
        return;
    }
    
    NSInteger count = _imageViewItems.count;
    
    for (int i = 0; i < count; i++) {
        
        PFCarouselImageView *imageView = _imageViewItems[i];
        
        imageView.frame = CGRectMake(kWidth * i, 0, kWidth, kHeight);
    }
    
    [self p_startTimer];
    
}


#pragma mark - delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.dragging) {
        
        _timer.fireDate = [NSDate distantFuture];
    }
    
    CGFloat x = scrollView.contentOffset.x;
    
    if (x > kWidth * (_imageViewItems.count - 1)) {
        
        [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        
    }
    
    if (x < 0) {
        
        [scrollView setContentOffset:CGPointMake(kWidth * (_imageViewItems.count - 1), 0) animated:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
    
    _timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:_coolDownTime];
    
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSInteger currentPage = scrollView.contentOffset.x / kWidth;
    
    if (currentPage + 1 > _pageControl.numberOfPages) {
        
        currentPage = 0;
    }
    
    _pageControl.currentPage = currentPage;
}


@end
