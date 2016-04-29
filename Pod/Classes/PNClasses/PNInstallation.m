//
//  PNInstallation.m
//  Pods
//
//  Created by Giuseppe Nucifora on 27/01/16.
//
//

#import "PNInstallation.h"
#import "DJLocalization.h"
#import "PNObjectConfig.h"




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
    
    NSDictionary *mapping = @{@"user":@{@"key":@"user",@"type":[[[PNObjectConfig sharedInstance] userSubClass] PNObjClassName]},
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

- (PNInstallationType) setDeviceTokenFromData:(NSData *)deviceTokenData {
    
    PNInstallationType response = PNInstallationTypeNone;
    
    self.deviceTokenData = deviceTokenData;
    
    NSString *ptoken = [[[[deviceTokenData description]
                          stringByReplacingOccurrencesOfString:@"<"withString:@""]
                         stringByReplacingOccurrencesOfString:@">" withString:@""]
                        stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    if (!_deviceToken) {
        
        response = PNInstallationTypeNew;
    }
    else if (_deviceToken && ![ptoken isEqualToString:_deviceToken]) {
        response = PNInstallationTypeChange;
    }
    
    /*[self setValue:_deviceToken forKey:VariableName(oldDeviceToken)];
     [self setValue:ptoken forKey:VariableName(deviceToken)];
     */
    _oldDeviceToken = _deviceToken;
    _deviceToken = ptoken;
    if (response != PNInstallationTypeNone) {
        _lastTokenUpdate = [NSDate date];
    }
    
    return response;
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
        
        /*[super setValue:@"iOS" forKey:VariableName(deviceType)];
         [super setValue:[[UIDevice currentDevice] model] forKey:VariableName(deviceModel)];
         [super setValue:[[UIDevice currentDevice] systemVersion] forKey:VariableName(osVersion)];
         [self setValue:[[UIDevice currentDevice] name] forKey:VariableName(deviceName)];
         [self setValue:[[DJLocalizationSystem shared] language] forKey:VariableName(localeIdentifier)];
         */
        _deviceType = @"iOS";
        _deviceModel = [[UIDevice currentDevice] model];
        _osVersion = [[UIDevice currentDevice] systemVersion];
        _deviceName = [[UIDevice currentDevice] name];
        _localeIdentifier = [[DJLocalizationSystem shared] language];
        
        
    }
    return self;
}

#pragma mark -

@end
