//
//  SyntaxHighlighter.swift
//  Syntax-Swift
//
//  Created by Philippe Hausler on 10/21/14.
//  Copyright (c) 2014 Philippe Hausler. All rights reserved.
//

public class Highlighter {
    init() {
        
    }
    
    func addFile(path: String, arguments: Array<String>) -> SourceFile? {
        return nil
    }
    
    func removeFile(path: String) {
        
    }
    
    func file(path: String) -> SourceFile? {
        return nil
    }
    
    func storage(path: String) -> SourceStorage? {
        return nil
    }
    
    func highlight(file: SourceFile) -> Bool {
        return false
    }
    
    func saveAll(Void) {
        
    }
}