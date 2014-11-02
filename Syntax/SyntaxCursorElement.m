//
//  SyntaxCursorElement.m
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxCursorElement+Internal.h"
#import "SyntaxHighlighter+Internal.h"
#import "SyntaxSourceFile+Internal.h"
#import "SyntaxDeclaration.h"
#import "SyntaxStatement.h"
#import "SyntaxExpression.h"
#import "SyntaxSourceStorage.h"
#import "SyntaxTranslationUnit+Internal.h"
#import "SyntaxDirective+Internal.h"
#import "CXUtils.h"

@implementation SyntaxCursorElement {
    CXCursor _cursor;
    __weak SyntaxTranslationUnit *_TU;
    __weak SyntaxSourceFile *_file;
}

@synthesize cursor = _cursor;
@synthesize TU = _TU;
@synthesize file = _file;

- (instancetype)initWithRange:(NSRange)range
{
    self = [super initWithRange:range];
    
    if (self) {
        NSAssert(_file != nil, @"File should not be nil!");
    }
    
    return self;
}

- (instancetype)initWithCursor:(CXCursor)cursor translationUnit:(SyntaxTranslationUnit *)TU
{
    self = [super initWithRange:CXCursorRange(cursor)];
    
    if (self) {
        _cursor = cursor;
        _TU = TU;
        CXSourceLocation loc = clang_getCursorLocation(_cursor);
        _file = SourceLocationFile(TU, loc);
    }
    
    return self;
}

+ (instancetype)elementWithCursor:(CXCursor)cursor translationUnit:(SyntaxTranslationUnit *)TU
{
    static int recursionCheck = 0;
    recursionCheck++;
    assert(recursionCheck == 1);
    SyntaxCursorElement *element = nil;
    enum CXCursorKind kind = clang_getCursorKind(cursor);
    if (kind == CXCursor_TranslationUnit) {
        element = [[SyntaxTranslationUnitElement alloc] initWithCursor:cursor translationUnit:TU];
    } else if (CXCursor_FirstDecl <= kind && kind <= CXCursor_LastDecl) {
        element = [SyntaxDeclaration elementWithCursor:cursor translationUnit:TU];
    } else if (CXCursor_FirstExpr <= kind && kind <= CXCursor_LastExpr) {
        element = [SyntaxExpression elementWithCursor:cursor translationUnit:TU];
    } else if (CXCursor_FirstStmt <= kind && kind <= CXCursor_LastStmt) {
        element = [SyntaxStatement elementWithCursor:cursor translationUnit:TU];
    } else if (CXCursor_FirstPreprocessing <= kind && kind <= CXCursor_LastPreprocessing) {
        element = [SyntaxDirective elementWithCursor:cursor translationUnit:TU];
    } else {
        element = [[SyntaxCursorElement alloc] initWithCursor:cursor translationUnit:TU];
    }
    recursionCheck--;
    return element;
}

- (NSUInteger)hash
{
    return clang_hashCursor(_cursor);
}

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[SyntaxCursorElement class]]) {
        return NO;
    }
    
    return clang_equalCursors(_cursor, [object cursor]) != 0;
}

- (NSRange)spellingRange
{
    CXSourceRange range = clang_getCursorExtent(_cursor);
    return NSRangeFromSourceRangeSpelling(range);
}

- (NSString *)extent
{
    return [self.file.storage.string substringWithRange:self.spellingRange];
}

- (NSString *)spelling
{
    CXString str = clang_getCursorSpelling(_cursor);
    NSString *spelling = NSStringFromCXString(str);
    clang_disposeString(str);
    return spelling;
}

- (SyntaxCursorElement *)lexicalParent
{
    CXCursor lexicalParentCursor = clang_getCursorLexicalParent(_cursor);
    return [_TU cursorElement:lexicalParentCursor];
}

- (SyntaxCursorElement *)semanticParent
{
    CXCursor semanticParentCursor = clang_getCursorSemanticParent(_cursor);
    return [_TU cursorElement:semanticParentCursor];
}

- (SyntaxCursorElementKind)kind
{
    switch (clang_getCursorKind(_cursor)) {
        case CXCursor_UnexposedDecl:
            return SyntaxCursorUnexposedDeclKind;
        case CXCursor_StructDecl:
            return SyntaxCursorStructDeclKind;
        case CXCursor_UnionDecl:
            return SyntaxCursorUnionDeclKind;
        case CXCursor_ClassDecl:
            return SyntaxCursorClassDeclKind;
        case CXCursor_EnumDecl:
            return SyntaxCursorEnumDeclKind;
        case CXCursor_FieldDecl:
            return SyntaxCursorFieldDeclKind;
        case CXCursor_EnumConstantDecl:
            return SyntaxCursorEnumConstantDeclKind;
        case CXCursor_FunctionDecl:
            return SyntaxCursorFunctionDeclKind;
        case CXCursor_VarDecl:
            return SyntaxCursorVarDeclKind;
        case CXCursor_ParmDecl:
            return SyntaxCursorParmDeclKind;
        case CXCursor_ObjCInterfaceDecl:
            return SyntaxCursorObjCInterfaceDeclKind;
        case CXCursor_ObjCCategoryDecl:
            return SyntaxCursorObjCCategoryDeclKind;
        case CXCursor_ObjCProtocolDecl:
            return SyntaxCursorObjCProtocolDeclKind;
        case CXCursor_ObjCPropertyDecl:
            return SyntaxCursorObjCPropertyDeclKind;
        case CXCursor_ObjCIvarDecl:
            return SyntaxCursorObjCIvarDeclKind;
        case CXCursor_ObjCInstanceMethodDecl:
            return SyntaxCursorObjCInstanceMethodDeclKind;
        case CXCursor_ObjCClassMethodDecl:
            return SyntaxCursorObjCClassMethodDeclKind;
        case CXCursor_ObjCImplementationDecl:
            return SyntaxCursorObjCImplementationDeclKind;
        case CXCursor_ObjCCategoryImplDecl:
            return SyntaxCursorObjCCategoryImplDeclKind;
        case CXCursor_TypedefDecl:
            return SyntaxCursorTypedefDeclKind;
        case CXCursor_CXXMethod:
            return SyntaxCursorCXXMethodKind;
        case CXCursor_Namespace:
            return SyntaxCursorNamespaceKind;
        case CXCursor_LinkageSpec:
            return SyntaxCursorLinkageSpecKind;
        case CXCursor_Constructor:
            return SyntaxCursorConstructorKind;
        case CXCursor_Destructor:
            return SyntaxCursorDestructorKind;
        case CXCursor_ConversionFunction:
            return SyntaxCursorConversionFunctionKind;
        case CXCursor_TemplateTypeParameter:
            return SyntaxCursorTemplateTypeParameterKind;
        case CXCursor_NonTypeTemplateParameter:
            return SyntaxCursorNonTypeTemplateParameterKind;
        case CXCursor_TemplateTemplateParameter:
            return SyntaxCursorTemplateTemplateParameterKind;
        case CXCursor_FunctionTemplate:
            return SyntaxCursorFunctionTemplateKind;
        case CXCursor_ClassTemplate:
            return SyntaxCursorClassTemplateKind;
        case CXCursor_ClassTemplatePartialSpecialization:
            return SyntaxCursorClassTemplatePartialSpecializationKind;
        case CXCursor_NamespaceAlias:
            return SyntaxCursorNamespaceAliasKind;
        case CXCursor_UsingDirective:
            return SyntaxCursorUsingDirectiveKind;
        case CXCursor_UsingDeclaration:
            return SyntaxCursorUsingDeclarationKind;
        case CXCursor_TypeAliasDecl:
            return SyntaxCursorTypeAliasDeclKind;
        case CXCursor_ObjCSynthesizeDecl:
            return SyntaxCursorObjCSynthesizeDeclKind;
        case CXCursor_ObjCDynamicDecl:
            return SyntaxCursorObjCDynamicDeclKind;
        case CXCursor_CXXAccessSpecifier:
            return SyntaxCursorCXXAccessSpecifierKind;
        case CXCursor_ObjCSuperClassRef:
            return SyntaxCursorObjCSuperClassRefKind;
        case CXCursor_ObjCProtocolRef:
            return SyntaxCursorObjCProtocolRefKind;
        case CXCursor_ObjCClassRef:
            return SyntaxCursorObjCClassRefKind;
        case CXCursor_TypeRef:
            return SyntaxCursorTypeRefKind;
        case CXCursor_CXXBaseSpecifier:
            return SyntaxCursorCXXBaseSpecifierKind;
        case CXCursor_TemplateRef:
            return SyntaxCursorTemplateRefKind;
        case CXCursor_NamespaceRef:
            return SyntaxCursorNamespaceRefKind;
        case CXCursor_MemberRef:
            return SyntaxCursorMemberRefKind;
        case CXCursor_LabelRef:
            return SyntaxCursorLabelRefKind;
        case CXCursor_OverloadedDeclRef:
            return SyntaxCursorOverloadedDeclRefKind;
        case CXCursor_VariableRef:
            return SyntaxCursorVariableRefKind;
        case CXCursor_InvalidFile:
            return SyntaxCursorInvalidFileKind;
        case CXCursor_NoDeclFound:
            return SyntaxCursorNoDeclFoundKind;
        case CXCursor_NotImplemented:
            return SyntaxCursorNotImplementedKind;
        case CXCursor_InvalidCode:
            return SyntaxCursorInvalidCodeKind;
        case CXCursor_UnexposedExpr:
            return SyntaxCursorUnexposedExprKind;
        case CXCursor_DeclRefExpr:
            return SyntaxCursorDeclRefExprKind;
        case CXCursor_MemberRefExpr:
            return SyntaxCursorMemberRefExprKind;
        case CXCursor_CallExpr:
            return SyntaxCursorCallExprKind;
        case CXCursor_ObjCMessageExpr:
            return SyntaxCursorObjCMessageExprKind;
        case CXCursor_BlockExpr:
            return SyntaxCursorBlockExprKind;
        case CXCursor_IntegerLiteral:
            return SyntaxCursorIntegerLiteralKind;
        case CXCursor_FloatingLiteral:
            return SyntaxCursorFloatingLiteralKind;
        case CXCursor_ImaginaryLiteral:
            return SyntaxCursorImaginaryLiteralKind;
        case CXCursor_StringLiteral:
            return SyntaxCursorStringLiteralKind;
        case CXCursor_CharacterLiteral:
            return SyntaxCursorCharacterLiteralKind;
        case CXCursor_ParenExpr:
            return SyntaxCursorParenExprKind;
        case CXCursor_UnaryOperator:
            return SyntaxCursorUnaryOperatorKind;
        case CXCursor_ArraySubscriptExpr:
            return SyntaxCursorArraySubscriptExprKind;
        case CXCursor_BinaryOperator:
            return SyntaxCursorBinaryOperatorKind;
        case CXCursor_CompoundAssignOperator:
            return SyntaxCursorCompoundAssignOperatorKind;
        case CXCursor_ConditionalOperator:
            return SyntaxCursorConditionalOperatorKind;
        case CXCursor_CStyleCastExpr:
            return SyntaxCursorCStyleCastExprKind;
        case CXCursor_CompoundLiteralExpr:
            return SyntaxCursorCompoundLiteralExprKind;
        case CXCursor_InitListExpr:
            return SyntaxCursorInitListExprKind;
        case CXCursor_AddrLabelExpr:
            return SyntaxCursorAddrLabelExprKind;
        case CXCursor_StmtExpr:
            return SyntaxCursorStmtExprKind;
        case CXCursor_GenericSelectionExpr:
            return SyntaxCursorGenericSelectionExprKind;
        case CXCursor_GNUNullExpr:
            return SyntaxCursorGNUNullExprKind;
        case CXCursor_CXXStaticCastExpr:
            return SyntaxCursorCXXStaticCastExprKind;
        case CXCursor_CXXDynamicCastExpr:
            return SyntaxCursorCXXDynamicCastExprKind;
        case CXCursor_CXXReinterpretCastExpr:
            return SyntaxCursorCXXReinterpretCastExprKind;
        case CXCursor_CXXConstCastExpr:
            return SyntaxCursorCXXConstCastExprKind;
        case CXCursor_CXXFunctionalCastExpr:
            return SyntaxCursorCXXFunctionalCastExprKind;
        case CXCursor_CXXTypeidExpr:
            return SyntaxCursorCXXTypeidExprKind;
        case CXCursor_CXXBoolLiteralExpr:
            return SyntaxCursorCXXBoolLiteralExprKind;
        case CXCursor_CXXNullPtrLiteralExpr:
            return SyntaxCursorCXXNullPtrLiteralExprKind;
        case CXCursor_CXXThisExpr:
            return SyntaxCursorCXXThisExprKind;
        case CXCursor_CXXThrowExpr:
            return SyntaxCursorCXXThrowExprKind;
        case CXCursor_CXXNewExpr:
            return SyntaxCursorCXXNewExprKind;
        case CXCursor_CXXDeleteExpr:
            return SyntaxCursorCXXDeleteExprKind;
        case CXCursor_UnaryExpr:
            return SyntaxCursorUnaryExprKind;
        case CXCursor_ObjCStringLiteral:
            return SyntaxCursorObjCStringLiteralKind;
        case CXCursor_ObjCEncodeExpr:
            return SyntaxCursorObjCEncodeExprKind;
        case CXCursor_ObjCSelectorExpr:
            return SyntaxCursorObjCSelectorExprKind;
        case CXCursor_ObjCProtocolExpr:
            return SyntaxCursorObjCProtocolExprKind;
        case CXCursor_ObjCBridgedCastExpr:
            return SyntaxCursorObjCBridgedCastExprKind;
        case CXCursor_PackExpansionExpr:
            return SyntaxCursorPackExpansionExprKind;
        case CXCursor_SizeOfPackExpr:
            return SyntaxCursorSizeOfPackExprKind;
        case CXCursor_LambdaExpr:
            return SyntaxCursorLambdaExprKind;
        case CXCursor_ObjCBoolLiteralExpr:
            return SyntaxCursorObjCBoolLiteralExprKind;
        case CXCursor_ObjCSelfExpr:
            return SyntaxCursorObjCSelfExprKind;
        case CXCursor_UnexposedStmt:
            return SyntaxCursorUnexposedStmtKind;
        case CXCursor_LabelStmt:
            return SyntaxCursorLabelStmtKind;
        case CXCursor_CompoundStmt:
            return SyntaxCursorCompoundStmtKind;
        case CXCursor_CaseStmt:
            return SyntaxCursorCaseStmtKind;
        case CXCursor_DefaultStmt:
            return SyntaxCursorDefaultStmtKind;
        case CXCursor_IfStmt:
            return SyntaxCursorIfStmtKind;
        case CXCursor_SwitchStmt:
            return SyntaxCursorSwitchStmtKind;
        case CXCursor_WhileStmt:
            return SyntaxCursorWhileStmtKind;
        case CXCursor_DoStmt:
            return SyntaxCursorDoStmtKind;
        case CXCursor_ForStmt:
            return SyntaxCursorForStmtKind;
        case CXCursor_GotoStmt:
            return SyntaxCursorGotoStmtKind;
        case CXCursor_IndirectGotoStmt:
            return SyntaxCursorIndirectGotoStmtKind;
        case CXCursor_ContinueStmt:
            return SyntaxCursorContinueStmtKind;
        case CXCursor_BreakStmt:
            return SyntaxCursorBreakStmtKind;
        case CXCursor_ReturnStmt:
            return SyntaxCursorReturnStmtKind;
        case CXCursor_GCCAsmStmt:
            return SyntaxCursorGCCAsmStmtKind;
        case CXCursor_ObjCAtTryStmt:
            return SyntaxCursorObjCAtTryStmtKind;
        case CXCursor_ObjCAtCatchStmt:
            return SyntaxCursorObjCAtCatchStmtKind;
        case CXCursor_ObjCAtFinallyStmt:
            return SyntaxCursorObjCAtFinallyStmtKind;
        case CXCursor_ObjCAtThrowStmt:
            return SyntaxCursorObjCAtThrowStmtKind;
        case CXCursor_ObjCAtSynchronizedStmt:
            return SyntaxCursorObjCAtSynchronizedStmtKind;
        case CXCursor_ObjCAutoreleasePoolStmt:
            return SyntaxCursorObjCAutoreleasePoolStmtKind;
        case CXCursor_ObjCForCollectionStmt:
            return SyntaxCursorObjCForCollectionStmtKind;
        case CXCursor_CXXCatchStmt:
            return SyntaxCursorCXXCatchStmtKind;
        case CXCursor_CXXTryStmt:
            return SyntaxCursorCXXTryStmtKind;
        case CXCursor_CXXForRangeStmt:
            return SyntaxCursorCXXForRangeStmtKind;
        case CXCursor_SEHTryStmt:
            return SyntaxCursorSEHTryStmtKind;
        case CXCursor_SEHExceptStmt:
            return SyntaxCursorSEHExceptStmtKind;
        case CXCursor_SEHFinallyStmt:
            return SyntaxCursorSEHFinallyStmtKind;
        case CXCursor_MSAsmStmt:
            return SyntaxCursorMSAsmStmtKind;
        case CXCursor_NullStmt:
            return SyntaxCursorNullStmtKind;
        case CXCursor_DeclStmt:
            return SyntaxCursorDeclStmtKind;
        case CXCursor_OMPParallelDirective:
            return SyntaxCursorOMPParallelDirectiveKind;
        case CXCursor_OMPSimdDirective:
            return SyntaxCursorOMPSimdDirectiveKind;
        case CXCursor_OMPForDirective:
            return SyntaxCursorOMPForDirectiveKind;
        case CXCursor_OMPSectionsDirective:
            return SyntaxCursorOMPSectionsDirectiveKind;
        case CXCursor_OMPSectionDirective:
            return SyntaxCursorOMPSectionDirectiveKind;
        case CXCursor_OMPSingleDirective:
            return SyntaxCursorOMPSingleDirectiveKind;
        case CXCursor_OMPParallelForDirective:
            return SyntaxCursorOMPParallelForDirectiveKind;
        case CXCursor_OMPParallelSectionsDirective:
            return SyntaxCursorOMPParallelSectionsDirectiveKind;
        case CXCursor_OMPTaskDirective:
            return SyntaxCursorOMPTaskDirectiveKind;
        case CXCursor_OMPMasterDirective:
            return SyntaxCursorOMPMasterDirectiveKind;
        case CXCursor_OMPCriticalDirective:
            return SyntaxCursorOMPCriticalDirectiveKind;
        case CXCursor_OMPTaskyieldDirective:
            return SyntaxCursorOMPTaskyieldDirectiveKind;
        case CXCursor_OMPBarrierDirective:
            return SyntaxCursorOMPBarrierDirectiveKind;
        case CXCursor_OMPTaskwaitDirective:
            return SyntaxCursorOMPTaskwaitDirectiveKind;
        case CXCursor_OMPFlushDirective:
            return SyntaxCursorOMPFlushDirectiveKind;
        case CXCursor_SEHLeaveStmt:
            return SyntaxCursorSEHLeaveStmtKind;
        case CXCursor_TranslationUnit:
            return SyntaxCursorTranslationUnitKind;
        case CXCursor_UnexposedAttr:
            return SyntaxCursorUnexposedAttrKind;
        case CXCursor_IBActionAttr:
            return SyntaxCursorIBActionAttrKind;
        case CXCursor_IBOutletAttr:
            return SyntaxCursorIBOutletAttrKind;
        case CXCursor_IBOutletCollectionAttr:
            return SyntaxCursorIBOutletCollectionAttrKind;
        case CXCursor_CXXFinalAttr:
            return SyntaxCursorCXXFinalAttrKind;
        case CXCursor_CXXOverrideAttr:
            return SyntaxCursorCXXOverrideAttrKind;
        case CXCursor_AnnotateAttr:
            return SyntaxCursorAnnotateAttrKind;
        case CXCursor_AsmLabelAttr:
            return SyntaxCursorAsmLabelAttrKind;
        case CXCursor_PackedAttr:
            return SyntaxCursorPackedAttrKind;
        case CXCursor_PureAttr:
            return SyntaxCursorPureAttrKind;
        case CXCursor_ConstAttr:
            return SyntaxCursorConstAttrKind;
        case CXCursor_NoDuplicateAttr:
            return SyntaxCursorNoDuplicateAttrKind;
        case CXCursor_CUDAConstantAttr:
            return SyntaxCursorCUDAConstantAttrKind;
        case CXCursor_CUDADeviceAttr:
            return SyntaxCursorCUDADeviceAttrKind;
        case CXCursor_CUDAGlobalAttr:
            return SyntaxCursorCUDAGlobalAttrKind;
        case CXCursor_CUDAHostAttr:
            return SyntaxCursorCUDAHostAttrKind;
        case CXCursor_PreprocessingDirective:
            return SyntaxCursorPreprocessingDirectiveKind;
        case CXCursor_MacroDefinition:
            return SyntaxCursorMacroDefinitionKind;
        case CXCursor_MacroExpansion:
            return SyntaxCursorMacroExpansionKind;
        case CXCursor_InclusionDirective:
            return SyntaxCursorInclusionDirectiveKind;
        case CXCursor_ModuleImportDecl:
            return SyntaxCursorModuleImportDeclKind;
        default:
            return SyntaxCursorUnknownKind;
    }
}

- (NSString *)key
{
    switch (self.kind) {
        case SyntaxCursorUnexposedDeclKind:
            return @"UnexposedDecl";
        case SyntaxCursorStructDeclKind:
            return @"StructDecl";
        case SyntaxCursorUnionDeclKind:
            return @"UnionDecl";
        case SyntaxCursorClassDeclKind:
            return @"ClassDecl";
        case SyntaxCursorEnumDeclKind:
            return @"EnumDecl";
        case SyntaxCursorFieldDeclKind:
            return @"FieldDecl";
        case SyntaxCursorEnumConstantDeclKind:
            return @"EnumConstantDecl";
        case SyntaxCursorFunctionDeclKind:
            return @"FunctionDecl";
        case SyntaxCursorVarDeclKind:
            return @"VarDecl";
        case SyntaxCursorParmDeclKind:
            return @"ParmDecl";
        case SyntaxCursorObjCInterfaceDeclKind:
            return @"ObjCInterfaceDecl";
        case SyntaxCursorObjCCategoryDeclKind:
            return @"ObjCCategoryDecl";
        case SyntaxCursorObjCProtocolDeclKind:
            return @"ObjCProtocolDecl";
        case SyntaxCursorObjCPropertyDeclKind:
            return @"ObjCPropertyDecl";
        case SyntaxCursorObjCIvarDeclKind:
            return @"ObjCIvarDecl";
        case SyntaxCursorObjCInstanceMethodDeclKind:
            return @"ObjCInstanceMethodDecl";
        case SyntaxCursorObjCClassMethodDeclKind:
            return @"ObjCClassMethodDecl";
        case SyntaxCursorObjCImplementationDeclKind:
            return @"ObjCImplementationDecl";
        case SyntaxCursorObjCCategoryImplDeclKind:
            return @"ObjCCategoryImplDecl";
        case SyntaxCursorTypedefDeclKind:
            return @"TypedefDecl";
        case SyntaxCursorCXXMethodKind:
            return @"CXXMethod";
        case SyntaxCursorNamespaceKind:
            return @"Namespace";
        case SyntaxCursorLinkageSpecKind:
            return @"LinkageSpec";
        case SyntaxCursorConstructorKind:
            return @"Constructor";
        case SyntaxCursorDestructorKind:
            return @"Destructor";
        case SyntaxCursorConversionFunctionKind:
            return @"ConversionFunction";
        case SyntaxCursorTemplateTypeParameterKind:
            return @"TemplateTypeParameter";
        case SyntaxCursorNonTypeTemplateParameterKind:
            return @"NonTypeTemplateParameter";
        case SyntaxCursorTemplateTemplateParameterKind:
            return @"TemplateTemplateParameter";
        case SyntaxCursorFunctionTemplateKind:
            return @"FunctionTemplate";
        case SyntaxCursorClassTemplateKind:
            return @"ClassTemplate";
        case SyntaxCursorClassTemplatePartialSpecializationKind:
            return @"ClassTemplatePartialSpecialization";
        case SyntaxCursorNamespaceAliasKind:
            return @"NamespaceAlias";
        case SyntaxCursorUsingDirectiveKind:
            return @"UsingDirective";
        case SyntaxCursorUsingDeclarationKind:
            return @"UsingDeclaration";
        case SyntaxCursorTypeAliasDeclKind:
            return @"TypeAliasDecl";
        case SyntaxCursorObjCSynthesizeDeclKind:
            return @"ObjCSynthesizeDecl";
        case SyntaxCursorObjCDynamicDeclKind:
            return @"ObjCDynamicDecl";
        case SyntaxCursorCXXAccessSpecifierKind:
            return @"CXXAccessSpecifier";
        case SyntaxCursorObjCSuperClassRefKind:
            return @"ObjCSuperClassRef";
        case SyntaxCursorObjCProtocolRefKind:
            return @"ObjCProtocolRef";
        case SyntaxCursorObjCClassRefKind:
            return @"ObjCClassRef";
        case SyntaxCursorTypeRefKind:
            return @"TypeRef";
        case SyntaxCursorCXXBaseSpecifierKind:
            return @"CXXBaseSpecifier";
        case SyntaxCursorTemplateRefKind:
            return @"TemplateRef";
        case SyntaxCursorNamespaceRefKind:
            return @"NamespaceRef";
        case SyntaxCursorMemberRefKind:
            return @"MemberRef";
        case SyntaxCursorLabelRefKind:
            return @"LabelRef";
        case SyntaxCursorOverloadedDeclRefKind:
            return @"OverloadedDeclRef";
        case SyntaxCursorVariableRefKind:
            return @"VariableRef";
        case SyntaxCursorInvalidFileKind:
            return @"InvalidFile";
        case SyntaxCursorNoDeclFoundKind:
            return @"NoDeclFound";
        case SyntaxCursorNotImplementedKind:
            return @"NotImplemented";
        case SyntaxCursorInvalidCodeKind:
            return @"InvalidCode";
        case SyntaxCursorUnexposedExprKind:
            return @"UnexposedExpr";
        case SyntaxCursorDeclRefExprKind:
            return @"DeclRefExpr";
        case SyntaxCursorMemberRefExprKind:
            return @"MemberRefExpr";
        case SyntaxCursorCallExprKind:
            return @"CallExpr";
        case SyntaxCursorObjCMessageExprKind:
            return @"ObjCMessageExpr";
        case SyntaxCursorBlockExprKind:
            return @"BlockExpr";
        case SyntaxCursorIntegerLiteralKind:
            return @"IntegerLiteral";
        case SyntaxCursorFloatingLiteralKind:
            return @"FloatingLiteral";
        case SyntaxCursorImaginaryLiteralKind:
            return @"ImaginaryLiteral";
        case SyntaxCursorStringLiteralKind:
            return @"StringLiteral";
        case SyntaxCursorCharacterLiteralKind:
            return @"CharacterLiteral";
        case SyntaxCursorParenExprKind:
            return @"ParenExpr";
        case SyntaxCursorUnaryOperatorKind:
            return @"UnaryOperator";
        case SyntaxCursorArraySubscriptExprKind:
            return @"ArraySubscriptExpr";
        case SyntaxCursorBinaryOperatorKind:
            return @"BinaryOperator";
        case SyntaxCursorCompoundAssignOperatorKind:
            return @"CompoundAssignOperator";
        case SyntaxCursorConditionalOperatorKind:
            return @"ConditionalOperator";
        case SyntaxCursorCStyleCastExprKind:
            return @"CStyleCastExpr";
        case SyntaxCursorCompoundLiteralExprKind:
            return @"CompoundLiteralExpr";
        case SyntaxCursorInitListExprKind:
            return @"InitListExpr";
        case SyntaxCursorAddrLabelExprKind:
            return @"AddrLabelExpr";
        case SyntaxCursorStmtExprKind:
            return @"StmtExpr";
        case SyntaxCursorGenericSelectionExprKind:
            return @"GenericSelectionExpr";
        case SyntaxCursorGNUNullExprKind:
            return @"GNUNullExpr";
        case SyntaxCursorCXXStaticCastExprKind:
            return @"CXXStaticCastExpr";
        case SyntaxCursorCXXDynamicCastExprKind:
            return @"CXXDynamicCastExpr";
        case SyntaxCursorCXXReinterpretCastExprKind:
            return @"CXXReinterpretCastExpr";
        case SyntaxCursorCXXConstCastExprKind:
            return @"CXXConstCastExpr";
        case SyntaxCursorCXXFunctionalCastExprKind:
            return @"CXXFunctionalCastExpr";
        case SyntaxCursorCXXTypeidExprKind:
            return @"CXXTypeidExpr";
        case SyntaxCursorCXXBoolLiteralExprKind:
            return @"CXXBoolLiteralExpr";
        case SyntaxCursorCXXNullPtrLiteralExprKind:
            return @"CXXNullPtrLiteralExpr";
        case SyntaxCursorCXXThisExprKind:
            return @"CXXThisExpr";
        case SyntaxCursorCXXThrowExprKind:
            return @"CXXThrowExpr";
        case SyntaxCursorCXXNewExprKind:
            return @"CXXNewExpr";
        case SyntaxCursorCXXDeleteExprKind:
            return @"CXXDeleteExpr";
        case SyntaxCursorUnaryExprKind:
            return @"UnaryExpr";
        case SyntaxCursorObjCStringLiteralKind:
            return @"ObjCStringLiteral";
        case SyntaxCursorObjCEncodeExprKind:
            return @"ObjCEncodeExpr";
        case SyntaxCursorObjCSelectorExprKind:
            return @"ObjCSelectorExpr";
        case SyntaxCursorObjCProtocolExprKind:
            return @"ObjCProtocolExpr";
        case SyntaxCursorObjCBridgedCastExprKind:
            return @"ObjCBridgedCastExpr";
        case SyntaxCursorPackExpansionExprKind:
            return @"PackExpansionExpr";
        case SyntaxCursorSizeOfPackExprKind:
            return @"SizeOfPackExpr";
        case SyntaxCursorLambdaExprKind:
            return @"LambdaExpr";
        case SyntaxCursorObjCBoolLiteralExprKind:
            return @"ObjCBoolLiteralExpr";
        case SyntaxCursorObjCSelfExprKind:
            return @"ObjCSelfExpr";
        case SyntaxCursorUnexposedStmtKind:
            return @"UnexposedStmt";
        case SyntaxCursorLabelStmtKind:
            return @"LabelStmt";
        case SyntaxCursorCompoundStmtKind:
            return @"CompoundStmt";
        case SyntaxCursorCaseStmtKind:
            return @"CaseStmt";
        case SyntaxCursorDefaultStmtKind:
            return @"DefaultStmt";
        case SyntaxCursorIfStmtKind:
            return @"IfStmt";
        case SyntaxCursorSwitchStmtKind:
            return @"SwitchStmt";
        case SyntaxCursorWhileStmtKind:
            return @"WhileStmt";
        case SyntaxCursorDoStmtKind:
            return @"DoStmt";
        case SyntaxCursorForStmtKind:
            return @"ForStmt";
        case SyntaxCursorGotoStmtKind:
            return @"GotoStmt";
        case SyntaxCursorIndirectGotoStmtKind:
            return @"IndirectGotoStmt";
        case SyntaxCursorContinueStmtKind:
            return @"ContinueStmt";
        case SyntaxCursorBreakStmtKind:
            return @"BreakStmt";
        case SyntaxCursorReturnStmtKind:
            return @"ReturnStmt";
        case SyntaxCursorGCCAsmStmtKind:
            return @"GCCAsmStmt";
        case SyntaxCursorObjCAtTryStmtKind:
            return @"ObjCAtTryStmt";
        case SyntaxCursorObjCAtCatchStmtKind:
            return @"ObjCAtCatchStmt";
        case SyntaxCursorObjCAtFinallyStmtKind:
            return @"ObjCAtFinallyStmt";
        case SyntaxCursorObjCAtThrowStmtKind:
            return @"ObjCAtThrowStmt";
        case SyntaxCursorObjCAtSynchronizedStmtKind:
            return @"ObjCAtSynchronizedStmt";
        case SyntaxCursorObjCAutoreleasePoolStmtKind:
            return @"ObjCAutoreleasePoolStmt";
        case SyntaxCursorObjCForCollectionStmtKind:
            return @"ObjCForCollectionStmt";
        case SyntaxCursorCXXCatchStmtKind:
            return @"CXXCatchStmt";
        case SyntaxCursorCXXTryStmtKind:
            return @"CXXTryStmt";
        case SyntaxCursorCXXForRangeStmtKind:
            return @"CXXForRangeStmt";
        case SyntaxCursorSEHTryStmtKind:
            return @"SEHTryStmt";
        case SyntaxCursorSEHExceptStmtKind:
            return @"SEHExceptStmt";
        case SyntaxCursorSEHFinallyStmtKind:
            return @"SEHFinallyStmt";
        case SyntaxCursorMSAsmStmtKind:
            return @"MSAsmStmt";
        case SyntaxCursorNullStmtKind:
            return @"NullStmt";
        case SyntaxCursorDeclStmtKind:
            return @"DeclStmt";
        case SyntaxCursorOMPParallelDirectiveKind:
            return @"OMPParallelDirective";
        case SyntaxCursorOMPSimdDirectiveKind:
            return @"OMPSimdDirective";
        case SyntaxCursorOMPForDirectiveKind:
            return @"OMPForDirective";
        case SyntaxCursorOMPSectionsDirectiveKind:
            return @"OMPSectionsDirective";
        case SyntaxCursorOMPSectionDirectiveKind:
            return @"OMPSectionDirective";
        case SyntaxCursorOMPSingleDirectiveKind:
            return @"OMPSingleDirective";
        case SyntaxCursorOMPParallelForDirectiveKind:
            return @"OMPParallelForDirective";
        case SyntaxCursorOMPParallelSectionsDirectiveKind:
            return @"OMPParallelSectionsDirective";
        case SyntaxCursorOMPTaskDirectiveKind:
            return @"OMPTaskDirective";
        case SyntaxCursorOMPMasterDirectiveKind:
            return @"OMPMasterDirective";
        case SyntaxCursorOMPCriticalDirectiveKind:
            return @"OMPCriticalDirective";
        case SyntaxCursorOMPTaskyieldDirectiveKind:
            return @"OMPTaskyieldDirective";
        case SyntaxCursorOMPBarrierDirectiveKind:
            return @"OMPBarrierDirective";
        case SyntaxCursorOMPTaskwaitDirectiveKind:
            return @"OMPTaskwaitDirective";
        case SyntaxCursorOMPFlushDirectiveKind:
            return @"OMPFlushDirective";
        case SyntaxCursorSEHLeaveStmtKind:
            return @"SEHLeaveStmt";
        case SyntaxCursorTranslationUnitKind:
            return @"TranslationUnit";
        case SyntaxCursorUnexposedAttrKind:
            return @"UnexposedAttr";
        case SyntaxCursorIBActionAttrKind:
            return @"IBActionAttr";
        case SyntaxCursorIBOutletAttrKind:
            return @"IBOutletAttr";
        case SyntaxCursorIBOutletCollectionAttrKind:
            return @"IBOutletCollectionAttr";
        case SyntaxCursorCXXFinalAttrKind:
            return @"CXXFinalAttr";
        case SyntaxCursorCXXOverrideAttrKind:
            return @"CXXOverrideAttr";
        case SyntaxCursorAnnotateAttrKind:
            return @"AnnotateAttr";
        case SyntaxCursorAsmLabelAttrKind:
            return @"AsmLabelAttr";
        case SyntaxCursorPackedAttrKind:
            return @"PackedAttr";
        case SyntaxCursorPureAttrKind:
            return @"PureAttr";
        case SyntaxCursorConstAttrKind:
            return @"ConstAttr";
        case SyntaxCursorNoDuplicateAttrKind:
            return @"NoDuplicateAttr";
        case SyntaxCursorCUDAConstantAttrKind:
            return @"CUDAConstantAttr";
        case SyntaxCursorCUDADeviceAttrKind:
            return @"CUDADeviceAttr";
        case SyntaxCursorCUDAGlobalAttrKind:
            return @"CUDAGlobalAttr";
        case SyntaxCursorCUDAHostAttrKind:
            return @"CUDAHostAttr";
        case SyntaxCursorPreprocessingDirectiveKind:
            return @"PreprocessingDirective";
        case SyntaxCursorMacroDefinitionKind:
            return @"MacroDefinition";
        case SyntaxCursorMacroExpansionKind:
            return @"MacroExpansion";
        case SyntaxCursorInclusionDirectiveKind:
            return @"InclusionDirective";
        case SyntaxCursorModuleImportDeclKind:
            return @"ModuleImportDecl";
        default:
            return @"unknown";
    }
}

@end
