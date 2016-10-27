//
//  NSString+JSON.m
//  Trip2013
//
//  Created by Ryou Zhang on 7/22/13.
//  Copyright (c) 2013 alibaba. All rights reserved.
//

#import "NSString+JSON.h"

@implementation NSString (JSON)
- (id)jsonObject {
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                                options:NSJSONReadingMutableContainers
                                                  error:&error];
    if (error || [NSJSONSerialization isValidJSONObject:result] == NO)
        return nil;
    
//    if ([result isKindOfClass:[NSMutableArray class]]) {
//        arrayFilterNullNode(result);
//    } else if([result isKindOfClass:[NSMutableDictionary class]]) {
//        dictionaryFilterNullNode(result);
//    }
    return result;
}
@end
