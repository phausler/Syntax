//
//  SyntaxSourceStorage.h
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SyntaxSourceFile;

@interface SyntaxSourceStorage : NSTextStorage

@property (nonatomic, readonly) BOOL dirty;
@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) SyntaxSourceFile *file;

@end
