//
//  NetService.m
//  doctorApp
//
//  Created by richardYang on 4/7/14.
//  Copyright (c) 2014 richardYang. All rights reserved.
//

#import "NetService.h"
//#import "commonConfig.h"
#import "ASIDownloadCache.h"
@implementation NetService
+(ASIFormDataRequest*)requestWithURL:(NSString*)urlString params:(NSMutableDictionary*)params httpMethod:(NSString*)httpMethod
{
    if ([httpMethod caseInsensitiveCompare:@"POST"] ==NSOrderedSame)
    {
        NSString *finalurl=[NSMutableString stringWithFormat:@"%@%@",HOST_URL,urlString];
        NSURL *url=[NSURL URLWithString:finalurl];
  
        ASIFormDataRequest * request=[ASIFormDataRequest requestWithURL:url];
        [request setRequestMethod:httpMethod];
        //request.delegate=self;
        request.timeOutSeconds=200;
        NSArray *allkeys=[params allKeys];
        for (int i=0; i<[allkeys count]; i++)
        {
            NSString *key=[allkeys objectAtIndex:i];
            id value=[params objectForKey:key];
            if ([value isKindOfClass:[NSData class]])
            {
                //post file
                [request addData:value forKey:key];
            }else
            {
                [request addPostValue:value forKey:key];
            }
        }
        return request;
    }else if([httpMethod caseInsensitiveCompare:@"GET"]==NSOrderedSame)
    {
        NSMutableString *paramString=[NSMutableString string];
        NSArray *allkeys=[params allKeys];
        for (int i=0;i<[allkeys count]; i++)
        {
            NSString *key=[allkeys objectAtIndex:i];
            id value=[params objectForKey:key];
            if (i==[allkeys count]-1) {
                [paramString appendFormat:@"%@=%@",key,value];
                break;
            }
            [paramString appendFormat:@"%@=%@&",key,value];
        }
        NSMutableString *finalurl=nil;
        finalurl=[NSMutableString stringWithFormat:@"%@%@%@",HOST_URL,urlString,paramString];
        NSURL *nsurl=[NSURL URLWithString:finalurl];
        ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:nsurl];
        [request setRequestMethod:httpMethod];
        request.timeOutSeconds=200;
        return request;
    }
    return nil;
}


@end
