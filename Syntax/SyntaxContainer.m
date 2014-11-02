//
//  SyntaxContainer.m
//  Syntax
//
//  Created by Philippe Hausler on 10/30/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxContainer.h"
#import "SyntaxSourceStorage.h"
#import "SyntaxSourceFile.h"

@implementation SyntaxContainer {
    NSMutableSet *_elements;
    NSMutableDictionary *_elementsPerPath;
}

#pragma mark NSSet

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _elements = [[NSMutableSet alloc] init];
        _elementsPerPath = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (NSUInteger)count
{
    return [_elements count];
}

- (id)member:(id)object
{
    return [_elements member:object];
}

- (NSEnumerator *)objectEnumerator
{
    return [_elements objectEnumerator];
}

#pragma mark NSMutableSet

- (void)addObject:(id)object
{
    if ([object isKindOfClass:[SyntaxSourceFile class]]) {
        SyntaxSourceFile *file = (SyntaxSourceFile *)object;
        NSString *path = file.path;
        NSMutableSet *perPath = [_elementsPerPath objectForKey:path];
        if (perPath == nil) {
            perPath = [[NSMutableSet alloc] init];
            [_elementsPerPath setObject:perPath forKey:path];
        }
        [perPath addObject:file];
        [_elements addObject:file];
    } else if ([object isKindOfClass:[SyntaxSourceStorage class]]) {
        SyntaxSourceStorage *storage = (SyntaxSourceStorage *)object;
        NSString *path = storage.path;
        NSMutableSet *perPath = [_elementsPerPath objectForKey:path];
        if (perPath == nil) {
            perPath = [[NSMutableSet alloc] init];
            [_elementsPerPath setObject:perPath forKey:path];
        }
        [perPath addObject:storage];
        [_elements addObject:storage];
    }
}

- (void)removeObject:(id)object
{
    if ([object isKindOfClass:[SyntaxSourceFile class]]) {
        SyntaxSourceFile *file = (SyntaxSourceFile *)object;
        NSString *path = file.path;
        NSMutableSet *perPath = [_elementsPerPath objectForKey:path];
        [perPath removeObject:file];
        if ([perPath count] == 0) {
            [_elementsPerPath removeObjectForKey:path];
        }
        [_elements removeObject:file];
    } else if ([object isKindOfClass:[SyntaxSourceStorage class]]) {
        SyntaxSourceStorage *storage = (SyntaxSourceStorage *)object;
        NSString *path = storage.path;
        NSMutableSet *perPath = [_elementsPerPath objectForKey:path];
        [perPath removeObject:storage];
        if ([perPath count] == 0) {
            [_elementsPerPath removeObjectForKey:path];
        }
        [_elements removeObject:storage];
    }
}

- (NSSet *)elementsForPath:(NSString *)path
{
    return [[_elementsPerPath objectForKey:path] copy];
}

@end
