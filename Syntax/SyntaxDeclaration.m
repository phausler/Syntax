//
//  SyntaxDeclaration.m
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxDeclaration.h"
#import "SyntaxCursorElement+Internal.h"
#import "SyntaxSourceFile+Internal.h"
#import "SyntaxTranslationUnit+Internal.h"
#import "CXUtils.h"

@implementation SyntaxDeclaration

+ (instancetype)elementWithCursor:(CXCursor)cursor translationUnit:(SyntaxTranslationUnit *)TU
{
    switch (clang_getCursorKind(cursor)) {
        case CXCursor_UnexposedDecl:
            return [[SyntaxUnexposedDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_StructDecl:
            return [[SyntaxStructDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_UnionDecl:
            return [[SyntaxUnionDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_ClassDecl:
            return [[SyntaxClassDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_EnumDecl:
            return [[SyntaxEnumDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_FieldDecl:
            return [[SyntaxFieldDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_EnumConstantDecl:
            return [[SyntaxEnumConstantDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_FunctionDecl:
            return [[SyntaxFunctionDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_VarDecl:
            return [[SyntaxVarDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_ParmDecl:
            return [[SyntaxParmDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_ObjCInterfaceDecl:
            return [[SyntaxObjCInterfaceDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_ObjCCategoryDecl:
            return [[SyntaxObjCCategoryDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_ObjCProtocolDecl:
            return [[SyntaxObjCProtocolDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_ObjCPropertyDecl:
            return [[SyntaxObjCPropertyDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_ObjCIvarDecl:
            return [[SyntaxObjCIvarDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_ObjCInstanceMethodDecl:
            return [[SyntaxObjCInstanceMethodDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_ObjCClassMethodDecl:
            return [[SyntaxObjCClassMethodDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_ObjCImplementationDecl:
            return [[SyntaxObjCImplementationDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_ObjCCategoryImplDecl:
            return [[SyntaxObjCCategoryImplDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_TypedefDecl:
            return [[SyntaxTypedefDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_CXXMethod:
            return [[SyntaxCXXMethodDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_Namespace:
            return [[SyntaxNamespaceDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_LinkageSpec:
            return [[SyntaxLinkageSpecDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_Constructor:
            return [[SyntaxConstructorDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_Destructor:
            return [[SyntaxDestructorDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_ConversionFunction:
            return [[SyntaxConversionFunctionDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_TemplateTypeParameter:
            return [[SyntaxTemplateTypeParameterDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_NonTypeTemplateParameter:
            return [[SyntaxNonTypeTemplateParameterDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_TemplateTemplateParameter:
            return [[SyntaxTemplateTemplateParameterDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_FunctionTemplate:
            return [[SyntaxFunctionTemplateDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_ClassTemplate:
            return [[SyntaxClassTemplateDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_ClassTemplatePartialSpecialization:
            return [[SyntaxClassTemplatePartialSpecializationDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_NamespaceAlias:
            return [[SyntaxNamespaceAliasDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_UsingDirective:
            return [[SyntaxUsingDirectiveDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_UsingDeclaration:
            return [[SyntaxUsingDeclarationDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_TypeAliasDecl:
            return [[SyntaxTypeAliasDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_ObjCSynthesizeDecl:
            return [[SyntaxObjCSynthesizeDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_ObjCDynamicDecl:
            return [[SyntaxObjCDynamicDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        case CXCursor_CXXAccessSpecifier:
            return [[SyntaxCXXAccessSpecifierDeclaration alloc] initWithCursor:cursor translationUnit:TU];
        default:
            return [[SyntaxDeclaration alloc] initWithCursor:cursor translationUnit:TU];
    }
}

@end

@implementation SyntaxNamedDeclaration {
    NSString *_name;
}

- (NSString *)name
{
    if (_name == nil) {
        CXString str = clang_getCursorSpelling(self.cursor);
        _name = NSStringFromCXString(str);
        clang_disposeString(str);
    }
    
    return _name;
}

@end

@implementation SyntaxUnexposedDeclaration

@end

@implementation SyntaxStructDeclaration

- (void)apply
{
//    NSMutableString *declaration = [@"typedef struct {\n" mutableCopy];
//    for (SyntaxFieldDeclaration *field in self.children) {
//        if (field.type.arraySize > -1) {
//            [declaration appendFormat:@"    %@ %@[%ld];\n", field.type.arrayElementType.spelling, field.name, (long)field.type.arraySize];
//        } else {
//            [declaration appendFormat:@"    %@ %@;\n", field.type.spelling, field.name];
//        }
//
//    }
//    [declaration appendFormat:@"} %@;", self.name];
//    NSLog(@"%@", declaration);
    [super apply];
}

@end

@implementation SyntaxUnionDeclaration

@end

@implementation SyntaxClassDeclaration

@end

@implementation SyntaxEnumDeclaration

@end

@implementation SyntaxFieldDeclaration {
    SyntaxType *_type;
}

@synthesize type = _type;

- (instancetype)initWithCursor:(CXCursor)cursor translationUnit:(SyntaxTranslationUnit *)TU
{
    self = [super initWithCursor:cursor translationUnit:TU];
    
    if (self) {
        CXType Ty = clang_getCursorType(cursor);
        _type = [TU type:Ty];
    }
    
    return self;
}

@end

@implementation SyntaxEnumConstantDeclaration

@end

@implementation SyntaxFunctionDeclaration

- (NSArray *)arguments
{
    NSMutableArray *args = [[NSMutableArray alloc] init];
    int nargs = clang_Cursor_getNumArguments(self.cursor);
    
    for (int idx = 0; idx < nargs; idx++) {
        CXCursor cursor = clang_Cursor_getArgument(self.cursor, idx);
        SyntaxCursorElement *arg = [SyntaxCursorElement elementWithCursor:cursor translationUnit:self.TU];
        [args addObject:arg];
    }
    
    return args;
}

@end

@implementation SyntaxVarDeclaration {
    SyntaxType *_type;
}

@synthesize type = _type;

- (instancetype)initWithCursor:(CXCursor)cursor translationUnit:(SyntaxTranslationUnit *)TU
{
    self = [super initWithCursor:cursor translationUnit:TU];
    
    if (self) {
        CXType Ty = clang_getCursorType(cursor);
        _type = [TU type:Ty];
    }
    
    return self;
}

- (void)dealloc
{
    
}

@end

@implementation SyntaxParmDeclaration

@end

@implementation SyntaxObjCInterfaceDeclaration

@end

@implementation SyntaxObjCCategoryDeclaration

@end

@implementation SyntaxObjCProtocolDeclaration

@end

@implementation SyntaxObjCPropertyDeclaration

@end

@implementation SyntaxObjCIvarDeclaration

@end

@implementation SyntaxObjCInstanceMethodDeclaration

@end

@implementation SyntaxObjCClassMethodDeclaration

@end

@implementation SyntaxObjCImplementationDeclaration

@end

@implementation SyntaxObjCCategoryImplDeclaration

@end

@implementation SyntaxTypedefDeclaration

@end

@implementation SyntaxCXXMethodDeclaration

@end

@implementation SyntaxNamespaceDeclaration

@end

@implementation SyntaxLinkageSpecDeclaration

@end

@implementation SyntaxConstructorDeclaration

@end

@implementation SyntaxDestructorDeclaration

@end

@implementation SyntaxConversionFunctionDeclaration

@end

@implementation SyntaxTemplateTypeParameterDeclaration

@end

@implementation SyntaxNonTypeTemplateParameterDeclaration

@end

@implementation SyntaxTemplateTemplateParameterDeclaration

@end

@implementation SyntaxFunctionTemplateDeclaration

@end

@implementation SyntaxClassTemplateDeclaration

@end

@implementation SyntaxClassTemplatePartialSpecializationDeclaration

@end

@implementation SyntaxNamespaceAliasDeclaration

@end

@implementation SyntaxUsingDirectiveDeclaration

@end

@implementation SyntaxUsingDeclarationDeclaration

@end

@implementation SyntaxTypeAliasDeclaration

@end

@implementation SyntaxObjCSynthesizeDeclaration

@end

@implementation SyntaxObjCDynamicDeclaration

@end

@implementation SyntaxCXXAccessSpecifierDeclaration

@end
