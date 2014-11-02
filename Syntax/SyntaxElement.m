//
//  SyntaxElement.m
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxElement.h"
#import "SyntaxSourceFile.h"
#import "SyntaxSourceStorage.h"
#import "SyntaxCursorElement+Internal.h"
#import "SyntaxToken+Internal.h"
#import "SyntaxTranslationUnit+Internal.h"
#import "SyntaxHighlighter+Internal.h"

@implementation SyntaxElement {
    NSMutableSet *_children;
    __weak SyntaxElement *_parent;
}

@synthesize parent = _parent;
@synthesize children = _children;

- (instancetype)initWithRange:(NSRange)range
{
    self = [super init];
    
    if (self) {
        _range = range;
        _children = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (NSString *)key
{
    return nil;
}

- (SyntaxSourceFile *)file
{
    return nil;
}

- (void)apply:(NSRange)range
{
    NSString *key = self.key;
    if (key == nil) {
        return;
    }
    
    if (NSMaxRange(range) > self.file.storage.length) {
        LexicalPosition start = [self.file locationForOffset:range.location];
        LexicalPosition end = [self.file locationForOffset:NSMaxRange(range)];
        NSLog(@"Element %@ out of range of file: start-line:%lu start-col:%lu end-line:%lu end-col:%lu", self, start.line, start.column, end.line, end.column);
        return;
    }
    if ([self isKindOfClass:[SyntaxCursorElement class]] ||
        [self isKindOfClass:[SyntaxToken class]]) {
        NSRange effectiveRange = range;
        NSMutableDictionary *currentAttributes = [[self.file.storage attributesAtIndex:range.location longestEffectiveRange:&effectiveRange inRange:range] mutableCopy];
        [currentAttributes addEntriesFromDictionary:@{key: self}];
        NSDictionary *effective = [self.file.highlighter effectiveAttributes:currentAttributes];
        [self.file.storage setAttributes:effective range:effectiveRange];
    } else {
        [self.file.storage addAttribute:key value:self range:range];
    }
}

- (void)apply
{
    [self apply:self.range];
}

- (void)unapply:(NSRange)range
{
    NSString *key = self.key;
    if (key == nil) {
        return;
    }
    
    [self.file.storage removeAttribute:key range:range];
}

- (void)unapply
{
    [self unapply:self.range];
}

- (NSString *)description
{
    LexicalRange lexRange = [self.file lexicalRangeFromRange:self.range];
    
    
    return [NSString stringWithFormat:@"<%@: %p %@ %@:%@ %@>", [self class], self, self.key, self.file.path, NSStringFromLexicalPosition(lexRange.start), NSStringFromRange(self.range)];
}

- (void)setParent:(SyntaxElement *)element
{
    _parent = element;
}

- (void)addChild:(SyntaxElement *)element
{
    [element setParent:self];
    [_children addObject:element];
}

@end
