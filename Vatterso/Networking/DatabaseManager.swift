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

protocol DBItem: Identifiable {

    static var tableName: String { get }
    static var colums: [String: DBType] { get }

    func valueFor(column: String) -> Any?
}

extension DBItem {
    
    static var columnLabels: [String] {
        return self.colums.map{ $0.key.lowercased() }
    }
    
    static var columnLabelsAndTypes: String {
        let columns = self.colums.map {
            let label = $0.key.lowercased()
            let type = $0.value.string.uppercased()
            var components = [label, type]
            if label == "id" {
                components.append("PRIMARY KEY")
            }
            return components.joined(separator: .space)
        }
        return columns.joined(separator: .comma)
    }
}

    // convenience init to store any struct conformig to Codable and Indentifiable
//    init?<T: Identifiable & Codable>(item: T) {
//        guard let data = try? NetworkingManager.defaultEncoder().encode(item) else { return nil }
//        self.id = "\(item.id)"
//        self.date = Date()
//        self.data = data
//
//
//        if let encoded = try? JSONEncoder().encode(item) {
//            if let json = String(data: encoded, encoding: .utf8) {
//                print(json)
//            }
//
//            let decoder = JSONDecoder()
//            if let decoded = try? decoder.decode(T.self, from: encoded) {
//                print(decoded.id)
//            }
//        }
//    }


class DBManager {
    
    init?() {
        guard let db = try? openDatabase() else { return nil }
        self.db = db
    }
    
    private let dbPath = "database.sqlite"
    private var db: OpaquePointer?
    
    private func openDatabase() throws -> OpaquePointer? {
        let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        
        if sqlite3_open(fileURL?.path, &db) != SQLITE_OK {
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
        }
        sqlite3_finalize(statement)
    }
    
    private func tableExists(named: String) -> Bool {
        let queryStatementString = "SELECT count(*) FROM sqlite_schema WHERE type='table' AND name='\(named.lowercased())';"
        var queryStatement: OpaquePointer? = nil
        var foundTable: Bool = false
                
        if sqlite3_prepare(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                foundTable = sqlite3_column_int(queryStatement, 0) > 0
            }
        }
        else {
            print("Count statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return foundTable
    }
    
    func insert<T: DBItem>(item: T) {
        
        let type = type(of: item)
        
        if !tableExists(named: type.tableName) {
            self.createTable(type: type)
        }
        // create insert statement
        // "INSERT INTO person (id, name, age) VALUES (?, ?, ?);"
        let columns = type.columnLabels
        let columnsString = columns.joined(separator: .comma)
        let questionmarks = Array(repeating: "?", count: columns.count).joined(separator: .comma)
        let insertStatementString = "INSERT OR REPLACE INTO \(type.tableName) (\(columnsString)) values (\(questionmarks))"
        
        var statement: OpaquePointer? = nil
        // insert values
        if sqlite3_prepare_v2(db, insertStatementString, -1, &statement, nil) == SQLITE_OK {
            for (index, column) in columns.enumerated() {
                let value = item.valueFor(column: column)
                try? self.bind(value: value, index: index, statement: statement)
            }
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully inserted row.")
            }
            else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(statement)

        
        
        
        
        
//
//        if let encoded = try? JSONEncoder().encode(item) {
//
//            print(encoded.description)
//
//            if let json = String(data: encoded, encoding: .utf8) {
//                print(json)
//            }
//
//            let decoder = JSONDecoder()
//            if let decoded = try? decoder.decode(T.self, from: encoded) {
//                print(decoded.id)
//            }
//        }
    }

    func insertData(table: String, values: () -> (key: String, value: DBManager.Value)) {  //(id: String, date: Date, data: Data) {
        
        let columnNames = self.columnNamesInTable(name: table)
        /*
        func insertItemStatement(named: String, properties: [DBManager.Value]) -> String {
            // "INSERT INTO person (Id, name, age) VALUES (?, ?, ?);"
            let properties = properties.map{ $0.label }
            let questionmarks = Array(repeating: "?", count: properties.count)
            
            return "INSERT INTO \(named) (\(properties.joined(separator: ", "))) VALUES (\(questionmarks.joined(separator: ", ")));"
        }
         */
        
        let date = Date()
        let id = "1234"
        let data = Data()
        
        let statementString = "INSERT INTO downloads (id, date, data) VALUES (?, ?, ?);"
        let unixDate = date.timeIntervalSince1970
        var statement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, statementString, -1, &statement, nil) == SQLITE_OK {
            
            try? self.bind(value: Value(id), index: 1, statement: statement)
            try? self.bind(value: Value(unixDate), index: 2, statement: statement)
            try? self.bind(value: Value(data), index: 3, statement: statement)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(statement)
    }
    
    func fetchAll<T: Codable>(table: String) -> [T] {
        let statementString = "SELECT * FROM \(table)"
        let tableInfo = self.columnNamesInTable(name: table)
        var statement: OpaquePointer? = nil
        var result: [T] = []
        if sqlite3_prepare_v2(db, statementString, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var item = Dictionary<String, Any>()
                for index in tableInfo.indices {
                    let info = tableInfo[index]
                    switch info[1] {
                    case "TEXT":
                        let value = String(describing: String(cString: sqlite3_column_text(statement, Int32(index))))
                        item[info[0]] = value
                    case "INTEGER":
                        let value = sqlite3_column_int(statement, Int32(index))
                        item[info[0]] = value
                    case "BLOB":
                        let value = sqlite3_column_blob(statement, Int32(index))
                        item[info[0]] = value
                    case "FLOAT":
                        let value = sqlite3_column_double(statement, Int32(index))
                        item[info[0]] = value
                    default:
                        break
                    }
                }
                if let instance = T(dictionary: item) {
                    result.append(instance)
                }
            }
        }
        return result
    }
    
    
    
    
    
//    func fetchItem<T: DBItem>(id: String) -> T {
//        DBItem(id: "test", date: Date(), data: Data())
//    }

    func fetchItem<T: Codable>(id: String, table: String) throws -> T? {
        
        let statementString = "SELECT * FROM \(table) WHERE id=\(id)"
        let tableInfo = self.columnNamesInTable(name: table)
        var statement: OpaquePointer? = nil
        var result: [T] = []
        
        let prepare = sqlite3_prepare_v2(db, statementString, -1, &statement, nil)
        guard prepare == SQLITE_OK else {
            return nil
            // throw DBManager.Error.onPrepareStatement(prepare, "Could not prepare fetch statement")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            var item = Dictionary<String, Any>()
            for index in tableInfo.indices {
                let info = tableInfo[index]
                switch info[1] {
                case "TEXT":
                    let value = String(describing: String(cString: sqlite3_column_text(statement, Int32(index))))
                    item[info[0]] = value
                case "INTEGER":
                    let value = sqlite3_column_int(statement, Int32(index))
                    item[info[0]] = value
                case "BLOB":
                    let value = sqlite3_column_blob(statement, Int32(index))
                    item[info[0]] = value
                case "FLOAT":
                    let value = sqlite3_column_double(statement, Int32(index))
                    item[info[0]] = value
                default:
                    break
                }
            }
            if let instance = T(dictionary: item) {
                result.append(instance)
            }
        }
        sqlite3_finalize(statement)

        return result.first
    }
    
    func read() -> [Post] {
        let queryStatementString = "SELECT * FROM person;"
        var queryStatement: OpaquePointer? = nil
        var psns : [Post] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let year = sqlite3_column_int(queryStatement, 2)
                psns.append(Post())
                print("Query Result:")
                print("\(id) | \(name) | \(year)")
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return psns
    }
    
    func deleteByID(id:Int) {
        let deleteStatementStirng = "DELETE FROM person WHERE Id = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
    
    // MARK: - Private stuff
    
    // string creation

    // introspect table
    private func columnNamesInTable(name: String) -> [[String]] {
        let columnsStatementString = "PRAGMA table_info('\(name)');"
        var columnsStatement: OpaquePointer? = nil
        var array = [[String]]()
        if sqlite3_prepare_v2(db, columnsStatementString, -1, &columnsStatement, nil) == SQLITE_OK {
            while sqlite3_step(columnsStatement) == SQLITE_ROW {
                //returns the name
                let name = String(describing: String(cString: sqlite3_column_text(columnsStatement, 1)))
                //returns the type
                let type = String(describing: String(cString: sqlite3_column_text(columnsStatement, 2)))
                array.append([name, type])
            }
        }
        sqlite3_finalize(columnsStatement)
        return array
    }
    
}

// MARK: helpers for handling values
extension DBManager {
    
    enum Value {
        
        case data(Data)
        case double(Double)
        case integer(Int64)
        case text(String)
        case null
        
        init(_ value: Any) {
            if let string = value as? String {
                self = .text(string)
            }
            else if let double = value as? Double {
                self = .double(double)
            }
            else if let int = value as? Int64 {
                self = .integer(int)
            }
            else if let data = value as? Data {
                self = .data(data)
            }
            else {
                self = .null
            }
        }
        
        init(rawValue: OpaquePointer) {
            switch sqlite3_value_type(rawValue) {
            case SQLITE_BLOB:
                if let bytes = sqlite3_value_blob(rawValue) {
                    self = .data(Data(bytes: bytes, count: Int(sqlite3_value_bytes(rawValue))))
                }
                else {
                    self = .data(Data())
                }
            case SQLITE_FLOAT:
                self = .double(sqlite3_value_double(rawValue))
            case SQLITE_INTEGER:
                self = .integer(sqlite3_value_int64(rawValue))
            case SQLITE_NULL:
                self = .null
            case SQLITE_TEXT:
                self = .text(String(cString: sqlite3_value_text(rawValue)))
            default:
                fatalError("\(rawValue) is not a valid 'sqlite3_value'")
            }
        }
    }
    
    func bind(value: Any?, index: Int, statement: OpaquePointer?) throws {
        let result: Int32
        let index = Int32(index)
        
        if let data = value as? Data {
            //            result = data.withUnsafeBytes { dataBytes in
            //                let buffer: UnsafePointer<UInt8> = dataBytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
            //                return sqlite3_bind_blob(statement, index, buffer, Int32(data.count), nil)
            //                //OutputStream(toMemory: ()).write(buffer, maxLength: dataBytes.count)
            //            }
            result = data.withUnsafeBytes { rawBufferPointer in
                let rawPtr = rawBufferPointer.baseAddress!
                return sqlite3_bind_blob(statement, index, rawPtr, Int32(data.count), nil)
            }
        }
        else if let string = value as? String {
            result = sqlite3_bind_text(statement, index, string, -1, nil)
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
            // throw DBManager.Error.onBindParameter(result, index, value)
        }
    }
    
}
