//
//  MosaikGameViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/08/31.
//  Copyright (c) 2016年 趙偉. All rights reserved.
//

import UIKit
import SpriteKit

class MosaikGameViewController: GameGameViewController, GameDelegate {
    typealias GM = MosaikGameMove
    typealias GS = MosaikGameState

    var scene: MosaikGameScene {
        get {return getScene() as! MosaikGameScene}
        set {setScene(scene: newValue)}
    }
    var game: MosaikGame {
        get {return getGame() as! MosaikGame}
        set {setGame(game: newValue)}
    }
    var gameDocument: MosaikDocument { return MosaikDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return MosaikDocument.sharedInstance }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and configure the scene.
        scene = MosaikGameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = UIColor.black
        
        // Present the scene.
        skView.presentScene(scene)
       
        startGame()
    }
    
    override func handleTap(_ sender: UITapGestureRecognizer) {
        guard !game.isSolved else {return}
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = scene.convertPoint(fromView: touchLocation)
        guard scene.gridNode.contains(touchLocationInScene) else {return}
        let touchLocationInGrid = scene.convert(touchLocationInScene, to: scene.gridNode)
        let p = scene.gridNode.cellPosition(point: touchLocationInGrid)
        var move = MosaikGameMove(p: p, obj: .empty)
        if game.switchObject(move: &move) { soundManager.playSoundTap() }
    }
    
    override func startGame() {
        lblLevel.text = gameDocument.selectedLevelID
        updateSolutionUI()
        
        let layout: [String] = gameDocument.levels.first(where: {$0.0 == gameDocument.selectedLevelID}).map({$0.1}) ?? gameDocument.levels.first!.1
        
        levelInitilizing = true
        defer {levelInitilizing = false}
        game = MosaikGame(layout: layout, delegate: self)
        
        // restore game state
        for case let rec as MoveProgress in gameDocument.moveProgress {
            var move = gameDocument.loadMove(from: rec)!
            _ = game.setObject(move: &move)
        }
        let moveIndex = gameDocument.levelProgress.moveIndex
        if case 0..<game.moveCount = moveIndex {
            while moveIndex != game.moveIndex {
                game.undo()
            }
        }
        scene.levelUpdated(from: game.states[0], to: game.state)
    }
    
    func moveAdded(_ game: AnyObject, move: MosaikGameMove) {
        guard !levelInitilizing else {return}
        gameDocument.moveAdded(game: game, move: move)
    }
    
    func updateMovesUI(_ game: MosaikGame) {
        lblMoves.text = "Moves: \(game.moveIndex)(\(game.moveCount))"
        lblSolved.textColor = game.isSolved ? .white : .black
        btnSaveSolution.isEnabled = game.isSolved
    }
    
    func levelInitilized(_ game: AnyObject, state: MosaikGameState) {
        let game = game as! MosaikGame
        updateMovesUI(game)
        scene.levelInitialized(game, state: state, skView: skView)
    }
    
    func levelUpdated(_ game: AnyObject, from stateFrom: MosaikGameState, to stateTo: MosaikGameState) {
        let game = game as! MosaikGame
        updateMovesUI(game)
        guard !levelInitilizing else {return}
        scene.levelUpdated(from: stateFrom, to: stateTo)
        gameDocument.levelUpdated(game: game)
    }
    
    func gameSolved(_ game: AnyObject) {
        guard !levelInitilizing else {return}
        soundManager.playSoundSolved()
        gameDocument.gameSolved(game: game)
        updateSolutionUI()
    }
}
