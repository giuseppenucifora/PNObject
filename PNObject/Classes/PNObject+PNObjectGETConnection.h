//
//  PNObjectConnection.h
//  Pods
//  Version 2.7.0
//
//  Created by Giuseppe Nucifora on 18/01/16.
//
//

#import "PNObject.h"
#import "PNObjectFormData.h"

@interface PNObject (PNObjectGETConnection)

#pragma mark - GET

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


+ (void) GETWithEndpointAction:(NSString * _Nonnull) endPoint
                      oauthMode:(OAuthMode) oauthMode
                      progress:(nullable void (^)(NSProgress * _Nullable downloadProgress)) downloadProgress
                       success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

+ (void) GETWithEndpointAction:(NSString * _Nonnull) endPoint
                      oauthMode:(OAuthMode) oauthMode
                    parameters:(NSDictionary * _Nullable) parameters
                      progress:(nullable void (^)(NSProgress * _Nullable downloadProgress)) downloadProgress
                       success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

+ (void) GETWithEndpointAction:(NSString * _Nonnull) endPoint
                      oauthMode:(OAuthMode) oauthMode
                    parameters:(NSDictionary * _Nullable) parameters
                       retries:(NSInteger) retries
                      progress:(nullable void (^)(NSProgress * _Nullable downloadProgress)) downloadProgress
                       success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

@end
