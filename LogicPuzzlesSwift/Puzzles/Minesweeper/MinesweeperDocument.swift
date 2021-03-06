//
//  MinesweeperDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class MinesweeperDocument: GameDocument<MinesweeperGame, MinesweeperGameMove> {
    static var sharedInstance = MinesweeperDocument()
    
    override func saveMove(_ move: MinesweeperGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> MinesweeperGameMove? {
        return MinesweeperGameMove(p: Position(rec.row, rec.col), obj: MinesweeperObject.fromString(str: rec.strValue1!))
    }
}
