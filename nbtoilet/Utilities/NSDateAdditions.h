/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <Foundation/Foundation.h>

@interface NSDate (KalAdditions)

// All of the following methods use [NSCalendar currentCalendar] to perform
// their calculations.

- (NSDate *)cc_dateByMovingToBeginningOfDay;
- (NSDate *)cc_dateByMovingToEndOfDay;
- (NSDate *)cc_dateByMovingToFirstDayOfTheMonth;
- (NSDate *)cc_dateByMovingToFirstDayOfThePreviousMonth;
- (NSDate *)cc_dateByMovingToFirstDayOfTheFollowingMonth;
- (NSDateComponents *)cc_componentsForMonthDayAndYear;
- (NSUInteger)cc_weekday;//1~7   1 is sunday
- (NSUInteger)cc_numberOfDaysInMonth;
- (NSString *)stringWithFormat:(NSString *)format;


//ADD by Hongye 20130121
- (NSDate *)cc_dateByMovingToPreviousDay;
- (NSDate *)cc_dateByMovingToNextDay;
- (NSDate *)cc_dateByAddingDays:(NSInteger)days;
- (NSDate *)cc_dateByAddingMonths:(NSInteger)months;
- (NSDate *)cc_dateByAddingYears:(NSInteger)years;
- (NSString *)cc_dateStringWithFormat:(NSString *)format;
@end
