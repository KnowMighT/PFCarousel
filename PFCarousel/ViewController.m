//
//  ViewController.m
//  PFCarousel
//
//  Created by wuyuchen on 9/23/16.
//  Copyright © 2016 One. All rights reserved.
//

#import "ViewController.h"
#import "PFCarouselView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // You should set this property to "NO" if you have a navigation bar.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSArray *dataSource = @[@"1", @"2", @"3", @"4"];
    
    NSInteger count = dataSource.count;
    
    NSMutableArray *itemsArr = [NSMutableArray array];
    
    for (int i = 0; i < count; i++) {
        
        PFCarouselItem *item = [[PFCarouselItem alloc] init];
        item.URLString = dataSource[i];
        [itemsArr addObject:item];
    }
    
    
    
    
    CGRect frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 200);
    
    PFCarouselView *view = [PFCarouselView carouselViewWithFrame:frame
                                                           Items:itemsArr
                                                    coolDownTime:2];
    
    [view setPFCarouselViewBlock:^(PFCarouselItem *item, NSInteger index) {
        
        NSLog(@"%ld",index);
        
    }];
    
    view.currentPageControlColor = [UIColor cyanColor];
    
    [self.view addSubview:view];
    
    
}


@end
