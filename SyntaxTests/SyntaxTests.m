//
//  SyntaxTests.m
//  SyntaxTests
//
//  Created by Philippe Hausler on 10/11/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <Syntax/Syntax.h>

@interface SyntaxTests : XCTestCase <SyntaxHighlighterDelegate>

@end

@implementation SyntaxTests

- (NSDictionary *)highlighter:(SyntaxHighlighter *)highlighter attributesForTokenKind:(SyntaxTokenKind)kind
{
    switch (kind) {
        case SyntaxTokenCommentKind:
            return @{NSForegroundColorAttributeName: [NSColor greenColor]};
        case SyntaxTokenKeywordKind:
            return @{NSForegroundColorAttributeName: [NSColor magentaColor]};
        default:
            return nil;
    }
}

- (NSUInteger)highlighter:(SyntaxHighlighter *)highlighter priorityForTokenKind:(SyntaxTokenKind)kind
{
    switch (kind) {
        case SyntaxTokenCommentKind:
            return 999;
        case SyntaxTokenKeywordKind:
            return 997;
        default:
            return 0;
    }
}

- (NSDictionary *)highlighter:(SyntaxHighlighter *)highlighter attributesForCursorElementKind:(SyntaxCursorElementKind)kind
{
    switch (kind) {
        case SyntaxCursorStringLiteralKind:
            return @{NSForegroundColorAttributeName: [NSColor redColor]};
        default:
            return nil;
    }
}

- (NSUInteger)highlighter:(SyntaxHighlighter *)highlighter priorityForCursorElementKind:(SyntaxCursorElementKind)kind
{
    switch (kind) {
        case SyntaxCursorStringLiteralKind:
            return 998;
        default:
            return 0;
    }
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDelegate {
    NSString *path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:1];
    XCTAssert(path != nil, @"Test execution is malformed");
    SyntaxHighlighter *highlighter = [[SyntaxHighlighter alloc] init];
    highlighter.delegate = self;
    SyntaxSourceFile *file = [highlighter addFile:path arguments:@[@"-c"] error:NULL];
    [highlighter syntaxHighlight:file error:NULL];
    SyntaxSourceStorage *storage = file.storage;
    NSLog(@"%@", storage);
}

- (void)testPerformanceExample {
    NSString *path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:1];
    SyntaxHighlighter *highlighter = [[SyntaxHighlighter alloc] init];
    SyntaxSourceFile *file = [highlighter addFile:path arguments:@[@"-c", path] error:NULL];
    // This is an example of a performance test case.
    [self measureBlock:^{
        [highlighter syntaxHighlight:file error:NULL];
        // Put the code you want to measure the time of here.
    }];
}

@end
