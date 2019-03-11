//
//  SetCardView.swift
//  SetGame
//
//  Created by 唐小雨 on 2019/2/19.
//  Copyright © 2019 唐小雨. All rights reserved.
//

import UIKit

@IBDesignable
class SetCardView: UIView {
    
    var number: Int = 3 { didSet{setNeedsDisplay(); setNeedsLayout()}}
    var shape: SetCard.Shape = .oval { didSet{setNeedsDisplay(); setNeedsLayout()}}
    var shading: SetCard.Shading = .striped { didSet{setNeedsDisplay(); setNeedsLayout()}}
    var color: UIColor = .magenta { didSet{setNeedsDisplay(); setNeedsLayout()}}
    var numberOfStrips = CGFloat(5) { didSet{setNeedsDisplay(); setNeedsLayout()}}
    var isFaceUp = true { didSet{
        setNeedsDisplay(); setNeedsLayout()
        backgroundColor = isFaceUp ? UIColor.white : .lightGray
        }}
    
    var isChosen = false {didSet{
        if isChosen{
            layer.borderColor = UIColor.black.cgColor
            layer.borderWidth = 2.0
            NotificationCenter.default.post(name: didSelectSetCardViewNotification, object: self)
        }else{
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
            NotificationCenter.default.post(name: didCancelSelectSetCardViewNotification, object: self)
        }
        }}
    
    lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(showBorder))
    
    override func draw(_ rect: CGRect) {
        if isFaceUp {
            color.set()
            
            var paths = [UIBezierPath]()
            let clipPath = UIBezierPath()
            
            guard number > 0 else {
                assertionFailure()
                return
            }
            
            for _ in 1...number{
                let path = drawShape(shape)
                paths.append(path)
            }
            
            switch number {
            case 2:
                paths.first!.apply(CGAffineTransform.identity.translatedBy(x: 0, y: -1.5 * halfHeight))
                paths.last!.apply(CGAffineTransform.identity.translatedBy(x: 0, y: 1.5 * halfHeight))
            case 3:
                paths.first!.apply(CGAffineTransform.identity.translatedBy(x: 0, y: -3 * halfHeight))
                paths.last!.apply(CGAffineTransform.identity.translatedBy(x: 0, y: 3 * halfHeight))
            default:
                break
            }
            
            for movedPath in paths{
                clipPath.append(movedPath)
            }
            
            clipPath.addClip()
            drawShading(shading, in: paths)
        }
    }
    
    
    
    func drawShape(_ shape: SetCard.Shape)-> UIBezierPath{
        var path = UIBezierPath()
        path.lineWidth = 2
        path.lineJoinStyle = .round
        switch shape {
        case .diamond:
            path.move(to: CGPoint(x: inset, y: bounds.midY))
            path.addLine(to: CGPoint(x: bounds.midX, y: bounds.midY - halfHeight))
            path.addLine(to: CGPoint(x: bounds.maxX - inset, y: bounds.midY))
            path.addLine(to: CGPoint(x: bounds.midX, y: bounds.midY + halfHeight))
            path.close()
        case .squiggle:
            path.move(to: CGPoint(x: inset, y: bounds.midY + halfHeight))
            path.addCurve(to: CGPoint(x: bounds.maxX - inset, y: bounds.midY - halfHeight), controlPoint1: CGPoint(x: inset, y: bounds.midY - halfHeight*2), controlPoint2: boundsCenter)
            path.addCurve(to: CGPoint(x: inset, y: bounds.midY + halfHeight), controlPoint1: CGPoint(x: bounds.maxX - inset, y: bounds.midY + halfHeight*2), controlPoint2: boundsCenter)
            path.close()
        case .oval:
            let rect = CGRect(x: inset, y: bounds.midY - halfHeight, width: bounds.width - 2*inset, height: 2*halfHeight)
            path = UIBezierPath(roundedRect: rect, cornerRadius: 2*min(rect.height, rect.width))
        }
        return path
    }
    
    
    func drawShading(_ shading: SetCard.Shading, in paths: [UIBezierPath]) {
        
        switch shading {
        case .solid:
            paths.forEach{ $0.fill() }
        case .striped:
            let linePath = UIBezierPath()
            linePath.lineWidth = 0.5
            linePath.lineJoinStyle = .round
            
            paths.forEach(){ path in
                path.stroke()
                let pathRect = path.bounds
                let spacing = pathRect.width / (numberOfStrips+1)
                var startPoint = pathRect.origin
                var endPoint = CGPoint(x: pathRect.minX, y: pathRect.maxY)
                while startPoint.x < pathRect.maxX {
                    startPoint.x += spacing
                    endPoint.x += spacing
                    linePath.move(to: startPoint)
                    linePath.addLine(to: endPoint)
                    linePath.stroke()
                }
            }
        case .open:
            paths.forEach{ $0.stroke() }
        }
    }
    
    
    @objc func showBorder() {
        isChosen = !isChosen
    }
    
    func setProperties(with setCard: SetCard) {
        number = setCard.number
        shape = setCard.shape
        shading = setCard.shading
        color = setCard.color
    }
    
    func setProperties(withAnotherSetCardView anotherSetCardView: SetCardView) {
        number = anotherSetCardView.number
        shape = anotherSetCardView.shape
        shading = anotherSetCardView.shading
        color = anotherSetCardView.color
    }
    
    func setUp() {
        contentMode = .redraw
        backgroundColor = isFaceUp ? UIColor.white : .lightGray
        addGestureRecognizer(tapGesture)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    convenience init(frame :CGRect = CGRect.zero, setCard: SetCard) {
        self.init(frame: frame)
        setProperties(with: setCard)
    }
}

extension SetCardView{
    
    var inset: CGFloat{
        return bounds.width / 6
    }
    
    var halfHeight: CGFloat{
        return bounds.height / 10
    }
    
    var boundsCenter: CGPoint{
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }

}
