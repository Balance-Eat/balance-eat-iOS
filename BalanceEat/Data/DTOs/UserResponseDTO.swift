//
//  UserResponseDTO.swift
//  BalanceEat
//
//  Created by 김견 on 8/21/25.
//


struct UserResponseDTO: Codable {
    let id: Int
    let uuid: String
    let name: String
    let email: String
    let gender: Gender
    let age: Int
    let weight: Double
    let height: Double
    let activityLevel: ActivityLevel
    let smi: Double
    let fatPercentage: Double
    let targetWeight: Double
    let targetCalorie: Int
    let targetSmi: Double
    let targetFatPercentage: Double
    let providerId: String
    let providerType: String
    
    enum CodingKeys: String, CodingKey {
        case id, uuid, name, email, gender, age, weight, height, activityLevel,
             smi, fatPercentage, targetWeight, targetCalorie, targetSmi,
             targetFatPercentage, providerId, providerType
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = (try? c.decode(Int.self, forKey: .id)) ?? 0
        self.uuid = try c.decodeIfPresent(String.self, forKey: .uuid) ?? ""
        self.name = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.email = try c.decodeIfPresent(String.self, forKey: .email) ?? ""
        self.gender = (try? c.decode(Gender.self, forKey: .gender)) ?? .male
        self.age = (try? c.decode(Int.self, forKey: .age)) ?? 0
        self.weight = (try? c.decode(Double.self, forKey: .weight)) ?? 0
        self.height = (try? c.decode(Double.self, forKey: .height)) ?? 0
        self.activityLevel = (try? c.decode(ActivityLevel.self, forKey: .activityLevel)) ?? .sedentary
        self.smi = (try? c.decode(Double.self, forKey: .smi)) ?? 0
        self.fatPercentage = (try? c.decode(Double.self, forKey: .fatPercentage)) ?? 0
        self.targetWeight = (try? c.decode(Double.self, forKey: .targetWeight)) ?? 0
        self.targetCalorie = (try? c.decode(Int.self, forKey: .targetCalorie)) ?? 0
        self.targetSmi = (try? c.decode(Double.self, forKey: .targetSmi)) ?? 0
        self.targetFatPercentage = (try? c.decode(Double.self, forKey: .targetFatPercentage)) ?? 0
        self.providerId = try c.decodeIfPresent(String.self, forKey: .providerId) ?? ""
        self.providerType = try c.decodeIfPresent(String.self, forKey: .providerType) ?? ""
    }
    
    init(
        id: Int = -1, uuid: String = "", name: String = "", email: String = "",
        gender: Gender = .male, age: Int = 0, weight: Double = 0, height: Double = 0,
        activityLevel: ActivityLevel = .sedentary, smi: Double = 0, fatPercentage: Double = 0,
        targetWeight: Double = 0, targetCalorie: Int = 0, targetSmi: Double = 0,
        targetFatPercentage: Double = 0, providerId: String = "", providerType: String = ""
    ) {
        self.id = id
        self.uuid = uuid
        self.name = name
        self.email = email
        self.gender = gender
        self.age = age
        self.weight = weight
        self.height = height
        self.activityLevel = activityLevel
        self.smi = smi
        self.fatPercentage = fatPercentage
        self.targetWeight = targetWeight
        self.targetCalorie = targetCalorie
        self.targetSmi = targetSmi
        self.targetFatPercentage = targetFatPercentage
        self.providerId = providerId
        self.providerType = providerType
    }
}

