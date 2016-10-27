//
//  NetService.h
//  doctorApp
//
//  Created by richardYang on 4/7/14.
//  Copyright (c) 2014 richardYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"

@interface NetService : NSObject

+(ASIFormDataRequest*)requestWithURL:(NSString*)urlString params:(NSMutableDictionary*)params httpMethod:(NSString*)httpMethod;
@end
