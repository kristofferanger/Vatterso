//
//  DatabaseManager.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-10-31.
//

import Foundation
import SQLite3
import SwiftUI

enum DBType {
    case string, integer, float, data, null
    
    var string: String {
        switch self {
        case .data: return "blob"
        case .string: return "text"
        case .float: return "float"
        case .integer: return "integer"
        case .null: return "null"
        }
    }
}

protocol DBItem: Identifiable & Codable {

    static var tableName: String { get }
    static var colums: [(label: String, type: DBType)] { get }

    func valueFor(columnLabel: String) -> Any?
}

fileprivate extension DBItem {
    
    static var columnLabels: [String] {
        return self.colums.map{ $0.label.lowercased() }
    }
    
    static var columnLabelsAndTypes: String {
        let columns = self.colums.map {
            let label = $0.label.lowercased()
            let type = $0.type.string.uppercased()
            var components = [label, type]
            // set id to primary key to avoid duplicates
            if label == "id" {
                components.append("PRIMARY KEY")
            }
            return components.joined(separator: .space)
        }
        return columns.joined(separator: .comma)
    }
}

class DBManager {
    
    init?() {
        guard let db = openDatabase() else { return nil }
        self.db = db
    }
    
    private let dbPath = "database.sqlite"
    private var db: OpaquePointer?
    
    private func openDatabase() -> OpaquePointer? {
        let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        
        if sqlite3_open(fileURL?.path, &db) == SQLITE_OK {
            print("Sucessfully opened database at: \(String(describing: fileURL))")
        }
        else {
            print("Error opening database")
        }
        return db
    }
    
    private func createTable<T: DBItem>(type: T.Type) {
        let createTableString = ["CREATE TABLE IF NOT EXISTS", "\(type.tableName)(\(type.columnLabelsAndTypes));"].joined(separator: .space)
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, createTableString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Table created with name: \(type.tableName).")
            }
            else {
                print("Table could not be created with name \(type.tableName).")
            }
            sqlite3_finalize(statement)
        }
    }
    
    private func tableExists(named: String) -> Bool {
        let queryStatementString = "SELECT count(*) FROM sqlite_schema WHERE type='table' AND name='\(named.lowercased())';"
        var queryStatement: OpaquePointer? = nil
        var foundTable: Bool = false
                
        if sqlite3_prepare(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                foundTable = sqlite3_column_int(queryStatement, 0) > 0
            }
            sqlite3_finalize(queryStatement)
        }
        else {
            print("Count statement could not be prepared")
        }
        return foundTable
    }
    
    func insert<T: DBItem>(item: T) {
        
        let type = type(of: item)
        
        if !tableExists(named: type.tableName) {
            self.createTable(type: type)
        }
        // create insert statement
        // "INSERT OR REPLACE INTO person (id, name, age) VALUES (?, ?, ?);"
        let labels = type.columnLabels
        let labelsString = labels.joined(separator: .comma)
        let questionmarks = Array(repeating: "?", count: labels.count).joined(separator: .comma)
        let insertStatementString = "INSERT OR REPLACE INTO \(type.tableName) (\(labelsString)) VALUES (\(questionmarks));"
        
        var statement: OpaquePointer? = nil
        // insert values
        if sqlite3_prepare_v2(db, insertStatementString, -1, &statement, nil) == SQLITE_OK {
            for (index, label) in labels.enumerated() {
                let value = item.valueFor(columnLabel: label)
                self.bind(value: value, index: index, statement: statement)
            }
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully inserted row.")
            }
            else {
                print("Could not insert row.")
            }
            sqlite3_finalize(statement)
        }
        else {
            print("INSERT statement could not be prepared.")
        }
    }
    
    func fetchItem<T: DBItem>(id: String, type: T.Type) -> T? {
        return fetchAll(contition: "id='\(id)'").first
    }
    
    func fetchAll<T: DBItem>(contition: String? = nil) -> [T] {
        var statementString = "SELECT * FROM \(T.tableName)"
        if let contition {
            statementString.append(" WHERE \(contition);")
        }
        let tableInfo = self.columnNamesInTable(name: T.tableName)

        var statement: OpaquePointer? = nil
        var result: [T] = []
        if sqlite3_prepare_v2(db, statementString, -1, &statement, nil) == SQLITE_OK {
            
            while sqlite3_step(statement) == SQLITE_ROW {
                var item = Dictionary<String, Any?>()
                for (index, property) in tableInfo.enumerated() {
                    switch property.type.lowercased() {
                    case "text":
                        let value = String(describing: String(cString: sqlite3_column_text(statement, Int32(index))))
                        item[property.label] = value
                    case "integer":
                        let value = sqlite3_column_int(statement, Int32(index))
                        item[property.label] = value
                    case "blob":
                        let value = sqlite3_column_blob(statement, Int32(index))
                        item[property.label] = value
                    case "float":
                        let value = sqlite3_column_double(statement, Int32(index))
                        item[property.label] = value
                    default:
                        continue
                    }
                }
                // create instance of T
                if let instance = T(dictionary: item) {
                    result.append(instance)
                }
                if sqlite3_step(statement) == SQLITE_DONE {
                   print("Done fetching data")
                }
                else {
                    print("Something went wrong when fetching data: \(sqlite3_step(statement))")
                }
            }
            sqlite3_finalize(statement)
        }
        return result
    }
    
    func deleteBy<T: DBItem>(id: String, type: T.Type) {
        
        let deleteStatementStirng = "DELETE FROM \(T.tableName) WHERE id = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            self.bind(value: id, index: 1, statement: deleteStatement)
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            }
            else {
                print("Could not delete row.")
            }
            sqlite3_finalize(deleteStatement)
        }
        else {
            print("DELETE statement could not be prepared")
        }
    }
    
    // MARK: - Private stuff
    // introspect table
    private func columnNamesInTable(name: String) -> [(label: String, type: String)] {
        let columnsStatementString = "PRAGMA table_info('\(name)');"
        var columnsStatement: OpaquePointer? = nil
        var array = [(String, String)]()
        if sqlite3_prepare_v2(db, columnsStatementString, -1, &columnsStatement, nil) == SQLITE_OK {
            while sqlite3_step(columnsStatement) == SQLITE_ROW {
                //returns the name
                let name = String(describing: String(cString: sqlite3_column_text(columnsStatement, 1)))
                //returns the type
                let type = String(describing: String(cString: sqlite3_column_text(columnsStatement, 2)))
                array.append((name, type))
            }
            sqlite3_finalize(columnsStatement)
        }
        return array
    }
}

// MARK: helpers for handling values
extension DBManager {

    func bind(value: Any?, index: Int, statement: OpaquePointer?) {
        let result: Int32
        let index = Int32(index + 1)
        
        if let data = value as? Data {
            result = data.withUnsafeBytes { rawBufferPointer in
                let rawPtr = rawBufferPointer.baseAddress!
                return sqlite3_bind_blob(statement, index, rawPtr, Int32(data.count), nil)
            }
        }
        else if let string = value as? NSString {
            result = sqlite3_bind_text(statement, index, string.utf8String, -1, nil)
        }
        else if let double = value as? Double {
            result = sqlite3_bind_double(statement, index, double)
        }
        else if let int = value as? Int {
            result = sqlite3_bind_int64(statement, index, sqlite3_int64(int))
        }
        else {
            result = sqlite3_bind_null(statement, index)
        }

        if SQLITE_OK != result {
            print("Failed to bind value '\(String(describing: value))' to property at index \(index)")
        }
    }
    
}
