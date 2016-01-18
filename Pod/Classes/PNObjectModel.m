//
//  PNObjectModel.m
//  Pods
//
//  Created by Giuseppe Nucifora on 16/01/16.
//
//

#import "PNObjectModel.h"
#import "PNObject.h"
#import "PEARFileManager.h"
#import "PNObjectConstants.h"

@interface PNObjectModel()

@property (nonatomic, strong) PEARFileManager *fileManager;

@end

@implementation PNObjectModel

static PNObjectModel *SINGLETON = nil;

static bool isFirstAccess = YES;

#pragma mark Public Method

+ (instancetype) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];
    });
    
    return SINGLETON;
}

- (NSString * _Nullable) objectName:(id _Nonnull) object {
    
    BOOL isPNObjectSubclass = [[object class] isSubclassOfClass:[PNObject class]];
    
    if(isPNObjectSubclass) {
        
        if ([[object class] conformsToProtocol:@protocol(PNObjectSubclassing)]) {
            
            NSLogDebug(@"%@",[object subClassDelegate]);
            
            //if ([[object subClassDelegate] respondsToSelector:@selector(objectClassName)]) {
            
            @try {
                return (NSString *)[[object class] performSelector:@selector(objectClassName)];
            }
            @catch (NSException *exception) {
                return nil;
            }
            @finally {
                
            }
            
            
            //}
        }
    }
    return nil;
}

- (BOOL) issetPNObjectModelForObject:(id _Nonnull) object {
    
    NSString *className = [self objectName:object];
    
    if (!className) {
        return NO;
    }
    
    return [_fileManager checkPath:className];
}

#pragma mark -

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copy
{
    return [[PNObjectModel alloc] init];
}

- (id)mutableCopy
{
    return [[PNObjectModel alloc] init];
}

- (id) init
{
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    
    if (self) {
        _fileManager = [PEARFileManager sharedInstatnce];
        
        [_fileManager setRootDirectory:k_ROOT_DIR_DOCUMENTS];
    }
    return self;
}


- (id _Nonnull) saveLocally:(id _Nonnull) object {
    
    BOOL isPNObjectSubclass = [[object class] isSubclassOfClass:[PNObject class]];
    
    if(isPNObjectSubclass) {
        
        if ([[object class] conformsToProtocol:@protocol(PNObjectSubclassing)]) {
            
            SEL selector = NSSelectorFromString(@"getObject");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[PNObject class] instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:object];
            [invocation invoke];
            
            NSDictionary *objectDict;
            [invocation getReturnValue:&objectDict];
            
            NSLogDebug(@"%@",objectDict);
            
            NSData *objectData = [NSKeyedArchiver archivedDataWithRootObject:objectDict];
            
            if ([self issetPNObjectModelForObject:object]) {
                if ([_fileManager updateFileWithData:objectData filePath:[self objectName:object] permisson:@(0755)]) {
                    return object;
                }
                else {
                    return [NSError errorWithDomain:NSLocalizedString(@"Object cannot be updated", @"") code:kHTTPStatusCodeBadRequest userInfo:nil];
                }
            }
            else {
                if ([_fileManager createFileWithData:objectData filePath:[self objectName:object] permisson:@(0755)]) {
                    return object;
                }
                else {
                    return [NSError errorWithDomain:NSLocalizedString(@"Object cannot be created", @"") code:kHTTPStatusCodeBadRequest userInfo:nil];
                }
            }
        }
        else {
            return [NSError errorWithDomain:NSLocalizedString(@"passed object is not conform to protocol PNObjectSubclassing", @"") code:kHTTPStatusCodeBadRequest userInfo:nil];
        }
    }
    else {
        return [NSError errorWithDomain:NSLocalizedString(@"passed object is not PNObject Subclass", @"") code:kHTTPStatusCodeBadRequest userInfo:nil];
    }
}

- (void) saveLocally:(id _Nonnull) object inBackGroundWithBlock:(nullable void (^)(BOOL saveStatus, id _Nullable responseObject, NSError * _Nullable error)) responseBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        __weak id responseObject = [self saveLocally:object];
        if ([responseObject isKindOfClass:[NSError class]]) {
            if (responseBlock) {
                responseBlock(NO, nil, responseObject);
            }
        }
        else if ([[responseObject class] isSubclassOfClass:[PNObject class]]){
            if (responseBlock) {
                responseBlock(YES,responseObject, nil);
            }
        }
    });
}

- (id _Nonnull) pushObjectAndSaveLocally:(id _Nonnull) object {
    
}

- (void) pushObjectAndSaveLocally:(id _Nonnull) object inBackGroundWithBlock:(nullable void (^)(BOOL saveStatus, id _Nullable responseObject, NSError * _Nullable error)) responseBlock {
    
    
    
}

@end
