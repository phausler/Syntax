//
//  SyntaxSourceStorage.m
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxSourceStorage+Internal.h"
#import "SyntaxHighlighter+Internal.h"
#import "SyntaxCursorElement.h"

@implementation SyntaxSourceStorage {
    NSString *_path;
    NSStringEncoding _encoding;
    NSMutableAttributedString *_string;
    BOOL _dirty;
    __weak SyntaxHighlighter *_highlighter;
}

@synthesize path = _path;

- (instancetype)initWithPath:(NSString *)path attributes:(NSDictionary *)attributes highlighter:(SyntaxHighlighter *)highlighter
{
    NSError *error = nil;
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSString *contents = [NSString stringWithContentsOfFile:path usedEncoding:&encoding error:&error];
    if (contents == nil) {
        self = nil;
        return nil;
    }
    return [self initWithPath:path attributes:attributes contents:contents encoding:encoding highlighter:highlighter dirty:NO];
}

- (instancetype)initWithPath:(NSString *)path attributes:(NSDictionary *)attributes contents:(NSString *)contents encoding:(NSStringEncoding)encoding highlighter:(SyntaxHighlighter *)highlighter dirty:(BOOL)dirty
{
    self = [super init];
    if (self) {
        _encoding = encoding;
        _path = [path copy];
        _string = [[NSMutableAttributedString alloc] initWithString:contents attributes:attributes];
        _highlighter = highlighter;
        _dirty = dirty;
    }
    return self;
}


- (SyntaxSourceFile *)file
{
    return [_highlighter _file:_path];
}

- (NSString *)string
{
    return _string.string;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [_string attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [_string replaceCharactersInRange:range withString:str];
    _dirty = ![_string.string isEqualToString:[NSString stringWithContentsOfFile:self.path usedEncoding:NULL error:NULL]];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [_string setAttributes:attrs range:range];
}

- (NSUInteger)hash
{
    return _path.hash;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[SyntaxSourceStorage class]]) {
        return NO;
    }
    
    return [[object path] isEqualToString:_path];
}

- (BOOL)save:(NSError **)error
{
    return [self.string writeToFile:self.path atomically:YES encoding:_encoding error:error];
}

- (BOOL)saveAs:(NSString *)path error:(NSError **)error
{
    if ([self.string writeToFile:path atomically:YES encoding:_encoding error:error])
    {
        _path = [path copy];
        return YES;
    }
    
    return NO;
}

@end
