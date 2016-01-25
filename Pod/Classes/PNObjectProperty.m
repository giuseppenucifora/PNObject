//
//  PNObjectProperty.m
//  Pods
//
//  Created by Giuseppe Nucifora on 28/12/15.
//
//

#import "PNObjectProperty.h"
#import "objc/runtime.h"
#import "PNObjectConstants.h"
#import "PNObject+Protected.h"

@implementation PNObjectProperty

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
        [results addEntriesFromDictionary:[self propertiesForClass:[PNObject class]]];
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
