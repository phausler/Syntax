//
//  SyntaxSourceStorage+Internal.h
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxSourceStorage.h"

@class SyntaxHighlighter;

@interface SyntaxSourceStorage ()

- (instancetype)initWithPath:(NSString *)path attributes:(NSDictionary *)attributes highlighter:(SyntaxHighlighter *)highlighter;
- (instancetype)initWithPath:(NSString *)path attributes:(NSDictionary *)attributes contents:(NSString *)contents encoding:(NSStringEncoding)encoding highlighter:(SyntaxHighlighter *)highlighter dirty:(BOOL)dirty;
- (BOOL)save:(NSError **)error;
- (BOOL)saveAs:(NSString *)path error:(NSError **)error;

@end
