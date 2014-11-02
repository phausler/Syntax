//
//  CXUtils.h
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#ifndef Syntax_CXLocation_h
#define Syntax_CXLocation_h

#import <Foundation/Foundation.h>
#import <clang-c/Index.h>
#import "SyntaxHighlighter+Internal.h"
#import "SyntaxSourceFile+Internal.h"
#import "SyntaxTranslationUnit+Internal.h"

static inline NSUInteger SourceLocationOffset(CXSourceLocation loc) {
    unsigned int offset = 0;
    clang_getFileLocation(loc, NULL, NULL, NULL, &offset);
    return offset;
}

static inline NSUInteger SourceLocationSpellingOffset(CXSourceLocation loc) {
    unsigned int offset = 0;
    clang_getSpellingLocation(loc, NULL, NULL, NULL, &offset);
    return offset;
}

static inline NSRange NSRangeFromSourceRange(CXSourceRange r) {
    NSUInteger start = SourceLocationOffset(clang_getRangeStart(r));
    NSUInteger end = SourceLocationOffset(clang_getRangeEnd(r));
    return NSMakeRange(start, end - start);
}

static inline NSRange NSRangeFromSourceRangeSpelling(CXSourceRange r) {
    NSUInteger start = SourceLocationSpellingOffset(clang_getRangeStart(r));
    NSUInteger end = SourceLocationSpellingOffset(clang_getRangeEnd(r));
    return NSMakeRange(start, end - start);
}

static NSString *NSStringFromCXString(CXString str) {
    const char *cstr = clang_getCString(str);
    if (cstr == NULL) {
        return nil;
    }
    return [NSString stringWithUTF8String:cstr];
}

static inline SyntaxSourceFile *SourceLocationFile(SyntaxTranslationUnit *TU, CXSourceLocation loc) {
    CXFile file;
    clang_getFileLocation(loc, &file, NULL, NULL, NULL);
    
    if (file == NULL) {
        return nil;
    }
    CXString str = clang_getFileName(file);
    NSString *path = NSStringFromCXString(str);
    clang_disposeString(str);
    SyntaxSourceFile *source = [TU.mainFile.highlighter _file:path];
    assert(source != nil);
    return source;
    
}

#endif
