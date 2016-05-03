//
//  PNObject.m
//  Pods
//
//  Created by Giuseppe Nucifora on 28/12/15.
//
//

#import "PNObject.h"
#import <NSDate_Utils/NSDate+NSDate_Util.h>
#import <AFNetworking/AFNetworking.h>
#import "PNObject/PNUser.h"
#import "PNObjectConstants.h"
#import "PNObject+Protected.h"
#import "objc/runtime.h"
#import "PNObject+PNObjectConnection.m"
#import <RZDataBinding/RZDataBinding.h>

#define PNOBJECT_DIR @"PNObjects"

NSString * const PNObjectMappingKey = @"key";
NSString * const PNObjectMappingType = @"type";
NSString * const PNObjectMappingSelector = @"selector";


@interface PNObject() <PNObjectPersistency,PNObjectSubclassing>

@property (nonatomic, strong) PNObjectModel * _Nonnull objectModel;

@property (nonatomic, strong) NSMutableDictionary * _Nonnull JSON;

@property (nonatomic, strong) NSString * _Nonnull endPoint;

@property (nonatomic) BOOL singleInstance;


@end

@implementation PNObject

#pragma mark PNObjectSubclassing

+ (NSDictionary *) objcetMapping {
    NSDictionary *mapping = @{@"objID":@"uuid",
                              @"localObjID":@"localObjID",
                              @"createdAt":@"created_at",
                              };
    return mapping;
}

+ (NSString *)objectEndPoint {
    return NSStringFromClass([self class]);
}

+ (BOOL) singleInstance {
    return NO;
}

+ (NSString*) objectClassName {
    return NSStringFromClass([self class]);
}

#pragma mark -

+ (NSString * _Nonnull) PNObjClassName {
    if ([[self class] resolveClassMethod:@selector(objectClassName)]) {
        return [[self class] objectClassName];
    }
    else {
        return  [[super class] objectClassName];
    }
}

+ (NSString * _Nonnull) PNObjEndPoint {
    if ([[self class] resolveClassMethod:@selector(objectEndPoint)]) {
        return [[self class] objectEndPoint];
    }
    else {
        return  [[super class] objectEndPoint];
    }
}


- (_Nullable instancetype) init {
    self = [super init];
    
    if (self) {
        if ([[self class] isSubclassOfClass:[PNObject class]]) {
            
            NSAssert([[self class] conformsToProtocol:@protocol(PNObjectSubclassing)], @"Subclass object must conform to PNObjectSubclassing");
            
            _localObjID = [[NSProcessInfo processInfo] globallyUniqueString];
            
            self.objectModel = [PNObjectModel sharedInstance];
            [self.objectModel setPersistencyDelegate:self];
            
            NSMutableDictionary * objectDict = [[NSMutableDictionary alloc] initWithDictionary:[[self class] objcetMapping]];
            [objectDict addEntriesFromDictionary:[PNObject objcetMapping]];
            
            self.JSONObjectMap = objectDict;
            
            NSAssert(self.JSONObjectMap, @"You must create objectMapping");
            
            self.singleInstance = [[self class] singleInstance];
            
            self.createdAt = [[NSDate date] toLocalTime];
        }
        
        self.JSON = [[NSMutableDictionary alloc] init];
        
        NSDictionary *properties = [PNObject propertiesForClass:self.class];
        
        for (NSString *propertyName in properties) {
            if ([propertyName isEqualToString:@"description"] || [propertyName isEqualToString:@"debugDescription"])  {
                continue;
            }
            //[self addObserver:self forKeyPath:propertyName options:NSKeyValueObservingOptionNew context:nil];
            
            [self rz_addTarget:self action:@selector(valueChanged:) forKeyPathChange:propertyName];
            
            NSString *propertyType = [properties valueForKey:propertyName];
            
            ((void (^)())@{
                           
                           @"NSMutableArray" : ^{
                NSMutableArray *arr = [[NSMutableArray alloc] init];
                
                [self setValue:arr forKey:propertyName];
            }
                           }[propertyType] ?: ^{
                               
                           })();
        }
    }
    return self;
}

- (_Nullable instancetype) initWithRemoteJSON:( NSDictionary * _Nonnull) JSON {
    return [self initWithJSON:JSON fromLocal:NO];
}

- (_Nullable instancetype) initWithLocalJSON:( NSDictionary * _Nonnull) JSON {
    return [self initWithJSON:JSON fromLocal:YES];
}


- (_Nullable instancetype) initWithJSON:( NSDictionary * _Nonnull) JSON fromLocal:(BOOL) fromLocal {
    self = [super init];
    if (self) {
        if ([[self class] isSubclassOfClass:[PNObject class]]) {
            NSAssert([[self class] conformsToProtocol:@protocol(PNObjectSubclassing)], @"Subclass object must conform to PNObjectSubclassing Protocol");
            
            _localObjID = [[NSProcessInfo processInfo] globallyUniqueString];
            
            self.objectModel = [PNObjectModel sharedInstance];
            [self.objectModel setPersistencyDelegate:self];
            
            NSMutableDictionary * objectDict = [[NSMutableDictionary alloc] initWithDictionary:[[self class] objcetMapping]];
            [objectDict addEntriesFromDictionary:[PNObject objcetMapping]];
            
            self.JSONObjectMap = objectDict;
            
            NSAssert(self.JSONObjectMap, @"You must create objectMapping");
            
            self.singleInstance = [[self class] singleInstance];
            
            _createdAt = [[NSDate date] toLocalTime];
            
        }
        
        NSDictionary *properties = [PNObject propertiesForClass:self.class];
        
        for (NSString *propertyName in properties) {
            if ([propertyName isEqualToString:@"description"] || [propertyName isEqualToString:@"debugDescription"])  {
                continue;
            }
            //[self addObserver:self forKeyPath:propertyName options:NSKeyValueObservingOptionNew context:nil];
            
            [self rz_addTarget:self action:@selector(valueChanged:) forKeyPathChange:propertyName];
            
            NSString *propertyType = [properties valueForKey:propertyName];
            
            ((void (^)())@{
                           
                           @"NSMutableArray" : ^{
                NSMutableArray *arr = [[NSMutableArray alloc] init];
                
                [self setValue:arr forKey:propertyName];
            }
                           }[propertyType] ?: ^{
                               
                           })();
        }
        
        NSAssert(self.JSONObjectMap, @"You must create objectMapping");
        self.JSON = [[NSMutableDictionary alloc] initWithDictionary:JSON];
        
        [self populateObjectFromJSON:self.JSON fromLocal:fromLocal];
    }
    return self;
}

- (NSDictionary * _Nonnull) reverseMapping
{
    NSMutableDictionary *JSON = [[NSMutableDictionary alloc] init];
    
    NSString *mappedJSONKey;
    NSString *mappedJSONType;
    NSString *type;
    
    
    
    NSDictionary *properties = [PNObject propertiesForClass:self.class];
    
    for (NSString* propertyName in self.JSONObjectMap) {
        id mappingValue = [self.JSONObjectMap objectForKey:propertyName];
        
        if([mappingValue isKindOfClass:NSDictionary.class]) {
            mappedJSONKey = [mappingValue valueForKey:PNObjectMappingKey];
            mappedJSONType = [mappingValue valueForKey:PNObjectMappingType];
            
        } else {
            mappedJSONKey = mappingValue;
            mappedJSONType = [properties valueForKey:propertyName];
        }
        
        type = [properties valueForKey:propertyName];
        
        NSLog(@"PropertyName MappedJsonType PropertyType: %@ - %@ - %@",propertyName,mappedJSONType,type);
        
        id value;
        
        @try {
            value = [self valueForKey:propertyName];
            
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
                           @"q" : ^{
                NSInteger val = [value integerValue];
                [JSON setValue:@(val) forKey:propertyName];
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
                for(id object in value) {
                    
                    BOOL isPNObjectSubclass = [[object class] isSubclassOfClass:[PNObject class]];
                    if(isPNObjectSubclass) {
                        NSDictionary *objectDict = [(PNObject*) object reverseMapping];
                        
                        [arr addObject:objectDict];
                    }
                    else {
                        [arr addObject:object];
                    }
                }
                
                [JSON setValue:arr forKey:propertyName];
            },
                           @"NSMutableArray" : ^{
                NSMutableArray *arr = [NSMutableArray array];
                for(id object in value) {
                    
                    BOOL isPNObjectSubclass = [[object class] isSubclassOfClass:[PNObject class]];
                    if(isPNObjectSubclass) {
                        NSDictionary *objectDict = [(PNObject*) object reverseMapping];
                        
                        [arr addObject:objectDict];
                    }
                    else {
                        [arr addObject:object];
                    }
                }
                
                [JSON setValue:arr forKey:propertyName];
            }
                           }[type] ?: ^{
                               BOOL isPNObjectSubclass = [NSClassFromString(mappedJSONType) isSubclassOfClass:[PNObject class]];
                               if(isPNObjectSubclass) {
                                   
                                   NSDictionary *objectDict = [(PNObject*)value reverseMapping];
                                   
                                   [JSON setValue:objectDict forKey:propertyName];
                               }
                               else {
                                   // do nothing
                                   [JSON setValue:value forKey:propertyName];
                               }
                           })();
        }
        @catch (NSException *exception) {
            continue;
        }
        @finally {
            
            //NSLog(@"PropertyName PropertyType Value: %@ - %@ - %@",propertyName,propertyType,value);
        }
    }
    
    if (self.JSON && [[self.JSON allKeys] count] == 0) {
        self.JSON = JSON;
    }
    
    return JSON;
}

- (NSDictionary * _Nonnull) JSONFormObject {
    
    NSMutableDictionary *JSONFormObject = [[NSMutableDictionary alloc] init];
    
    NSString *mappedJSONKey;
    NSString *mappedJSONType;
    
    NSDictionary *properties = [PNObject propertiesForClass:self.class];
    
    for (NSString* propertyName in self.JSONObjectMap) {
        id mappingValue = [self.JSONObjectMap objectForKey:propertyName];
        
        if([mappingValue isKindOfClass:NSDictionary.class]) {
            mappedJSONKey = [mappingValue valueForKey:@"key"];
            mappedJSONType = [mappingValue valueForKey:@"type"];
        } else {
            mappedJSONKey = mappingValue;
            mappedJSONType = [properties valueForKey:propertyName];
        }
        
        NSLog(@"PropertyName PropertyType: %@ - %@",propertyName,mappedJSONType);
        
        id value;
        
        @try {
            value = [self valueForKey:propertyName];
            
            ((void (^)())@{
                           @"c" : ^{
                char val = [value charValue];
                [JSONFormObject setValue:@(val) forKey:propertyName];
            },
                           @"d" : ^{
                double val = [value doubleValue];
                [JSONFormObject setValue:@(val) forKey:propertyName];
            },
                           @"f" : ^{
                float val = [value floatValue];
                [JSONFormObject setValue:@(val) forKey:propertyName];
            },
                           @"i" : ^{
                int val = [value intValue];
                [JSONFormObject setValue:@(val) forKey:propertyName];
            },
                           @"l" : ^{
                long val = [value longValue];
                [JSONFormObject setValue:@(val) forKey:propertyName];
            },
                           @"s" : ^{
                short val = [value shortValue];
                [JSONFormObject setValue:@(val) forKey:propertyName];
            },
                           @"B" : ^{
                BOOL val = [value boolValue];
                [JSONFormObject setValue:@(val) forKey:propertyName];
            },
                           @"q" : ^{
                NSInteger val = [value integerValue];
                [JSONFormObject setValue:@(val) forKey:propertyName];
            },
                           @"NSURL" : ^{
                NSURL *url = value;
                
                if (![self isObjNull:url]) {
                    [JSONFormObject setValue:[url absoluteString] forKey:propertyName];
                }
            },
                           @"NSString" : ^{
                NSString *val = [NSString stringWithFormat:@"%@", value];
                if (![self isObjNull:val]) {
                    [JSONFormObject setValue:val forKey:propertyName];
                }
            },
                           @"NSNumber" : ^{
                NSInteger val = [value integerValue];
                [JSONFormObject setValue:@(val) forKey:propertyName];
            },
                           @"NSDate" : ^{
                NSString *val = [[value toLocalTime] stringWithFormat:kNSDateHelperFormatSQLDateWithTime];
                if (![self isObjNull:val]) {
                    [JSONFormObject setValue:val forKey:propertyName];
                }
            },
                           @"NSArray" : ^{
                NSMutableArray *arr = [NSMutableArray array];
                for(id object in value) {
                    
                    BOOL isPNObjectSubclass = [[object class] isSubclassOfClass:[PNObject class]];
                    if(isPNObjectSubclass) {
                        NSDictionary *objectDict = [(PNObject*) object JSONFormObject];
                        
                        [arr addObject:objectDict];
                    }
                    else {
                        [arr addObject:object];
                    }
                }
                
                [JSONFormObject setValue:arr forKey:mappedJSONKey];
            },
                           @"NSMutableArray" : ^{
                NSMutableArray *arr = [NSMutableArray array];
                for(id object in value) {
                    
                    BOOL isPNObjectSubclass = [[object class] isSubclassOfClass:[PNObject class]];
                    if(isPNObjectSubclass) {
                        NSDictionary *objectDict = [(PNObject*) object JSONFormObject];
                        
                        [arr addObject:objectDict];
                    }
                    else {
                        [arr addObject:object];
                    }
                }
                
                [JSONFormObject setValue:arr forKey:mappedJSONKey];
            }
                           }[mappedJSONType] ?: ^{
                               BOOL isPNObjectSubclass = [NSClassFromString(mappedJSONType) isSubclassOfClass:[PNObject class]];
                               if(isPNObjectSubclass) {
                                   
                                   NSDictionary *objectDict = [(PNObject*)value JSONFormObject];
                                   
                                   [JSONFormObject setValue:objectDict forKey:mappedJSONKey];
                               }
                               else {
                                   // do nothing
                                   [JSONFormObject setValue:value forKey:propertyName];
                               }
                           })();
        }
        @catch (NSException *exception) {
            continue;
        }
        @finally {
            
            //NSLog(@"PropertyName PropertyType Value: %@ - %@ - %@",propertyName,propertyType,value);
        }
    }
    return JSONFormObject;
}


- (NSString* _Nonnull) description {
    return [[self reverseMapping] description];
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
    
    __weak id weakSelf = self;
    
    return [self.objectModel saveLocally:weakSelf];
}

- (BOOL) autoRemoveLocally {
    return [self.objectModel removeObjectLocally:self];
}

+ (NSArray *)batch:(id)JSON fromLocal:(BOOL) fromLocal
{
    NSString *className = NSStringFromClass([self class]);
    
    NSMutableArray *batch = [NSMutableArray array];
    
    for(id objectJSON in JSON) {
        PNObject *val = [[NSClassFromString(className) alloc] initWithJSON:objectJSON fromLocal:fromLocal];
        [batch addObject:val];
    }
    
    return batch;
}

#pragma mark -
/*
 NSString* const kRZDBChangeKeyObject  = @"RZDBChangeObject";
 NSString* const kRZDBChangeKeyOld     = @"RZDBChangeOld";
 NSString* const kRZDBChangeKeyNew     = @"RZDBChangeNew";
 NSString* const kRZDBChangeKeyKeyPath = @"RZDBChangeKeyPath";
 */

- (void) valueChanged:(NSDictionary *) value {
    
    if ([value objectForKey:kRZDBChangeKeyNew]) {
        if ([[[value objectForKey:kRZDBChangeKeyNew] class] isSubclassOfClass:[PNObject class]]) {
            
            NSDictionary *objectDict = [(PNObject*)[value objectForKey:kRZDBChangeKeyNew] reverseMapping];
            
            if ([[[[self class] objcetMapping] allKeys] containsObject:[value objectForKey:kRZDBChangeKeyKeyPath]]) {
                [self.JSON setValue:objectDict forKey:[[[self class] objcetMapping] objectForKey:[value objectForKey:kRZDBChangeKeyKeyPath]]];
            }
        }
        else {
            if ([[[[self class] objcetMapping] allKeys] containsObject:[value objectForKey:kRZDBChangeKeyKeyPath]]) {
                
                [self.JSON setValue:[value objectForKey:kRZDBChangeKeyNew] forKey:[[[self class] objcetMapping] objectForKey:[value objectForKey:kRZDBChangeKeyKeyPath]]];
            }
        }
    }
}

- (void)dealloc
{
    
    _JSON = nil;
    _JSONObjectMap = nil;
    _objID = nil;
    _localObjID = nil;
    _createdAt = nil;
}


@end
