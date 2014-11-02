//
//  SyntaxSourceFile+Internal.h
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxSourceFile.h"
#import "SyntaxType+Internal.h"

@class SyntaxHighlighter, SyntaxElement;

@interface SyntaxSourceFile ()

@property (nonatomic, copy) NSArray *compilationArguments;
@property (nonatomic, readonly) SyntaxHighlighter *highlighter;

- (instancetype)initWithPath:(NSString *)path highligher:(SyntaxHighlighter *)highligher;

- (BOOL)highlight:(NSError **)error;
- (void)storageChanged:(NSNotification *)notif;

@end
