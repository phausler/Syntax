//
//  SyntaxModule.h
//  Syntax
//
//  Created by Philippe Hausler on 10/27/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyntaxModule : NSObject

@property (nonatomic, readonly) SyntaxModule *parent;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *fullName;
@property (nonatomic, readonly, getter=isSystem) BOOL system;
@property (nonatomic, readonly) NSArray *topLevelHeaders;

@end
