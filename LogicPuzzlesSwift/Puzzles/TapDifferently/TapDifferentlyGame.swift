//
//  TapDifferentlyGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TapDifferentlyGame: GridGame<TapDifferentlyGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(-1, 1),
        Position(0, 1),
        Position(1, 1),
        Position(1, 0),
        Position(1, -1),
        Position(0, -1),
        Position(-1, -1),
    ]
    static let offset2 = [
        Position(0, 0),
        Position(0, 1),
        Position(1, 0),
        Position(1, 1),
    ]

    var pos2hint = [Position: [Int]]()
    
    init(layout: [String], delegate: TapDifferentlyGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length / 4)
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let p = Position(r, c)
                let s = str[c * 4...c * 4 + 3].trimmed()
                guard s != "" else {continue}
                pos2hint[p] = [Int]()
                for ch in s.trimmed().characters {
                    switch ch {
                    case "0"..."9":
                        pos2hint[p]!.append(ch.toInt!)
                    case "?":
                        pos2hint[p]!.append(-1)
                    default:
                        break
                    }
                }
            }
        }
        
        let state = TapDifferentlyGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func changeObject(move: inout TapDifferentlyGameMove, f: (inout TapDifferentlyGameState, inout TapDifferentlyGameMove) -> Bool) -> Bool {
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
    
    func switchObject(move: inout TapDifferentlyGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout TapDifferentlyGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
