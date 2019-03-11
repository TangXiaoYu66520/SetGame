//
//  ViewController.swift
//  SetGame
//
//  Created by 唐小雨 on 2019/2/19.
//  Copyright © 2019 唐小雨. All rights reserved.
//

import UIKit

extension SetGameViewController{
    struct TimeInterval {
        static let interval: Double = 0.1
        static let duration: Double = 0.5
        static let delay: Double = 0.5
    }
}

class SetGameViewController: UIViewController {
    
    @IBOutlet weak var setsLabel: UILabel!{ didSet{
        setsLabel.font = UIFont.preferredFont(forTextStyle: .body).withSize(40)
        }
    }
    
    @IBOutlet weak var dealButton: UIButton!
    
    @IBOutlet var stackViewsOfSetCard: [UIStackView]!{
        didSet{ stackViewsOfSetCard.forEach(){$0.arrangedSubviews.forEach{$0.isHidden = true}}
        }
    }
    
    lazy var chosenCardViews = [SetCardView]()
    
    lazy var setCardDeck = Deck()
    lazy var animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: self.view)
    lazy var cardViewBehavior = SetCardViewBehavior(withAnimator: self.animator)
    
    var cardSize: CGSize{
        return stackViewsOfSetCard.first!.arrangedSubviews.first!.bounds.size
    }
    
    var rectOfDealButtonInView: CGRect{
        return dealButton.convert(dealButton.bounds, to: view)
    }
    
    var animationViewForFly: SetCardView?{
        if let card = setCardDeck.drawCard(){
            let cardView = SetCardView(frame: CGRect(origin: CGPoint(x: rectOfDealButtonInView.midX - cardSize.width/2, y: rectOfDealButtonInView.maxY - cardSize.height), size: cardSize), setCard: card)
            cardView.isFaceUp = false
            view.addSubview(cardView)
            return cardView
        }
        else{
            return nil
        }
    }
    
//    var notHiddenCardViews: [SetCardView] {
//        var cardviews = [SetCardView]()
//        for stackView in stackViewsOfSetCard{
//            for cardView in stackView.arrangedSubviews{
//                if let setCardView = cardView as? SetCardView, setCardView.isHidden == false{
//                    cardviews.append(setCardView)
//                }
//            }
//        }
//
//        return cardviews
//    }
    
    var startCardViews = [SetCardView]()
    
    let gameBeginRows = 3
    let gameBeginColumns = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for outIndex in 0..<gameBeginRows{
            for index in 0..<gameBeginColumns{
                if let cardView = stackViewsOfSetCard[outIndex].arrangedSubviews[index] as? SetCardView {
                cardView.isHidden = false
                cardView.alpha = 0
                startCardViews.append(cardView)
                }
            }
        }
        
        startGame()
    }
    
    func startGame() {
        isDealingCard = true
        let cardViewsToAnimate = startCardViews
        
        var index = 0
        
        Timer.scheduledTimer(withTimeInterval: TimeInterval.interval, repeats: true) { (cardTimer) in
            if index < cardViewsToAnimate.count, let animationView = self.animationViewForFly {
                
                let cardView = cardViewsToAnimate[index]
                
                self.animate(animationView, to: cardView)
                
                index += 1
            }
            
            if index == cardViewsToAnimate.count{
                cardTimer.invalidate()
            }
        }
        
    }
    
    func animate(_ animationView: SetCardView,to cardView: SetCardView) {
        
        let localCardViewsToShow = cardViewsToShow
        let rect = cardView.convert(cardView.bounds, to: self.view)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: TimeInterval.duration, delay: 0, options: [], animations: {
            animationView.frame = rect
        }) { (position) in
            if position == .end {
                UIView.transition(with: animationView, duration: TimeInterval.duration, options: [.beginFromCurrentState, .transitionFlipFromLeft], animations: {
                    animationView.isFaceUp = true
                }, completion: {isFinished in
                    if isFinished {
                        cardView.alpha = 1
                        cardView.isFaceUp = true
                        cardView.setProperties(withAnotherSetCardView: animationView)
                        animationView.isHidden = true
                        animationView.removeFromSuperview()
                    }
                    
                    if cardView === self.startCardViews.last! || (!localCardViewsToShow.isEmpty && cardView === localCardViewsToShow.last!) {
                        self.cardViewsToShow.removeAll()
                        self.isDealingCard = false
                    }
                })
            }
        }
        
    }
    
    
    
    
    var isDealingCard = false { didSet{
        if isDealingCard{
            dealButton.isEnabled = false
            dealButton.setTitle("Dealing", for: .disabled)
        }else{
            dealButton.isEnabled = true
            dealButton.setTitle("Deal", for: .normal)
        }
        }}
    
    var cardViewsToShow = [SetCardView]()
    let numberOfShowCard = 9

    @IBAction func dealCard() {
        cardViewsToShow.removeAll()
        stackViewsOfSetCard.forEach(){ $0.arrangedSubviews.forEach(){ cardView in
            if cardView.isHidden{
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: TimeInterval.duration, delay: 0, options: [], animations: {
                    cardView.isHidden = false
                }, completion: nil)
                
                cardView.alpha = 0
            } } }
        
        var count = 0
        
        stackViewsOfSetCard.forEach(){ $0.arrangedSubviews.forEach(){ cardView in
            if cardView.alpha == 0, count < numberOfShowCard, !setCardDeck.isEmpty, !isDealingCard{
                cardViewsToShow.append(cardView as! SetCardView)
                count += 1
            }
            } }
        
        var index = 0
        
        if !cardViewsToShow.isEmpty {
            isDealingCard = true
            Timer.scheduledTimer(withTimeInterval: TimeInterval.interval, repeats: true) { (timer) in
                
                if index < self.cardViewsToShow.count, let animationView = self.animationViewForFly {
                    let cardView = self.cardViewsToShow[index]
                    self.animate(animationView, to: cardView)
                }
                
                if index == self.cardViewsToShow.count {
                    timer.invalidate()
                }
                
                index += 1
            }
            
        }
        
    }
    
    
    var numberOfSets = 0 {didSet{
        let string = numberOfSets < 2 ? "Set" : "Sets"
        UIView.transition(with: setsLabel, duration: TimeInterval.duration, options: .transitionFlipFromLeft, animations: {
            self.setsLabel.text = String(self.numberOfSets) + " " + string
        }, completion: nil)
        }}
    
}



extension SetGameViewController{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(receiveSelect(notification:)), name: didSelectSetCardViewNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveCancelSelect(notification:)), name: didCancelSelectSetCardViewNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveDeckBecomeEmpty(notification:)), name: deckDidEmptyNotification, object: nil)
    }
    
    @objc func receiveSelect(notification: Notification){
        if let cardView = notification.object as? SetCardView {
            chosenCardViews.append(cardView)
        }
        
        if chosenCardViews.count == 3 {
            let CardViewsToAnimate = chosenCardViews
            for viewToAnimate in CardViewsToAnimate{
                let rectInView = viewToAnimate.convert(viewToAnimate.bounds, to: self.view)
                let copyChosenCardView = SetCardView(frame: rectInView)
                copyChosenCardView.setProperties(withAnotherSetCardView: viewToAnimate)
                copyChosenCardView.isFaceUp = true
                self.view.addSubview(copyChosenCardView)
                viewToAnimate.alpha = 0
                viewToAnimate.isChosen = false
                cardViewBehavior.add(item: copyChosenCardView)
                
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: TimeInterval.duration, delay: TimeInterval.delay, options: [], animations: {
                    copyChosenCardView.alpha = 0
                }, completion: { (position) in
                    self.cardViewBehavior.remove(item: copyChosenCardView)
                    copyChosenCardView.removeFromSuperview()
                })
            }
            
            Timer.scheduledTimer(withTimeInterval: TimeInterval.delay, repeats: false) { (timer) in
                self.dealCard()
            }
            
            numberOfSets += 1
        }

    }
    
    @objc func receiveCancelSelect(notification: Notification){
        if let cardView = notification.object as? SetCardView{
            let index = chosenCardViews.firstIndex(of: cardView)!
            chosenCardViews.remove(at: index)
        }
    }
    
    @objc func receiveDeckBecomeEmpty(notification: Notification){
        dealButton.isEnabled = false
        dealButton.setTitle("Empty", for: .disabled)
        NotificationCenter.default.removeObserver(self, name: deckDidEmptyNotification, object: nil)
    }
    
}
