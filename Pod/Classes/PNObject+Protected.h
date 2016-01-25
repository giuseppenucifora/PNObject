//
//  PNObject+Protected.h
//  Pods
//
//  Created by Giuseppe Nucifora on 25/01/16.
//
//

#import <PNObject/PNObject.h>
#import <objc/runtime.h>

@interface PNObject (Protected)

@property (nonatomic, strong) PNObjectModel * _Nonnull objectModel;

@property (nonatomic, strong) NSDictionary * _Nonnull JSON;

@property (nonatomic, strong) NSString * _Nonnull endPoint;

@property (nonatomic) BOOL singleInstance;

- (void)populateObjectFromJSON:(id _Nullable)JSON;

- (BOOL)isStringNull:(NSString * _Nullable)str;

- (BOOL)isObjNull:(id _Nullable)obj;

+ (NSArray * _Nonnull) protectedProperties;

@end
