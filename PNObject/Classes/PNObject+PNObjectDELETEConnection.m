//
//  PNObjectConnection.m
//  Pods
//
//  Created by Giuseppe Nucifora on 18/01/16.
//
//

#import "PNObject+PNObjectDELETEConnection.h"
#import "PNObjectConstants.h"
#import <NSDate_Utils/NSDate+NSDate_Util.h>
#import "PNObjectConfig.h"
#import "PNObjectModel.h"
#import <AFNetworking/AFNetworking.h>
#import "PNObject+Protected.h"
#import "PNObject+PNObjectConnection.h"

@implementation PNObject (PNObjectDELETEConnection)

+ (void) DELETEWithEndpointAction:(NSString * _Nonnull) endPoint
                       parameters:(NSDictionary * _Nullable) parameters
                         progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                          success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    return [self DELETEWithEndpointAction:endPoint oauthMode:OAuthModeNo parameters:parameters retries:MAX_RETRIES progress:uploadProgress success:success failure:failure];
}

+ (void) DELETEWithEndpointAction:(NSString * _Nonnull) endPoint
                       parameters:(NSDictionary * _Nullable) parameters
                          retries:(NSInteger) retries
                         progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                          success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    return [self DELETEWithEndpointAction:endPoint oauthMode:OAuthModeNo parameters:parameters retries:retries progress:uploadProgress success:success failure:failure];
}

+ (void) DELETEWithEndpointAction:(NSString * _Nonnull) endPoint
                         oauthMode:(OAuthMode) oauthMode
                       parameters:(NSDictionary * _Nullable) parameters
                         progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                          success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    return [self DELETEWithEndpointAction:endPoint oauthMode:oauthMode parameters:parameters retries:MAX_RETRIES progress:uploadProgress success:success failure:failure];
}

+ (void) DELETEWithEndpointAction:(NSString * _Nonnull) endPoint
                         oauthMode:(OAuthMode) oauthMode
                       parameters:(NSDictionary * _Nullable) parameters
                          retries:(NSInteger) retries
                         progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                          success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    
    if([[PNObjectConfig sharedInstance] setCredentialTokenForOauthMode:oauthMode]){
    
        [[[PNObjectConfig sharedInstance] manager] DELETE:[[[PNObjectConfig sharedInstance] endPointUrl] stringByAppendingFormat:@"%@",endPoint]
                                               parameters:parameters
                                                  headers:@{} 
                                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                      if (success) {
                                                          success(task,responseObject);
                                                      }
                                                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                      if (retries > 0) {
                                                          
                                                              return [self DELETEWithEndpointAction:endPoint
                                                                                    oauthMode:oauthMode
                                                                                  parameters:parameters
                                                                                     retries:retries-1
                                                                                    progress:uploadProgress
                                                                                     success:success
                                                                                     failure:failure];
                                                      }
                                                      else {
                                                          if (failure) {
                                                              failure(nil,error);
                                                          }
                                                      }
                                                  }];
        
    }
    else {
        [[PNObjectConfig sharedInstance] refreshTokenForOauthMode:oauthMode retries:MAX_RETRIES WithBlockSuccess:^(BOOL refreshSuccess) {
            
            [self DELETEWithEndpointAction:endPoint
                                  oauthMode:oauthMode
                                parameters:parameters
                                   retries:retries-1
                                  progress:uploadProgress
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
