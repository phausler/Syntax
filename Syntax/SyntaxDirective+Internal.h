//
//  SyntaxDirective+Internal.h
//  Syntax
//
//  Created by Philippe Hausler on 10/28/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#include "SyntaxDirective.h"
#include <clang-c/Index.h>

@class SyntaxTranslationUnit;

@interface SyntaxDirective ()

+ (instancetype)elementWithCursor:(CXCursor)cursor translationUnit:(SyntaxTranslationUnit *)TU;

@end
