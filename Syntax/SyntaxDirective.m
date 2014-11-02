//
//  SyntaxDirective.m
//  Syntax
//
//  Created by Philippe Hausler on 10/28/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxDirective+Internal.h"
#import "SyntaxCursorElement+Internal.h"
#import "SyntaxInclusionDirective.h"

@implementation SyntaxDirective

- (instancetype)initWithCursor:(CXCursor)cursor translationUnit:(SyntaxTranslationUnit *)TU
{
    self = [super initWithCursor:cursor translationUnit:TU];
    
    if (self) {
        
    }
    
    return self;
}

+ (instancetype)elementWithCursor:(CXCursor)cursor translationUnit:(SyntaxTranslationUnit *)TU
{
    switch (clang_getCursorKind(cursor)) {
        case CXCursor_InclusionDirective:
            return [[SyntaxInclusionDirective alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_PreprocessingDirective:
        case CXCursor_MacroDefinition:
        case CXCursor_MacroExpansion:
//        case CXCursor_MacroInstantiation: // this is a dup?
        default:
            return [[SyntaxDirective alloc] initWithCursor:cursor translationUnit:TU];
    }
}

@end
