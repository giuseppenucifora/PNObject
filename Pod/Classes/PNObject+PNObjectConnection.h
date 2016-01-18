//
//  PNObjectConnection.h
//  Pods
//
//  Created by Giuseppe Nucifora on 18/01/16.
//
//

#import "PNObject.h"

@interface PNObject (PNObjectConnection)

- (NSURLSessionDataTask * _Nonnull)GETWithProgress:(void (^ _Nullable)(NSProgress * _Nonnull))downloadProgress
                                           success:(void (^ _Nullable)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                                           failure:(void (^ _Nullable)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure;

@end
