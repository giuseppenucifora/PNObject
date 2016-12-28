//
//  PNObjectConnection.h
//  Pods
//
//  Created by Giuseppe Nucifora on 18/01/16.
//
//

#import "PNObject.h"
#import "PNObjectFormData.h"

@interface PNObject (PNObjectConnection)


+ (void) GETWithEndpointAction:(NSString * _Nonnull) endPoint
                      progress:(nullable void (^)(NSProgress * _Nullable downloadProgress)) downloadProgress
                       success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

+ (void) GETWithEndpointAction:(NSString * _Nonnull) endPoint
					parameters:(NSDictionary * _Nullable) parameters
                      progress:(nullable void (^)(NSProgress * _Nullable downloadProgress)) downloadProgress
                       success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

+ (void) GETWithEndpointAction:(NSString * _Nonnull) endPoint
                    parameters:(NSDictionary * _Nullable) parameters
                       retries:(NSInteger) retries
                      progress:(nullable void (^)(NSProgress * _Nullable downloadProgress)) downloadProgress
                       success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

+ (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                     parameters:(NSDictionary * _Nullable) parameters
                       progress:(nullable void (^)(NSProgress * _Nullable uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

+ (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                     parameters:(NSDictionary * _Nullable) parameters
                        retries:(NSInteger) retries
                       progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

+ (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                       formData:(NSArray * _Nullable) postFormData
                     parameters:(NSDictionary * _Nullable) parameters
                       progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

+ (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                       formData:(NSArray * _Nullable) postFormData
                     parameters:(NSDictionary * _Nullable) parameters
                        retries:(NSInteger) retries
                       progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

+ (void) DELETEWithEndpointAction:(NSString * _Nonnull) endPoint
                       parameters:(NSDictionary * _Nullable) parameters
                         progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                          success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

+ (void) DELETEWithEndpointAction:(NSString * _Nonnull) endPoint
                       parameters:(NSDictionary * _Nullable) parameters
                          retries:(NSInteger) retries
                         progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                          success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

+ (id _Nonnull) parseObjectFromResponse:(id _Nullable) response;

@end
