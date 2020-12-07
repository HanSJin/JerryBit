//
//  UITableViewCell+Ext.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/07.
//

import UIKit

// MARK: - UITableViewCell + Identifier

extension UITableViewCell: Identifier { }

// MARK: - UITableViewHeaderFooterView + Identifier

extension UITableViewHeaderFooterView: Identifier { }

// MARK: - UITableViewCell + Nib

extension UITableViewCell: Nib {

    static func fromNib() -> Self {
        Self.loadNib(for: Self.self, owner: nil) as! Self
    }
}
