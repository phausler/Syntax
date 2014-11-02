//
//  SyntaxInclusionDirective.h
//  Syntax
//
//  Created by Philippe Hausler on 10/28/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import <Syntax/SyntaxDirective.h>

@class SyntaxSourceFile;

@interface SyntaxInclusionDirective : SyntaxDirective

@property (nonatomic, readonly) SyntaxSourceFile *includedFile;

@end
