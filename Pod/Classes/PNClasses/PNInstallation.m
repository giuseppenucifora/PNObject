//
//  PNInstallation.m
//  Pods
//
//  Created by Giuseppe Nucifora on 27/01/16.
//
//

#import "PNInstallation.h"
#import "DJLocalization.h"

@interface PNInstallation() <PNObjectSubclassing>

/**
 *  <#Description#>
 */
@property (nonatomic, strong, nullable) NSData *deviceTokenData;

@end

@implementation PNInstallation

static PNInstallation *INSTALLATION = nil;

static bool isFirstAccess = YES;

#pragma mark PNObjectSubclassing Protocol

+ (NSDictionary *)objcetMapping {
    
    NSDictionary *mapping = @{
                              @"deviceType":@"deviceType",
                              @"deviceModel":@"deviceModel",
                              @"deviceName":@"deviceName",
                              @"osVersion":@"osVersion",
                              @"deviceToken":@"deviceToken",
                              @"oldDeviceToken":@"oldDeviceToken",
                              @"badge":@"badge",
                              @"localeIdentifier":@"localeIdentifier",
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

- (BOOL) setDeviceTokenFromData:(NSData *)deviceTokenData {
    
    BOOL response = NO;
    
    _deviceTokenData = deviceTokenData;
    
    NSString *ptoken = [[[[deviceTokenData description]
                          stringByReplacingOccurrencesOfString:@"<"withString:@""]
                         stringByReplacingOccurrencesOfString:@">" withString:@""]
                        stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    if (!_deviceToken || (_deviceToken && ![ptoken isEqualToString:_deviceToken])) {
        
        response = YES;
    }
    
    _oldDeviceToken = _deviceToken;
    _deviceToken = ptoken;
    
    return response;
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
        
        _deviceType = @"iOS";
        _deviceModel = [[UIDevice currentDevice] model];
        _osVersion = [[UIDevice currentDevice] systemVersion];
        _deviceName = [[UIDevice currentDevice] name];
        _localeIdentifier = [[DJLocalizationSystem shared] language];
        
        INSTALLATION = self;
        
    }
    return INSTALLATION;
}

#pragma mark -

@end
