//
//  LightenUpGame.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class LightenUpGame: GridGame<LightenUpGameViewController> {
    static let offset = [
        Position(-1, 0),
        Position(0, 1),
        Position(1, 0),
        Position(0, -1),
    ]

    var wall2Lightbulbs = [Position: Int]()
    
    init(layout: [String], delegate: LightenUpGameViewController? = nil) {
        super.init(delegate: delegate)
        
        size = Position(layout.count, layout[0].length)
        
        func addWall(row: Int, col: Int, lightbulbs: Int) {
            wall2Lightbulbs[Position(row, col)] = lightbulbs
        }
        
        for r in 0..<rows {
            let str = layout[r]
            for c in 0..<cols {
                let ch = str[c]
                switch ch {
                case "W":
                    addWall(row: r, col: c, lightbulbs: -1)
                case "0"..."9":
                    addWall(row: r, col: c, lightbulbs: ch.toInt!)
                default:
                    break
                }
            }
        }
        
        let state = LightenUpGameState(game: self)
        states.append(state)
        levelInitilized(state: state)
    }
    
    private func changeObject(move: inout LightenUpGameMove, f: (inout LightenUpGameState, inout LightenUpGameMove) -> Bool) -> Bool {
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
    
    func switchObject(move: inout LightenUpGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.switchObject(move: &move)})
    }
    
    func setObject(move: inout LightenUpGameMove) -> Bool {
        return changeObject(move: &move, f: {state, move in state.setObject(move: &move)})
    }
    
}
