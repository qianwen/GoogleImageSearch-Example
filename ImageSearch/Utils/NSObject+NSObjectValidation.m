//
//  NSObject+NSObjectValidation.m
//  ImageSearch
//
//  Created by sissi on 8/31/14.
//  Copyright (c) 2014 qianwen. All rights reserved.
//

#import "NSObject+NSObjectValidation.h"

@implementation NSObject (NSObjectValidation)

- (BOOL)isValidObject {
    return self != nil && self != [NSNull null];
}

- (BOOL)isValidDict {
    return [self isValidObject] && [self isKindOfClass:[NSDictionary class]];
}

- (BOOL)isValidArray {
    return [self isValidObject] && [self isKindOfClass:[NSArray class]];
}

- (BOOL)isValidString {
    return [self isValidObject] && [self isKindOfClass:[NSString class]];
}

@end
