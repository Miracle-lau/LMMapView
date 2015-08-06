//
//  UIButton+FillColor.m
//  WeilianDemo
//
//  Created by 刘明 on 15/7/15.
//  Copyright (c) 2015年 刘明. All rights reserved.
//

#import "UIButton+FillColor.h"

@implementation UIButton (FillColor)

+ (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
