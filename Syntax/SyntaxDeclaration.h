//
//  SyntaxDeclaration.h
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import <Syntax/SyntaxCursorElement.h>

@class SyntaxType;

@interface SyntaxDeclaration : SyntaxCursorElement

@end

@interface SyntaxNamedDeclaration : SyntaxDeclaration

@property (nonatomic, readonly) NSString *name;

@end

@interface SyntaxUnexposedDeclaration : SyntaxDeclaration

@end

@interface SyntaxStructDeclaration : SyntaxNamedDeclaration

@end

@interface SyntaxUnionDeclaration : SyntaxDeclaration

@end

@interface SyntaxClassDeclaration : SyntaxDeclaration

@end

@interface SyntaxEnumDeclaration : SyntaxDeclaration

@end

@interface SyntaxFieldDeclaration : SyntaxNamedDeclaration

@property (nonatomic, readonly) SyntaxType *type;

@end

@interface SyntaxEnumConstantDeclaration : SyntaxDeclaration

@end

@interface SyntaxFunctionDeclaration : SyntaxNamedDeclaration

@property (nonatomic, readonly) NSArray *arguments;

@end

@interface SyntaxVarDeclaration : SyntaxNamedDeclaration

@property (nonatomic, readonly) SyntaxType *type;

@end

@interface SyntaxParmDeclaration : SyntaxVarDeclaration

@end

@interface SyntaxObjCInterfaceDeclaration : SyntaxDeclaration

@end

@interface SyntaxObjCCategoryDeclaration : SyntaxDeclaration

@end

@interface SyntaxObjCProtocolDeclaration : SyntaxDeclaration

@end

@interface SyntaxObjCPropertyDeclaration : SyntaxDeclaration

@end

@interface SyntaxObjCIvarDeclaration : SyntaxDeclaration

@end

@interface SyntaxObjCInstanceMethodDeclaration : SyntaxDeclaration

@end

@interface SyntaxObjCClassMethodDeclaration : SyntaxDeclaration

@end

@interface SyntaxObjCImplementationDeclaration : SyntaxDeclaration

@end

@interface SyntaxObjCCategoryImplDeclaration : SyntaxDeclaration

@end

@interface SyntaxTypedefDeclaration : SyntaxDeclaration

@end

@interface SyntaxCXXMethodDeclaration : SyntaxDeclaration

@end

@interface SyntaxNamespaceDeclaration : SyntaxDeclaration

@end

@interface SyntaxLinkageSpecDeclaration : SyntaxDeclaration

@end

@interface SyntaxConstructorDeclaration : SyntaxDeclaration

@end

@interface SyntaxDestructorDeclaration : SyntaxDeclaration

@end

@interface SyntaxConversionFunctionDeclaration : SyntaxDeclaration

@end

@interface SyntaxTemplateTypeParameterDeclaration : SyntaxDeclaration

@end

@interface SyntaxNonTypeTemplateParameterDeclaration : SyntaxDeclaration

@end

@interface SyntaxTemplateTemplateParameterDeclaration : SyntaxDeclaration

@end

@interface SyntaxFunctionTemplateDeclaration : SyntaxDeclaration

@end

@interface SyntaxClassTemplateDeclaration : SyntaxDeclaration

@end

@interface SyntaxClassTemplatePartialSpecializationDeclaration : SyntaxDeclaration

@end

@interface SyntaxNamespaceAliasDeclaration : SyntaxDeclaration

@end

@interface SyntaxUsingDirectiveDeclaration : SyntaxDeclaration

@end

@interface SyntaxUsingDeclarationDeclaration : SyntaxDeclaration

@end

@interface SyntaxTypeAliasDeclaration : SyntaxDeclaration

@end

@interface SyntaxObjCSynthesizeDeclaration : SyntaxDeclaration

@end

@interface SyntaxObjCDynamicDeclaration : SyntaxDeclaration

@end

@interface SyntaxCXXAccessSpecifierDeclaration : SyntaxDeclaration

@end
