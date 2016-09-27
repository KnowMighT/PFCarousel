# PFCarousel

## Notice
a simple carousel for iOS

In this project, I use the local images instead of downloading from the Internet. 

So if you want to use the net image, you may use `SDWebImage` and change the code in method:

    - (void)p_insertPageWithItemIndex:(NSInteger)index

## Sample Code

1.Prepare the dataSource

    NSMutableArray *itemsArr = [NSMutableArray array];
    
    for (int i = 0; i < count; i++) {
        
        PFCarouselItem *item = [[PFCarouselItem alloc] init];
        item.URLString = dataSource[i];
        [itemsArr addObject:item];
    }


2.Init

     PFCarouselView *view = [PFCarouselView carouselViewWithFrame:frame
                                                            Items:itemsArr
                                                     coolDownTime:2];
    
    [view setPFCarouselViewBlock:^(PFCarouselItem *item, NSInteger index) {
        NSLog(@"%ld",index);
    }];
    
    view.currentPageControlColor = [UIColor orangeColor];
    
    [self.view addSubview:view];




