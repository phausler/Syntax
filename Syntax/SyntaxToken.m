//
//  SyntaxToken.m
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxToken+Internal.h"
#import "SyntaxTranslationUnit+Internal.h"
#import "CXUtils.h"

@implementation SyntaxToken {
    CXToken _token;
    __weak SyntaxTranslationUnit *_TU;
    __weak SyntaxSourceFile *_file;
}

@synthesize token = _token;
@synthesize TU = _TU;

- (instancetype)initWithToken:(CXToken)token translationUnit:(SyntaxTranslationUnit *)TU
{
    self = [super initWithRange:CXTokenRange(TU.TU, token)];
    
    if (self) {
        _token = token;
        _TU = TU;
    }
    
    return self;
}

- (SyntaxSourceFile *)file
{
    if (_file == nil) {
        CXSourceLocation loc = clang_getTokenLocation(_TU.TU, _token);
        _file = SourceLocationFile(_TU, loc);
    }
    
    return _file;
}

- (NSUInteger)hash
{
    NSRange r = self.range;
    return (r.location ^ r.length) ^ self.kind;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[SyntaxToken class]]) {
        return NO;
    }
    
    if (self.kind != [(SyntaxToken *)object kind]) {
        return NO;
    }
    
    return NSEqualRanges(self.range, [object range]);
}

- (SyntaxTokenKind)kind
{
    switch (clang_getTokenKind(_token)) {
        case CXToken_Punctuation:
            return SyntaxTokenPunctuationKind;
        case CXToken_Keyword:
            return SyntaxTokenKeywordKind;
        case CXToken_Identifier:
            return SyntaxTokenIdentifierKind;
        case CXToken_Literal:
            return SyntaxTokenLiteralKind;
        case CXToken_Comment:
            return SyntaxTokenCommentKind;
        default:
            return SyntaxTokenUnknownKind;
    }
}

- (NSString *)key
{
    switch (self.kind) {
        case SyntaxTokenPunctuationKind:
            return @"Punctuation";
        case SyntaxTokenKeywordKind:
            return @"Keyword";
        case SyntaxTokenIdentifierKind:
            return @"Identifier";
        case SyntaxTokenLiteralKind:
            return @"Literal";
        case SyntaxTokenCommentKind:
            return @"Comment";
        default:
            return @"Unknown";
    }
}

@end
