//
//  SyntaxType+Internal.h
//  Syntax
//
//  Created by Philippe Hausler on 10/16/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#include "SyntaxType.h"
#include <clang-c/Index.h>

@class SyntaxTranslationUnit;

@interface SyntaxType ()

@property (nonatomic, readonly) CXType type;

- (instancetype)initWithType:(CXType)type translationUnit:(SyntaxTranslationUnit *)TU;

@end
