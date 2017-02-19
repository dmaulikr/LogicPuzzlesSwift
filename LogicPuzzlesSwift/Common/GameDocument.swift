//
//  GameDocument.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/18.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import UIKit
import SharkORM

class GameDocument<G: GameBase, GM> {
    private(set) var levels = [String: [String]]()
    var selectedLevelID: String!
    var selectedLevelIDSolution: String { return selectedLevelID + " Solution" }
    
    var gameProgress: GameProgress {
        let result = GameProgress.query().where(withFormat: "gameID = %@", withParameters: [G.gameID]).fetch()!
        if result.count == 0 {
            let rec = GameProgress()
            rec.gameID = G.gameID
            return rec
        } else {
            return result[0] as! GameProgress
        }
    }
    private func getLevelProgress(levelID: String) -> LevelProgress {
        let result = LevelProgress.query().where(withFormat: "gameID = %@ AND levelID = %@", withParameters: [G.gameID, levelID]).fetch()!
        if result.count == 0 {
            let rec = LevelProgress()
            rec.gameID = G.gameID
            rec.levelID = levelID
            return rec
        } else {
            return result[0] as! LevelProgress
        }
    }
    var levelProgress: LevelProgress { return getLevelProgress(levelID: selectedLevelID) }
    var levelProgressSolution: LevelProgress { return getLevelProgress(levelID: selectedLevelIDSolution) }
    private func getMoveProgress(levelID: String) -> SRKResultSet {
        return MoveProgress.query().where(withFormat: "gameID = %@ AND levelID = %@", withParameters: [G.gameID, levelID]).order(by: "moveIndex").fetch()!
    }
    var moveProgress: SRKResultSet { return getMoveProgress(levelID: selectedLevelID) }
    var moveProgressSolution: SRKResultSet { return getMoveProgress(levelID: selectedLevelIDSolution) }
    
    init() {
        let path = Bundle.main.path(forResource: G.gameID, ofType: "xml")!
        let xml = try! String(contentsOfFile: path)
        let doc = try! XMLDocument(string: xml)
        for elem in doc.root!.children {
            guard let key = elem.attr("id") else {continue}
            var arr = elem.stringValue.components(separatedBy: "\n")
            arr = Array(arr[2..<(arr.count - 2)])
            arr = arr.map { s in s.substring(to: s.index(before: s.endIndex)) }
            levels["Level " + key] = arr
        }
        selectedLevelID = gameProgress.levelID
    }
    
    func levelUpdated(game: AnyObject) {
        let game = game as! G
        let rec = levelProgress
        rec.moveIndex = game.moveIndex
        rec.commit()
    }
    
    func gameSolved(game: AnyObject) {
        let recLP = levelProgress
        let recLPS = levelProgressSolution
        guard recLPS.moveIndex == 0 || recLPS.moveIndex > recLP.moveIndex else {return}
        saveSolution()
    }

    func moveAdded(game: AnyObject, move: GM) {
        let game = game as! G
        MoveProgress.query().where(withFormat: "gameID = %@ AND levelID = %@ AND moveIndex >= %@", withParameters: [G.gameID, selectedLevelID, game.moveIndex]).fetch().removeAll()
        let rec = MoveProgress()
        rec.gameID = G.gameID
        rec.levelID = selectedLevelID
        rec.moveIndex = game.moveIndex
        saveMove(move, to: rec)
        rec.commit()
    }
    
    func saveMove(_ move: GM, to rec: MoveProgress) {}
    
    func loadMove(from rec: MoveProgress) -> GM? {return nil}
    
    func resumeGame() {
        let rec = gameProgress
        rec.levelID = selectedLevelID
        rec.commit()
    }
    
    func clearGame() {
        MoveProgress.query().where(withFormat: "gameID = %@ AND levelID = %@", withParameters: [G.gameID, selectedLevelID]).fetch().removeAll()
        
        let rec = levelProgress
        rec.moveIndex = 0
        rec.commit()
    }
    
    private func copyMoves(moveProgressFrom: SRKResultSet, levelIDTo: String) {
        MoveProgress.query().where(withFormat: "gameID = %@ AND levelID = %@", withParameters: [G.gameID, levelIDTo]).fetch().removeAll()
        for case let recMP as MoveProgress in moveProgressFrom {
            let move = loadMove(from: recMP)!
            let recMPS = MoveProgress()
            recMPS.gameID = G.gameID
            recMPS.levelID = levelIDTo
            recMPS.moveIndex = recMP.moveIndex
            saveMove(move, to: recMPS)
            recMPS.commit()
        }
    }
    func saveSolution() { copyMoves(moveProgressFrom: moveProgress, levelIDTo: selectedLevelIDSolution) }
    func loadSolution() { copyMoves(moveProgressFrom: moveProgressSolution, levelIDTo: selectedLevelID) }
    func deleteSolution() {
        MoveProgress.query().where(withFormat: "gameID = %@ AND levelID = %@", withParameters: [G.gameID, selectedLevelIDSolution]).fetch().removeAll()
    }
}
