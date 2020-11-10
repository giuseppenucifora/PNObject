//
//  AFJSONResponseSerializerWithData.m
//  Pods
//  Version 2.7.0
//
//  Created by Giuseppe Nucifora on 08/02/16.
//
//

#import "AFJSONResponseSerializerWithData.h"

@implementation AFJSONResponseSerializerWithData

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    id JSONObject = [super responseObjectForResponse:response data:data error:error];
    NSHTTPURLResponse *currentResponse = (NSHTTPURLResponse*)response;
    
    if (*error != nil) {
        NSData *errorData = [[(*error).userInfo mutableCopy] objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSMutableDictionary *userInfo = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];;
       
        NSError *newError = [NSError errorWithDomain:(*error).domain code:currentResponse.statusCode userInfo:userInfo];
        (*error) = newError;
    }
    
    return (JSONObject);
}

@end
