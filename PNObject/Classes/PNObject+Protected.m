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

- (void) populateObjectFromJSON:(id)JSON {
    return [self populateObjectFromJSON:JSON fromLocal:NO];
}

- (void) populateObjectFromJSON:(id _Nullable)JSON fromLocal:(BOOL) fromLocal {
    
    NSDictionary *properties = [PNObject propertiesForClass:self.class];
    
    for(NSString *propertyName in properties) {
        
        if([propertyName isEqualToString:@"mappingError"])
            continue;
        
        NSString *mappedJSONKey;
        NSString *mappedJSONType;
        
        NSString *propertyType = [properties valueForKey:propertyName];
        
        id mappingValue = [self.JSONObjectMap valueForKey:propertyName];
        
        if([mappingValue isKindOfClass:NSDictionary.class]) {
            mappedJSONKey = [mappingValue valueForKey:PNObjectMappingKey];
            mappedJSONType = [mappingValue valueForKey:PNObjectMappingType];
        } else {
            mappedJSONKey = mappingValue;
        }
        
        /*if (fromLocal) {
         propertyName = mappedJSONKey;
         }*/
        
        if ([[PNObject protectedProperties] containsObject:propertyName] || [self isObjNull:mappedJSONKey]) {
            continue;
        }
        
        // Get JSON value for the mapped key
        id value;
        if (fromLocal) {
            value = [JSON valueForKeyPath:propertyName];
        }
        else {
            value = [JSON valueForKeyPath:mappedJSONKey];
        }
        
        
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
                       @"q" : ^{
            NSInteger val = [value integerValue];
            [self setValue:@(val) forKey:propertyName];
        },
                       @"NSString" : ^{
            if (![self isObjNull:value]) {
                [self setValue:value forKey:propertyName];
            }
        },
                       @"NSNumber" : ^{
            NSNumber *val =  [NSNumber numberWithDouble:[value doubleValue]];
            
            [self setValue:val forKey:propertyName];
        },
                       @"NSDate" : ^{
            NSString *str = [NSString stringWithFormat:@"%@", value];
            NSString *dateFormat = [NSDate parseDateFormatFromString:str];
            
            if (dateFormat == nil) {
                dateFormat = kNSDateHelperFormatSQLDateWithTime;
            }
            
            NSDate *val = [[NSDate dateFromString:str withFormat:dateFormat] toLocalTime];
            
            if (!val) {
                val = [NSDate dateFromISO8601String:str];
            }
            if (![self isObjNull:val]) {
                [self setValue:val forKey:propertyName];
            }
        },
                       @"NSURL" : ^{
            NSString *str = [NSString stringWithFormat:@"%@", value];
            NSURL *val = [NSURL URLWithString:str];
            [self setValue:val forKey:propertyName];
        },
                       @"NSArray" : ^{
            NSMutableArray *arr = [NSMutableArray array];
            for(id JSONObject in value) {
                if(fromLocal || [[JSONObject class] isSubclassOfClass:[PNObject class]] || [NSClassFromString(mappedJSONType) isSubclassOfClass:[PNObject class]]) {
                    PNObject *val = [[NSClassFromString(mappedJSONType) alloc] initWithJSON:JSONObject fromLocal:fromLocal];
                    [arr addObject:val];
                }
                else {
                    [arr addObject:JSONObject];
                }
            }
            
            [self setValue:arr forKey:propertyName];
        },
                       @"NSMutableArray" : ^{
            NSMutableArray *arr = [NSMutableArray array];
            for(id JSONObject in value) {
                if(fromLocal || [[JSONObject class] isSubclassOfClass:[PNObject class]] || [NSClassFromString(mappedJSONType) isSubclassOfClass:[PNObject class]]) {
                    PNObject *val = [[NSClassFromString(mappedJSONType) alloc] initWithJSON:JSONObject fromLocal:fromLocal];
                    [arr addObject:val];
                }
                else {
                    [arr addObject:JSONObject];
                }
            }
            
            [self setValue:arr forKey:propertyName];
        }
                       }[propertyType] ?: ^{
                           
                           BOOL isPNObjectSubclass = [NSClassFromString(propertyType) isSubclassOfClass:[PNObject class]];
                           
                           if(isPNObjectSubclass) {
                               
                               PNObject *val = [[NSClassFromString(propertyType) alloc] initWithJSON:value fromLocal:fromLocal];
                               [self setValue:val forKey:propertyName];
                           }
                           else {
                               NSLogDebug(@"%@",[NSString stringWithFormat:@"Property '%@' could not be assigned any value.", propertyName]);
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
        
        id mappingValue = [self.JSONObjectMap valueForKey:propertyName];
        
        if([mappingValue isKindOfClass:NSDictionary.class]) {
            mappedJSONKey = [mappingValue valueForKey:PNObjectMappingKey];
            mappedJSONType = [mappingValue valueForKey:PNObjectMappingType];
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
                       @"q" : ^{
            NSInteger val = 0;
            [self setValue:@(val) forKey:propertyName];
        },
                       @"B" : ^{
            [self setValue:@(NO) forKey:propertyName];
        },
                       @"NSString" : ^{
            [self setValue:[NSString string] forKey:propertyName];
        },
                       @"NSNumber" : ^{
            [self setValue:[[NSNumber alloc] init] forKey:propertyName];
        },
                       @"NSDate" : ^{
            [self setValue:[[NSDate alloc] init] forKey:propertyName];
        },
                       @"NSArray" : ^{
            [self setValue:[NSArray array] forKey:propertyName];
        },
                       @"NSMutableArray" : ^{
            [self setValue:[NSMutableArray array] forKey:propertyName];
        }
                       }[propertyType] ?: ^{
                           BOOL isPNObjectSubclass = [NSClassFromString(propertyType) isSubclassOfClass:[PNObject class]];
                           if(isPNObjectSubclass) {
                               [self setValue:@"" forKey:propertyName];
                           }
                           else {
                               NSLogDebug(@"%@",[NSString stringWithFormat:@"Property '%@' could not be assigned any value.", propertyName]);
                           }
                       })();
    }
}

- (NSDictionary* _Nonnull) getFormObject:(SEL _Nonnull) dictionaryMappingSelector
{
    NSMutableDictionary *JSON = [NSMutableDictionary dictionary];
    
    if ([[self class] respondsToSelector:dictionaryMappingSelector]) {
        
        NSDictionary *properties = [PNObject propertiesForClass:self.class];
        
        //NSDictionary *formMapping = [[self class] performSelector:dictionaryMappingSelector];
        
        NSDictionary *formMapping;
        
        NSMethodSignature *methodSig = [[self class] instanceMethodSignatureForSelector:dictionaryMappingSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setSelector:dictionaryMappingSelector];
        [invocation setTarget:formMapping];
        [invocation invoke];
        
        for (NSString *formMappingKey in formMapping) {
            
            if ([[properties allKeys] containsObject:formMappingKey] && [properties objectForKey:formMappingKey]) {
                
                id property = [self valueForKey:formMappingKey];
                
                id formMappingValue = [formMapping objectForKey:formMappingKey];
                
                NSString *mappedKey;
                NSString *mappedType;
                NSDictionary *mappedValues;
                
                if ([formMappingValue isKindOfClass:[NSDictionary class]]) {
                    mappedKey = [formMappingValue valueForKey:@"key"];
                    mappedType = [formMappingValue valueForKey:@"type"];
                    mappedValues = [formMappingValue valueForKey:@"values"];
                }
                else {
                    mappedKey = formMappingKey;
                }
                
                ((void (^)())@{
                               @"c" : ^{
                    char val = [property charValue];
                    [JSON setValue:@(val) forKey:mappedKey];
                },
                               @"d" : ^{
                    double val = [property doubleValue];
                    [JSON setValue:@(val) forKey:mappedKey];
                },
                               @"f" : ^{
                    float val = [property floatValue];
                    [JSON setValue:@(val) forKey:mappedKey];
                },
                               @"i" : ^{
                    int val = [property intValue];
                    [JSON setValue:@(val) forKey:mappedKey];
                },
                               @"l" : ^{
                    long val = [property longValue];
                    [JSON setValue:@(val) forKey:mappedKey];
                },
                               @"s" : ^{
                    short val = [property shortValue];
                    [JSON setValue:@(val) forKey:mappedKey];
                },
                               @"B" : ^{
                    BOOL val = [property boolValue];
                    [JSON setValue:@(val) forKey:mappedKey];
                },
                               @"q" : ^{
                    NSInteger val = [property integerValue];
                    [JSON setValue:@(val) forKey:mappedKey];
                },
                               
                               @"UIImage" : ^{
                    UIImage *image = [UIImage imageWithData:property];
                    [JSON setValue:image forKey:mappedKey];
                },
                               @"NSURL" : ^{
                    NSURL *url = property;
                    
                    if (![self isObjNull:url]) {
                        [JSON setValue:[url absoluteString] forKey:mappedKey];
                    }
                },
                               @"NSString" : ^{
                    NSString *val = [NSString stringWithFormat:@"%@", property];
                    if (![self isObjNull:val]) {
                        [JSON setValue:val forKey:mappedKey];
                    }
                },
                               @"NSNumber" : ^{
                    NSNumber *val =  [NSNumber numberWithDouble:[property doubleValue]];
                    [JSON setValue:val forKey:mappedKey];
                },
                               @"NSDate" : ^{
                    NSDate *val = [property toLocalTime];
                    if (![self isObjNull:val]) {
                        [JSON setValue:val forKey:mappedKey];
                    }
                },
                               @"NSArray" : ^{
                    NSMutableArray *arr = [NSMutableArray array];
                    for(id object in property) {
                        
                        BOOL isPNObjectSubclass = [[object class] isSubclassOfClass:[PNObject class]];
                        if(isPNObjectSubclass) {
                            NSDictionary *objectDict = [(PNObject*) object getFormObject:dictionaryMappingSelector];
                            
                            [arr addObject:objectDict];
                        }
                        else {
                            [arr addObject:object];
                        }
                    }
                    
                    [JSON setValue:arr forKey:mappedKey];
                },
                               @"NSMutableArray" : ^{
                    NSMutableArray *arr = [NSMutableArray array];
                    for(id object in property) {
                        
                        BOOL isPNObjectSubclass = [[object class] isSubclassOfClass:[PNObject class]];
                        if(isPNObjectSubclass) {
                            NSDictionary *objectDict = [(PNObject*) object getFormObject:dictionaryMappingSelector];
                            
                            [arr addObject:objectDict];
                        }
                        else {
                            [arr addObject:object];
                        }
                    }
                    
                    [JSON setValue:arr forKey:mappedKey];
                }
                               }[[property class]] ?: ^{
                                   BOOL isPNObjectSubclass = [[property class] isSubclassOfClass:[PNObject class]];
                                   if(isPNObjectSubclass) {
                                       
                                       NSDictionary *objectDict = [(PNObject*)property getFormObject:dictionaryMappingSelector];
                                       
                                       [JSON setValue:objectDict forKey:mappedKey];
                                   }
                                   else {
                                   
                                       NSLogDebug(@"%@",[NSString stringWithFormat:@"Property '%@' could not be assigned any value.", property]);
                                   }
                               })();
            }
        }
    }
    return JSON;
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
