//
//  SyntaxContainer.h
//  Syntax
//
//  Created by Philippe Hausler on 10/30/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyntaxContainer : NSMutableSet

- (NSSet *)elementsForPath:(NSString *)path;

@end
