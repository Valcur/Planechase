//
//  String+.swift
//  Planechase
//
//  Created by Loic D on 12/12/2023.
//

import Foundation

extension String {
    func translate() -> String {
        return NSLocalizedString(self, comment: self)
    }
}
