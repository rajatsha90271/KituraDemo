//
//  Acronym.swift
//  KituraTIL
//
//  Created by Rajat on 15/04/18.
//

import Foundation

struct Acronym:Codable{
    var id:String?
    var short: String
    var long: String
    init?(id:String?,short:String,long:String) {
        if let id = id{
            self.id = id
        }
        if short.isEmpty || long.isEmpty {
            return nil
        }
        self.short = short
        self.long = long
    }
}
extension Acronym :Equatable{
    public static func == (lhs:Acronym,rhs :Acronym) -> Bool{
        return lhs.short == rhs.short && lhs.long == rhs.long
    }
}
