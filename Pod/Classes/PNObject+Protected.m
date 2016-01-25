//
//  PNObject+Protected.m
//  Pods
//
//  Created by Giuseppe Nucifora on 25/01/16.
//
//

#import "PNObject+Protected.h"
#import <PNObjectProperty.h>
#import "PNObjectConstants.h"
#import <NSDate_Utils/NSDate+NSDate_Util.h>

@implementation PNObject (Protected)

@dynamic endPoint;
@dynamic objectModel;
@dynamic JSON;
@dynamic singleInstance;

+ (NSArray * _Nonnull) protectedProperties {
    return @[@"JSON",@"subClassDelegate",@"objectModel",@"objectMapping"];
}

- (void)populateObjectFromJSON:(id _Nullable)JSON
{
    NSDictionary *properties = [PNObjectProperty propertiesForClass:self.class];
    
    for(NSString *propertyName in properties) {
        
        if([propertyName isEqualToString:@"mappingError"])
            continue;
        
        NSString *mappedJSONKey;
        NSString *mappedJSONType;
        
        NSString *propertyType = [properties valueForKey:propertyName];
        
        id mappingValue = [self.objectMapping valueForKey:propertyName];
        
        if([mappingValue isKindOfClass:NSDictionary.class]) {
            mappedJSONKey = [mappingValue valueForKey:@"key"];
            mappedJSONType = [mappingValue valueForKey:@"type"];
        } else {
            mappedJSONKey = mappingValue;
        }
        
        // Check if there is mapping for the property
        if([self isObjNull:mappedJSONKey]) {
            // No mapping so just continue
            continue;
        }
        
        
        // Get JSON value for the mapped key
        id value = [JSON valueForKeyPath:propertyName];
        if([self isObjNull:value]) {
            continue;
        }
        
        
        ((void (^)())@{
                       @"c" : ^{
            char val = [value charValue];
            [self setValue:@(val) forKey:propertyName];
        },
                       @"d" : ^{
            double val = [value doubleValue];
            [self setValue:@(val) forKey:propertyName];
        },
                       @"f" : ^{
            float val = [value floatValue];
            [self setValue:@(val) forKey:propertyName];
        },
                       @"i" : ^{
            int val = [value intValue];
            [self setValue:@(val) forKey:propertyName];
        },
                       @"l" : ^{
            long val = [value longValue];
            [self setValue:@(val) forKey:propertyName];
        },
                       @"s" : ^{
            short val = [value shortValue];
            [self setValue:@(val) forKey:propertyName];
        },
                       @"B" : ^{
            BOOL val = [value boolValue];
            [self setValue:@(val) forKey:propertyName];
        },
                       @"NSString" : ^{
            NSString *val = [NSString stringWithFormat:@"%@", value];
            if (![self isObjNull:val]) {
                [self setValue:val forKey:propertyName];
            }
            
        },
                       @"NSNumber" : ^{
            NSInteger val = [value integerValue];
            [self setValue:@(val) forKey:propertyName];
        },
                       @"NSDate" : ^{
            NSString *str = [NSString stringWithFormat:@"%@", value];
            NSDate *val = [[NSDate dateFromString:str withFormat:kNSDateHelperFormatSQLDateWithTime] toLocalTime];
            if (![self isObjNull:val]) {
                [self setValue:val forKey:propertyName];
            }
        },
                       @"NSArray" : ^{
            NSMutableArray *arr = [NSMutableArray array];
            for(id JSONObject in value) {
                PNObject *val = [[NSClassFromString(mappedJSONType) alloc] initWithJSON:JSONObject];
                [arr addObject:val];
            }
            
            [self setValue:arr forKey:propertyName];
        },
                       @"NSMutableArray" : ^{
            NSMutableArray *arr = [NSMutableArray array];
            for(id JSONObject in value) {
                PNObject *val = [[NSClassFromString(mappedJSONType) alloc] initWithJSON:JSONObject];
                [arr addObject:val];
            }
            
            [self setValue:arr forKey:propertyName];
        }
                       }[propertyType] ?: ^{
                           BOOL isPNObjectSubclass = [NSClassFromString(propertyType) isSubclassOfClass:[PNObject class]];
                           if(isPNObjectSubclass) {
                               PNObject *val = [[NSClassFromString(propertyType) alloc] initWithJSON:value];
                               [self setValue:val forKey:propertyName];
                           }
                           else {
                               NSString *errorStr = [NSString stringWithFormat:@"Property '%@' could not be assigned any value.", propertyName];
                               NSLogDebug(@"%@",errorStr);
                           }
                       })();
    }
    
}

- (BOOL)isObjNull:(id _Nullable)obj
{
    if(!obj || nil == obj || NSNull.null == obj || ([obj isKindOfClass:[NSString class]] && [obj isEqualToString:@"(null)"]) || [obj isEqual:[NSNull null]])
        return YES;
    else
        return NO;
}

@end
