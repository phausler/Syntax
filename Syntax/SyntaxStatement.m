//
//  SyntaxStatement.m
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxStatement.h"
#import "SyntaxCursorElement+Internal.h"

@implementation SyntaxStatement

+ (instancetype)elementWithCursor:(CXCursor)cursor translationUnit:(SyntaxTranslationUnit *)TU
{
    return [[SyntaxStatement alloc] initWithCursor:cursor translationUnit:TU];
}

@end
