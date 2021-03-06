//
//  GameState.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/19.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Foundation

protocol GameStateBase: class {
    var isSolved: Bool {get}
}

class GameState: Copyable, GameStateBase {
    var isSolved = false
    
    func copy() -> GameState {
        let v = GameState()
        return setup(v: v)
    }
    func setup(v: GameState) -> GameState {
        v.isSolved = isSolved
        return v
    }
    deinit {
        // print("deinit called: \(NSStringFromClass(type(of: self)))")
    }
}

class GridGameState: GameState {
    // http://stackoverflow.com/questions/24094158/overriding-superclass-property-with-different-type-in-swift
    private weak var game: GridGameBase?
    func getGame() -> GridGameBase? {return game}
    func setGame(game: GridGameBase) {self.game = game}
    private var gameDocument: GameDocumentBase! { return getGameDocument() }
    func getGameDocument() -> GameDocumentBase! { return nil }
    var gameOptions: GameProgress { return gameDocument.gameProgress }
    var markerOption: Int { return gameOptions.option1?.toInt() ?? 0 }
    var allowedObjectsOnly: Bool { return gameOptions.option2?.toBool() ?? false }
    
    var size: Position { return game!.size }
    var rows: Int { return size.row }
    var cols: Int { return size.col }
    func isValid(p: Position) -> Bool {
        return game!.isValid(row: p.row, col: p.col)
    }
    func isValid(row: Int, col: Int) -> Bool {
        return game!.isValid(row: row, col: col)
    }
    
    override func copy() -> GridGameState {
        let v = GridGameState(game: game)
        return setup(v: v)
    }
    func setup(v: GridGameState) -> GridGameState {
        _ = super.setup(v: v)
        return v
    }
    
    init(game: GridGameBase?) {
        self.game = game
    }
    
    func succ(ch: Character) -> Character {
        // http://stackoverflow.com/questions/26761390/changing-value-of-character-using-ascii-value-in-swift
        let scalars = String(ch).unicodeScalars      // unicode scalar(s) of the character
        let val = scalars[scalars.startIndex].value  // value of the unicode scalar
        return Character(UnicodeScalar(val + 1)!)     // return an incremented character
    }
}
