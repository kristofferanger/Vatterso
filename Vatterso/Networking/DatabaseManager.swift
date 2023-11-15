//
//  DatabaseManager.swift
//  Vatterso
//
//  Created by Kristoffer Anger on 2023-10-31.
//

import Foundation
import SQLite3
import SwiftUI


// MARK: error handling
extension DBManager {
    enum Error: Swift.Error {
        case onOpen(Int32, String)
        case onClose(Int32)
        case onPrepareStatement(Int32, String)
        case onGetParameterIndex(String)
        case onBindParameter(Int32, Int32, DBManager.Value)
        case onStep(Int32, String)
        case onGetColumnType(Int32)
    }
}


class DBManager<T: Codable & Identifiable> {
    
    init() {
        db = try? openDatabase()
    }
    
    private let dbPath = "database.sqlite"
    private var db: OpaquePointer?
    
    private func openDatabase() throws -> OpaquePointer? {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        
        let result = sqlite3_open(fileURL.path, &db)
        guard result == SQLITE_OK else {
            throw DBManager.Error.onOpen(result, "error opening database")
        }
        print("Successfully opened connection to database at \(dbPath)")
        return db
    }
    
    private func createTable(dictionary: PropertyListDecoder) {
        
        let createTableString = "CREATE TABLE IF NOT EXISTS downloads(id TEXT PRIMARY KEY, date INTEGER, data BLOB);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("person table created.")
            }
            else {
                print("person table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func insert(item: T) {
        item.id
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
    
    func fetchItem<T: Codable>(id: String, table: String) throws -> T? {
        
        
        
        let statementString = "SELECT * FROM \(table) WHERE id=\(id)"
        let tableInfo = self.columnNamesInTable(name: table)
        var statement: OpaquePointer? = nil
        var result: [T] = []
        
        let prepare = sqlite3_prepare_v2(db, statementString, -1, &statement, nil)
        guard prepare == SQLITE_OK else {
            throw DBManager.Error.onPrepareStatement(prepare, "Could not prepare fetch statement")
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
    
    // private stuff
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
    
    func bind(value: DBManager.Value, index: Int, statement: OpaquePointer?) throws {
        let result: Int32
        let index = Int32(index)
        
        switch value {
        case .data(let data):
            result = data.withUnsafeBytes { buffer -> Int32 in
                return sqlite3_bind_blob(statement, index, buffer, Int32(data.count), nil)
            }
        case .text(let string):
            result = sqlite3_bind_text(statement, index, string, -1, nil)
        case .double(let double):
            result = sqlite3_bind_double(statement, index, double)
        case .integer(let int):
            result = sqlite3_bind_int64(statement, index, int)
        case .null:
            result = sqlite3_bind_null(statement, index)
        }
        
        if SQLITE_OK != result {
            throw DBManager.Error.onBindParameter(result, index, value)
        }
    }
    
}
