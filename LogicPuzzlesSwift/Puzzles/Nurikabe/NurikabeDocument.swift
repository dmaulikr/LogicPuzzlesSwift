//
//  NurikabeDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class NurikabeDocument: GameDocument<NurikabeGame, NurikabeGameMove> {
    static var sharedInstance = NurikabeDocument()
    
    override func saveMove(_ move: NurikabeGameMove, to rec: MoveProgress) {
        (rec.row, rec.col) = move.p.unapply()
        rec.strValue1 = move.obj.toString()
    }
    
    override func loadMove(from rec: MoveProgress) -> NurikabeGameMove? {
        return NurikabeGameMove(p: Position(rec.row, rec.col), obj: NurikabeObject.fromString(str: rec.strValue1!))
    }
}
