//
//  PNObjectModel.m
//  Pods
//
//  Created by Giuseppe Nucifora on 16/01/16.
//
//

#import "PNObjectModel.h"
#import "PNObject+Protected.h"
#import "PEARFileManager.h"
#import "PNObjectConstants.h"
#import <DDDKeychainWrapper/DDDKeychainWrapper.h>
#import <NAChloride/NAChloride.h>
#import "HTTPStatusCodes.h"

@interface PNObjectModel()

@property (nonatomic, strong) PEARFileManager *fileManager;
@property (nonatomic, strong) NASecretBox *secretBox;
@end

@implementation PNObjectModel

static PNObjectModel *SINGLETON_PNObjectModel = nil;

static bool isFirstAccess = YES;

#pragma mark Public Method

+ (instancetype) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON_PNObjectModel = [[super allocWithZone:NULL] init];
    });
    
    return SINGLETON_PNObjectModel;
}

- (NSString * _Nullable) objectName:(id _Nonnull) object {
    
    BOOL isPNObjectSubclass = [[object class] isSubclassOfClass:[PNObject class]];
    
    if(isPNObjectSubclass) {
        
        if ([[object class] conformsToProtocol:@protocol(PNObjectSubclassing)]) {
            
            NSString *className;
            //if ([[object subClassDelegate] respondsToSelector:@selector(objectClassName)]) {
            
            @try {
                
                className = (NSString *)[[object class] performSelector:@selector(objectClassName)];
                
            }
            @catch (NSException *exception) {
                return nil;
            }
            @finally {
                return className;
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
    if(SINGLETON_PNObjectModel){
        return SINGLETON_PNObjectModel;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    
    if (self) {
        _fileManager = [PEARFileManager sharedInstatnce];
        
        [_fileManager setRootDirectory:k_ROOT_DIR_DOCUMENTS];
        NSLogDebug(@"%@",[_fileManager getRootDirectoryPath]);
        _secretBox = [[NASecretBox alloc] init];
    }
    return self;
}

#pragma mark Public Methods

- (id _Nonnull) fetchObjectsWithClass:(Class _Nonnull) class {
    BOOL isPNObjectSubclass = [class isSubclassOfClass:[PNObject class]];
    
    if(isPNObjectSubclass) {
        
        NSString *className;
        
        @try {
            
            className = (NSString *)[class performSelector:@selector(objectClassName)];
            
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
            if ([_fileManager checkPath:className]) {
                
                NSError *error = nil;
                
                NSData *data = [_secretBox decrypt:[_fileManager fetchFileDataWithPath:className] nonce:[DDDKeychainWrapper dataForKey:PNObjectEncryptionNonce] key:[DDDKeychainWrapper dataForKey: PNObjectEncryptionKey] error:&error]; // password:[[PNObjectConfig sharedInstance] encrypKey] error:&error];
                
                return [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
            else
                return nil;
        }
    }
}

- (id _Nonnull) saveLocally:(id _Nonnull) object {
    
    BOOL isPNObjectSubclass = [[object class] isSubclassOfClass:[PNObject class]];
    
    NSError *error = nil;
    
    if(isPNObjectSubclass) {
        
        
        if ([[object class] conformsToProtocol:@protocol(PNObjectSubclassing)]) {
            
            if ([(PNObject*) object singleInstance]) {
                
                NSDictionary *objectDict = [(PNObject*) object reverseMapping];
                
                NSData *objectData = [_secretBox encrypt:[NSKeyedArchiver archivedDataWithRootObject:objectDict] nonce:[DDDKeychainWrapper dataForKey: PNObjectEncryptionNonce] key:[DDDKeychainWrapper dataForKey: PNObjectEncryptionKey] error:&error];//[RNCryptor encryptData:[NSKeyedArchiver archivedDataWithRootObject:objectDict] password:[[PNObjectConfig sharedInstance] encrypKey]];
                
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
                if ([self issetPNObjectModelForObject:object]) {
                    
                    //NSData * data = [_fileManager fetchFileDataWithPath:[self objectName:object]];
                    
                    
                    
                    NSData *data = [_secretBox decrypt:[_fileManager fetchFileDataWithPath:[self objectName:object]] nonce:[DDDKeychainWrapper dataForKey: PNObjectEncryptionNonce] key:[DDDKeychainWrapper dataForKey: PNObjectEncryptionKey] error:&error];
                    //[RNCryptor decryptData:[_fileManager fetchFileDataWithPath:[self objectName:object]] password:[[PNObjectConfig sharedInstance] encrypKey] error:&error];
                    
                    NSMutableArray *objects = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
                    
                    NSDictionary *objectDict = [(PNObject*)object reverseMapping];
                    
                    [objects addObject:objectDict];
                    
                    NSData *objectData = [_secretBox encrypt:[NSKeyedArchiver archivedDataWithRootObject:objects] nonce:[DDDKeychainWrapper dataForKey: PNObjectEncryptionNonce] key:[DDDKeychainWrapper dataForKey:PNObjectEncryptionKey] error:&error];
                    //[RNCryptor encryptData:[NSKeyedArchiver archivedDataWithRootObject:objects] password:[[PNObjectConfig sharedInstance] encrypKey]];
                    
                    if ([_fileManager updateFileWithData:objectData filePath:[self objectName:object] permisson:@(0755)]) {
                        
                        return objects;
                    }
                    else {
                        return [NSError errorWithDomain:NSLocalizedString(@"Objects list cannot be updated", @"") code:kHTTPStatusCodeBadRequest userInfo:nil];
                    }
                }
                else {
                    
                    NSMutableArray *objects = [[NSMutableArray alloc] init];
                    
                    NSDictionary *objectDict = [(PNObject*)object reverseMapping];
                    
                    [objects addObject:objectDict];
                    
                    NSData *objectData = [_secretBox encrypt:[NSKeyedArchiver archivedDataWithRootObject:objects] nonce:[DDDKeychainWrapper dataForKey:PNObjectEncryptionNonce] key:[DDDKeychainWrapper dataForKey:PNObjectEncryptionKey] error:&error];
                    //[RNCryptor encryptData:[NSKeyedArchiver archivedDataWithRootObject:objects] password:[[PNObjectConfig sharedInstance] encrypKey]];
                    
                    if ([_fileManager createFileWithData:objectData filePath:[self objectName:object] permisson:@(0755)]) {
                        return object;
                    }
                    else {
                        return [NSError errorWithDomain:NSLocalizedString(@"Objects list cannot be created", @"") code:kHTTPStatusCodeBadRequest userInfo:nil];
                    }
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

/*- (id _Nonnull) saveNSUSerDefautls:(id _Nonnull) object {
 
 }*/

- (BOOL) removeObjectLocally:(id _Nonnull) object {
    BOOL isPNObjectSubclass = [[object class] isSubclassOfClass:[PNObject class]];
    
    if(isPNObjectSubclass) {
        
        if ([[object class] conformsToProtocol:@protocol(PNObjectSubclassing)]) {
            
            if ([self issetPNObjectModelForObject:object]) {
                return [_fileManager deletePath:[self objectName:object]];
            }
        }
    }
    return NO;
}

@end