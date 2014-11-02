//
//  SyntaxSourceFile.m
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxSourceFile+Internal.h"
#import "SyntaxHighlighter+Internal.h"
#import "SyntaxSourceStorage+Internal.h"
#import "SyntaxExpression.h"
#import "SyntaxDeclaration.h"
#import "SyntaxStatement.h"
#import "SyntaxCursorElement+Internal.h"
#import "SyntaxToken+Internal.h"
#import "SyntaxTranslationUnit+Internal.h"
#import "NSRunLoop+Block.h"

@implementation SyntaxSourceFile {
    NSString *_path;
    BOOL _dirty;
    NSMutableArray *_highlightingElements;
    SyntaxTranslationUnit *_TU;
    __weak SyntaxHighlighter *_highlighter;
}

//@synthesize unsaved = _dirty;

- (instancetype)initWithPath:(NSString *)path highligher:(SyntaxHighlighter *)highlighter
{
    self = [super init];
    
    if (self) {
        _path = [path copy];
        _highlighter = highlighter;
        _highlightingElements = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (SyntaxHighlighter *)highlighter
{
    return _highlighter;
}

- (SyntaxSourceStorage *)storage
{
    return [_highlighter _storage:self.path];
}

- (BOOL)parse:(NSError **)error
{
    if (_compilationArguments == nil) {
        return NO;
    }
    return [_TU parse:error];
}

- (BOOL)reparse:(NSError **)error
{
    return [_TU reparse:error];
}

- (BOOL)tokenize:(NSError **)error
{
    return [_TU tokenize:error];
}

- (BOOL)parseAST:(NSError **)error
{
    return [_TU parseAST:error];
}

- (void)applyTokens:(NSArray *)pendingTokens ast:(NSArray *)pendingAST
{
    [[NSRunLoop mainRunLoop] performBlock:^{
        NSMutableSet *changingContents = [[NSMutableSet alloc] init];
        [_highlightingElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SyntaxElement *element = obj;
            SyntaxSourceStorage *storage = element.file.storage;
            if (storage) {
                [changingContents addObject:storage];
            }
        }];
        [pendingTokens enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SyntaxSourceStorage *storage = [[obj file] storage];
            if (storage) {
                [changingContents addObject:storage];
            }
        }];
        
        [pendingAST enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SyntaxSourceStorage *storage = [[obj file] storage];
            if (storage) {
                [changingContents addObject:storage];
            }
        }];
        
        [changingContents makeObjectsPerformSelector:@selector(beginEditing)];
        
        [_highlightingElements makeObjectsPerformSelector:@selector(unapply)];
        
        [_highlightingElements removeAllObjects];
        [_highlightingElements addObjectsFromArray:pendingTokens];
        
        [pendingTokens makeObjectsPerformSelector:@selector(apply)];
        
        [_highlightingElements addObjectsFromArray:pendingAST];
        
        [pendingAST makeObjectsPerformSelector:@selector(apply)];
        [changingContents makeObjectsPerformSelector:@selector(endEditing)];
    }];
}

- (BOOL)highlight:(NSError **)error
{
    if (_TU == nil) {
        _TU = [[SyntaxTranslationUnit alloc] initWithMainFile:self];
        if (![self parse:error]) {
            return NO;
        }
    } else {
        if (![self reparse:error]) {
            return NO;
        }
    }
    
    if (![self tokenize:error]) {
        return NO;
    }
    
    if (![self parseAST:error]) {
        return NO;
    }
    
    [self applyTokens:[_TU.tokens copy] ast:[_TU.elements copy]];
    
    return YES;
}

- (void)storageChanged:(NSNotification *)notif
{
    SyntaxSourceStorage *storage = notif.object;
    if ((storage.editedMask & NSTextStorageEditedCharacters)) {
        _dirty = storage.dirty;
    }
}

- (LexicalPosition)locationForOffset:(NSUInteger)offset
{
    LexicalPosition pos = {0, 0};
    CXFile file = clang_getFile(_TU.TU, self.path.UTF8String);
    CXSourceLocation loc = clang_getLocationForOffset(_TU.TU, file, (unsigned)offset);
    if (clang_equalLocations(loc, clang_getNullLocation()) != 0) {
        pos.line = NSNotFound;
        pos.column = NSNotFound;
        return pos;
    }
    clang_getFileLocation(loc, NULL, (unsigned *)&pos.line, (unsigned *)&pos.column, NULL);
    return pos;
}

- (LexicalRange)lexicalRangeFromRange:(NSRange)range
{
    LexicalRange lexRange;
    CXFile file = clang_getFile(_TU.TU, self.path.UTF8String);
    CXSourceLocation start = clang_getLocationForOffset(_TU.TU, file, (unsigned)range.location);
    CXSourceLocation end = clang_getLocationForOffset(_TU.TU, file, (unsigned)NSMaxRange(range));
    
    if (clang_equalLocations(start, clang_getNullLocation()) != 0 ||
        clang_equalLocations(end, clang_getNullLocation()) != 0) {
        lexRange.start.line = NSNotFound;
        lexRange.start.column = NSNotFound;
        lexRange.end.line = NSNotFound;
        lexRange.end.column = NSNotFound;
        return lexRange;
    }
    
    clang_getFileLocation(start, NULL, (unsigned *)&lexRange.start.line, (unsigned *)&lexRange.start.column, NULL);
    clang_getFileLocation(end, NULL, (unsigned *)&lexRange.end.line, (unsigned *)&lexRange.end.column, NULL);
    return lexRange;
}

- (NSUInteger)offsetForPosition:(LexicalPosition)pos
{
    NSUInteger offset = 0;
    CXFile file = clang_getFile(_TU.TU, self.path.UTF8String);
    if (file == NULL) {
        return NSNotFound;
    }
    CXSourceLocation loc = clang_getLocation(_TU.TU, file, (unsigned int)pos.line, (unsigned int)pos.column);
    if (clang_equalLocations(loc, clang_getNullLocation()) != 0) {
        return NSNotFound;
    }
    clang_getFileLocation(loc, NULL, NULL, NULL, (unsigned *)&offset);
    return offset;
}

- (NSRange)characterRangeFromRange:(LexicalRange)range
{
    NSUInteger start = 0;
    NSUInteger end = 0;
    CXFile file = clang_getFile(_TU.TU, self.path.UTF8String);
    if (file == NULL) {
        return NSMakeRange(NSNotFound, 0);
    }
    CXSourceLocation startLoc = clang_getLocation(_TU.TU, file, (unsigned int)range.start.line, (unsigned int)range.start.column);
    CXSourceLocation endLoc = clang_getLocation(_TU.TU, file, (unsigned int)range.end.line, (unsigned int)range.end.column);
    
    if (clang_equalLocations(startLoc, clang_getNullLocation()) != 0 ||
        clang_equalLocations(endLoc, clang_getNullLocation()) != 0) {
        return NSMakeRange(NSNotFound, 0);
    }
    
    clang_getFileLocation(startLoc, NULL, NULL, NULL, (unsigned *)&start);
    clang_getFileLocation(endLoc, NULL, NULL, NULL, (unsigned *)&end);
    return NSMakeRange(start, end - start);
}

- (NSUInteger)hash
{
    return _path.hash ^ _compilationArguments.hash;
}

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[SyntaxSourceFile class]]) {
        return NO;
    }
    
    if (![[object path] isEqualToString:_path]) {
        return NO;
    }
    
    NSArray *args = [object compilationArguments];
    if (_compilationArguments == nil && args == nil) {
        return YES;
    }
    
    return [args isEqualToArray:_compilationArguments];
}

- (BOOL)save:(NSError **)error
{
    _dirty = ![self.storage save:error];
    return !_dirty;
}

- (BOOL)saveAs:(NSString *)path error:(NSError **)error
{
    _dirty = ![self.storage saveAs:path error:error];
    if (!_dirty) {
        _path = [path copy];
    }
    return !_dirty;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p %@>", [self class], self, self.path];
}

@end
