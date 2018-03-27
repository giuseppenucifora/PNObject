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
#import "PNObject+PNObjectConnection.h"

@implementation PNObject (PNObjectPOSTConnection)


+ (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                     parameters:(NSDictionary * _Nullable) parameters
                       progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    return [self POSTWithEndpointAction:endPoint oauthMode:OAuthModeClientCredential parameters:parameters retries:MAX_RETRIES progress:uploadProgress success:success failure:failure];
}

+ (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                     parameters:(NSDictionary * _Nullable) parameters
                        retries:(NSInteger) retries
                       progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    return [self POSTWithEndpointAction:endPoint oauthMode:OAuthModeClientCredential parameters:parameters retries:retries progress:uploadProgress success:success failure:failure];

}

+ (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                      oauthMode:(OAuthMode) oauthMode
                     parameters:(NSDictionary * _Nullable) parameters
                       progress:(nullable void (^)(NSProgress * _Nullable uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    return [self POSTWithEndpointAction:endPoint oauthMode:oauthMode parameters:parameters retries:MAX_RETRIES progress:uploadProgress success:success failure:failure];
}

+ (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                      oauthMode:(OAuthMode) oauthMode
                     parameters:(NSDictionary * _Nullable) parameters
                        retries:(NSInteger) retries
                       progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    
    if([[PNObjectConfig sharedInstance] setCredentialTokenForOauthMode:oauthMode]){
        
        [[[PNObjectConfig sharedInstance] manager] POST:[[[PNObjectConfig sharedInstance] endPointUrl] stringByAppendingFormat:@"%@",endPoint]  parameters:parameters progress:uploadProgress success:^(NSURLSessionDataTask *task, id responseObject) {
            
            if (success) {
                success(task,responseObject);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (retries > 0) {
                [[PNObjectConfig sharedInstance] refreshTokenForOauthMode:oauthMode retries:MAX_RETRIES WithBlockSuccess:^(BOOL refreshSuccess) {
                    
                    return [self POSTWithEndpointAction:endPoint parameters:parameters retries:retries-1 progress:uploadProgress success:success failure:failure];
                } failure:^(NSError * _Nonnull error) {
                    
                    if (failure) {
                        failure(nil,error);
                    }
                }];
            }
            else {
                if (failure) {
                    failure(task, error);
                }
            }
        }];
    }
    else {
        [[PNObjectConfig sharedInstance] refreshTokenForOauthMode:oauthMode retries:MAX_RETRIES WithBlockSuccess:^(BOOL refreshSuccess) {
            
            return [self POSTWithEndpointAction:endPoint oauthMode:oauthMode parameters:parameters retries:retries-1 progress:uploadProgress success:success failure:failure];
        } failure:^(NSError * _Nonnull error) {
            
            if (failure) {
                failure(nil,error);
            }
        }];
    }
}


+ (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                       formData:(NSArray * _Nullable) postFormData
                     parameters:(NSDictionary * _Nullable) parameters
                       progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    
    return [self POSTWithEndpointAction:endPoint  oauthMode:OAuthModeClientCredential formData:postFormData parameters:parameters retries:MAX_RETRIES progress:uploadProgress success:success failure:failure];
}


+ (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                       formData:(NSArray * _Nullable) postFormData
                     parameters:(NSDictionary * _Nullable) parameters
                        retries:(NSInteger) retries
                       progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    return [self POSTWithEndpointAction:endPoint  oauthMode:OAuthModeClientCredential formData:postFormData parameters:parameters retries:retries progress:uploadProgress success:success failure:failure];
}

+ (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                      oauthMode:(OAuthMode) oauthMode
                       formData:(NSArray * _Nullable) postFormData
                     parameters:(NSDictionary * _Nullable) parameters
                       progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    return [self POSTWithEndpointAction:endPoint  oauthMode:oauthMode formData:postFormData parameters:parameters retries:MAX_RETRIES progress:uploadProgress success:success failure:failure];
}

+ (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                      oauthMode:(OAuthMode) oauthMode
                       formData:(NSArray * _Nullable) postFormData
                     parameters:(NSDictionary * _Nullable) parameters
                        retries:(NSInteger) retries
                       progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    
    
    if([[PNObjectConfig sharedInstance] setCredentialTokenForOauthMode:oauthMode]){
        
        [[[PNObjectConfig sharedInstance] manager] POST:[[[PNObjectConfig sharedInstance] endPointUrl] stringByAppendingFormat:@"%@",endPoint]
                                             parameters:parameters
                              constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                  if (postFormData) {
                                      for (PNObjectFormData *postData in postFormData) {
                                          
                                          [formData appendPartWithFileData:[postData formData] name:[postData name] fileName:[postData fileName] mimeType:[postData mimeType]];
                                      }
                                  }
                              }
                                               progress:uploadProgress
                                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                    if (success) {
                                                        success(task,responseObject);
                                                    }
                                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                    if (retries > 0) {
                                                        [[PNObjectConfig sharedInstance] refreshTokenWithBlockSuccess:^(BOOL refreshSuccess) {
                                                            
                                                            return [self POSTWithEndpointAction:endPoint formData:postFormData parameters:parameters retries:retries-1 progress:uploadProgress success:success failure:failure];
                                                        } failure:^(NSError * _Nonnull error) {
                                                            
                                                            if (failure) {
                                                                failure(nil,error);
                                                            }
                                                        }];
                                                        
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
            
            return [self POSTWithEndpointAction:endPoint oauthMode:oauthMode formData:postFormData parameters:parameters retries:retries-1 progress:uploadProgress success:success failure:failure];
        } failure:^(NSError * _Nonnull error) {
            
            if (failure) {
                failure(nil,error);
            }
        }];
    }
}

@end
