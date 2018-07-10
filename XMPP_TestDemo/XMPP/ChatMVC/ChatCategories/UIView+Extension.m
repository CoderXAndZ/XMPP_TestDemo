//
//  UIView+Extension.m
//  01-黑酷
//
//  Created by apple on 14-6-27.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

- (void)setFm_x:(CGFloat)fm_x {
    CGRect frame = self.frame;
    frame.origin.x = fm_x;
    self.frame = frame;
}

//- (void)setX:(CGFloat)x
//{
//    CGRect frame = self.frame;
//    frame.origin.x = x;
//    self.frame = frame;
//
//}

- (CGFloat)fm_x {
    return self.frame.origin.x;
}

//- (CGFloat)x
//{
//    return self.frame.origin.x;
//}

- (void)setFm_centerX:(CGFloat)fm_centerX {
    CGPoint center = self.center;
    center.x = fm_centerX;
    self.center = center;
}

//- (void)setCenterX:(CGFloat)centerX
//{
//    CGPoint center = self.center;
//    center.x = centerX;
//    self.center = center;
//}

- (CGFloat)fm_centerX {
    return self.center.x;
}

//- (CGFloat)centerX
//{
//    return self.center.x;
//}

- (void)setFm_centerY:(CGFloat)fm_centerY {
    CGPoint center = self.center;
    center.y = fm_centerY;
    self.center = center;
}

//- (void)setCenterY:(CGFloat)centerY
//{
//    CGPoint center = self.center;
//    center.y = centerY;
//    self.center = center;
//}

- (CGFloat)fm_centerY {
    return self.center.y;
}

//- (CGFloat)centerY
//{
//    return self.center.y;
//}

- (void)setFm_y:(CGFloat)fm_y {
    CGRect frame = self.frame;
    frame.origin.y = fm_y;
    self.frame = frame;
}
//- (void)setY:(CGFloat)y
//{
//    CGRect frame = self.frame;
//    frame.origin.y = y;
//    self.frame = frame;
//}

- (CGFloat)fm_y {
    return self.frame.origin.y;
}
//
//- (CGFloat)y
//{
//    return self.frame.origin.y;
//}

- (void)setFm_width:(CGFloat)fm_width {
    CGRect frame = self.frame;
    frame.size.width = fm_width;
    self.frame = frame;
}

//- (void)setWidth:(CGFloat)width
//{
//    CGRect frame = self.frame;
//    frame.size.width = width;
//    self.frame = frame;
//}

- (CGFloat)fm_width {
    return self.frame.size.width;
}

//- (CGFloat)width
//{
//    return self.frame.size.width;
//}

- (void)setFm_height:(CGFloat)fm_height {
    CGRect frame = self.frame;
    frame.size.height = fm_height;
    self.frame = frame;
}

//- (void)setHeight:(CGFloat)height
//{
//    CGRect frame = self.frame;
//    frame.size.height = height;
//    self.frame = frame;
//}

- (CGFloat)fm_height {
    return self.frame.size.height;
}
//- (CGFloat)height
//{
//    return self.frame.size.height;
//}

- (void)setFm_size:(CGSize)fm_size {
    CGRect frame = self.frame;
    frame.size = fm_size;
    self.frame = frame;
}

//- (void)setSize:(CGSize)size
//{
////    self.width = size.width;
////    self.height = size.height;
//    CGRect frame = self.frame;
//    frame.size = size;
//    self.frame = frame;
//}

- (CGSize)fm_size {
   return self.frame.size;
}

//- (CGSize)size
//{
//    return self.frame.size;
//}

@end
