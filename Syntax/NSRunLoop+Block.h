//
//  NSRunLoop+Block.h
//  Syntax
//
//  Created by Philippe Hausler on 11/2/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSRunLoop (Block)

- (void)performBlock:(void (^)(void))block mode:(NSString *)mode;
- (void)performBlock:(void (^)(void))block;

@end
