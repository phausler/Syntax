//
//  SyntaxTranslationUnit.m
//  Syntax
//
//  Created by Philippe Hausler on 10/19/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxTranslationUnit+Internal.h"
#import "SyntaxSourceFile+Internal.h"
#import "SyntaxHighlighter+Internal.h"
#import "SyntaxSourceStorage.h"
#import "SyntaxToken+Internal.h"
#import "SyntaxCursorElement+Internal.h"
#import "SyntaxSourceStorage+Internal.h"
#import "SyntaxModule+Internal.h"
#import "NSMapTable+NSPointerArray.h"
#import <clang-c/Index.h>

NSString *const SyntaxClangDomain = @"clang";

@implementation SyntaxTranslationUnit {
    __weak SyntaxSourceFile *_mainFile;
    CXTranslationUnit _TU;
    NSMapTable *_tokens;
    NSMapTable *_types;
    NSMapTable *_elements;
    NSMapTable *_modules;
    __weak SyntaxTranslationUnitElement *_rootElement;
    CXToken *__tokens;
    unsigned _numTokens;
}

@synthesize TU = _TU;

static inline NSUInteger tokenSize(const void *item) {
    return sizeof(CXToken);
}

static inline BOOL tokenEquals(const void *item1, const void*item2, NSUInteger (*size)(const void *item)) {
    CXToken *A = (CXToken *)item1;
    CXToken *B = (CXToken *)item2;
    if (A == B) {
        return YES;
    }
    
    if (clang_getTokenKind(*A) != clang_getTokenKind(*B)) {
        return NO;
    }
    
    return memcmp(item1, item2, size(item1)) == 0;
}

static inline NSUInteger cursorSize(const void *item) {
    return sizeof(CXCursor);
}

static inline BOOL cursorEquals(const void *item1, const void*item2, NSUInteger (*size)(const void *item)) {
    CXCursor *A = (CXCursor *)item1;
    CXCursor *B = (CXCursor *)item2;
    return clang_equalCursors(*A, *B);
}

static inline NSUInteger cursorHash(const void *item, NSUInteger (*size)(const void *item)) {
    CXCursor *cursor = (CXCursor *)item;
    return clang_hashCursor(*cursor);
}

static inline NSUInteger typeSize(const void *item) {
    return sizeof(CXType);
}

static inline BOOL typeEquals(const void *item1, const void*item2, NSUInteger (*size)(const void *item)) {
    CXType *A = (CXType *)item1;
    CXType *B = (CXType *)item2;
    return clang_equalTypes(*A, *B);
}

- (instancetype)initWithMainFile:(SyntaxSourceFile *)file
{
    self = [super init];
    if (self)
    {
        _mainFile = file;
        NSPointerFunctions *objectFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality];
        NSPointerFunctions *tokenFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsStructPersonality];
        NSPointerFunctions *cursorFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsStructPersonality];
        NSPointerFunctions *typeFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsStructPersonality];
        
        tokenFunctions.sizeFunction = &tokenSize;
        tokenFunctions.isEqualFunction = &tokenEquals;
        
        cursorFunctions.sizeFunction = &cursorSize;
        cursorFunctions.isEqualFunction = &cursorEquals;
        cursorFunctions.hashFunction = &cursorHash;
        
        typeFunctions.sizeFunction = &typeSize;
        typeFunctions.isEqualFunction = &typeEquals;
        
        _tokens = [[NSMapTable alloc] initWithKeyPointerFunctions:tokenFunctions valuePointerFunctions:objectFunctions capacity:1024];
        _elements = [[NSMapTable alloc] initWithKeyPointerFunctions:cursorFunctions valuePointerFunctions:objectFunctions capacity:1024];
        _types = [[NSMapTable alloc] initWithKeyPointerFunctions:typeFunctions valuePointerFunctions:objectFunctions capacity:1024];
        _modules = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPersonality valueOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality capacity:256];
    }
    return self;
}

- (void)dealloc
{
    if (_TU != NULL) {
        clang_disposeTranslationUnit(_TU);
    }
}

- (void)clear
{
    [_tokens removeAllObjects];
    [_elements removeAllObjects];
    [_types removeAllObjects];
    _rootElement = nil;
}

- (BOOL)parse:(NSError **)error
{
    [self clear];
    NSArray *compilationArguments = _mainFile.compilationArguments;
    NSString *path = _mainFile.path;
    
    NSIndexSet *pathArg = [compilationArguments indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if (idx > 0) {
            return [compilationArguments[idx - 1] isEqual:@"-c"] && [[obj stringByExpandingTildeInPath] isEqualToString:path];
        }
        return NO;
    }];
    
    NSMutableArray *args = [compilationArguments mutableCopy];
    [args removeObjectsAtIndexes:pathArg];
    int argv = (int)[args count];
    const char **argc = alloca((argv + 1) * sizeof(char *));
    int idx = 0;
    
    for (NSString *arg in args) {
        argc[idx++] = arg.UTF8String;
    }
    
    SyntaxHighlighter *highlighter = _mainFile.highlighter;
    NSSet *unsaved = highlighter.unsavedStorage;
    int unsavedCount = (int)[unsaved count];
    struct CXUnsavedFile *unsavedFiles = alloca((unsavedCount + 1) * sizeof(struct CXUnsavedFile));
    idx = 0;
    
    for (SyntaxSourceStorage *storage in unsaved) {
        unsavedFiles[idx].Filename = storage.path.UTF8String;
        NSString *contents = storage.string;
        unsavedFiles[idx].Contents = contents.UTF8String;
        unsavedFiles[idx].Length = [contents lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        idx++;
    }
    
    enum CXErrorCode err = clang_parseTranslationUnit2(highlighter.index, path.UTF8String, argc, argv, unsavedFiles, unsavedCount, clang_defaultEditingTranslationUnitOptions() | CXTranslationUnit_DetailedPreprocessingRecord, &_TU);
    
    switch (err) {
        case CXError_Success:
            return YES;
        case CXError_InvalidArguments:
            if (error != NULL) {
                *error = [NSError errorWithDomain:SyntaxClangDomain code:err userInfo:@{NSLocalizedFailureReasonErrorKey: @"Invalid arguments"}];
            }
            return NO;
        case CXError_Failure:
            if (error != NULL) {
                *error = [NSError errorWithDomain:SyntaxClangDomain code:err userInfo:@{NSLocalizedFailureReasonErrorKey: @"Clang failure"}];
            }
            return NO;
        case CXError_Crashed:
            if (error != NULL) {
                *error = [NSError errorWithDomain:SyntaxClangDomain code:err userInfo:@{NSLocalizedFailureReasonErrorKey: @"Crash averted"}];
            }
            return NO;
        case CXError_ASTReadError:
            if (error != NULL) {
                *error = [NSError errorWithDomain:SyntaxClangDomain code:err userInfo:@{NSLocalizedFailureReasonErrorKey: @"Unable to read AST"}];
            }
            return NO;
    }
}

- (BOOL)reparse:(NSError **)error
{
    [self clear];
    SyntaxHighlighter *highlighter = _mainFile.highlighter;
    NSSet *unsaved = highlighter.unsavedStorage;
    int unsavedCount = (int)[unsaved count];
    struct CXUnsavedFile *unsavedFiles = alloca((unsavedCount + 1) * sizeof(struct CXUnsavedFile));
    int idx = 0;
    
    for (SyntaxSourceStorage *storage in unsaved) {
        unsavedFiles[idx].Filename = storage.path.UTF8String;
        NSString *contents = storage.string;
        unsavedFiles[idx].Contents = contents.UTF8String;
        unsavedFiles[idx].Length = [contents lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        idx++;
    }
    
    clang_reparseTranslationUnit(_TU, unsavedCount, unsavedFiles, clang_defaultEditingTranslationUnitOptions() | CXTranslationUnit_DetailedPreprocessingRecord);

    return YES;
}

- (BOOL)tokenize:(NSError **)error
{
    if (__tokens != NULL) {
        clang_disposeTokens(_TU, __tokens, _numTokens);
    }
    
    CXFile file = clang_getFile(_TU, _mainFile.path.UTF8String);
    CXSourceLocation begin = clang_getLocationForOffset(_TU, file, 0);
    CXSourceLocation end = clang_getLocationForOffset(_TU, file, (unsigned int)[_mainFile.storage.string lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    CXSourceRange range = clang_getRange(begin, end);
    clang_tokenize(_TU, range, &__tokens, &_numTokens);
    
    for (unsigned idx = 0; idx < _numTokens; idx++) {
        SyntaxToken *token = [[SyntaxToken alloc] initWithToken:__tokens[idx] translationUnit:self];
        NSMapInsert(_tokens, &__tokens[idx], (__bridge const void *)(token));
    }

    return YES;
}

- (BOOL)parseAST:(NSError **)error
{
    CXCursor root = clang_getTranslationUnitCursor(_TU);
    if (_rootElement == nil) {
        _rootElement = [SyntaxTranslationUnitElement elementWithCursor:root translationUnit:self];
        NSMapInsert(_elements, &root, (__bridge const void *)(_rootElement));
    }
    
    clang_visitChildrenWithBlock(root, ^enum CXChildVisitResult(CXCursor cursor, CXCursor parent) {
        CXSourceLocation loc = clang_getCursorLocation(cursor);
        CXFile file = NULL;
        clang_getFileLocation(loc, &file, NULL, NULL, NULL);
        
        if (file == NULL) {
            return CXChildVisit_Continue;
        }
        
        CXString path = clang_getFileName(file);
        
        if (clang_getCString(path) == NULL) {
            clang_disposeString(path);
            return CXChildVisit_Continue;
        }
        
        clang_disposeString(path);
        
        SyntaxElement *parentElement = (__bridge SyntaxElement *)(NSMapGet(_elements, &parent));
        if (parentElement == nil) {
            parentElement = [SyntaxCursorElement elementWithCursor:parent translationUnit:self];
            NSMapInsert(_elements, &parent, (__bridge const void *)(parentElement));
        }
        
        if (NSMapGet(_elements, &cursor) == NULL) {
            SyntaxElement *element = [SyntaxCursorElement elementWithCursor:cursor translationUnit:self];
            [parentElement addChild:element];
            NSMapInsert(_elements, &cursor, (__bridge const void *)(element));
        }
        
        return CXChildVisit_Recurse;
    });
    return YES;
}

- (NSArray *)tokens
{
    return [[_tokens objectEnumerator] allObjects];
}

- (NSArray *)elements
{
    return [[_elements objectEnumerator] allObjects];
}

- (SyntaxType *)type:(CXType)type
{
    SyntaxType *t = (__bridge SyntaxType *)(NSMapGet(_types, &type));
    
    if (t == nil) {
        t = [[SyntaxType alloc] initWithType:type translationUnit:self];
        NSMapInsert(_types, &type, (__bridge const void *)(t));
    }
    
    return t;
}

- (SyntaxCursorElement *)cursorElement:(CXCursor)cursor
{
    SyntaxCursorElement *element = (__bridge SyntaxCursorElement *)NSMapGet(_elements, &cursor);
    
    if (element == nil) {
        element = [SyntaxCursorElement elementWithCursor:cursor translationUnit:self];
        NSMapInsert(_elements, &cursor, (__bridge const void *)(element));
    }
    
    return element;
}

- (SyntaxModule *)module:(SyntaxSourceFile *)file
{
    SyntaxModule *module = [_modules objectForKey:file];
    if (module != nil) {
        return module;
    }
    
    CXFile f = clang_getFile(_TU, file.path.UTF8String);
    if (f == NULL) {
        return nil;
    }
    
    CXModule mod = clang_getModuleForFile(_TU, f);
    module = [[SyntaxModule alloc] initWithModule:mod translationUnit:self];
    [_modules setObject:module forKey:file];
    return module;
}

@end

@implementation SyntaxTranslationUnitElement

- (SyntaxSourceFile *)file
{
    return nil;
}

- (void)apply
{
    // Translation Units need not apply
}

@end
