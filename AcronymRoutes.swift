//
//  AcronymRoutes.swift
//  KituraTIL
//
//  Created by Rajat on 17/04/18.
//

import Foundation
import CouchDB
import Kitura
import KituraContracts
import LoggerAPI

private var database: Database?

func initializeAcronymRoutes(app: App) {
    database = app.database
    // 1
    app.router.get("/acronyms", handler: getAcronyms)
    app.router.post("/acronyms", handler: addAcronym)
    app.router.delete("/acronyms", handler: deleteAcronym)
}

// 2
private func getAcronyms(completion: @escaping ([Acronym]?, RequestError?) -> Void) {
    guard let database = database else {
        return completion(nil, .internalServerError)
    }
    Acronym.Persistence.getAll(from: database) { acronyms, error in
        return completion(acronyms, error as? RequestError)
    }
}

// 3
private func addAcronym(acronym: Acronym, completion: @escaping (Acronym?, RequestError?) -> Void) {
    guard let database = database else {
        return completion(nil, .internalServerError)
    }
    Acronym.Persistence.save(acronym, to: database) { id, error in
        guard let id = id else {
            return completion(nil, .notAcceptable)
        }
        Acronym.Persistence.get(from: database, with: id) { newAcronym, error in
            return completion(newAcronym, error as? RequestError)
        }
    }
}

// 4
private func deleteAcronym(id: String, completion: @escaping (RequestError?) -> Void) {
    guard let database = database else {
        return completion(.internalServerError)
    }
    Acronym.Persistence.delete(with: id, from: database) { error in
        return completion(error as? RequestError)
    }
}
