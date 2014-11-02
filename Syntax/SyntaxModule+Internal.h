//
//  SyntaxModule+Internal.h
//  Syntax
//
//  Created by Philippe Hausler on 10/27/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxModule.h"
#import <clang-c/Index.h>

@class SyntaxTranslationUnit;

@interface SyntaxModule ()

- (instancetype)initWithModule:(CXModule)module translationUnit:(SyntaxTranslationUnit *)TU;

@end