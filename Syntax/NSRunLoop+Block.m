//
//  NSRunLoop+Block.m
//  Syntax
//
//  Created by Philippe Hausler on 11/2/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "NSRunLoop+Block.h"

@implementation NSRunLoop (Block)

- (void)performBlock:(void (^)(void))block mode:(NSString *)mode
{
    CFRunLoopRef rl = [self getCFRunLoop];
    if (rl == CFRunLoopGetCurrent()) {
        block();
    } else {
        CFRunLoopPerformBlock([self getCFRunLoop], (__bridge CFTypeRef)mode, block);
    }
}

- (void)performBlock:(void (^)(void))block
{
    [self performBlock:block mode:NSDefaultRunLoopMode];
}

@end
