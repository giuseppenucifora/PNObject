//
//  PNObjectConnection.h
//  Pods
//
//  Created by Giuseppe Nucifora on 18/01/16.
//
//

#import "PNObject.h"

@interface PNObject (PNObjectConnection)

+ (NSURLSessionDataTask * _Nonnull) GETWithProgress:(nullable void (^)(NSProgress * _Nonnull downloadProgress)) downloadProgress
											success:(nullable void (^)(NSURLSessionDataTask * _Nullable task, PNObject * _Nullable responseObject))success
											failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

@end
