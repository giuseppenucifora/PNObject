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

+ (void) GETWithProgress:(nullable void (^)(NSProgress * _Nonnull downloadProgress)) downloadProgress
                                            success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, PNObject * _Nullable responseObject))success
                                            failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {

    if ([[PNObjectConfig sharedInstance] currentOauthCredential] && ![[[PNObjectConfig sharedInstance] currentOauthCredential] isExpired]) {

        [[[PNObjectConfig sharedInstance] manager] GET:[[[PNObjectConfig sharedInstance] baseUrl] stringByAppendingFormat:@"%@",[[self class] objectEndPoint]]
                                                   parameters:nil
                                                     progress:downloadProgress
                                                      success:^(NSURLSessionDataTask *task, id responseObject) {

            id PNObjectResponse = [[[self class] alloc] initWithJSON:[responseObject copy]];

            if (success) {
                success(task,PNObjectResponse);
            }

        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                failure(task,error);
            }
        }];
    }
    else {
        [[PNObjectConfig sharedInstance] refreshTokenForClientCredentialWithBlockSuccess:^(BOOL refreshSuccess) {

            [self GETWithProgress:downloadProgress success:success failure:failure];
        } failure:^(NSError * _Nonnull error) {
            
            
        }];
    }
}

+ (void) GETWithEndpointAction:(NSString * _Nonnull) endPoint
                                                 Progress:(nullable void (^)(NSProgress * _Nonnull downloadProgress)) downloadProgress
                                                  success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, PNObject * _Nullable responseObject))success
                                                  failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {


    if ([[PNObjectConfig sharedInstance] currentOauthCredential] && ![[[PNObjectConfig sharedInstance] currentOauthCredential] isExpired]) {

        [[[PNObjectConfig sharedInstance] manager] GET:[[[PNObjectConfig sharedInstance] baseUrl] stringByAppendingFormat:@"%@",endPoint]  parameters:nil progress:downloadProgress success:^(NSURLSessionDataTask *task, id responseObject) {

            id PNObjectResponse = [[[self class] alloc] initWithJSON:[responseObject copy]];

            if (success) {
                success(task,PNObjectResponse);
            }

        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                failure(task,error);
            }
        }];
    }
    else {
        [[PNObjectConfig sharedInstance] refreshTokenForClientCredentialWithBlockSuccess:^(BOOL refreshSuccess) {

            [self GETWithProgress:downloadProgress success:success failure:failure];
        } failure:^(NSError * _Nonnull error) {
            
            
        }];
    }
}

+ (void) POSTWithProgress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                                             success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, PNObject * _Nullable responseObject))success
                                             failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {



}

- (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                       Progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, PNObject * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {

    if ([[PNObjectConfig sharedInstance] currentOauthCredential] && ![[[PNObjectConfig sharedInstance] currentOauthCredential] isExpired]) {

        [[[PNObjectConfig sharedInstance] manager] POST:[[[PNObjectConfig sharedInstance] baseUrl] stringByAppendingFormat:@"%@",endPoint]  parameters:[self JSONFormObject] progress:uploadProgress success:^(NSURLSessionDataTask *task, id responseObject) {

            id PNObjectResponse = [[[self class] alloc] initWithJSON:[responseObject copy]];

            if (success) {
                success(task,PNObjectResponse);
            }

        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                failure(task,error);
            }
        }];
    }
    else {
        [[PNObjectConfig sharedInstance] refreshTokenForClientCredentialWithBlockSuccess:^(BOOL refreshSuccess) {

            [self POSTWithEndpointAction:endPoint Progress:uploadProgress success:success failure:failure];
        } failure:^(NSError * _Nonnull error) {
            
            
        }];
    }
}

/*+ (nullable NSURLSessionDataTask *) POSTConstructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData>  _Nonnull formData))block
 progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
 success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
 failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure {

 NSDictionary *parameters = [NSDictionary dictionary];

 [[[PNObjectConfig sharedInstance] manager] POST:[[[PNObjectConfig sharedInstance] baseUrl] stringByAppendingFormat:@"%@",[[self class] objectEndPoint]]
 parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

 } progress:^(NSProgress * _Nonnull uploadProgress) {

 } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

 }];
 }

 - (NSURLSessionDataTask * _Nonnull) GETWithProgress:(nullable void (^)(NSProgress * _Nonnull downloadProgress)) downloadProgress
 success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, PNObject * _Nullable responseObject))success
 failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure {

 return [[[PNObjectConfig sharedInstance] manager] GET:[[[PNObjectConfig sharedInstance] baseUrl] stringByAppendingFormat:@"%@",[[self class] objectEndPoint]]  parameters:nil progress:downloadProgress success:^(NSURLSessionDataTask *task, id responseObject) {

 [self resetObject];
 [self populateObjectFromJSON:responseObject];

 if (success) {
 success(task,self);
 }

 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
 if (failure) {
 failure(task,error);
 }
 }];
 }*/   


@end
