//
//  UIView+frame.h
//  imagePicker
//
//  Created by  apple on 16/9/20.
//  Copyright © 2016年 FYXin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (frame)


@property (nonatomic) CGFloat left;

@property (nonatomic) CGFloat top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  size;

+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer;

@end
