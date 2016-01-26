//
//  PNObjectConnection.m
//  Pods
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



- (NSURLSessionDataTask * _Nonnull)GETWithProgress:(void (^ _Nullable)(NSProgress * _Nonnull))downloadProgress
                                           success:(void (^ _Nullable)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                                           failure:(void (^ _Nullable)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    
    return [[[PNObjectConfig sharedInstance] manager] GET:[[[PNObjectConfig sharedInstance] PNObjEndpoint] stringByAppendingFormat:@"%@",[[self class] objectClassName]]  parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        
        NSLogDebug(@"JSON: %@", responseObject);
        NSLogDebug(@"JSON: %@", [responseObject class]);
        
        self.JSON = [[NSDictionary alloc] initWithDictionary:responseObject];
        
        [self populateObjectFromJSON:responseObject];
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSLogDebug(@"Error: %@", error);
        
    }];
}


- (NSURLSessionDataTask *)POSTWithProgress:(nullable void (^)(NSProgress * _Nonnull)) uploadProgress
                                   success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                   failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    return [[[PNObjectConfig sharedInstance] manager] POST:[[[PNObjectConfig sharedInstance] PNObjEndpoint] stringByAppendingFormat:@"%@",[[self class] objectClassName]]
                                                parameters:[self getJSONObject] constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                                    
                                                } progress:^(NSProgress * _Nonnull _uploadProgress) {
                                                    if (uploadProgress) {
                                                        uploadProgress(_uploadProgress);
                                                    }
                                                } success:^(NSURLSessionDataTask * _Nonnull _task, id  _Nullable _responseObject) {
                                                    if (success) {
                                                        success(_task,_responseObject);
                                                    }
                                                } failure:^(NSURLSessionDataTask * _Nullable _task, NSError * _Nonnull _error) {
                                                    if (failure) {
                                                        failure(_task,_error);
                                                    }
                                                }];
}

- (NSURLSessionDataTask *)PUTWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                 failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    return [[[PNObjectConfig sharedInstance] manager] PUT:[[[PNObjectConfig sharedInstance] PNObjEndpoint] stringByAppendingFormat:@"%@",[[self class] objectClassName]]
                                               parameters:[self getJSONObject]
                                                  success:^(NSURLSessionDataTask * _Nonnull _task, id  _Nullable _responseObject) {
                                                      if (success) {
                                                          success(_task,_responseObject);
                                                      }
                                                  } failure:^(NSURLSessionDataTask * _Nullable _task, NSError * _Nonnull _error) {
                                                      if (failure) {
                                                          failure(_task,_error);
                                                      }
                                                  }];
}

- (NSURLSessionDataTask *)DELETEWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    return [[[PNObjectConfig sharedInstance] manager] DELETE:[[[PNObjectConfig sharedInstance] PNObjEndpoint] stringByAppendingFormat:@"%@",[[self class] objectClassName]]
                                                  parameters:[self getJSONObject]
                                                     success:^(NSURLSessionDataTask * _Nonnull _task, id  _Nullable _responseObject) {
                                                         if (success) {
                                                             success(_task,_responseObject);
                                                         }
                                                     } failure:^(NSURLSessionDataTask * _Nullable _task, NSError * _Nonnull _error) {
                                                         if (failure) {
                                                             failure(_task,_error);
                                                         }
                                                     }];
}

@end
