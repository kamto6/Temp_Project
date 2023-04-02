//
//  QUHomePreferredCompanyLogo.swift
//  BNUQuote
//
//  Created by JKW on 2022/8/18.
//

import Foundation
import UIKit

class QUHomePreferredCompanyLogo: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = frame.size.width * 0.5
        layer.masksToBounds = true
        if let item = subviews.filter({ ($0 is UIImageView) }).first {
            item.frame = bounds
        }
    }
    
    var content: String? {
        didSet {
            if let content = content {
                let letter = getFirstUpperCaseLetter(enName: content)
                text = letter
                font = UIFont.bnFont(fontStyle: .MunkenSansBold, fontSize: 28)
                textColor = getTextColor(letter: letter)
                backgroundColor = getBgColor(letter: letter)
                let reg = "^[a-zA-Z0-9]+$"
                let predicate = NSPredicate(format: "SELF MATCHES %@", reg)
                if letter.length > 0, predicate.evaluate(with: letter) {
                    hideImage()
                } else {
                    showImage()
                }
            }
        }
    }
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(bnNamed: "static_quote_company_logo_defalut")
        return view
    }()
   
    private func getFirstUpperCaseLetter(enName: String) -> String {
        if let letter = enName.capitalized.first {
            return "\(letter)"
        }
        return ""
    }
    
    private func getBgColor(letter: String) -> UIColor {
        switch letter {
        case "A"..."E":
            return UIColor.color(colorHexString: "#E8DEFF")
        case "F"..."K":
            return UIColor.color(colorHexString: "#DCECFF")
        case "L"..."P":
            return UIColor.color(colorHexString: "#FFE9CD")
        case "Q"..."V":
            return UIColor.color(colorHexString: "#E4E4FF")
        case "W"..."Z":
            return UIColor.color(colorHexString: "#FFE3E7")
        case "0"..."9":
            return UIColor.color(colorHexString: "#AFB6CD")
        default:
            return .white
        }
    }
    
    private func getTextColor(letter: String) -> UIColor {
        switch letter {
        case "A"..."E":
            return UIColor.color(colorHexString: "#7317F9")
        case "F"..."K":
            return UIColor.color(colorHexString: "#0D74D4")
        case "L"..."P":
            return UIColor.color(colorHexString: "#F29800")
        case "Q"..."V":
            return UIColor.color(colorHexString: "#3125BE")
        case "W"..."Z":
            return UIColor.color(colorHexString: "#BF2A27")
        case "0"..."9":
            return UIColor.color(colorHexString: "#E3E8F6")
        default:
            return .white
        }
    }
    
    private func showImage() {
        if imageView.superview == nil {
            addSubview(imageView)
        }
        imageView.frame = bounds
    }
    
    private func hideImage() {
        if let item = subviews.filter({ ($0 is UIImageView) }).first {
            item.removeFromSuperview()
        }
    }
    
}
