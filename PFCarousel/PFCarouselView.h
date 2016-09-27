//
//  PFCarouselView.h
//  PFCarousel
//
//  Created by wuyuchen on 9/23/16.
//  Copyright © 2016 One. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 * PFCarousel's item model!
 *
 * You can add the property you need here...
 *
 * There's only Image URL now...
 */

@interface PFCarouselItem : NSObject

@property (nonatomic, copy) NSString *URLString;

@end


typedef void(^PFCarouselViewBlock)(PFCarouselItem *item, NSInteger index); // click block


@interface PFCarouselView : UIView

@property (nonatomic, assign, readonly) NSTimeInterval coolDownTime; // How often NSTimer call his method


@property (nonatomic, strong) UIColor *currentPageControlColor; // UIPageControl -> currentPageIndicatorTintColor



// Designated Initializer
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items coolDownTime:(NSTimeInterval)coolDownTime;

+ (instancetype)carouselViewWithFrame:(CGRect)frame Items:(NSArray *)items coolDownTime:(NSTimeInterval)coolDownTime;



/*
 * If you don't set Items in the initializer, you must call this method after init;
 */

- (void)setItems:(NSArray *)items;



/*
 * If you have the tap event for each item, you can call this method after init
 */

- (void)setPFCarouselViewBlock:(PFCarouselViewBlock)block;

@end
