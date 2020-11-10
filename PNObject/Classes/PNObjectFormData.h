//
//  PNObjectFormData.h
//  Pods
//  Version 2.7.0
//
//  Created by Giuseppe Nucifora on 16/02/16.
//
//

#import <Foundation/Foundation.h>

@interface PNObjectFormData : NSObject

@property (nonatomic, strong, nonnull) NSData *formData;
@property (nonatomic, strong, nonnull) NSString * name;
@property (nonatomic, strong, nonnull) NSString * fileName;
@property (nonatomic, strong, nonnull) NSString * mimeType;

/**
 *  <#Description#>
 *
 *  @param formData <#formData description#>
 *  @param name     <#name description#>
 *  @param fileName <#fileName description#>
 *  @param mimeType <#mimeType description#>
 *
 *  @return <#return value description#>
 */
+ (instancetype _Nonnull) formDataFromNSData:(NSData * _Nonnull) formData name:(NSString * _Nonnull) name fileName:(NSString * _Nonnull) fileName mimeType:(NSString * _Nonnull) mimeType;
/**
 *  <#Description#>
 *
 *  @param image    <#image description#>
 *  @param name     <#name description#>
 *  @param fileName <#fileName description#>
 *  @param mimeType <#mimeType description#>
 *
 *  @return <#return value description#>
 */
+ (instancetype _Nonnull) formDataFromUIImage:(UIImage * _Nonnull) image name:(NSString * _Nonnull) name fileName:(NSString * _Nonnull) fileName mimeType:(NSString * _Nonnull) mimeType;
/**
 *  <#Description#>
 *
 *  @param image       <#image description#>
 *  @param compression <#compression description#>
 *  @param name        <#name description#>
 *  @param fileName    <#fileName description#>
 *  @param mimeType    <#mimeType description#>
 *
 *  @return <#return value description#>
 */
+ (instancetype _Nonnull) formDataFromUIImage:(UIImage * _Nonnull) image compression:(CGFloat) compression name:(NSString * _Nonnull) name fileName:(NSString * _Nonnull) fileName mimeType:(NSString * _Nonnull) mimeType;

+ (instancetype _Nonnull) formDataFromFilepath:(NSString * _Nonnull) filePath name:(NSString * _Nonnull) name fileName:(NSString * _Nonnull) fileName mimeType:(NSString * _Nonnull) mimeType;

+ (instancetype _Nonnull) formDataFromFileUrl:(NSURL * _Nonnull) fileUrl name:(NSString * _Nonnull) name fileName:(NSString * _Nonnull) fileName mimeType:(NSString * _Nonnull) mimeType;

@end
