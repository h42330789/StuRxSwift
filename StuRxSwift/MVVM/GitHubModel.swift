//
//  GitHubModel.swift
//  StuRxSwift
//
//  Created by aaa on 1/2/23.
//

import Foundation
import ObjectMapper

struct GitHubRepositories: Mappable {
    
    var totalCount: Int!
    var incompleteResults: Bool!
    var items: [GitHubRepository]!
    
    init() {
        print("init()")
        totalCount = 0
        incompleteResults = false
        items = []
    }
    
    init?(map: ObjectMapper.Map) {
        
    }
    
    mutating func mapping(map: ObjectMapper.Map) {
        totalCount <- map["total_count"]
        incompleteResults <- map["incomplete_results"]
        items <- map["items"]
    }
}

struct GitHubRepository: Mappable {
    var id: Int!
    var name: String!
    var fullName: String!
    var htmlUrl: String!
    var description: String!
     
    init?(map: Map) { }
     
    // Mappable
    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        fullName <- map["full_name"]
        htmlUrl <- map["html_url"]
        description <- map["description"]
    }
}
