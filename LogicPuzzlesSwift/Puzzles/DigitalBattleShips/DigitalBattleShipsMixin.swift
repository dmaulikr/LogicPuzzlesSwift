//
//  DigitalBattleShipsMixin.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/10/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol DigitalBattleShipsMixin: GameMixin {
}

extension DigitalBattleShipsMixin {
    var gameDocumentBase: GameDocumentBase { return DigitalBattleShipsDocument.sharedInstance }
    var gameDocument: DigitalBattleShipsDocument { return DigitalBattleShipsDocument.sharedInstance }
}