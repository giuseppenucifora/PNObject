//
//  PNObjectConnection.m
//  Pods
//  Version 2.7.0
//
//  Created by Giuseppe Nucifora on 18/01/16.
//
//

#import "PNObject+PNObjectConnection.h"
#import "PNObjectConstants.h"
#import <NSDate_Utils/NSDate+NSDate_Util.h>
#import "PNObjectConfig.h"
#import "PNObjectModel.h"
#import <AFNetworking/AFNetworking.h>
#import "PNObject+Protected.h"

@implementation PNObject (PNObjectConnection)

#pragma mark Private Methods

+ (id _Nonnull) parseObjectFromResponse:(id _Nullable) response {
    
    id PNObjectResponse;
    if (response) {
        
        if ([response isKindOfClass:[NSDictionary class]] && [[response allKeys] count] > 0) {
            PNObjectResponse = [[[self class] alloc] initWithRemoteJSON:[response copy]];
        }
        else if ([response isKindOfClass:[NSArray class]] && [response count] > 0){
            
            NSMutableArray * resposeArray = [[NSMutableArray alloc] init];
            for (id singleObjectDict  in response) {
                if ([singleObjectDict isKindOfClass:[NSDictionary class]]) {
                    id singleObject = [[[self class] alloc] initWithRemoteJSON:singleObjectDict];
                    [resposeArray addObject:singleObject];
                }
            }
            
            PNObjectResponse = resposeArray;
        }
    }
    return PNObjectResponse;
}


+ (NSError* _Nonnull) getErrorFromTask:(NSURLSessionDataTask* _Nonnull) task andError:(NSError * _Nonnull) error {
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
    
    return [NSError errorWithDomain:[error domain] code:response.statusCode userInfo:serializedData];
}

#pragma mark -

@end
