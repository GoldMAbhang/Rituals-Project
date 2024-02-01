//
//  UserData.swift
//  RitualsTask
//
//  Created by Abhang Mane @Goldmedal on 22/01/24.
//

import Foundation
//Codable structure for api data
struct UserData: Codable{
    let Data: [Data]
    
    struct Data:Codable{
        let PinName: String
        let TypeID: String
        let LocationName: String
        let Lmodifydt: String
        let PinImages:String
    }
}
