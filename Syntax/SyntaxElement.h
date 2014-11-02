//
//  SyntaxElement.h
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SyntaxSourceFile;

@interface SyntaxElement : NSObject

@property (nonatomic, readonly) SyntaxSourceFile *file;
@property (nonatomic, readonly) NSRange range;
@property (nonatomic, readonly) SyntaxElement *parent;
@property (nonatomic, readonly) NSSet *children;

@end
