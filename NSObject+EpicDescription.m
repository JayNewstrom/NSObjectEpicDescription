//
//  NSObject+EpicDescription.m
//  RubyMidwest
//
//  Created by Jay Newstrom on 1/5/13.
//  Copyright (c) 2013 Agape Red. All rights reserved.
//

#import "NSObject+EpicDescription.h"
#import "objc/runtime.h"
@implementation NSObject (EpicDescription)

NSString * property_getTypeString( objc_property_t property )
{
    const char * attrs = property_getAttributes( property );
    if ( attrs == NULL )
        return ( NULL );
    
    static char buffer[256];
    const char * e = strchr( attrs, ',' );
    if ( e == NULL )
        return ( NULL );
    
    int len = (int)(e - attrs);
    memcpy( buffer, attrs, len );
    buffer[len] = '\0';
    
    NSString *begining = [[NSString stringWithUTF8String:buffer] substringFromIndex:3];

    return  [begining substringToIndex:begining.length - 1];
}

- (NSString *)describe
{
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:@"\n**********%@**********\n", NSStringFromClass([self class])];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for(i = 0; i < outCount; i++) {
    	objc_property_t property = properties[i];
    	NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];

        NSString *propertyValue = @"";
        NSString *propertyType = property_getTypeString(property);
        if ([propertyType isEqualToString:@"NSArray"] ||
            [propertyType isEqualToString:@"NSMutableArray"])
        {
            NSArray *temp = [self valueForKey:propertyName];
            propertyValue = [NSString stringWithFormat:@"%d", [temp count]];
        }
        else
            propertyValue = [self valueForKey:propertyName];
        
    	result = [result stringByAppendingFormat:@"%@: %@\n", propertyName, propertyValue];
    }
    free(properties);
    
    result = [result stringByAppendingString:@"\n"];
    
    return result;
}

- (NSString *)describeRecursive
{
    return [self describeRecursiveWithTabs:0];
}

- (NSString *)describeRecursiveWithTabs:(int)tabs
{
    NSString *result = @"";
    
    NSString *tabString = @"";
    for (int b = 0; b < tabs; b++)
        tabString = [tabString stringByAppendingString:@"\t"];
    
    result = [result stringByAppendingFormat:@"\n%@**********%@**********\n", tabString, NSStringFromClass([self class])];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for(i = 0; i < outCount; i++) {
    	objc_property_t property = properties[i];
    	NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        
        NSString *propertyValue = @"";
        NSString *propertyType = property_getTypeString(property);
        if ([propertyType isEqualToString:@"NSArray"] ||
            [propertyType isEqualToString:@"NSMutableArray"])
        {
            NSArray *temp = [self valueForKey:propertyName];
            for (NSObject *obj in temp) {
                propertyValue = [propertyValue stringByAppendingFormat:@"%@", [obj describeRecursiveWithTabs:tabs + 1]];
            }
        }
        else if ([propertyType isEqualToString:@"NSString"])
        {
            NSString *temp = [self valueForKey:propertyName];
            if (![temp isEqual:[NSNull null]])
            {    
                NSString *replacementString = [NSString stringWithFormat:@"\r\n\t%@", tabString];
                propertyValue = [temp stringByReplacingOccurrencesOfString:@"\r\n" withString:replacementString];
            }
        }
        else
            propertyValue = [self valueForKey:propertyName];
        
        result = [result stringByAppendingFormat:@"%@%@: %@\n", tabString, propertyName, propertyValue];
    }
    free(properties);
    
    result = [result stringByAppendingString:@"\n"];
    
    return result;
}

@end
