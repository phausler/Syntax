//
//  SyntaxElement+Internal.h
//  Syntax
//
//  Created by Philippe Hausler on 10/13/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import "SyntaxElement.h"

@interface SyntaxElement ()

@property (nonatomic, readonly) NSString *key;

- (instancetype)initWithRange:(NSRange)range;

- (void)apply:(NSRange)range;
- (void)apply;

- (void)unapply:(NSRange)range;
- (void)unapply;

- (void)addChild:(SyntaxElement *)element;

@end
