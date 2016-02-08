//
//  PNObject+Protected.m
//  Pods
//
//  Created by Giuseppe Nucifora on 25/01/16.
//
//

#import "PNObject+Protected.h"
#import "PNObjectConstants.h"
#import <NSDate_Utils/NSDate+NSDate_Util.h>
#import "objc/runtime.h"

@implementation PNObject (Protected)

@dynamic endPoint;
@dynamic objectModel;
@dynamic JSON;
@dynamic singleInstance;

+ (NSArray * _Nonnull) protectedProperties {
    return @[@"JSON",@"objectModel",@"objectMapping",@"singleInstance"];
}

- (void)populateObjectFromJSON:(id _Nullable)JSON
{
    NSDictionary *properties = [PNObject propertiesForClass:self.class];
    
    for(NSString *propertyName in properties) {
        
        if([propertyName isEqualToString:@"mappingError"])
            continue;
        
        NSString *mappedJSONKey;
        NSString *mappedJSONType;
        
        NSString *propertyType = [properties valueForKey:propertyName];
        NSLogDebug(@"%@",self.JSONObject);
        
        NSLogDebug(@"%@",[[self class] objcetMapping]);
        
        id mappingValue = [[[self class] objcetMapping] valueForKey:propertyName];
        
        if([mappingValue isKindOfClass:NSDictionary.class]) {
            mappedJSONKey = [mappingValue valueForKey:@"key"];
            mappedJSONType = [mappingValue valueForKey:@"type"];
        } else {
            mappedJSONKey = mappingValue;
        }
        
        
        if ([[PNObject protectedProperties] containsObject:propertyName]) {
            continue;
        }
        
        // Get JSON value for the mapped key
        id value = [JSON valueForKeyPath:mappedJSONKey];
        
        
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
            if (![self isObjNull:value]) {
                [self setValue:value forKey:propertyName];
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

- (void)resetObject
{
    NSDictionary *properties = [PNObject propertiesForClass:self.class];
    
    for(NSString *propertyName in properties) {
        
        if([propertyName isEqualToString:@"mappingError"])
            continue;
        
        NSString *mappedJSONKey;
        NSString *mappedJSONType;
        
        NSString *propertyType = [properties valueForKey:propertyName];
        
        id mappingValue = [self.JSONObject valueForKey:propertyName];
        
        if([mappingValue isKindOfClass:NSDictionary.class]) {
            mappedJSONKey = [mappingValue valueForKey:@"key"];
            mappedJSONType = [mappingValue valueForKey:@"type"];
        } else {
            mappedJSONKey = mappingValue;
        }
        
        
        if ([[PNObject protectedProperties] containsObject:propertyName]
            || [propertyName isEqualToString:@"description"]
            || [propertyName isEqualToString:@"debugDescription"]) {
            continue;
        }
        
        // Get JSON value for the mapped key
        
        ((void (^)())@{
                       @"c" : ^{
            char val = '\0';
            [self setValue:@(val) forKey:propertyName];
        },
                       @"d" : ^{
            double val = 0.0;
            [self setValue:@(val) forKey:propertyName];
        },
                       @"f" : ^{
            float val = 0.0;
            [self setValue:@(val) forKey:propertyName];
        },
                       @"i" : ^{
            int val = 0;
            [self setValue:@(val) forKey:propertyName];
        },
                       @"l" : ^{
            long val = 0;
            [self setValue:@(val) forKey:propertyName];
        },
                       @"s" : ^{
            short val = 0;
            [self setValue:@(val) forKey:propertyName];
        },
                       @"B" : ^{
            [self setValue:@(NO) forKey:propertyName];
        },
                       @"NSString" : ^{
            [self setValue:[[NSString alloc] init] forKey:propertyName];
        },
                       @"NSNumber" : ^{
            [self setValue:[[NSNumber alloc] init] forKey:propertyName];
        },
                       @"NSDate" : ^{
            [self setValue:[[NSDate alloc] init] forKey:propertyName];
        },
                       @"NSArray" : ^{
            [self setValue:[[NSArray alloc] init] forKey:propertyName];
        },
                       @"NSMutableArray" : ^{
            [self setValue:[[NSMutableArray alloc] init] forKey:propertyName];
        }
                       }[propertyType] ?: ^{
                           BOOL isPNObjectSubclass = [NSClassFromString(propertyType) isSubclassOfClass:[PNObject class]];
                           if(isPNObjectSubclass) {
                               [self setValue:@"" forKey:propertyName];
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

static BOOL property_getTypeString( objc_property_t property, char *buffer )
{
    const char * attrs = property_getAttributes( property );
    if ( attrs == NULL )
        return NO;
    
    const char * e = strchr( attrs, ',' );
    if ( e == NULL )
        return NO;
    
    int len = (int)(e - attrs);
    memcpy( buffer, attrs, len );
    buffer[len] = '\0';
    
    return YES;
}



+ (NSDictionary *)propertiesForClass:(Class)PNObjClass
{
    if (PNObjClass == NULL) {
        return nil;
    }
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    if ([PNObjClass isSubclassOfClass:[PNObject class]] &&  PNObjClass != [PNObject class]) {

        [results addEntriesFromDictionary:[self propertiesForClass:class_getSuperclass(PNObjClass)]];
    }
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(PNObjClass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            //const char *propType = getPropertyType(property);
            char propType[256];
            if (!property_getTypeString(property, propType)) {
                continue;
            }
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [NSString stringWithUTF8String:propType];
            
            NSRange range = [propertyType rangeOfString:@"T@\""];
            NSRange range2 = [propertyType rangeOfString:@"T"];
            if (range.location != NSNotFound) {
                NSRange subStrRange = NSMakeRange(range.length, propertyType.length - (range.length + 1));
                propertyType = [propertyType substringWithRange:subStrRange];
            }
            else if (range2.location != NSNotFound) {
                NSRange subStrRange = NSMakeRange(range2.length, propertyType.length - (range2.length));
                propertyType = [propertyType substringWithRange:subStrRange];
            }
            
            //NSLogDebug(@"Prop type & name: %@ -- %@", propertyType, propertyName);
            
            if (![[PNObject protectedProperties] containsObject:propertyName]) {
                [results setObject:propertyType forKey:propertyName];
            }
        }
    }
    free(properties);
    
    // returning a copy here to make sure the dictionary is immutable
    return [NSDictionary dictionaryWithDictionary:results];
}

@end
