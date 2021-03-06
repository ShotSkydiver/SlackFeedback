//
//  FSTextView.swift
//  SlackTest
//
//  Created by Ueoka Kazuya on 2016/08/21.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import UIKit

class FSTextView: UITextView {
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.inputAccessoryView = self.toolbar
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.inputAccessoryView = self.toolbar
    }
    
    lazy var closeButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.closeButtonDidTapped(_:)))
    }()
    
    lazy var toolbar: UIToolbar = {
        let spacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0))
        toolbar.setItems([spacer, self.closeButton], animated: false)
        return toolbar
    }()
    
    @objc func closeButtonDidTapped(_ button: UIBarButtonItem) {
        self.resignFirstResponder()
    }
}
