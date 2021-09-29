//
//  FIleController.swift
//  JerryBit
//
//  Created by USER on 2020/12/07.
//

import Foundation

struct FileController {
    
    func readFile(name fileName: String) -> String? {
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: "") else { return nil }
        return try? String(contentsOfFile: filePath, encoding: .utf8)
    }
}
