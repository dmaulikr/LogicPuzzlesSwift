//
//  BridgesObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum BridgesObject {
    case empty
    case island(state: HintState, bridges: [Int])
    case bridge
    init() {
        self = .empty
    }
}

struct BridgesGameMove {
    var pFrom = Position()
    var pTo = Position()
}

