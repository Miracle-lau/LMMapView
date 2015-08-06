//
//  Handler.h
//  WeilianDemo
//
//  Created by 刘明 on 15/7/14.
//  Copyright (c) 2015年 刘明. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Handler : NSObject

+ (CLLocationCoordinate2D *)coordinatesForString:(NSString *)string
                                 coordinateCount:(NSUInteger *)coordinateCount
                                      parseToken:(NSString *)token;

@end
