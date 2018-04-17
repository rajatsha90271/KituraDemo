//
//  AcronymPersistence.swift
//  KituraTIL
//
//  Created by Rajat on 17/04/18.
//

import Foundation
import CouchDB
import SwiftyJSON

extension Acronym{
    class Persistence{
        static func getAll(from database:Database,callback: @escaping (_ acronym:[Acronym]?,_ error:NSError?)->Void){
            database.retrieveAll(includeDocuments: true) { (documents, error) in
                guard let documents  = documents else{
                    callback(nil,error)
                    return
                }
                var acronym :[Acronym] = []
                for document in documents["rows"].arrayValue{
                    let id = document["id"].stringValue
                    let short = document["doc"]["short"].stringValue
                    let long = document["doc"]["long"].stringValue
                    if let acronymVal = Acronym(id: id, short: short, long: long){
                        acronym.append(acronymVal)
                    }
                }
                callback(acronym, nil)
            }
        }
        static func save(_ acronym: Acronym, to database: Database,
                         callback: @escaping (_ id: String?, _ error: NSError?) -> Void) {
            getAll(from: database) { acronyms, error in
                guard let acronyms = acronyms else {
                    return callback(nil, error)
                }
                
                guard !acronyms.contains(acronym) else {
                    return callback(nil, NSError(domain: "Kitura-TIL",
                                                 code: 400,
                                                 userInfo: ["localizedDescription": "Duplicate entry"]))
                }
                database.create(JSON(["short": acronym.short, "long": acronym.long])) { id, _, _, error in
                    callback(id, error)
                }
            }
        }
        
        
        static func get(from database: Database, with id: String,
                        callback: @escaping (_ acronym: Acronym?, _ error: NSError?) -> Void) {
            database.retrieve(id) { document, error in
                guard let document = document else {
                    return callback(nil, error)
                }
                guard let acronym = Acronym(id: document["_id"].stringValue,
                                            short: document["short"].stringValue,
                                            long: document["long"].stringValue) else {
                                                return callback(nil, error)
                }
                callback(acronym, nil)
            }
        }
        
        static func delete(with id: String, from database: Database,
                           callback: @escaping (_ error: NSError?) -> Void) {
            database.retrieve(id) { document, error in
                guard let document = document else {
                    return callback(error)
                }
                let id = document["_id"].stringValue
                
                let revision = document["_rev"].stringValue
                database.delete(id, rev: revision) { error in
                    callback(error)
                }
            }
        }
    }
}
