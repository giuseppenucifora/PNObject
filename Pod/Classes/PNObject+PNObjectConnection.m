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

#define MAX_RETRIES 3

@implementation PNObject (PNObjectConnection)

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
    
    return [self GETWithEndpointAction:endPoint parameters:nil retries:MAX_RETRIES progress:downloadProgress success:success failure:failure];
}

+ (void) GETWithEndpointAction:(NSString * _Nonnull) endPoint
                    parameters:(NSDictionary * _Nullable) parameters
                       retries:(NSInteger) retries
                      progress:(nullable void (^)(NSProgress * _Nullable downloadProgress)) downloadProgress
                       success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    
    if ([[PNObjectConfig sharedInstance] currentOauthCredential] && ![[[PNObjectConfig sharedInstance] currentOauthCredential] isExpired]) {
        [[[PNObjectConfig sharedInstance] manager] GET:[[[PNObjectConfig sharedInstance] baseUrl] stringByAppendingFormat:@"%@",endPoint]  parameters:parameters progress:downloadProgress success:^(NSURLSessionDataTask *task, id responseObject) {
            
            if (success) {
                success(task,responseObject);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (retries > 0) {
                [[PNObjectConfig sharedInstance] refreshTokenWithBlockSuccess:^(BOOL refreshSuccess) {
                    
                    return [self GETWithEndpointAction:endPoint parameters:parameters retries:retries-1 progress:downloadProgress success:success failure:failure];
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
            
            return [self GETWithEndpointAction:endPoint parameters:parameters retries:retries-1 progress:downloadProgress success:success failure:failure];
        } failure:^(NSError * _Nonnull error) {
            if (failure) {
                failure(nil,error);
            }
        }];
    }
}
+ (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                     parameters:(NSDictionary * _Nullable) parameters
                       progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    return [self POSTWithEndpointAction:endPoint parameters:parameters retries:MAX_RETRIES progress:uploadProgress success:success failure:failure];
}

+ (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                     parameters:(NSDictionary * _Nullable) parameters
                        retries:(NSInteger) retries
                       progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    
    if ([[PNObjectConfig sharedInstance] currentOauthCredential] && ![[[PNObjectConfig sharedInstance] currentOauthCredential] isExpired]) {
        [[[PNObjectConfig sharedInstance] manager] POST:[[[PNObjectConfig sharedInstance] baseUrl] stringByAppendingFormat:@"%@",endPoint]  parameters:parameters progress:uploadProgress success:^(NSURLSessionDataTask *task, id responseObject) {
            
            if (success) {
                success(task,responseObject);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (retries > 0) {
                [[PNObjectConfig sharedInstance] refreshTokenWithBlockSuccess:^(BOOL refreshSuccess) {
                    
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
        [[PNObjectConfig sharedInstance] refreshTokenWithBlockSuccess:^(BOOL refreshSuccess) {
            
            return [self POSTWithEndpointAction:endPoint parameters:parameters retries:retries-1 progress:uploadProgress success:success failure:failure];
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
    
    return [self POSTWithEndpointAction:endPoint formData:postFormData parameters:parameters retries:MAX_RETRIES progress:uploadProgress success:success failure:failure];
}

+ (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                       formData:(NSArray * _Nullable) postFormData
                     parameters:(NSDictionary * _Nullable) parameters
                        retries:(NSInteger) retries
                       progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    
    if ([[PNObjectConfig sharedInstance] currentOauthCredential] && ![[[PNObjectConfig sharedInstance] currentOauthCredential] isExpired]) {
        [[[PNObjectConfig sharedInstance] manager] POST:[[[PNObjectConfig sharedInstance] baseUrl] stringByAppendingFormat:@"%@",endPoint]
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
        [[PNObjectConfig sharedInstance] refreshTokenWithBlockSuccess:^(BOOL refreshSuccess) {
            
            return [self POSTWithEndpointAction:endPoint formData:postFormData parameters:parameters retries:retries-1 progress:uploadProgress success:success failure:failure];
        } failure:^(NSError * _Nonnull error) {
            
            if (failure) {
                failure(nil,error);
            }
        }];
    }
}

+ (void) DELETEWithEndpointAction:(NSString * _Nonnull) endPoint
                       parameters:(NSDictionary * _Nullable) parameters
                         progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                          success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    return [self DELETEWithEndpointAction:endPoint parameters:parameters retries:MAX_RETRIES progress:uploadProgress success:success failure:failure];
}

+ (void) DELETEWithEndpointAction:(NSString * _Nonnull) endPoint
                       parameters:(NSDictionary * _Nullable) parameters
                          retries:(NSInteger) retries
                         progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                          success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject))success
                          failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {
    
    if ([[PNObjectConfig sharedInstance] currentOauthCredential] && ![[[PNObjectConfig sharedInstance] currentOauthCredential] isExpired]) {
        [[[PNObjectConfig sharedInstance] manager] DELETE:[[[PNObjectConfig sharedInstance] baseUrl] stringByAppendingFormat:@"%@",endPoint]
                                               parameters:parameters
                                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                      if (success) {
                                                          success(task,responseObject);
                                                      }
                                                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                      if (retries > 0) {
                                                          [[PNObjectConfig sharedInstance] refreshTokenWithBlockSuccess:^(BOOL refreshSuccess) {
                                                              
                                                              [self DELETEWithEndpointAction:endPoint parameters:parameters retries:retries-1 progress:uploadProgress success:success failure:failure];
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
        [[PNObjectConfig sharedInstance] refreshTokenWithBlockSuccess:^(BOOL refreshSuccess) {
            
            [self DELETEWithEndpointAction:endPoint parameters:parameters retries:retries-1 progress:uploadProgress success:success failure:failure];
        } failure:^(NSError * _Nonnull error) {
            
            if (failure) {
                failure(nil,error);
            }
        }];
    }
}


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
