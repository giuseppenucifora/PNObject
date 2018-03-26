//
//  PNObjectConnection.m
//  Pods
//
//  Created by Giuseppe Nucifora on 18/01/16.
//
//

#import "PNObject+PNObjectGETConnection.h"
#import "PNObject+PNObjectConnection.h"
#import "PNObjectConstants.h"
#import <NSDate_Utils/NSDate+NSDate_Util.h>
#import "PNObjectConfig.h"
#import "PNObjectModel.h"
#import <AFNetworking/AFNetworking.h>
#import "PNObject+Protected.h"

@implementation PNObject (PNObjectGETConnection)

+ (void) GETWithEndpointAction:(NSString * _Nonnull) endPoint
                      progress:(nullable void (^)(NSProgress * _Nonnull downloadProgress)) downloadProgress
                       success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    
    return [self GETWithEndpointAction:endPoint parameters:nil progress:downloadProgress success:success failure:failure];
    
}

+ (void) GETWithEndpointAction:(NSString * _Nonnull) endPoint
                    parameters:(NSDictionary * _Nullable) parameters
                      progress:(nullable void (^)(NSProgress * _Nullable downloadProgress)) downloadProgress
                       success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    
    return [self GETWithEndpointAction:endPoint authMode:OAuthModeClientCredential parameters:parameters retries:MAX_RETRIES progress:downloadProgress success:success failure:failure];
}

+ (void) GETWithEndpointAction:(NSString * _Nonnull) endPoint
                    parameters:(NSDictionary * _Nullable) parameters
                       retries:(NSInteger) retries
                      progress:(nullable void (^)(NSProgress * _Nullable downloadProgress)) downloadProgress
                       success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    
    return [self GETWithEndpointAction:endPoint authMode:OAuthModeClientCredential parameters:parameters retries:retries progress:downloadProgress success:success failure:failure];
}

+ (void) GETWithEndpointAction:(NSString * _Nonnull) endPoint
                      authMode:(OAuthMode) authMode
                      progress:(nullable void (^)(NSProgress * _Nullable downloadProgress)) downloadProgress
                       success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    return [self GETWithEndpointAction:endPoint authMode:authMode parameters:nil retries:MAX_RETRIES progress:downloadProgress success:success failure:failure];
}

+ (void) GETWithEndpointAction:(NSString * _Nonnull) endPoint
                      authMode:(OAuthMode) authMode
                    parameters:(NSDictionary * _Nullable) parameters
                       progress:(nullable void (^)(NSProgress * _Nullable downloadProgress)) downloadProgress
                       success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    return [self GETWithEndpointAction:endPoint authMode:authMode parameters:parameters retries:MAX_RETRIES progress:downloadProgress success:success failure:failure];
}

+ (void) GETWithEndpointAction:(NSString * _Nonnull) endPoint
                      authMode:(OAuthMode) authMode
                    parameters:(NSDictionary * _Nullable) parameters
                       retries:(NSInteger) retries
                      progress:(nullable void (^)(NSProgress * _Nullable downloadProgress)) downloadProgress
                       success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    
    if ([[PNObjectConfig sharedInstance] currentOauthClientCredential] && ![[[PNObjectConfig sharedInstance] currentOauthClientCredential] isExpired]) {
        [[[PNObjectConfig sharedInstance] manager] GET:[[[PNObjectConfig sharedInstance] endPointUrl] stringByAppendingFormat:@"%@",endPoint]  parameters:parameters progress:downloadProgress success:^(NSURLSessionDataTask *task, id responseObject) {
            
            if (success) {
                success(task,responseObject);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (retries > 0) {
                [[PNObjectConfig sharedInstance] refreshTokenWithBlockSuccess:^(BOOL refreshSuccess) {
                    
                    return [self GETWithEndpointAction:endPoint
                                              authMode:authMode
                                            parameters:parameters
                                               retries:retries-1
                                              progress:downloadProgress
                                               success:success
                                               failure:failure];
                } failure:^(NSError * _Nonnull error) {
                    if (failure) {
                        failure(nil,error);
                    }
                }];
                return;
            }else {
                if (failure) {
                    failure(task,error);
                }
            }
        }];
    }
    else {
        [[PNObjectConfig sharedInstance] refreshTokenWithBlockSuccess:^(BOOL refreshSuccess) {
            
            return [self GETWithEndpointAction:endPoint
                                      authMode:authMode
                                    parameters:parameters
                                       retries:retries-1
                                      progress:downloadProgress
                                       success:success
                                       failure:failure];
        } failure:^(NSError * _Nonnull error) {
            if (failure) {
                failure(nil,error);
            }
        }];
    }
}

@end
