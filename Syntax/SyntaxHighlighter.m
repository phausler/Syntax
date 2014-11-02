//
//  SyntaxHighlighter.m
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxHighlighter+Internal.h"
#import "SyntaxSourceFile+Internal.h"
#import "SyntaxSourceStorage+Internal.h"
#import "SyntaxContainer.h"
#import "NSMapTable+NSPointerArray.h"

typedef struct {
    NSUInteger kind;
    Class cls;
    NSUInteger priority;
} SyntaxKey;


static NSUInteger syntaxKeySize(const void *item) {
    return sizeof(SyntaxKey);
}

static BOOL syntaxKeyEquals(const void *item1, const void*item2, NSUInteger (*size)(const void *item)) {
    SyntaxKey *A = (SyntaxKey *)item1;
    SyntaxKey *B = (SyntaxKey *)item2;
    if (A == B) {
        return YES;
    }
    
    if (A->cls != B->cls) {
        return NO;
    }
    
    if (A->kind != B->kind) {
        return NO;
    }
    
    return YES;
}

static NSUInteger syntaxKeyHash(const void *item, NSUInteger (*size)(const void *item)) {
    SyntaxKey *key = (SyntaxKey *)item;
    return [key->cls hash] ^ key->kind;
}

static void syntaxKeyRelinquish(const void *item, NSUInteger (*size)(const void *item)) {
    SyntaxKey *key = (SyntaxKey *)item;
    free(key);
}

static void *syntaxKeyAcquire(const void *src, NSUInteger (*size)(const void *item), BOOL shouldCopy) {
    size_t sz = size(src);
    SyntaxKey *key = malloc(sz);
    memcpy(key, src, sz);
    return key;
}


@implementation SyntaxHighlighter {
//    NSMutableSet *_files;
//    NSMutableSet *_storage;
    SyntaxContainer *_files;
    SyntaxContainer *_storage;
    CXIndex _index;
    struct {
        unsigned int attributesForTokenKind:1;
        unsigned int priorityForTokenKind:1;
        unsigned int attributesForCursorElementKind:1;
        unsigned int priorityForCursorElementKind:1;
    } _flags;
    
    NSMapTable *_attributes;
}

@synthesize index = _index;

- (instancetype)init
{
    self = [super init];

    if (self) {
        _index = clang_createIndex(0, 1);
        _files = [[SyntaxContainer alloc] init];
        _storage = [[SyntaxContainer alloc] init];
        
        NSPointerFunctions *keyFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsStructPersonality];
        NSPointerFunctions *objectFunctions = [NSPointerFunctions pointerFunctionsWithOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality | NSPointerFunctionsCopyIn];
        
        keyFunctions.hashFunction = &syntaxKeyHash;
        keyFunctions.isEqualFunction = &syntaxKeyEquals;
        keyFunctions.sizeFunction = &syntaxKeySize;
        keyFunctions.acquireFunction = &syntaxKeyAcquire;
        keyFunctions.relinquishFunction = &syntaxKeyRelinquish;
        
        _attributes = [[NSMapTable alloc] initWithKeyPointerFunctions:keyFunctions valuePointerFunctions:objectFunctions capacity:32];
    }
    
    return self;
}

- (void)dealloc
{
    clang_disposeIndex(_index);
}

- (void)setDelegate:(id<SyntaxHighlighterDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        
        _flags.attributesForTokenKind = [_delegate respondsToSelector:@selector(highlighter:attributesForTokenKind:)];
        _flags.priorityForTokenKind = [_delegate respondsToSelector:@selector(highlighter:priorityForTokenKind:)];
        _flags.attributesForCursorElementKind = [_delegate respondsToSelector:@selector(highlighter:attributesForCursorElementKind:)];
        _flags.priorityForCursorElementKind = [_delegate respondsToSelector:@selector(highlighter:priorityForCursorElementKind:)];
        
        [_attributes removeAllObjects];
        
        for (SyntaxTokenKind kind = SyntaxTokenPunctuationKind; kind < SyntaxTokenUnknownKind; kind++) {
            SyntaxKey key = {
                .kind = kind,
                .cls = [SyntaxToken class],
                .priority = 0
            };
            
            if (_flags.priorityForTokenKind) {
                key.priority = [_delegate highlighter:self priorityForTokenKind:kind];
            }
            
            if (_flags.attributesForTokenKind) {
                NSDictionary *attributes = [_delegate highlighter:self attributesForTokenKind:kind];
                
                if (attributes) {
                    NSMapInsert(_attributes, &key, (__bridge const void *)(attributes));
                }
            }
        }

        for (SyntaxCursorElementKind kind = SyntaxCursorUnexposedDeclKind; kind < SyntaxCursorUnknownKind; kind++) {
            SyntaxKey key = {
                .kind = kind,
                .cls = [SyntaxCursorElement class],
                .priority = 0
            };
            
            if (_flags.priorityForCursorElementKind) {
                key.priority = [_delegate highlighter:self priorityForCursorElementKind:kind];
            }
            
            if (_flags.attributesForCursorElementKind) {
                NSDictionary *attributes = [_delegate highlighter:self attributesForCursorElementKind:kind];

                if (attributes) {
                    NSMapInsert(_attributes, &key, (__bridge const void *)(attributes));
                }
            }
        }
    }
}

- (NSDictionary *)effectiveAttributes:(NSDictionary *)attributes
{
    NSPointerArray *keys = NSMapTableAllKeys(_attributes);
    
    NSArray *elements = [[attributes allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        SyntaxElement *element1 = obj1;
        SyntaxElement *element2 = obj2;
        SyntaxKey key1 = {
            .priority = 0
        };
        SyntaxKey key2 = {
            .priority = 0
        };
        
        if ([element1 isKindOfClass:[SyntaxCursorElement class]]) {
            key1.cls = [SyntaxCursorElement class];
            key1.kind = [(SyntaxCursorElement *)element1 kind];
        } else if ([element1 isKindOfClass:[SyntaxToken class]]) {
            key1.cls = [SyntaxToken class];
            key1.kind = [(SyntaxToken *)element1 kind];
        }
        
        if ([element2 isKindOfClass:[SyntaxCursorElement class]]) {
            key2.cls = [SyntaxCursorElement class];
            key2.kind = [(SyntaxCursorElement *)element2 kind];
        } else if ([element2 isKindOfClass:[SyntaxToken class]]) {
            key2.cls = [SyntaxToken class];
            key2.kind = [(SyntaxToken *)element2 kind];
        }
        
        NSUInteger keyIndex1 = NSPointerArrayIndexOfPointerPassingTest(keys, ^BOOL(void *ptr, NSUInteger idx, BOOL *stop) {
            SyntaxKey *key = (SyntaxKey *)ptr;
            return key->kind == key1.kind && key->cls == key1.cls;
        });
        
        NSUInteger keyIndex2 = NSPointerArrayIndexOfPointerPassingTest(keys, ^BOOL(void *ptr, NSUInteger idx, BOOL *stop) {
            SyntaxKey *key = (SyntaxKey *)ptr;
            return key->kind == key2.kind && key->cls == key2.cls;
        });
        
        if (keyIndex1 == NSNotFound) {
            return NSOrderedDescending;
        }
        
        if (keyIndex2 == NSNotFound) {
            return NSOrderedAscending;
        }
        
        SyntaxKey *k1 = [keys pointerAtIndex:keyIndex1];
        SyntaxKey *k2 = [keys pointerAtIndex:keyIndex2];
        
        if (k1->priority < k2->priority) {
            return NSOrderedAscending;
        } else if (k1->priority > k2->priority) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    NSMutableDictionary *effectiveAttributes = [[NSMutableDictionary alloc] init];
    
    for (NSUInteger idx = [elements count]; idx > 0; idx--) {
        SyntaxKey searchKey = {
            .priority = 0
        };
        
        SyntaxElement *element = elements[idx - 1];
        
        if ([element isKindOfClass:[SyntaxCursorElement class]]) {
            searchKey.cls = [SyntaxCursorElement class];
            searchKey.kind = [(SyntaxCursorElement *)element kind];
        } else if ([element isKindOfClass:[SyntaxToken class]]) {
            searchKey.cls = [SyntaxToken class];
            searchKey.kind = [(SyntaxToken *)element kind];
        }
        
        NSUInteger found = NSPointerArrayIndexOfPointerPassingTest(keys, ^BOOL(void *ptr, NSUInteger idx, BOOL *stop) {
            SyntaxKey *key = ptr;
            return key->cls == searchKey.cls && key->kind == searchKey.kind;
        });
        
        if (found != NSNotFound) {
            SyntaxKey *foundKey = [keys pointerAtIndex:found];
            NSDictionary *appliedAttributes = (__bridge NSDictionary *)NSMapGet(_attributes, foundKey);
            [effectiveAttributes addEntriesFromDictionary:appliedAttributes];
        }
    }
    
    [effectiveAttributes addEntriesFromDictionary:attributes];
    
    return effectiveAttributes;
}

- (NSSet *)unsavedStorage
{
    NSSet *unsaved = nil;
    @synchronized(self) {
        unsaved = [_storage objectsPassingTest:^BOOL(id obj, BOOL *stop) {
            return [obj dirty];
        }];
    }
    return unsaved;
}

- (SyntaxSourceFile *)addFile:(NSString *)path arguments:(NSArray *)arguments error:(NSError **)error
{
    NSString *expanded = [path stringByExpandingTildeInPath];
    BOOL isDir;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:expanded isDirectory:&isDir] && !isDir) {
        SyntaxSourceFile *file = nil;
        @synchronized(self) {
            file = [[SyntaxSourceFile alloc] initWithPath:expanded highligher:self];
            file.compilationArguments = arguments;
            [_files addObject:file];
        }
        return file;
    }
    
    // TODO: assign error here
    return nil;
}

- (void)removeFile:(NSString *)path
{
    @synchronized(self) {
        NSString *expanded = [path stringByExpandingTildeInPath];
        NSSet *matchingFiles = [_files elementsForPath:expanded];
        NSSet *matchingStorage = [_storage elementsForPath:expanded];
        for (SyntaxSourceFile *file in matchingFiles) {
            [[NSNotificationCenter defaultCenter] removeObserver:file name:NSTextStorageDidProcessEditingNotification object:nil];
        }
        [_files minusSet:matchingFiles];
        [_storage minusSet:matchingStorage];
    }
}

- (SyntaxSourceFile *)file:(NSString *)path
{
    NSString *expanded = [path stringByExpandingTildeInPath];
    SyntaxSourceFile *file = nil;
    @synchronized(self) {
        file = [[_files elementsForPath:expanded] anyObject];
    }
    return file;
}

- (SyntaxSourceFile *)_file:(NSString *)path
{
    NSString *expanded = [path stringByExpandingTildeInPath];
    SyntaxSourceFile *file = nil;
    @synchronized(self) {
        file = [[_files elementsForPath:expanded] anyObject];
        BOOL isDir;
        
        if (file == nil && [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && !isDir) {
            file = [[SyntaxSourceFile alloc] initWithPath:expanded highligher:self];
            [_files addObject:file];
        }
    }
    
    return file;
}

- (SyntaxSourceStorage *)storage:(NSString *)path
{
    NSString *expanded = [path stringByExpandingTildeInPath];
    SyntaxSourceStorage *storage = nil;
    @synchronized(self) {
        storage = [[_storage elementsForPath:expanded] anyObject];
    }
    return storage;
}

- (SyntaxSourceStorage *)_storage:(NSString *)path
{
    NSString *expanded = [path stringByExpandingTildeInPath];
    SyntaxSourceStorage *storage = nil;
    @synchronized(self) {
        storage = [[_storage elementsForPath:expanded] anyObject];
        BOOL isDir;
        
        if (storage == nil && [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && !isDir) {
            storage = [[SyntaxSourceStorage alloc] initWithPath:expanded attributes:@{} highlighter:self];
            [_storage addObject:storage];
            [[NSNotificationCenter defaultCenter] addObserver:[self _file:path] selector:@selector(storageChanged:) name:NSTextStorageDidProcessEditingNotification object:storage];
        }
    }
    
    return storage;
}

- (BOOL)syntaxHighlight:(SyntaxSourceFile *)file error:(NSError **)error
{
    return [file highlight:error];
}

- (BOOL)saveAll:(NSError **)error
{
    @synchronized(self) {
        for (SyntaxSourceFile *file in _files) {
            if (![file save:error]) {
                return NO;
            }
        }
    }
    return YES;
}

@end
