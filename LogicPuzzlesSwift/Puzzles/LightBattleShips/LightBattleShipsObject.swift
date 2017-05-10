//
//  LightBattleShipsObject.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/26.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

enum LightBattleShipsObject: Int {
    case empty, forbidden, marker
    case battleShipTop, battleShipBottom, battleShipLeft, battleShipRight, battleShipMiddle, battleShipUnit
    init() {
        self = .empty
    }
}

struct LightBattleShipsGameMove {
    var p = Position()
    var obj = LightBattleShipsObject()
}
