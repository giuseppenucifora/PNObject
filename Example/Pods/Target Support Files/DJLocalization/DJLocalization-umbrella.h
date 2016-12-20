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

#import "DJLocalizableString.h"
#import "DJLocalization.h"
#import "DJLocalizationSystem.h"
#import "UIStoryboard+DJLocalization.h"

FOUNDATION_EXPORT double DJLocalizationVersionNumber;
FOUNDATION_EXPORT const unsigned char DJLocalizationVersionString[];

