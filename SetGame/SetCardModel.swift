//
//  SetCardModel.swift
//  SetGame
//
//  Created by 唐小雨 on 2019/2/19.
//  Copyright © 2019 唐小雨. All rights reserved.
//

import UIKit

struct SetCard {
    
    var number = SetCard.numbers.first!
    var shape: Shape = .diamond
    var shading: Shading = .solid
    var color = SetCard.colors.first!
    
}

extension SetCard: Hashable{
    
    enum Shape {
        case diamond
        case squiggle
        case oval
        
        static let shapes = [SetCard.Shape.diamond, .squiggle, .oval]
    }
    
    enum Shading {
        case solid
        case striped
        case open
        
        static let shadings = [SetCard.Shading.solid, .striped, .open]
    }
    
    static let numbers = [1, 2, 3]
    static let colors = [#colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1)]
}
