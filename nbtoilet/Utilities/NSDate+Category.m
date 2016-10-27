//
//  NSDate+Category.m
//  WSFouncDesign
//
//  Created by wangsen on 14-7-28.
//  Copyright (c) 2014年 wangsen. All rights reserved.
//

#import "NSDate+Category.h"

@implementation NSDate (Category)

+ (NSString *)currentDate
{
   return [NSDate getCurrentDateTimeWithFormatStr:@"yyyy/MM/dd"];
}
+ (NSString *)currentOtherDate
{
    return [NSDate getCurrentDateTimeWithFormatStr:@"yyyy-MM-dd"];
}

+ (NSString *)currentTime
{
   return [NSDate getCurrentDateTimeWithFormatStr:@"HH:mm:ss"];
}
+ (NSString *)current_DateTime
{
    return [NSDate getCurrentDateTimeWithFormatStr:@"yyyy-MM-dd HH:mm:ss"];
}
+ (NSString *)getCurrentDateTimeWithFormatStr:(NSString *)formatStr
{
    //用[NSDate date]可以获取系统当前时间
    NSDate *date = [NSDate date];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:formatStr];
    //输出格式为：2010-10-27 10:22:13
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr;
}
@end
