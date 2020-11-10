//
//  PNInstallation.m
//  Pods
//  Version 2.7.0
//
//  Created by Giuseppe Nucifora on 27/01/16.
//
//

#import "PNInstallation.h"
#import "PNObjectConfig.h"
#import "PNObject+PNObjectConnection.h"
#import "NSDate+NSDate_Util.h"




@interface PNInstallation() <PNObjectSubclassing>

/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSData *deviceTokenData;

@end

@implementation PNInstallation

static id INSTALLATION = nil;

static bool isFirstAccess = YES;

#pragma mark PNObjectSubclassing Protocol

+ (NSDictionary *)objcetMapping {
    
    NSDictionary *mapping = @{@"user":@{PNObjectMappingKey:@"user",PNObjectMappingType:[[[PNObjectConfig sharedInstance] userSubClass] PNObjClassName]},
                              @"deviceType":@"deviceType",
                              @"deviceModel":@"deviceModel",
                              @"deviceName":@"deviceName",
                              @"osVersion":@"osVersion",
                              @"deviceToken":@"deviceToken",
                              @"oldDeviceToken":@"oldDeviceToken",
                              @"badge":@"badge",
                              @"localeIdentifier":@"localeIdentifier",
                              @"registeredAt":@"registeredAt",
                              @"updatedAt":@"updatedAt",
                              @"lastTokenUpdate":@"lastTokenUpdate",
                              };
    return mapping;
}

+ (NSString *)objectClassName {
    return  @"PNInstallation";
}

+ (NSString *)objectEndPoint {
    return @"PNInstallation";
}

+ (BOOL) singleInstance {
    return YES;
}

#pragma mark -

#pragma mark Public Methods


+ (instancetype) currentInstallation {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        
        INSTALLATION = [[super allocWithZone:NULL] initForCurrentInstallation];
    });
    
    return INSTALLATION;
}

- (PNInstallationStatus) setDeviceTokenFromData:(NSData *)deviceTokenData {
    
    if(!deviceTokenData){
        _installationStatus = PNInstallationStatusNone;
        return _installationStatus;
    }
    
    self.deviceTokenData = deviceTokenData;
    
    const unsigned *tokenBytes = [deviceTokenData bytes];
    NSString *ptoken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                         ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                         ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                         ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    if (!_deviceToken) {
        
        _installationStatus = PNInstallationStatusNew;
    }
    else if (_deviceToken && ![ptoken isEqualToString:_deviceToken]) {
        _installationStatus = PNInstallationStatusChange;
    }
    
    /*[self setValue:_deviceToken forKey:VariableName(oldDeviceToken)];
     [self setValue:ptoken forKey:VariableName(deviceToken)];
     */
    _oldDeviceToken = _deviceToken;
    _deviceToken = ptoken;
    if (_installationStatus != PNInstallationStatusNone) {
        _lastTokenUpdate = [NSDate date];
    }
    
    return _installationStatus;
}

- (void) setBadge:(NSInteger)badge {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];
}

- (NSInteger) badge {
    return [[UIApplication sharedApplication] applicationIconBadgeNumber];
}

- (void) resetBadge {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void) setRegistered {
    _registeredAt = [NSDate date];
}

- (void) setUpdated {
    _updatedAt = [NSDate date];
}

- (void) setUser:(PNUser *)user {
    if (!_user && user) {
        _user = user;
        [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationPNInstallationUserNew object:nil];
    }
    else if(_user.objID != user.objID) {
        _user = user;
        [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationPNInstallationUserChange object:nil];
    }
    else if (user == nil && _user){
        _user = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:PNObjectLocalNotificationPNInstallationUserDelete object:nil];
    }
}

#pragma mark -

#pragma mark Private Methods

- (id) initForCurrentInstallation
{
    if(INSTALLATION){
        return INSTALLATION;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    
    NSDictionary *savedInstallation = [[PNObjectModel sharedInstance] fetchObjectsWithClass:[self class]];
    
    if (savedInstallation) {
        
        Class objectClass = NSClassFromString([[self class] PNObjClassName]);
        
        self = [[objectClass alloc] initWithLocalJSON:savedInstallation];
    }
    else {
        self = [super init];
    }
    
    if (self) {
        
        _installationStatus = PNInstallationStatusNone;
        _deviceType = @"iOS";
        _deviceModel = [[UIDevice currentDevice] model];
        _osVersion = [[UIDevice currentDevice] systemVersion];
        _deviceName = [[UIDevice currentDevice] name];
        _localeIdentifier = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
        
        
    }
    return self;
}


- (void) registerDeviceWithBlockProgress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                                 Success:(nullable void (^)(BOOL response))success
                                 failure:(nullable void (^)(NSError * _Nonnull error))failure {
    [self registerDeviceForced:NO WithBlockProgress:uploadProgress Success:success failure:failure];
    
}


- (void) registerDeviceForced:(BOOL) forced
            WithBlockProgress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                      Success:(nullable void (^)(BOOL response))success
                      failure:(nullable void (^)(NSError * _Nonnull error))failure {
    if (self.deviceToken && (forced || !self.registeredAt || [self.registeredAt isEarlierThanDate:[[NSDate date] dateByAddingHours:3]])) {
        
        [[self class] POSTWithEndpointAction:@"device/register" parameters:[self registrationDeviceFormObject]
                                    progress:uploadProgress
                                     success:^(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject) {
                                         [self setRegistered];
                                         [self saveLocally];
                                         if(success){
                                             success(YES);
                                         }
                                     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                         [self setRegistered];
                                         [self saveLocally];
                                         if (failure) {
                                             failure(error);
                                         }
                                     }];
    }
    else {
        if (success) {
            success(YES);
        }
    }
}

- (NSDictionary * _Nonnull) registrationDeviceFormObject {
    
    NSMutableDictionary *registrationDeviceDictionary = [[NSMutableDictionary alloc] initWithDictionary:[self JSONFormObject]];
    
    [registrationDeviceDictionary setObject:[self deviceType] forKey:@"platform"];
    
    return registrationDeviceDictionary;
}


- (void) updateDeviceWithBlockProgress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                               Success:(nullable void (^)(BOOL response))success
                               failure:(nullable void (^)(NSError * _Nonnull error))failure {
    if (self.deviceToken && self.oldDeviceToken && (!self.updatedAt || [self.updatedAt isEarlierThanDate:[[NSDate date] dateByAddingHours:3]])) {
        
        [[self class] POSTWithEndpointAction:@"device/update" parameters:[self updateDeviceFormObject]
                                    progress:uploadProgress
                                     success:^(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject) {
                                         [self setUpdated];
                                         [self saveLocally];
                                         if(success){
                                             success(YES);
                                         }
                                     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                         if (failure) {
                                             failure(error);
                                         }
                                     }];
    }
    else {
        if (success) {
            success(YES);
        }
    }
}

- (NSDictionary * _Nonnull) updateDeviceFormObject {
    
    NSMutableDictionary *updateDeviceDictionary = [[NSMutableDictionary alloc] initWithDictionary:[self JSONFormObject]];
    
    if ([updateDeviceDictionary objectForKey:VariableName(self.deviceToken)]) {
        [updateDeviceDictionary setObject:[updateDeviceDictionary objectForKey:VariableName(self.deviceToken)] forKey:@"newDeviceToken"];
        
    }
    if ([updateDeviceDictionary objectForKey:VariableName(self.oldDeviceToken)]) {
        [updateDeviceDictionary setObject:[updateDeviceDictionary objectForKey:VariableName(self.oldDeviceToken)] forKey:VariableName(self.deviceToken)];
        [updateDeviceDictionary removeObjectForKey:VariableName(self.oldDeviceToken)];
    }
    
    
    
    return updateDeviceDictionary;
}

- (void) removeDeviceWithBlockProgress:(nullable void (^)(NSProgress * _Nonnull uploadProgress)) uploadProgress
                               Success:(nullable void (^)(BOOL response))success
                               failure:(nullable void (^)(NSError * _Nonnull error))failure {
    
    if (self.deviceToken) {
        
        [[self class] POSTWithEndpointAction:@"device/remove-user" parameters:[self removeDeviceFormObject]
                                    progress:uploadProgress
                                     success:^(NSURLSessionDataTask * _Nullable task, NSDictionary * _Nullable responseObject) {
                                         NSLogDebug(@"response %@",responseObject);
                                         if(success){
                                             success(YES);
                                         }
                                     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                         NSLogDebug(@"error : %@",error);
                                         if (failure) {
                                             failure(error);
                                         }
                                     }];
    }
    else{
        if (success) {
            success(YES);
        }
    }
}

- (NSDictionary * _Nonnull) removeDeviceFormObject {
    
    NSMutableDictionary *updateDeviceDictionary = [[NSMutableDictionary alloc] init];
    
    [updateDeviceDictionary setObject:self.deviceToken forKey:VariableName(self.deviceToken)];
    
    return updateDeviceDictionary;
}


#pragma mark -

@end
