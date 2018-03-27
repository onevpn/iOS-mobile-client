import UIKit

class OneTextField: UITextField {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.textColor = UIColor(red: 39/255, green: 208/255, blue: 199/255, alpha: 1)
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSForegroundColorAttributeName:UIColor.white])
        self.borderStyle = .none
        self.backgroundColor = UIColor(white: 0, alpha: 0.33)
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
    }

}
