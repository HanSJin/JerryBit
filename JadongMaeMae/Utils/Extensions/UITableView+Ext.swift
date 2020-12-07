//
//  UITableView+Ext.swift
//  JadongMaeMae
//
//  Created by HanSJin on 2020/12/07.
//

import UIKit

extension UITableView {

    var emptyCell: UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        return cell
    }

    var bottomPadding: CGFloat {
        100
    }

    func registerNib(cellIdentifier identifier: String) {
        register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
    }
}

// MARK: - Dequeue Reusable Cell

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T? {
        dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T
    }
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T? {
        dequeueReusableHeaderFooterView(withIdentifier: T.identifier) as? T
    }
    func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T? {
        dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T
    }
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(with: T.Type) -> T? {
        dequeueReusableHeaderFooterView(withIdentifier: T.identifier) as? T
    }
}

// MARK: - reloadData with Animation

extension UITableView {
    func reloadDataWithAnimation(with options: UIView.AnimationOptions = .transitionCrossDissolve) {
        UIView.transition(with: self, duration: 0.25, options: options, animations: { [weak self] in
            self?.reloadData()
        })
    }
}
