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

#import "CodFis+Helper.h"
#import "CodFisResponse.h"
#import "ResponseConstants.h"
#import "VatNumber+Helper.h"

FOUNDATION_EXPORT double CodFis_HelperVersionNumber;
FOUNDATION_EXPORT const unsigned char CodFis_HelperVersionString[];

