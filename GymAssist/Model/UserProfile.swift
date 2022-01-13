//
//  UserProfile.swift
//  GymAssist
//
//  Created by Александр on 11.01.2022.
//

import RealmSwift

class Profile: Object {
    @Persisted var height = 0.0
    @Persisted var weight = 0.0
    @Persisted var weightHistory = List<Double> ()
}
