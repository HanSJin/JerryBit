//
//  Nib.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/07.
//

import UIKit

protocol Nib {
    func loadNib() -> UIView?
}

extension Nib where Self: UIView {

    // MARK: Internal

    static func loadNib<T: UIView>(for type: T.Type, owner: Any?) -> UIView? {
        guard let nibName = type.description().components(separatedBy: ".").last else {
            return nil
        }
        #if !TARGET_INTERFACE_BUILDER
        let bundle = Bundle(for: type)
        guard let _ = bundle.path(forResource: nibName, ofType: "nib") else {
            fatalError("can't find \(nibName) xib resource in current bundle")
        }
        #endif
        return Bundle(for: type).loadNibNamed(nibName, owner: owner, options: nil)?.first as? UIView
    }

    @discardableResult
    func loadNib() -> UIView? {
        Self.loadNib(for: type(of: self), owner: self).flatMap {
            backgroundColor = .clear
            frame = $0.bounds
            addSubview($0)
            return $0
        }
    }

    func printDeinitNibName() {
        print("deinit \(nibName())")
    }

    // MARK: Private

    private func nibName() -> String {
        type(of: self).description().components(separatedBy: ".").last ?? ""
    }
}
