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
    NSDictionary *mapping = @{@"objID":@"objID",
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

            _objID = [[NSProcessInfo processInfo] globallyUniqueString];

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
            [self addObserver:self forKeyPath:propertyName options:NSKeyValueObservingOptionNew context:nil];

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

            _objID = [[NSProcessInfo processInfo] globallyUniqueString];

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
            [self addObserver:self forKeyPath:propertyName options:NSKeyValueObservingOptionNew context:nil];

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

    NSDictionary *properties = [PNObject propertiesForClass:self.class];

    for (NSString* propertyName in self.JSONObjectMap) {
        id mappingValue = [self.JSONObjectMap objectForKey:propertyName];

        if([mappingValue isKindOfClass:NSDictionary.class]) {
            mappedJSONKey = [mappingValue valueForKey:@"key"];
            mappedJSONType = [mappingValue valueForKey:@"type"];
        } else {
            mappedJSONKey = mappingValue;
        }


        NSString *propertyType = [properties valueForKey:propertyName];

        NSLog(@"PropertyName PropertyType: %@ - %@",propertyName,propertyType);

        id value;

        @try {
            value = [self valueForKey:propertyName];
        }
        @catch (NSException *exception) {
            continue;
        }
        @finally {

            //NSLog(@"PropertyName PropertyType Value: %@ - %@ - %@",propertyName,propertyType,value);

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
                }

                [JSON setValue:arr forKey:propertyName];
            }
                           }[propertyType] ?: ^{
                               BOOL isPNObjectSubclass = [NSClassFromString(propertyType) isSubclassOfClass:[PNObject class]];
                               if(isPNObjectSubclass) {

                                   NSDictionary *objectDict = [(PNObject*)value reverseMapping];

                                   [JSON setValue:objectDict forKey:propertyName];
                               }
                               else {
                                   // do nothing
                               }
                           })();
        }
    }

    return JSON;
}

- (NSDictionary * _Nonnull) JSONFormObject {

    NSMutableDictionary *JSONFormObject = [[NSMutableDictionary alloc] init];

    NSDictionary *JSONMap = [[self class] objcetMapping];

    for (NSString *key in JSONMap) {

        if ([self.JSON objectForKey:[JSONMap objectForKey:key]]) {
            [JSONFormObject setObject:[self.JSON objectForKey:[JSONMap objectForKey:key]] forKey:[JSONMap objectForKey:key]];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    @try {
        if ([change objectForKey:@"new"]) {
            if ([[[change objectForKey:@"new"] class] isSubclassOfClass:[PNObject class]]) {

                NSDictionary *objectDict = [(PNObject*)[change objectForKey:@"new"] reverseMapping];

                [self.JSON setValue:objectDict forKey:[[[self class] objcetMapping] objectForKey:keyPath]];
            }
            else {
                [self.JSON setObject:[change objectForKey:@"new"] forKey:[[[self class] objcetMapping] objectForKey:keyPath]];
            }
        }
        else {
            [self.JSON removeObjectForKey:[[[self class] objcetMapping] objectForKey:keyPath]];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}


- (void)dealloc
{
    NSDictionary *properties = [PNObject propertiesForClass:self.class];
    
    for (NSString *propertyName in properties) {
        if ([propertyName isEqualToString:@"description"] || [propertyName isEqualToString:@"debugDescription"])  {
            continue;
        }
        
        @try {
            [self removeObserver:self forKeyPath:propertyName];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    _JSON = nil;
    _JSONObjectMap = nil;
    _objID = nil;
    _createdAt = nil;
}


@end
