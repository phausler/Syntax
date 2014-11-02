//
//  SyntaxExpression.m
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxExpression.h"
#import "SyntaxCursorElement+Internal.h"

@implementation SyntaxExpression

+ (instancetype)elementWithCursor:(CXCursor)cursor translationUnit:(SyntaxTranslationUnit *)TU
{
    return [[SyntaxExpression alloc] initWithCursor:cursor translationUnit:TU];
}

@end
