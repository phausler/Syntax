//
//  SyntaxSourceFile.h
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SyntaxSourceStorage;

typedef struct {
    NSUInteger line;
    NSUInteger column;
} LexicalPosition;

typedef struct {
    LexicalPosition start;
    LexicalPosition end;
} LexicalRange;

static inline NSString *NSStringFromLexicalPosition(LexicalPosition pos) {
    return [NSString stringWithFormat:@"%lu.%lu", pos.line, pos.column];
}

static inline NSString *NSStringFromLexicalRange(LexicalRange range) {
    return [NSString stringWithFormat:@"%lu.%lu-%lu.%lu", range.start.line, range.start.column, range.end.line, range.end.column];
}

@interface SyntaxSourceFile : NSObject

@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) SyntaxSourceStorage *storage;

- (LexicalPosition)locationForOffset:(NSUInteger)offset;
- (LexicalRange)lexicalRangeFromRange:(NSRange)range;

- (NSUInteger)offsetForPosition:(LexicalPosition)pos;
- (NSRange)characterRangeFromRange:(LexicalRange)range;

- (BOOL)save:(NSError **)error;

@end
