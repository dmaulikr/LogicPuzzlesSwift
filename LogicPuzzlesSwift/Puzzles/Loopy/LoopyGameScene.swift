//
//  LoopyGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class LoopyGameScene: GameScene<LoopyGameState> {
    var gridNode: LoopyGridNode {
        get {return getGridNode() as! LoopyGridNode}
        set {setGridNode(gridNode: newValue)}
    }
    
    func addLine(dir: Int, color: SKColor, point: CGPoint, nodeName: String) {
        let pathToDraw = CGMutablePath()
        let lineNode = SKShapeNode(path:pathToDraw)
        switch dir {
        case 1:
            pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
            pathToDraw.addLine(to: CGPoint(x: point.x + gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
            lineNode.glowWidth = 8
        case 2:
            pathToDraw.move(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y + gridNode.blockSize / 2))
            pathToDraw.addLine(to: CGPoint(x: point.x - gridNode.blockSize / 2, y: point.y - gridNode.blockSize / 2))
            lineNode.glowWidth = 8
        default:
            break
        }
        lineNode.path = pathToDraw
        lineNode.strokeColor = color
        lineNode.name = nodeName
        gridNode.addChild(lineNode)
    }
    
    override func levelInitialized(_ game: AnyObject, state: LoopyGameState, skView: SKView) {
        let game = game as! LoopyGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols - 1)
        
        // addGrid
        let offset:CGFloat = 0.5
        addGrid(gridNode: LoopyGridNode(blockSize: blockSize, rows: game.rows - 1, cols: game.cols - 1), point: CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols - 1) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows - 1) / 2 + offset))

        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.dotPosition(p: p)
                let dotNode = SKShapeNode(circleOfRadius: 5)
                dotNode.position = point
                dotNode.name = "dot"
                dotNode.strokeColor = .white
                dotNode.glowWidth = 1.0
                dotNode.fillColor = .white
                gridNode.addChild(dotNode)
            }
        }

        for r in 0..<game.rows {
            for c in 0..<game.cols {
                let p = Position(r, c)
                let point = gridNode.gridPosition(p: p)
                for dir in 1...2 {
                    guard game[r, c][dir] else {continue}
                    let nodeNameSuffix = "-\(r)-\(c)-\(dir)"
                    let lineNodeName = "line" + nodeNameSuffix
                    addLine(dir: dir, color: .white, point: point, nodeName: lineNodeName)
                }
            }
        }
    }
    
    override func levelUpdated(from stateFrom: LoopyGameState, to stateTo: LoopyGameState) {
        let markerOffset: CGFloat = 7.5
        for r in 0..<stateFrom.rows {
            for c in 0..<stateFrom.cols {
                for dir in 1...2 {
                    guard !stateFrom.game[r, c][dir] else {continue}
                    let p = Position(r, c)
                    let point = gridNode.gridPosition(p: p)
                    let nodeNameSuffix = "-\(r)-\(c)-\(dir)"
                    let lineNodeName = "line" + nodeNameSuffix
                    func removeLine() { removeNode(withName: lineNodeName) }
                    let (o1, o2) = (stateFrom[p][dir], stateTo[p][dir])
                    guard o1 != o2 else {continue}
                    if o1 {removeLine()}
                    if o2 {addLine(dir: dir, color: .green, point: point, nodeName: lineNodeName)}
                }
            }
        }
    }
}
