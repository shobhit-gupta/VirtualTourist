//
//  Dictionary+Ease.swift
//  OnTheMap
//
//  Created by Shobhit Gupta on 29/05/17.
//  Copyright © 2017 Shobhit Gupta. All rights reserved.
//

import Foundation


// Modified from: https://stackoverflow.com/a/24052094/471960
public func += <K, V> (lhs: inout [K : V], rhs: [K : V]) {
    rhs.forEach { lhs[$0] = $1 }
}
