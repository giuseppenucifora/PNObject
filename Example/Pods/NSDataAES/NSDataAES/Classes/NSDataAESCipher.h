//
//  NSDataAESCipher.h
//  MJ-iOS-Toolkit
//
//  Created by Joan Martin on 09/05/16.
//  Copyright © 2016 Mobile Jazz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint32_t, MJCCOption) {
    MJCCOptionPKCS7Padding   = 0x0001,
    MJCCOptionECBMode        = 0x0002
};

typedef NS_ENUM(uint32_t, MJCCOperation) {
    MJCCEncrypt = 0,
    MJCCDecrypt,
};

extern NSString * NSDataAESCipherErrorDomain;

extern NSInteger const NSDataAESCipherUndefinedErrorCode;
extern NSInteger const NSDataAESCipherParamErrorCode;
extern NSInteger const NSDataAESCipherBufferTooSmallErrorCode;
extern NSInteger const NSDataAESCipherMemoryFailureErrorCode;
extern NSInteger const NSDataAESCipherAlignmentErrorCode;
extern NSInteger const NSDataAESCipherDecodeErrorCode;
extern NSInteger const NSDataAESCipherCUnimplementedErrorCode;

/**
 * Cipher NSData handler
 **/
@interface NSDataAESCipher : NSObject

+ (NSData*)cipherWithkey:(NSData*)key
                   value:(NSData*)value
                      iv:(NSData*)iv
               operation:(MJCCOperation)operation
                 options:(MJCCOption)options
                  output:(NSMutableData*)output
                   error:(NSError**)error;

@end
