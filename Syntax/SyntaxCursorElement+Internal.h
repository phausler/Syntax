//
//  SyntaxCursorElement+Internal.h
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxCursorElement.h"
#import "SyntaxElement+Internal.h"
#import "CXUtils.h"
#import <clang-c/Index.h>

@class SyntaxHighlighter, SyntaxTranslationUnit;

@interface SyntaxCursorElement ()

@property (nonatomic, readonly) CXCursor cursor;
@property (nonatomic, readonly) SyntaxTranslationUnit *TU;

- (instancetype)initWithCursor:(CXCursor)cursor translationUnit:(SyntaxTranslationUnit *)TU;

+ (instancetype)elementWithCursor:(CXCursor)cursor translationUnit:(SyntaxTranslationUnit *)TU;

@end

static inline NSRange CXCursorRange(CXCursor cursor) {
    CXSourceRange range = clang_getCursorExtent(cursor);
    return NSRangeFromSourceRange(range);
}
