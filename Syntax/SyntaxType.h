//
//  SyntaxType.h
//  Syntax
//
//  Created by Philippe Hausler on 10/16/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SyntaxElement;

@interface SyntaxType : NSObject

@property (nonatomic, readonly) SyntaxType *canonicalType;

@property (nonatomic, readonly, getter=isConstQualified) BOOL constQualified;
@property (nonatomic, readonly, getter=isVolatileQualified) BOOL volatileQualified;
@property (nonatomic, readonly, getter=isRestrictQualified) BOOL restrictQualified;

@property (nonatomic, readonly, getter=isPOD) BOOL plain;

@property (nonatomic, readonly) SyntaxType *pointeeType;
@property (nonatomic, readonly) SyntaxType *elementType;
@property (nonatomic, readonly) NSInteger elementCount;
@property (nonatomic, readonly) SyntaxType *arrayElementType;
@property (nonatomic, readonly) NSInteger arraySize;

@property (nonatomic, readonly) NSArray *templateArgumentTypes;
@property (nonatomic, readonly) SyntaxType *classType;

@property (nonatomic, readonly) NSString *spelling;

@property (nonatomic, readonly) size_t size;
@property (nonatomic, readonly) size_t alignment;

- (ssize_t)offsetOf:(NSString *)member;

@property (nonatomic, readonly) SyntaxElement *declaration;



@end
