//
//  SetCardDeck.swift
//  SetGame
//
//  Created by 唐小雨 on 2019/2/20.
//  Copyright © 2019 唐小雨. All rights reserved.
//

import Foundation

struct Deck {
    
    lazy var setCards: [SetCard] = {
        var cards = [SetCard]()
        for number in 1...3{
            for shape in SetCard.Shape.shapes{
                for shading in SetCard.Shading.shadings{
                    for color in SetCard.colors{
                        cards.append(SetCard(number: number, shape: shape, shading: shading, color: color))
                    }
                }
            }
        }
        return cards
    }()
    
    var isEmpty = false
    
    mutating func drawCard() -> SetCard? {
        if setCards.count == 0{
            isEmpty = true
            NotificationCenter.default.post(name: deckDidEmptyNotification, object: nil)
            return nil
        }
        
        return setCards.remove(at: Int.random(in: setCards.indices))
    }
    
}
