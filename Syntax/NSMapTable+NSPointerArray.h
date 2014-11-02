//
//  NSMapTable+NSPointerArray.h
//  Syntax
//
//  Created by Philippe Hausler on 10/31/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

#import <Foundation/Foundation.h>

static inline void NSMapTableEnumerateKeysAndValuesUsingBlock(NSMapTable *table, void (^block)(void *key, void *value, BOOL *stop)) {
    NSMapEnumerator enumerator = NSEnumerateMapTable(table);
    void *key = NULL;
    void *value = NULL;
    BOOL stop = NO;
    
    while (NSNextMapEnumeratorPair(&enumerator, &key, &value)) {
        block(key, value, &stop);
        if (stop) {
            break;
        }
    }
    
    NSEndMapTableEnumeration(&enumerator);
}

static inline NSPointerArray *NSMapTableSortKeysUsingBlock(NSMapTable *table, NSComparisonResult (^block)(void *key1, void *key2)) {
    NSPointerArray *sortedKeys = [[NSPointerArray alloc] initWithPointerFunctions:table.keyPointerFunctions];
    size_t count = [table count];
    void *stack_keyArray[1024] = { NULL };
    void **keyArray = &stack_keyArray[0];
    
    if (count > sizeof(stack_keyArray) / sizeof(*stack_keyArray)) {
        keyArray = malloc(sizeof(void *) * count);
        if (keyArray == NULL) {
            return nil;
        }
    }
    __block NSUInteger idx = 0;
    
    NSMapTableEnumerateKeysAndValuesUsingBlock(table, ^(void *key, void *value, BOOL *stop) {
        keyArray[idx++] = key;
    });
    
    qsort_b(keyArray, count, sizeof(void *), ^int(const void *key1, const void *key2) {
        return block((void *)key1, (void *)key2);
    });
    
    for (idx = 0; idx < count; idx++) {
        [sortedKeys addPointer:keyArray[idx]];
    }
    
    if (keyArray != &stack_keyArray[0]) {
        free(keyArray);
    }
    
    return sortedKeys;
}

static inline NSPointerArray *NSMapTableAllKeys(NSMapTable *table) {
    NSPointerArray *keys = [[NSPointerArray alloc] initWithPointerFunctions:table.keyPointerFunctions];
    NSMapTableEnumerateKeysAndValuesUsingBlock(table, ^(void *key, void *value, BOOL *stop) {
        [keys addPointer:key];
    });
    return keys;
}

static inline NSUInteger NSPointerArrayIndexOfPointerPassingTest(NSPointerArray *array, BOOL (^predicate)(void *ptr, NSUInteger idx, BOOL *stop)) {
    NSUInteger found = NSNotFound;
    NSUInteger count = [array count];
    BOOL stop = NO;
    
    for (NSUInteger idx = 0; idx < count; idx++) {
        if (predicate([array pointerAtIndex:idx], idx, &stop)) {
            found = idx;
            break;
        }
        
        if (stop) {
            break;
        }
    }
    
    return found;
}
