//
//  test.c
//  Syntax
//
//  Created by Philippe Hausler on 10/11/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#include <stdio.h>

#define BAR main
#define FOO BAR

int FOO(int argc, char *argv[]) {
    printf("Hello world\n");
    return 0;
}