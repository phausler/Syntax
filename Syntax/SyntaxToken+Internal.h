//
//  SyntaxToken+Internal.h
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxToken.h"
#import "SyntaxElement+Internal.h"
#import "CXUtils.h"
#import <clang-c/Index.h>

@class SyntaxHighlighter, SyntaxTranslationUnit;

@interface SyntaxToken ()

@property (nonatomic, readonly) CXToken token;
@property (nonatomic, readonly) SyntaxTranslationUnit *TU;

- (instancetype)initWithToken:(CXToken)token translationUnit:(SyntaxTranslationUnit *)TU;

@end

static inline NSRange CXTokenRange(CXTranslationUnit TU, CXToken token) {
    CXSourceRange range = clang_getTokenExtent(TU, token);
    return NSRangeFromSourceRange(range);
}
