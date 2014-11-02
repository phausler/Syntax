//
//  SyntaxType.m
//  Syntax
//
//  Created by Philippe Hausler on 10/16/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxType+Internal.h"
#import "SyntaxSourceFile+Internal.h"
#import "SyntaxTranslationUnit+Internal.h"
#import "CXUtils.h"

@implementation SyntaxType {
    CXType _type;
    NSString *_spelling;
    __weak SyntaxTranslationUnit *_TU;
}

@synthesize type = _type;

- (instancetype)initWithType:(CXType)type translationUnit:(SyntaxTranslationUnit *)TU
{
    self = [super init];

    if (self) {
        _type = type;
        _TU = TU;
    }
    
    return self;
}

- (void)dealloc
{
    
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[SyntaxType class]]) {
        return NO;
    }
    
    return clang_equalTypes(_type, [(SyntaxType *)object type]);
}

- (SyntaxType *)canonicalType
{
    return [_TU type:clang_getCanonicalType(_type)];
}

- (BOOL)isConstQualified
{
    return clang_isConstQualifiedType(_type) != 0;
}

- (BOOL)isVolatileQualified
{
    return clang_isVolatileQualifiedType(_type) != 0;
}

- (BOOL)isRestrictQualified
{
    return clang_isRestrictQualifiedType(_type) != 0;
}

- (SyntaxType *)pointeeType
{
    return [_TU type:clang_getPointeeType(_type)];
}

- (SyntaxElement *)declaration
{
    return (SyntaxElement *)[_TU cursorElement:clang_getTypeDeclaration(_type)];
}

- (BOOL)isPOD
{
    return clang_isPODType(_type) != 0;
}

- (SyntaxType *)elementType
{
    return [_TU type:clang_getElementType(_type)];
}

- (NSInteger)elementCount
{
    return clang_getNumElements(_type);
}

- (SyntaxType *)arrayElementType
{
    return [_TU type:clang_getArrayElementType(_type)];
}

- (NSInteger)arraySize
{
    return clang_getArraySize(_type);
}

- (size_t)alignment
{
    return clang_Type_getAlignOf(_type);
}

- (size_t)size
{
    return clang_Type_getSizeOf(_type);
}

- (SyntaxType *)classType
{
    return [_TU type:clang_Type_getClassType(_type)];
}

- (ssize_t)offsetOf:(NSString *)member
{
    return clang_Type_getOffsetOf(_type, [member UTF8String]);
}

- (NSArray *)templateArgumentTypes
{
    int count = clang_Type_getNumTemplateArguments(_type);
    if (count == -1) {
        return nil;
    }
    NSMutableArray *templateArgs = [[NSMutableArray alloc] initWithCapacity:count];
    for (int idx = 0; idx < count; idx++) {
        [templateArgs addObject:[_TU type:clang_Type_getTemplateArgumentAsType(_type, idx)]];
    }
    return templateArgs;
}

- (NSString *)spelling
{
    if (_spelling == nil) {
        CXString str = clang_getTypeSpelling(_type);
        _spelling = NSStringFromCXString(str);
        clang_disposeString(str);
    }
    
    return _spelling;
}

@end
