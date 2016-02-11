//
//  PNObjectConnection.h
//  Pods
//
//  Created by Giuseppe Nucifora on 18/01/16.
//
//

#import "PNObject.h"

@interface PNObject (PNObjectConnection)


- (void) GETWithEndpointAction:(NSString * _Nonnull) endPoint
                      progress:(nullable void (^)(NSProgress * _Nonnull downloadProgress)) downloadProgress
                       success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
                       failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

- (void) POSTWithEndpointAction:(NSString * _Nonnull) endPoint
                     parameters:(NSDictionary * _Nonnull) parameters
                       progress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                        success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject))success
                        failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

@end
