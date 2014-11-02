//
//  SyntaxTranslationUnit.h
//  Syntax
//
//  Created by Philippe Hausler on 10/19/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SyntaxModule;

@interface SyntaxTranslationUnit : NSObject

@property (nonatomic, readonly) NSArray *tokens;
@property (nonatomic, readonly) NSArray *elements;

- (BOOL)parse:(NSError **)error;
- (BOOL)reparse:(NSError **)error;
- (BOOL)tokenize:(NSError **)error;
- (BOOL)parseAST:(NSError **)error;

@end
