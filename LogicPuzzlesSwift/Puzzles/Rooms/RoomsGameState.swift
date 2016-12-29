//
//  RoomsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class RoomsGameState: CellsGameState, RoomsMixin {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: RoomsGame {
        get {return getGame() as! RoomsGame}
        set {setGame(game: newValue)}
    }
    var objArray = [GridDotObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> RoomsGameState {
        let v = RoomsGameState(game: game)
        return setup(v: v)
    }
    func setup(v: RoomsGameState) -> RoomsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: RoomsGame) {
        super.init(game: game);
        objArray = Array<GridDotObject>(repeating: Array<GridLineObject>(repeating: .empty, count: 4), count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position, dir: Int) -> GridLineObject {
        get {
            return self[p.row, p.col, dir]
        }
        set(newValue) {
            self[p.row, p.col, dir] = newValue
        }
    }
    subscript(row: Int, col: Int, dir: Int) -> GridLineObject {
        get {
            return objArray[row * cols + col][dir]
        }
        set(newValue) {
            objArray[row * cols + col][dir] = newValue
        }
    }
    
    func setObject(move: inout RoomsGameMove) -> Bool {
        var changed = false
        func f(o1: inout GridLineObject, o2: inout GridLineObject) {
            if o1 != move.obj {
                changed = true
                o1 = move.obj
                o2 = move.obj
                // updateIsSolved() cannot be called here
                // self[p] will not be updated until the function returns
            }
        }
        let p = move.p
        let dir = move.dir, dir2 = (dir + 2) % 4
        f(o1: &self[p, dir], o2: &self[p + RoomsGame.offset[dir], dir2])
        if changed {updateIsSolved()}
        return changed
    }
    
    func switchObject(move: inout RoomsGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: GridLineObject) -> GridLineObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .line
            case .line:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .line : .empty
            }
        }
        let o = f(o: self[move.p, move.dir])
        move.obj = o
        return setObject(move: &move)
    }
    
    private func updateIsSolved() {
        isSolved = true
        for (p, n2) in game.pos2hint {
            var n1 = 0
            for i in 0..<4 {
                let (os1, os2, dir) = (RoomsGame.offset[i], RoomsGame.offset2[i], RoomsGame.dirs[i])
                var p2 = p
                while(isValid(p: p2 + os1) && self[p2 + os2, dir] != .line) {
                    n1 += 1; p2 += os1
                }
            }
            pos2state[p] = n1 > n2 ? .normal : n1 == n2 ? .complete : .error
            if n1 != n2 {isSolved = false}
        }
    }
}
