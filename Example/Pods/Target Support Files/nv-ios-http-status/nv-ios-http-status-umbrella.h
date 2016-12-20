#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HTTPStatusCodes.h"
#import "nv_ios_http_status.h"

FOUNDATION_EXPORT double nv_ios_http_statusVersionNumber;
FOUNDATION_EXPORT const unsigned char nv_ios_http_statusVersionString[];

