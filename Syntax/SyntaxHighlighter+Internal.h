//
//  SyntaxHighlighter+Internal.h
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxHighlighter.h"
#import <clang-c/Index.h>

@class SyntaxSourceStorage;

@interface SyntaxHighlighter ()

@property (nonatomic, readonly) CXIndex index;

- (SyntaxSourceFile *)_file:(NSString *)path;
- (SyntaxSourceStorage *)_storage:(NSString *)path;
- (NSDictionary *)effectiveAttributes:(NSDictionary *)attributes;

@end