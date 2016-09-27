//
//  PFCarouselView.h
//  PFCarousel
//
//  Created by wuyuchen on 9/23/16.
//  Copyright © 2016 One. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 * You can add the property you need here...
 */

@interface PFCarouselItem : NSObject

@property (nonatomic, copy) NSString *URLString;

@end


typedef void(^PFCarouselViewBlock)(PFCarouselItem *item, NSInteger index);

@interface PFCarouselView : UIView

@property (nonatomic, assign, readonly) NSTimeInterval coolDownTime;

@property (nonatomic, strong) UIColor *currentPageControlColor;

// Designated Initializer
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items coolDownTime:(NSTimeInterval)coolDownTime;

+ (instancetype)carouselViewWithFrame:(CGRect)frame Items:(NSArray *)items coolDownTime:(NSTimeInterval)coolDownTime;

/*
 * If you don't set Items in the initializer, you must call this method after init;
 *
 */
- (void)setItems:(NSArray *)items;

/*
 * If you have the tap event for each item, you can call this method after init
 *
 */

- (void)setPFCarouselViewBlock:(PFCarouselViewBlock)block;

@end
