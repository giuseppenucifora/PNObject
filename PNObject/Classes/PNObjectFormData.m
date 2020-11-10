//
//  PNObjectFormData.m
//  Pods
//  Version 2.7.0
//
//  Created by Giuseppe Nucifora on 16/02/16.
//
//

#import "PNObjectFormData.h"

@implementation PNObjectFormData

+ (instancetype _Nonnull) formDataFromNSData:(NSData * _Nonnull) formData name:(NSString * _Nonnull) name fileName:(NSString * _Nonnull) fileName mimeType:(NSString * _Nonnull) mimeType {
    PNObjectFormData * responseData = [PNObjectFormData new];

    [responseData setFormData:formData];
    [responseData setName:name];
    [responseData setFileName:fileName];
    [responseData setMimeType:mimeType];

    return responseData;
}

+ (instancetype _Nonnull) formDataFromUIImage:(UIImage * _Nonnull) image name:(NSString * _Nonnull) name fileName:(NSString * _Nonnull) fileName mimeType:(NSString * _Nonnull) mimeType {
    return [self formDataFromUIImage:image compression:1 name:name fileName:fileName mimeType:mimeType];
}

+ (instancetype _Nonnull) formDataFromUIImage:(UIImage * _Nonnull) image compression:(CGFloat) compression name:(NSString * _Nonnull) name fileName:(NSString * _Nonnull) fileName mimeType:(NSString * _Nonnull) mimeType {
    PNObjectFormData * responseData = [PNObjectFormData new];

    [responseData setFormData:UIImageJPEGRepresentation(image, compression)];
    [responseData setName:name];
    [responseData setFileName:fileName];
    [responseData setMimeType:mimeType];

    return responseData;
}

+ (instancetype _Nonnull) formDataFromFilepath:(NSString * _Nonnull) filePath name:(NSString * _Nonnull) name fileName:(NSString * _Nonnull) fileName mimeType:(NSString * _Nonnull) mimeType {
    return [self formDataFromFileUrl:[NSURL URLWithString:filePath] name:name fileName:fileName mimeType:mimeType];
}

+ (instancetype _Nonnull) formDataFromFileUrl:(NSURL * _Nonnull) fileUrl name:(NSString * _Nonnull) name fileName:(NSString * _Nonnull) fileName mimeType:(NSString * _Nonnull) mimeType {
    PNObjectFormData * responseData = [PNObjectFormData new];
    
    [responseData setFormData:[NSData dataWithContentsOfURL:fileUrl]];
    [responseData setName:name];
    [responseData setFileName:fileName];
    [responseData setMimeType:mimeType];
    
    return responseData;
}


@end
