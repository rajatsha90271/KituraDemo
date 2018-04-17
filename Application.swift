//
//  Application.swift
//  KituraTIL
//
//  Created by Rajat on 15/04/18.
//
import Kitura
import LoggerAPI
import Foundation
import CouchDB

public class App{
    
    var client :CouchDBClient?
    var database:Database?
    let router = Router()
    private func postInit(){
        let connectionProperties = ConnectionProperties(host: "localhost", port:5984, secured: false)
        client = CouchDBClient(connectionProperties: connectionProperties)
        client?.dbExists("acronyms", callback: { (exists, error) in
            guard exists else{
                self.createNewDataBase()
                return
            }
        })
        Log.info("Acronyms database located - loading ...")
        self.finalizeRoutes(with: Database(connProperties: connectionProperties, dbName: "acronyms"))
    }
    private func createNewDataBase(){
        Log.info("Database does not exist, creating new database")
        client?.createDB("acronyms", callback: { (database, error) in
            guard let database = database else{
                let errorReason = String(describing: error?.localizedDescription)
                Log.error("could not create new database: \(errorReason)")
                return
            }
            self.finalizeRoutes(with: database)
        })
        
    }
    private func finalizeRoutes(with database:Database){
        self.database = database
        initializeAcronymRoutes(app: self)
        Log.info("Acronym routes created")
        
    }
    public func Run(){
        postInit()
        Kitura.addHTTPServer(onPort: 8080, with: router)
        Kitura.run()
    }
}
