//
//  NSArray+JSON.m
//  Trip2013
//
//  Created by Ryou Zhang on 7/22/13.
//  Copyright (c) 2013 alibaba. All rights reserved.
//

#import "NSArray+JSON.h"

@implementation NSArray (JSON)
- (NSString *)jsonString {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:0
                                                         error:&error];
    if (error)
        return nil;
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}
@end
