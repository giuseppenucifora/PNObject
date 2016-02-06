//
//  PNObjectConnection.h
//  Pods
//
//  Created by Giuseppe Nucifora on 18/01/16.
//
//

#import "PNObject.h"

@interface PNObject (PNObjectConnection)

+ (void) GETWithProgress:(nullable void (^)(NSProgress * _Nonnull downloadProgress)) downloadProgress
                 success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, PNObject * _Nullable responseObject))success
                 failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

+ (void) GETWithEndpointAction:(NSString * _Nonnull) endPoint
                      Progress:(nullable void (^)(NSProgress * _Nonnull downloadProgress)) downloadProgress
                       success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, PNObject * _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

+ (void) POSTWithProgress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                  success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, PNObject * _Nullable responseObject))success
                  failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

- (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                       Progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, PNObject * _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

@end
