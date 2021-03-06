//
//  MiniLitsGameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

class MiniLitsAreaInfo {
    var trees = [Position]()
    var blockIndexes = Set<Int>()
    var neighborIndexes = Set<Int>()
    var triominoIndex: Int?
}

class MiniLitsGameState: GridGameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    var game: MiniLitsGame {
        get {return getGame() as! MiniLitsGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: MiniLitsDocument { return MiniLitsDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return MiniLitsDocument.sharedInstance }
    var objArray = [MiniLitsObject]()
    var pos2state = [Position: HintState]()
    
    override func copy() -> MiniLitsGameState {
        let v = MiniLitsGameState(game: game, isCopy: true)
        return setup(v: v)
    }
    func setup(v: MiniLitsGameState) -> MiniLitsGameState {
        _ = super.setup(v: v)
        v.objArray = objArray
        v.pos2state = pos2state
        return v
    }
    
    required init(game: MiniLitsGame, isCopy: Bool = false) {
        super.init(game: game)
        guard !isCopy else {return}
        objArray = Array<MiniLitsObject>(repeating: .empty, count: rows * cols)
        updateIsSolved()
    }
    
    subscript(p: Position) -> MiniLitsObject {
        get {
            return self[p.row, p.col]
        }
        set(newValue) {
            self[p.row, p.col] = newValue
        }
    }
    subscript(row: Int, col: Int) -> MiniLitsObject {
        get {
            return objArray[row * cols + col]
        }
        set(newValue) {
            objArray[row * cols + col] = newValue
        }
    }
    
    func setObject(move: inout MiniLitsGameMove) -> Bool {
        let p = move.p
        guard String(describing: self[p]) != String(describing: move.obj) else {return false}
        self[p] = move.obj
        updateIsSolved()
        return true
    }
    
    func switchObject(move: inout MiniLitsGameMove) -> Bool {
        let markerOption = MarkerOptions(rawValue: self.markerOption)
        func f(o: MiniLitsObject) -> MiniLitsObject {
            switch o {
            case .empty:
                return markerOption == .markerFirst ? .marker : .tree(state: .normal)
            case .tree:
                return markerOption == .markerLast ? .marker : .empty
            case .marker:
                return markerOption == .markerFirst ? .tree(state: .normal) : .empty
            default:
                return o
            }
        }
        let p = move.p
        guard isValid(p: p) else {return false}
        move.obj = f(o: self[p])
        return setObject(move: &move)
    }
    
    /*
        iOS Game: Logic Games/Puzzle Set 14/Mini-Lits

        Summary
        Lits Jr.

        Description
        1. You play the game with triominos (pieces of three squares).
        2. The board is divided into many areas. You have to place a triomino
           into each area respecting these rules:
        3. No two adjacent (touching horizontally / vertically) triominos should
           be of equal shape & orientation.
        4. All the shaded cells should form a valid Nurikabe.
    */
    private func updateIsSolved() {
        let allowedObjectsOnly = self.allowedObjectsOnly
        isSolved = true
        let g = Graph()
        var pos2node = [Position: Node]()
        for r in 0..<rows {
            for c in 0..<cols {
                let p = Position(r, c)
                switch self[p] {
                case .forbidden:
                    self[p] = .empty
                case .tree:
                    self[p] = .tree(state: .normal)
                    pos2node[p] = g.addNode(p.description)
                default:
                    break
                }
            }
        }
        for p in pos2node.keys {
            for os in MiniLitsGame.offset {
                let p2 = p + os
                if let node2 = pos2node[p2] {
                    g.addEdge(pos2node[p]!, neighbor: node2)
                }
            }
        }
        var blocks = [[Position]]()
        while !pos2node.isEmpty {
            let nodesExplored = breadthFirstSearch(g, source: pos2node.first!.value)
            let block = pos2node.filter({(p, _) in nodesExplored.contains(p.description)}).map{$0.0}
            blocks.append(block)
            pos2node = pos2node.filter({(p, _) in !nodesExplored.contains(p.description)})
        }
        if blocks.count != 1 {isSolved = false}
        var infos = [MiniLitsAreaInfo]()
        for i in 0..<game.areas.count {
            infos.append(MiniLitsAreaInfo())
        }
        for i in 0..<blocks.count {
            let block = blocks[i]
            for p in block {
                let n = game.pos2area[p]!
                let info = infos[n]
                info.trees.append(p)
                info.blockIndexes.insert(i)
            }
        }
        for i in 0..<infos.count {
            let info = infos[i]
            for p in info.trees {
                for os in MiniLitsGame.offset {
                    let p2 = p + os
                    guard let index = infos.index(where: {$0.trees.contains(p2)}),
                        index != i else {continue}
                    info.neighborIndexes.insert(index)
                }
            }
        }
        func notSolved(info: MiniLitsAreaInfo) {
            isSolved = false
            for p in info.trees {
                self[p] = .tree(state: .error)
            }
        }
        for i in 0..<infos.count {
            let info = infos[i]
            let treeCount = info.trees.count
            if treeCount >= 3 && allowedObjectsOnly {
                for p in game.areas[i] {
                    switch self[p] {
                    case .empty, .marker:
                        self[p] = .forbidden
                    default:
                        break
                    }
                }
            }
            if treeCount > 3 || treeCount == 3 && info.blockIndexes.count > 1 {notSolved(info: info)}
            if treeCount == 3 && info.blockIndexes.count == 1 {
                info.trees.sort()
                var treeOffsets = [Position]()
                let p2 = Position(info.trees.min(by: {$0.row < $1.row})!.row, info.trees.min(by: {$0.col < $1.col})!.col)
                for p in info.trees {
                    treeOffsets.append(p - p2)
                }
                info.triominoIndex = MiniLitsGame.triominos.index(where: {$0 == treeOffsets})
                if info.triominoIndex == nil {notSolved(info: info)}
            }
            if treeCount < 3 {isSolved = false}
        }
        for i in 0..<infos.count {
            let info = infos[i]
            guard let index = info.triominoIndex else {continue}
            if info.neighborIndexes.contains(where: {infos[$0].triominoIndex == index}) {notSolved(info: info)}
        }
        guard isSolved else {return}
        let block = blocks[0]
        rule2x2:
        for p in block {
            for os in MiniLitsGame.offset3 {
                guard block.contains(p + os) else {continue rule2x2}
            }
            isSolved = false
            for os in MiniLitsGame.offset3 {
                self[p + os] = .tree(state: .error)
            }
        }
    }
}
