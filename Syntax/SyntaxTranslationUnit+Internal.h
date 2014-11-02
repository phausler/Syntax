//
//  SyntaxTranslationUnit+Internal.h
//  Syntax
//
//  Created by Philippe Hausler on 10/19/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxTranslationUnit.h"
#import "SyntaxCursorElement.h"
#import <clang-c/Index.h>

@class SyntaxSourceFile, SyntaxType, SyntaxCursorElement;

@interface SyntaxTranslationUnit ()

@property (nonatomic, readonly) CXTranslationUnit TU;
@property (nonatomic, readonly) SyntaxSourceFile *mainFile;

- (instancetype)initWithMainFile:(SyntaxSourceFile *)file;

- (SyntaxType *)type:(CXType)type;
- (SyntaxCursorElement *)cursorElement:(CXCursor)cursor;
- (SyntaxModule *)module:(SyntaxSourceFile *)file;

@end

@interface SyntaxTranslationUnitElement : SyntaxCursorElement

@end