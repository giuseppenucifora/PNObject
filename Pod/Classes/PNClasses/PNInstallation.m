//
//  PNInstallation.m
//  Pods
//
//  Created by Giuseppe Nucifora on 27/01/16.
//
//

#import "PNInstallation.h"

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
                              @"badge":@"badge",
                              @"localeIdentifier":@"localeIdentifier",
                              };
    return mapping;
}

+ (NSString *)objectClassName {
    return  @"Installation";
}

+ (NSString *)objectEndPoint {
    return @"Installation";
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
        
        INSTALLATION = [[super allocWithZone:NULL] init];
    });
    
    return INSTALLATION;
}

- (void)setDeviceTokenFromData:(NSData *)deviceTokenData {
    
    _deviceTokenData = deviceTokenData;
    
    NSString *ptoken = [[[[deviceTokenData description]
                          stringByReplacingOccurrencesOfString:@"<"withString:@""]
                         stringByReplacingOccurrencesOfString:@">" withString:@""]
                        stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    _deviceToken = ptoken;
}

#pragma mark -

#pragma mark Private Methods

- (id) init
{
    if(INSTALLATION){
        return INSTALLATION;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    
    NSDictionary *savedInstallation = [[PNObjectModel sharedInstance] fetchObjectsWithClass:[self class]];
    
    if (savedInstallation) {
        self = [super initWithJSON:savedInstallation];
    }
    else {
        self = [super init];
    }
    
    if (self) {
        
        _deviceType = @"iOS";
        _deviceModel = [[UIDevice currentDevice] model];
        _osVersion = [[UIDevice currentDevice] systemVersion];
        _deviceName = [[UIDevice currentDevice] name];
        
    }
    return self;
}

#pragma mark -

@end
