//
//  SyntaxToken.h
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import <Syntax/SyntaxElement.h>

typedef enum {
    SyntaxTokenPunctuationKind,
    SyntaxTokenKeywordKind,
    SyntaxTokenIdentifierKind,
    SyntaxTokenLiteralKind,
    SyntaxTokenCommentKind,
    SyntaxTokenUnknownKind
} SyntaxTokenKind;

@interface SyntaxToken : SyntaxElement

@property (nonatomic, readonly) SyntaxTokenKind kind;

@end
