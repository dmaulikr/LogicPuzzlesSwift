//
//  SumscrapersGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class SumscrapersGame: GridGame<SumscrapersGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]

    override func isValid(row: Int, col: Int) -> Bool {
        return 1..<rows - 1 ~= row && 1..<cols - 1 ~= col
    }

    var objArray = [Int]()
    var intMax: Int {return rows - 2}
    subscript(p: Position) -> Int {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> Int {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    init(layout: [String], delegate: SumscrapersGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length / 2)
        objArray = Array<Int>(repeating: 0, count: rows * cols)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let s = str[c * 2...c * 2 + 1]
                let n = s == "  " ? 0 : s.toInt()!
                self[r, c] = n
            }
        }
        
        let state = SumscrapersGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func changeObject(move: inout SumscrapersGameMove, f: (inout SumscrapersGameState, inout SumscrapersGameMove) -> Bool) -> Bool {
        if canRedo {
            states.removeSubrange((stateIndex + 1)..<states.count)
            moves.removeSubrange(stateIndex..<moves.count)
        }
        // copy a state
        var state = self.state.copy()
        guard f(&state, &move) else {return false}
        
        states.append(state)
        stateIndex += 1
        moves.append(move)
        moveAdded(move: move)
        levelUpdated(from: states[stateIndex - 1], to: state)
        return true
    }
    
    func switchObject(move: inout SumscrapersGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout SumscrapersGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
