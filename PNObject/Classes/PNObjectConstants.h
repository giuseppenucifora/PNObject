//
//  PNObjectConstants.h
//  Pods
//
//  Created by Giuseppe Nucifora on 16/01/16.
//
//

#ifndef PNObjectConstants_h

#define PNObjectConstants_h

#pragma mark Constants

#define DEF_DOCUMENT_ROOT @"Documents"

#pragma mark -

#pragma mark NSLogDebug Macro

#define FORCE_NO_LOG 0

#if defined(FORCE_NO_LOG) && FORCE_NO_LOG == 0
#define NSLogDebug(format, ...) NSLog(@"<%s:%d> %s, " format, strrchr("/" __FILE__, '/') + 1, __LINE__, __PRETTY_FUNCTION__, ## __VA_ARGS__)
#else
#define NSLogDebug(format, ...)
#endif

#define VariableName(arg) ([[[@""#arg stringByReplacingOccurrencesOfString:@"_" withString:@""] componentsSeparatedByString:@"."] lastObject])

#endif
