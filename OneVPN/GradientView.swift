import UIKit

class GradientView: UIView {

    var gradient: CAGradientLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layer = CAGradientLayer()
        
        layer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        layer.cornerRadius = frame.width/2
        layer.colors = [UIColor.red.cgColor, UIColor.black.cgColor]
        layer.startPoint = CGPoint(x: 1, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        
        layer.shadowColor = UIColor.red.cgColor
        layer.shadowOpacity = 0.32
        layer.shadowRadius = 32
        layer.shadowOffset = .zero
        
        self.layer.addSublayer(layer)
        
        self.gradient = layer
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func fill(with color1: UIColor, color2: UIColor) {
        
        UIView.animate(withDuration: 0.25) { 
            self.gradient.colors = [color1.cgColor, color2.cgColor]
            self.gradient.shadowColor = color1.cgColor
        }
        
    }

}
