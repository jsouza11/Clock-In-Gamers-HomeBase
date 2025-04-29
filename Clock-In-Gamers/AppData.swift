//
//  AppData.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.
//

import Foundation
import SwiftUI

enum GamerType : String, Codable {
    case SUPER
    case RELIABLE
    case UNRELIABLE
    case NOTAGAMER
}

enum StatusType : String, Codable {
    case LATE
    case CLOCKEDIN
    case CLOCKEDOUT
}

struct alteredDate : Codable {
    var date : String
    var times : String?
    var isGaming : Bool
}

struct Schedules : Codable {
    var sunday: String // "12:00pm-04:30pm"
    var monday : String
    var tuesday : String
    var wednesday : String
    var thrusday : String
    var friday : String
    var saturday : String
    
    var alteredDates : [alteredDate]
}

protocol UserProto : Identifiable {
    var id : UUID { get set }
    var bio : String { get set }
    var name : String { get set }
    var discordLink : String { get set }
    var steamUserName : String { get set }
    var xboxUserName : String { get set }
    var status: StatusType { get set }
    var points: Int64 { get set }
    var type: GamerType { get set }
    var isClockedIn: Bool { get set }
    var clockedInAt : Date? { get set }
    var clockedOutAt : Date? { get set }
    var games : [String] { get set }
    var friends : [String] { get set }
    var schedule : Schedules? { get set }
}

class User : UserProto, ObservableObject, Codable {
    enum CodingKeys : CodingKey {
        case id, bio, name, discordLink, steamUserName, xboxUserName, status, points, type, isClockedIn, clockedInAt, clockedOutAt, games, friends, schedule
    }
    @Published var id: UUID
    @Published var name: String
    @Published var bio: String
    @Published var discordLink: String
    @Published var steamUserName: String
    @Published var xboxUserName: String
    @Published var status: StatusType
    @Published var points: Int64
    @Published var type: GamerType
    @Published var isClockedIn: Bool
    @Published var clockedInAt: Date?
    @Published var clockedOutAt: Date?
    @Published var games: [String]
    @Published var friends: [String]
    @Published var schedule: Schedules?
    
    
    init() {
        self.id = UUID()
        self.bio = "Happy Gamer"
        self.name = ""
        self.discordLink = ""
        self.steamUserName = ""
        self.xboxUserName = ""
        self.status = StatusType.CLOCKEDOUT
        self.points = 0
        self.type = GamerType.NOTAGAMER
        self.isClockedIn = false
        self.games = []
        self.friends = []
    }
    init(bio : String, name: String, discordLink: String, steamUserName : String, xboxUserName: String, status: StatusType, points: Int64, type: GamerType, isClockedIn : Bool) {
        self.id = UUID()
        self.bio = bio
        self.name = name
        self.discordLink = discordLink
        self.steamUserName = steamUserName
        self.xboxUserName = xboxUserName
        self.status = status
        self.points = points
        self.type = type
        self.isClockedIn = isClockedIn
        self.games = []
        self.friends = []
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.bio = try container.decode(String.self, forKey: .bio)
        self.name = try container.decode(String.self, forKey: .name)
        self.discordLink = try container.decode(String.self, forKey: .discordLink)
        self.steamUserName = try container.decode(String.self, forKey: .steamUserName)
        self.xboxUserName = try container.decode(String.self, forKey: .xboxUserName)
        self.status = try container.decode(StatusType.self, forKey: .status)
        self.points = try container.decode(Int64.self, forKey: .points)
        self.type = try container.decode(GamerType.self, forKey: .type)
        self.isClockedIn = try container.decode(Bool.self, forKey: .isClockedIn)
        self.clockedInAt = try container.decodeIfPresent(Date.self, forKey: .clockedInAt)
        self.clockedOutAt = try container.decodeIfPresent(Date.self, forKey: .clockedOutAt)
        self.games = try container.decode([String].self, forKey: .games)
        self.friends = try container.decode([String].self, forKey: .friends)
        self.schedule = try container.decodeIfPresent(Schedules.self, forKey: .schedule)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(bio, forKey: .bio)
        try container.encode(name, forKey: .name)
        try container.encode(discordLink, forKey: .discordLink)
        try container.encode(steamUserName, forKey: .steamUserName)
        try container.encode(xboxUserName, forKey: .xboxUserName)
        try container.encode(status, forKey: .status)
        try container.encode(points, forKey: .points)
        try container.encode(type, forKey: .type)
        try container.encode(isClockedIn, forKey: .isClockedIn)
        try container.encodeIfPresent(clockedInAt, forKey: .clockedInAt)
        try container.encodeIfPresent(clockedOutAt, forKey: .clockedOutAt)
        try container.encode(games, forKey: .games)
        try container.encode(friends, forKey: .friends)
        try container.encodeIfPresent(schedule, forKey: .schedule)
    }
    
}
struct AppJsonData : Codable {
    var activeUser : User
    var allUsers : [User]
    var allGames : [String]
    var loggedInUsers : [User]
}

class AppData : ObservableObject {
    @Published var activeUser : User
    @Published var allUsers : [User]
    @Published var allGames : [String]
    @Published var loggedInUsers : [User]
    
    init() {
        self.activeUser = User(bio: "Hello whats going on", name: "User1", discordLink: "", steamUserName: "", xboxUserName: "", status: StatusType.CLOCKEDIN, points: 100, type: GamerType.RELIABLE, isClockedIn: true)
        self.loggedInUsers = []
        self.allUsers =
        [
            User(bio: "Hello whats going on", name: "Frank", discordLink: "", steamUserName: "", xboxUserName: "", status: StatusType.CLOCKEDIN, points: 100, type: GamerType.RELIABLE, isClockedIn: true),
            User(bio: "Hello whats going on", name: "Kai", discordLink: "", steamUserName: "", xboxUserName: "", status: StatusType.CLOCKEDOUT, points: 100, type: GamerType.RELIABLE, isClockedIn: false),
            User(bio: "Hello whats going on", name: "Peter", discordLink: "", steamUserName: "", xboxUserName: "", status: StatusType.CLOCKEDIN, points: 100, type: GamerType.RELIABLE, isClockedIn: false),
            User(bio: "Hello whats going on", name: "Luke", discordLink: "", steamUserName: "", xboxUserName: "", status: StatusType.CLOCKEDOUT, points: 100, type: GamerType.RELIABLE, isClockedIn: false),
            User(bio: "Hello whats going on", name: "Victor", discordLink: "", steamUserName: "", xboxUserName: "", status: StatusType.CLOCKEDIN, points: 100, type: GamerType.RELIABLE, isClockedIn: false)
        ]
        self.allGames =
        [
            "Legend of Zelda",
            "Super Smash Bros",
            "Call of Duty"
        ]
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func getFileURL() -> URL {
        print(getDocumentsDirectory().appendingPathComponent("clockingamers").appendingPathExtension("json"))
        return getDocumentsDirectory().appendingPathComponent("clockingamers").appendingPathExtension("json")
    }
    
    func saveData() {
        let fileURL = getFileURL()
        let appJson = AppJsonData(activeUser: self.activeUser, allUsers: self.allUsers, allGames: self.allGames, loggedInUsers: self.loggedInUsers)
        
        if let jsonData = try? JSONEncoder().encode(appJson) {
//            print(activeUser.name)
            try? jsonData.write(to: fileURL)
        } else {
          print("Error encoding object to JSON")
        }
    }
    
    func loadData() {
        print("Loading")
        let fileURL = getFileURL()
        var retrievedData : Data
        do {
            retrievedData = try Data(contentsOf: fileURL)
//            print(retrievedData)
            do {
                let allDataJson = try JSONDecoder().decode(AppJsonData.self, from: retrievedData)
                self.activeUser = allDataJson.activeUser
                self.allGames = allDataJson.allGames
                self.loggedInUsers = allDataJson.loggedInUsers
                self.allUsers = allDataJson.allUsers
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        } catch let error {
            print(error.localizedDescription)
            print("Error loading data")
        }
    }
}




