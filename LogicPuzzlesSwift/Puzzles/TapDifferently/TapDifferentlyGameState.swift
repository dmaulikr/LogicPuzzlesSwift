//
//  TapDifferentlyGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class TapDifferentlyGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: TapDifferentlyGame {
        get {return getGame() as! TapDifferentlyGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: TapDifferentlyDocument { return TapDifferentlyDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return TapDifferentlyDocument.sharedInstance }
    var objArray = [TapDifferentlyObject]()
    
    override func copy() -> TapDifferentlyGameState {
        let v = TapDifferentlyGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: TapDifferentlyGameState) -> TapDifferentlyGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        return v
    }
    
    required init(game: TapDifferentlyGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<TapDifferentlyObject>(repeating: TapDifferentlyObject(), count: rows * cols)
        for p in game.pos2hint.keys {
            self[p] = .hint(state: .normal)
        }
        updateIsSolved()
    }
    
    subscript(p: Position) -> TapDifferentlyObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> TapDifferentlyObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout TapDifferentlyGameMove) -> Bool {
        let p = move.p
        let (o1, o2) = (self[p], move.obj)
        if case .hint = o1 {return false}
        guard String(describing: o1) != String(describing: o2) else {return false}
        self[p] = o2
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout TapDifferentlyGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: TapDifferentlyObject) -> TapDifferentlyObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .wall
            case .wall:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .wall : .empty
            case .hint:
                return o
            }
        }
        move.obj = f(o: self[move.p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 10/Tap Differently

        Summary
        Tapa Landscaper

        Description
        1. Plays with the same rules as Tapa with these variations:
        2. Each row must have a different number of filled cells.
        3. Each column must have a different number of filled cells.
    */
    private func updateIsSolved() {
        isSolved = true
        func computeHint(filled: [Int]) -> [Int] {
            if filled.isEmpty {return [0]}
            var hint = [Int]()
            for j in 0..<filled.count {
                if j == 0 || filled[j] - filled[j - 1] != 1 {
                    hint.append(1)
                } else {
                    hint[hint.count - 1] += 1
                }
            }
            if filled.count > 1 && hint.count > 1 && filled.last! - filled.first! == 7 {
                hint[0] += hint.last!; hint.removeLast()
            }
            return hint.sorted()
        }
        func isCompatible(computedHint: [Int], givenHint: [Int]) -> Bool {
            if computedHint == givenHint {return true}
            if computedHint.count != givenHint.count {return false}
            let h1 = Set(computedHint)
            var h2 = Set(givenHint)
            h2.remove(-1)
            return h2.isSubset(of: h1)
        }
        for (p, arr2) in game.pos2hint {
            let filled = [Int](0..<8).filter({
                let p2 = p + TapDifferentlyGame.offset[$0]
                return isValid(p: p2) && String(describing: self[p2]) == String(describing: TapDifferentlyObject.wall)
            })
            let arr = computeHint(filled: filled)
            let s: HintState = arr == [0] ? .normal : isCompatible(computedHint: arr, givenHint: arr2) ? .complete : .error
            self[p] = .hint(state: s)
            if s != .complete {isSolved = false}
        }
        guard isSolved else {return}
        for r in 0..<rows - 1 {
            for c in 0..<cols - 1 {
                let p = Position(r, c)
                if TapDifferentlyGame.offset2.testAll({os in
                    let o = self[p + os]
                    if case .wall = o {return true} else {return false}
                }) {isSolved = false; return}
            }
        }
        let g = Graph()
        var pos2node = [Position: Node]()
        var rngWalls = [Position]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                pos2node[p] = g.addNode(p.description)
                switch self[p] {
                case .wall:
                    rngWalls.append(p)
                default:
                    break
                }
            }
        }
        for p in rngWalls {
            for os in TapDifferentlyGame.offset {
                let p2 = p + os
                if rngWalls.contains(p2) {
                    g.addEdge(pos2node[p]!, neighbor: pos2node[p2]!)
                }
            }
        }
        let nodesExplored = breadthFirstSearch(g, source: pos2node[rngWalls.first!]!)
        if rngWalls.count != nodesExplored.count {isSolved = false; return}
        var nums = Set<Int>()
        for r in 0..<rows {
            var n = 0
            for c in 0..<cols {
                if case .wall = self[r, c] {n += 1}
            }
            nums.insert(n)
        }
        if nums.count != rows {isSolved = false; return}
        nums.removeAll()
        for c in 0..<cols {
            var n = 0
            for r in 0..<rows {
                if case .wall = self[r, c] {n += 1}
            }
            nums.insert(n)
        }
        if nums.count != cols {isSolved = false; return}
    }
}
