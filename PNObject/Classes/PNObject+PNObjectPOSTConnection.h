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

@interface PNObject (PNObjectPOSTConnection)

#pragma mark - POST

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
                       oauthMode:(OAuthMode) oauthMode
                     parameters:(NSDictionary * _Nullable) parameters
                       progress:(nullable void (^)(NSProgress * _Nullable uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

+ (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                       oauthMode:(OAuthMode) oauthMode
                     parameters:(NSDictionary * _Nullable) parameters
                        retries:(NSInteger) retries
                       progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;


#pragma mark - FORM DATA

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

+ (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                       oauthMode:(OAuthMode) oauthMode
                       formData:(NSArray * _Nullable) postFormData
                     parameters:(NSDictionary * _Nullable) parameters
                       progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

+ (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                       oauthMode:(OAuthMode) oauthMode
                       formData:(NSArray * _Nullable) postFormData
                     parameters:(NSDictionary * _Nullable) parameters
                        retries:(NSInteger) retries
                       progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

@end
