//
//  SyntaxHighlighter.h
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Syntax/SyntaxToken.h>
#import <Syntax/SyntaxCursorElement.h>

@class SyntaxSourceFile;
@class SyntaxSourceStorage;
@class SyntaxElement;
@class SyntaxHighlighter;

@protocol SyntaxHighlighterDelegate <NSObject>

@optional
- (NSDictionary *)highlighter:(SyntaxHighlighter *)highlighter attributesForTokenKind:(SyntaxTokenKind)kind;
- (NSUInteger)highlighter:(SyntaxHighlighter *)highlighter priorityForTokenKind:(SyntaxTokenKind)kind;

- (NSDictionary *)highlighter:(SyntaxHighlighter *)highlighter attributesForCursorElementKind:(SyntaxCursorElementKind)kind;
- (NSUInteger)highlighter:(SyntaxHighlighter *)highlighter priorityForCursorElementKind:(SyntaxCursorElementKind)kind;

@end

@interface SyntaxHighlighter : NSObject

@property (nonatomic, weak) id<SyntaxHighlighterDelegate> delegate;

@property (nonatomic, readonly) NSSet *unsavedStorage;

- (SyntaxSourceFile *)addFile:(NSString *)path arguments:(NSArray *)arguments error:(NSError **)error;
- (void)removeFile:(NSString *)path;

- (SyntaxSourceFile *)file:(NSString *)path;

- (SyntaxSourceStorage *)storage:(NSString *)path;

- (BOOL)syntaxHighlight:(SyntaxSourceFile *)file error:(NSError **)error;

- (BOOL)saveAll:(NSError **)error;

@end
