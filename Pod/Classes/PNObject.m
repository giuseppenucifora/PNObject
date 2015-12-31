//
//  PNObject.m
//  Pods
//
//  Created by Giuseppe Nucifora on 28/12/15.
//
//

#import "PNObject.h"
#import <PNObjectProperty.h>
#import <NSDate_Utils/NSDate+NSDate_Util.h>

@interface PNObject()

@property (nonatomic, strong) NSDictionary *JSON;

@property (nonatomic, strong) NSString *endPoint;

@end

@implementation PNObject

- (instancetype) init {
    self = [super init];
    
    if (self) {
        NSAssert(_objectMapping, @"You must create objectMapping");

    }
    return self;
}

- (instancetype) initWithJSON:(NSDictionary*) JSON {
    self = [self init];
    if (self) {
        _JSON = [[NSDictionary alloc] initWithDictionary:JSON];
        
        [self populateObjectFromJSON:JSON];
    }
    return self;
}

- (BOOL)isStringNull:(NSString *)str
{
    if(nil == str || NSNull.null == (id)str)
        return YES;
    else
        return NO;
}

- (BOOL)isObjNull:(id)obj
{
    if(nil == obj || NSNull.null == obj)
        return YES;
    else
        return NO;
}

- (NSDictionary *)reverseMapping
{
    NSMutableDictionary *JSON = [NSMutableDictionary dictionary];
    
    NSString *mappedJSONKey;
    NSString *mappedJSONType;
    
    NSDictionary *properties = [PNObjectProperty propertiesForClass:self.class];
    
    for (NSString* propertyName in _objectMapping) {
        id mappingValue = [_objectMapping objectForKey:propertyName];
        
        if([mappingValue isKindOfClass:NSDictionary.class]) {
            mappedJSONKey = [mappingValue valueForKey:@"key"];
            mappedJSONType = [mappingValue valueForKey:@"type"];
        } else {
            mappedJSONKey = mappingValue;
        }
        
        NSString *propertyType = [properties valueForKey:propertyName];
        
        id value = [self valueForKey:propertyName];
        
        // NSDate
        if([propertyType isEqualToString:@"NSDate"]) {
            
            value = [NSDate stringFromDate:value];
        }
        // NSURL
        else if([propertyType isEqualToString:@"NSURL"]) {
            NSURL *url = value;
            value = [url absoluteString];
        }
        // NSArray, NSMutableArray
        else if([propertyType isEqualToString:@"NSArray"] ||
                [propertyType isEqualToString:@"NSMutableArray"]) {
            
            NSMutableArray *arr = [NSMutableArray array];
            for(id LLObject in value) {
                SEL selector = NSSelectorFromString(@"reverseMapping");
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                            [[PNObject class] instanceMethodSignatureForSelector:selector]];
                [invocation setSelector:selector];
                [invocation setTarget:LLObject];
                [invocation invoke];
                NSDictionary *returnValue;
                [invocation getReturnValue:&returnValue];
                
                [arr addObject:returnValue];
            }
            
            value = arr;
            
        }
        // Other LLModel or an unidentified value
        else {
            BOOL isPNObjectSubclass = [NSClassFromString(propertyType) isSubclassOfClass:[PNObject class]];
            if(isPNObjectSubclass) {
                SEL selector = NSSelectorFromString(@"reverseMapping");
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                            [[PNObject class] instanceMethodSignatureForSelector:selector]];
                [invocation setSelector:selector];
                [invocation setTarget:value];
                [invocation invoke];
                NSDictionary *returnValue;
                [invocation getReturnValue:&returnValue];
                
                value = returnValue;
                
            }
            else {
                // do nothing
            }
        }
        
        
        [JSON setValue:value forKey:propertyName];
    }
    
    _JSON = JSON;
    
    return _JSON;
}

- (void)populateObjectFromJSON:(id)JSON
{
    
    NSDictionary *properties = [PNObjectProperty propertiesForClass:self.class];
    
    for(NSString *propertyName in properties) {
        
        if([propertyName isEqualToString:@"mappingError"])
            continue;
        
        NSString *mappedJSONKey;
        NSString *mappedJSONType;
        
        NSString *propertyType = [properties valueForKey:propertyName];
        
        id mappingValue = [_objectMapping valueForKey:propertyName];
        
        if([mappingValue isKindOfClass:NSDictionary.class]) {
            mappedJSONKey = [mappingValue valueForKey:@"key"];
            mappedJSONType = [mappingValue valueForKey:@"type"];
        } else {
            mappedJSONKey = mappingValue;
        }
        
        // Check if there is mapping for the property
        if([self isStringNull:mappedJSONKey]) {
            // No mapping so just continue
            continue;
        }
        
        
        // Get JSON value for the mapped key
        id value = [JSON valueForKeyPath:mappedJSONKey];
        if([self isObjNull:value]) {
            continue;
        }
        
        //NSLog(@"Looking for : %@ -- %@ -- %@", propertyType, mappedJSONKey, value);
        
        
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
                       @"NSString" : ^{
            NSString *val = [NSString stringWithFormat:@"%@", value];
            [self setValue:val forKey:propertyName];
        },
                       @"NSNumber" : ^{
            NSInteger val = [value integerValue];
            [self setValue:@(val) forKey:propertyName];
        },
                       @"NSDate" : ^{
            NSString *str = [NSString stringWithFormat:@"%@", value];
            NSDate *val = [NSDate dateFromString:str];
            [self setValue:val forKey:propertyName];
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
                               NSLog(@"%@",errorStr);
                           }
                       })();
        /*// char
        if([propertyType isEqualToString:@"c"]) {
            char val = [value charValue];
            [self setValue:@(val) forKey:propertyName];
        }
        // double
        else if([propertyType isEqualToString:@"d"]) {
            double val = [value doubleValue];
            [self setValue:@(val) forKey:propertyName];
        }
        // float
        else if([propertyType isEqualToString:@"f"]) {
            float val = [value floatValue];
            [self setValue:@(val) forKey:propertyName];
        }
        // integer
        else if([propertyType isEqualToString:@"i"]) {
            int val = [value intValue];
            [self setValue:@(val) forKey:propertyName];
        }
        // long
        else if([propertyType isEqualToString:@"l"]) {
            long val = [value longValue];
            [self setValue:@(val) forKey:propertyName];
        }
        // short
        else if([propertyType isEqualToString:@"s"]) {
            short val = [value shortValue];
            [self setValue:@(val) forKey:propertyName];
        }
        // NSString
        else if([propertyType isEqualToString:@"NSString"]) {
            NSString *val = [NSString stringWithFormat:@"%@", value];
            [self setValue:val forKey:propertyName];
        }
        // NSNumber
        else if([propertyType isEqualToString:@"NSNumber"]) {
            NSInteger val = [value integerValue];
            [self setValue:@(val) forKey:propertyName];
        }
        // NSDate
        else if([propertyType isEqualToString:@"NSDate"]) {
            
            
            NSString *str = [NSString stringWithFormat:@"%@", value];
            NSDate *val = [NSDate dateFromString:str];
            [self setValue:val forKey:propertyName];
        }
        // NSURL
        else if([propertyType isEqualToString:@"NSURL"]) {
            NSString *str = [NSString stringWithFormat:@"%@", value];
            NSURL *val = [NSURL URLWithString:str];
            [self setValue:val forKey:propertyName];
        }
        // NSArray, NSMutableArray
        else if([propertyType isEqualToString:@"NSArray"] ||
                [propertyType isEqualToString:@"NSMutableArray"]) {
            
            NSMutableArray *arr = [NSMutableArray array];
            for(id JSONObject in value) {
                PNObject *val = [[NSClassFromString(mappedJSONType) alloc] initWithJSON:JSONObject];
                [arr addObject:val];
            }
            
            [self setValue:arr forKey:propertyName];
            
        }
        // Other LLModel or an unidentified value
        else {
            BOOL isPNObjectSubclass = [NSClassFromString(propertyType) isSubclassOfClass:[PNObject class]];
            if(isPNObjectSubclass) {
                PNObject *val = [[NSClassFromString(propertyType) alloc] initWithJSON:value];
                [self setValue:val forKey:propertyName];
            }
            else {
                NSString *errorStr = [NSString stringWithFormat:@"Property '%@' could not be assigned any value.", propertyName];
                NSLog(@"%@",errorStr);
            }
        }*/
        
    }
    
}

@end
