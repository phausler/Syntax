//
//  SyntaxModule.m
//  Syntax
//
//  Created by Philippe Hausler on 10/27/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxModule+Internal.h"
#import "SyntaxTranslationUnit+Internal.h"
#import "SyntaxSourceFile+Internal.h"
#import "SyntaxHighlighter+Internal.h"
#import "CXUtils.h"

@implementation SyntaxModule {
    CXModule _module;
    __weak SyntaxTranslationUnit *_TU;
}

- (instancetype)initWithModule:(CXModule)module translationUnit:(SyntaxTranslationUnit *)TU
{
    self = [super init];
    
    if (self) {
        _module = module;
        _TU = TU;
    }
    
    return self;
}

- (SyntaxModule *)parent
{
    CXModule mod = clang_Module_getParent(_module);
    if (mod == NULL) {
        return nil;
    }
    
    CXFile parentFile = clang_Module_getASTFile(mod);
    CXString parentPath = clang_getFileName(parentFile);
    NSString *path = NSStringFromCXString(parentPath);
    clang_disposeString(parentPath);
    SyntaxSourceFile *parentSource = [_TU.mainFile.highlighter file:path];
    return [_TU module:parentSource];
}

- (NSString *)name
{
    CXString moduleName = clang_Module_getName(_module);
    NSString *name = NSStringFromCXString(moduleName);
    clang_disposeString(moduleName);
    return name;
}

- (NSString *)fullName
{
    CXString moduleFullName = clang_Module_getFullName(_module);
    NSString *fullName = NSStringFromCXString(moduleFullName);
    clang_disposeString(moduleFullName);
    return fullName;
}

- (BOOL)isSystem
{
    return clang_Module_isSystem(_module) != 0;
}

- (NSArray *)topLevelHeaders
{
    CXTranslationUnit TU = _TU.TU;
    SyntaxHighlighter *highlighter = _TU.mainFile.highlighter;
    unsigned count = clang_Module_getNumTopLevelHeaders(TU, _module);
    NSMutableArray *headers = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (unsigned idx = 0; idx < count; idx++) {
        CXFile file = clang_Module_getTopLevelHeader(TU, _module, idx);
        CXString path = clang_getFileName(file);
        NSString *filePath = NSStringFromCXString(path);
        [headers addObject:[highlighter file:filePath]];
        clang_disposeString(path);
    }
    
    return headers;
}

@end
