//
//  SyntaxInclusionDirective.m
//  Syntax
//
//  Created by Philippe Hausler on 10/28/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxInclusionDirective.h"
#import "SyntaxCursorElement+Internal.h"
#import "SyntaxTranslationUnit+Internal.h"
#import "SyntaxSourceFile+Internal.h"
#import "SyntaxHighlighter+Internal.h"
#import "CXUtils.h"


@implementation SyntaxInclusionDirective

- (SyntaxSourceFile *)includedFile
{
    CXFile file = clang_getIncludedFile(self.cursor);
    CXString str = clang_getFileName(file);
    NSString *path = NSStringFromCXString(str);
    clang_disposeString(str);
    return [self.TU.mainFile.highlighter file:path];
}

@end
