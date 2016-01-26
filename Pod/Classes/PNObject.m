//
//  PNObject.m
//  Pods
//
//  Created by Giuseppe Nucifora on 28/12/15.
//
//

#import "PNObject.h"
#import <PNObjectProperty.h>
#import <NSDate_Utils/NSDate+NSDate_Util.h>
#import <AFNetworking/AFNetworking.h>
#import "PNObject/PNUser.h"
#import "PNObjectConstants.h"
#import "PNObject+Protected.h"

#define PNOBJECT_DIR @"PNObjects"


@interface PNObject() <PNObjectPersistency>

@property (nonatomic, strong) PNObjectModel * _Nonnull objectModel;

@property (nonatomic, strong) NSMutableDictionary * _Nonnull JSON;

@property (nonatomic, strong) NSString * _Nonnull endPoint;

@property (nonatomic) BOOL singleInstance;

@end

@implementation PNObject

- (NSDictionary *) PNObjectMapping {
    NSDictionary *mapping = @{@"objID":@"objID",
                              @"createdAt":@"created_at",
                              };
    return mapping;
}

- (_Nullable instancetype) init {
    self = [super init];
    
    if (self) {
        if ([[self class] isSubclassOfClass:[PNObject class]]) {
            
            NSAssert([[self class] conformsToProtocol:@protocol(PNObjectSubclassing)], @"Subclass object must conform to PNObjectSubclassing");
            
            _objID = [[NSProcessInfo processInfo] globallyUniqueString];
            
            _objectModel = [PNObjectModel sharedInstance];
            [_objectModel setPersistencyDelegate:self];
            
            NSMutableDictionary * objectDict = [[NSMutableDictionary alloc] initWithDictionary:[[self class] objcetMapping]];
            [objectDict addEntriesFromDictionary:[self PNObjectMapping]];
            
            _objectMapping = objectDict;
            
            NSAssert(_objectMapping, @"You must create objectMapping");
            
            _singleInstance = [[self class] singleInstance];
            
            _createdAt = [[NSDate date] toLocalTime];
            
        }
    }
    return self;
}

- (_Nullable instancetype) initWithJSON:( NSDictionary * _Nonnull) JSON {
    self = [super init];
    if (self) {
        if ([[self class] isSubclassOfClass:[PNObject class]]) {
            NSAssert([[self class] conformsToProtocol:@protocol(PNObjectSubclassing)], @"Subclass object must conform to PNObjectSubclassing");
            
            _objID = [[NSProcessInfo processInfo] globallyUniqueString];
            
            _objectModel = [PNObjectModel sharedInstance];
            [_objectModel setPersistencyDelegate:self];
            
            NSMutableDictionary * objectDict = [[NSMutableDictionary alloc] initWithDictionary:[[self class] objcetMapping]];
            [objectDict addEntriesFromDictionary:[self PNObjectMapping]];
            
            _objectMapping = objectDict;
            
            NSAssert(_objectMapping, @"You must create objectMapping");
            
            _singleInstance = [[self class] singleInstance];
            
            _createdAt = [[NSDate date] toLocalTime];
            
        }
        
        NSAssert(_objectMapping, @"You must create objectMapping");
        _JSON = [[NSMutableDictionary alloc] initWithDictionary:JSON];
        
        [self populateObjectFromJSON:_JSON];
    }
    return self;
}

- (NSDictionary * _Nonnull)reverseMapping
{
    NSMutableDictionary *JSON = [NSMutableDictionary dictionary];
    
    NSString *mappedJSONKey;
    NSString *mappedJSONType;
    
    NSDictionary *properties = [PNObjectProperty propertiesForClass:self.class];
    
    for (NSString* propertyName in _objectMapping) {
        id mappingValue = [_objectMapping objectForKey:propertyName];
        
        if([mappingValue isKindOfClass:NSDictionary.class]) {
            mappedJSONKey = [mappingValue valueForKey:@"key"];
            mappedJSONType = [mappingValue valueForKey:@"type"];
        } else {
            mappedJSONKey = mappingValue;
        }
        
        NSString *propertyType = [properties valueForKey:propertyName];
        
        id value = [self valueForKey:propertyName];
        
        NSLog(@"PropertyName PropertyType Value: %@ - %@ - %@",propertyName,propertyType,value);
        
        ((void (^)())@{
                       @"c" : ^{
            char val = [value charValue];
            [JSON setValue:@(val) forKey:propertyName];
        },
                       @"d" : ^{
            double val = [value doubleValue];
            [JSON setValue:@(val) forKey:propertyName];
        },
                       @"f" : ^{
            float val = [value floatValue];
            [JSON setValue:@(val) forKey:propertyName];
        },
                       @"i" : ^{
            int val = [value intValue];
            [JSON setValue:@(val) forKey:propertyName];
        },
                       @"l" : ^{
            long val = [value longValue];
            [JSON setValue:@(val) forKey:propertyName];
        },
                       @"s" : ^{
            short val = [value shortValue];
            [JSON setValue:@(val) forKey:propertyName];
        },
                       @"B" : ^{
            BOOL val = [value boolValue];
            [JSON setValue:@(val) forKey:propertyName];
        },
                       
                       @"UIImage" : ^{
            UIImage *image = [UIImage imageWithData:value];
            [JSON setValue:image forKey:propertyName];
        },
                       @"NSURL" : ^{
            NSURL *url = value;
            
            if (![self isObjNull:url]) {
                [JSON setValue:[url absoluteString] forKey:propertyName];
            }
        },
                       @"NSString" : ^{
            NSString *val = [NSString stringWithFormat:@"%@", value];
            if (![self isObjNull:val]) {
                [JSON setValue:val forKey:propertyName];
            }
        },
                       @"NSNumber" : ^{
            NSInteger val = [value integerValue];
            [JSON setValue:@(val) forKey:propertyName];
        },
                       @"NSDate" : ^{
            NSDate *val = [value toLocalTime];
            if (![self isObjNull:val]) {
                [JSON setValue:val forKey:propertyName];
            }
        },
                       @"NSArray" : ^{
            NSMutableArray *arr = [NSMutableArray array];
            for(id PNObject in value) {
                SEL selector = NSSelectorFromString(@"getJSONObject");
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: [[PNObject class] instanceMethodSignatureForSelector:selector]];
                [invocation setSelector:selector];
                [invocation setTarget:PNObject];
                [invocation invoke];
                NSDictionary *returnValue;
                [invocation getReturnValue:&returnValue];
                
                [arr addObject:returnValue];
            }
            
            [JSON setValue:arr forKey:propertyName];
        },
                       @"NSMutableArray" : ^{
            NSMutableArray *arr = [NSMutableArray array];
            for(id JSONObject in value) {
                PNObject *val = [[NSClassFromString(mappedJSONType) alloc] initWithJSON:JSONObject];
                [arr addObject:val];
                
                SEL selector = NSSelectorFromString(@"getJSONObject");
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[PNObject class] instanceMethodSignatureForSelector:selector]];
                [invocation setSelector:selector];
                [invocation setTarget:value];
                [invocation invoke];
                NSDictionary *returnValue;
                [invocation getReturnValue:&returnValue];
            }
            
            [JSON setValue:arr forKey:propertyName];
        }
                       }[propertyType] ?: ^{
                           BOOL isPNObjectSubclass = [NSClassFromString(propertyType) isSubclassOfClass:[PNObject class]];
                           if(isPNObjectSubclass) {
                               SEL selector = NSSelectorFromString(@"getJSONObject");
                               NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[PNObject class] instanceMethodSignatureForSelector:selector]];
                               [invocation setSelector:selector];
                               [invocation setTarget:value];
                               [invocation invoke];
                               NSDictionary *returnValue;
                               [invocation getReturnValue:&returnValue];
                               
                               [JSON setValue:returnValue forKey:propertyName];
                           }
                           else {
                               // do nothing
                           }
                       })();
        
        
        
        
    }
    
    _JSON = JSON;
    
    return _JSON;
}

- (NSDictionary* _Nonnull) getJSONObject {
    return [self reverseMapping];
}

- (NSString* _Nonnull) description {
    return [_JSON description];
}

- (void) setSingleInstance:(BOOL)singleInstance {
    _singleInstance = singleInstance;
}

#pragma mark PNObjectPersistency protocol

- (BOOL) initObjectPersistency {
    
    BOOL isDir=YES;
    NSError *error;
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSFileManager *fileManager= [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:[docDir stringByAppendingFormat:@"/%@",PNOBJECT_DIR] isDirectory:&isDir]) {
        
        if (![[NSFileManager defaultManager] createDirectoryAtPath:[docDir stringByAppendingFormat:@"/%@",PNOBJECT_DIR] withIntermediateDirectories:NO attributes:nil error:&error]) {
#ifdef DEBUG
            NSLogDebug(@"Create directory error: %@", error);
#endif
            return NO;
        }
    }
#ifdef DEBUG
    NSLogDebug(@"%@",[docDir stringByAppendingFormat:@"/%@",PNOBJECT_DIR]);
#endif
    return YES;
}

- (id _Nonnull) saveLocally {
    
    return [_objectModel saveLocally:self];
}

- (BOOL) autoRemoveLocally {
    return [_objectModel removeObjectLocally:self];
}

#pragma mark -

@end
