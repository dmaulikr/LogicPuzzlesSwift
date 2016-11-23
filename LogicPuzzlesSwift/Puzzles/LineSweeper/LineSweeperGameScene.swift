//
//  LineSweeperGameScene.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2016/09/09.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import SpriteKit

class LineSweeperGameScene: GameScene<LineSweeperGameState> {
    private(set) var gridNode: LineSweeperGridNode!
    
    func coloredRectSize() -> CGSize {
        let sz = gridNode.blockSize - 4
        return CGSize(width: sz, height: sz)
    }
    
    func addHintNumber(n: Int, s: HintState, point: CGPoint, nodeName: String) {
        let numberNode = SKLabelNode(text: String(n))
        numberNode.fontColor = s == .normal ? SKColor.white : s == .complete ? SKColor.green : SKColor.red
        numberNode.fontName = numberNode.fontName! + "-Bold"
        // http://stackoverflow.com/questions/32144666/resize-a-sklabelnode-font-size-to-fit
        let scalingFactor = min(gridNode.blockSize / numberNode.frame.width, gridNode.blockSize / numberNode.frame.height)
        numberNode.fontSize *= scalingFactor
        numberNode.verticalAlignmentMode = .center
        numberNode.position = point
        numberNode.name = nodeName
        gridNode.addChild(numberNode)
    }
    
    override func levelInitialized(_ game: AnyObject, state: LineSweeperGameState, skView: SKView) {
        let game = game as! LineSweeperGame
        removeAllChildren()
        let blockSize = CGFloat(skView.bounds.size.width) / CGFloat(game.cols)
        
        // addGrid
        let offset:CGFloat = 0.5
        scaleMode = .resizeFill
        gridNode = LineSweeperGridNode(blockSize: blockSize, rows: game.rows, cols: game.cols)
        gridNode.position = CGPoint(x: skView.frame.midX - blockSize * CGFloat(game.cols) / 2 - offset, y: skView.frame.midY + blockSize * CGFloat(game.rows) / 2 + offset)
        addChild(gridNode)
        gridNode.anchorPoint = CGPoint(x: 0, y: 1.0)
        
        // addHints
        for (p, n) in game.pos2hint {
            let point = gridNode.gridPosition(p: p)
            let nodeNameSuffix = "-\(p.row)-\(p.col)"
            let hintNumberNodeName = "hintNumber" + nodeNameSuffix
            addHintNumber(n: n, s: state.pos2state[p]!, point: point, nodeName: hintNumberNodeName)
        }
    }
    
    override func levelUpdated(from stateFrom: LineSweeperGameState, to stateTo: LineSweeperGameState) {
        for row in 0..<stateFrom.rows {
            for col in 0..<stateFrom.cols {
                for dir in 1...2 {
                    let p = Position(row, col)
                    let point = gridNode.gridPosition(p: p)
                    let nodeNameSuffix = "-\(row)-\(col)-\(dir)"
                    let hintNumberNodeName = "hintNumber" + nodeNameSuffix
                    let lineNodeName = "line" + nodeNameSuffix
                    func removeNode(withName: String) {
                        gridNode.enumerateChildNodes(withName: withName) { (node, pointer) in
                            node.removeFromParent()
                        }
                    }
                    func removeHintNumber() { removeNode(withName: hintNumberNodeName) }
                    func removeLine() { removeNode(withName: lineNodeName) }
                    func addLine() {
                        let pathToDraw = CGMutablePath()
                        let lineNode = SKShapeNode(path:pathToDraw)
                        lineNode.glowWidth = 8
                        switch dir {
                        case 1:
                            pathToDraw.move(to: CGPoint(x: point.x, y: point.y))
                            pathToDraw.addLine(to: CGPoint(x: point.x + gridNode.blockSize, y: point.y))
                        case 2:
                            pathToDraw.move(to: CGPoint(x: point.x, y: point.y))
                            pathToDraw.addLine(to: CGPoint(x: point.x, y: point.y - gridNode.blockSize))
                        default:
                            break
                        }
                        lineNode.path = pathToDraw
                        lineNode.strokeColor = SKColor.yellow
                        lineNode.name = lineNodeName
                        gridNode.addChild(lineNode)
                    }
                    let (o1, o2) = (stateFrom[p][dir], stateTo[p][dir])
                    if o1 != o2 {
                        if o1 {removeLine()}
                        if o2 {addLine()}
                    }
                    guard let s1 = stateFrom.pos2state[p], let s2 = stateTo.pos2state[p] else {continue}
                    if s1 != s2 {
                        removeHintNumber()
                        addHintNumber(n: stateFrom.game.pos2hint[p]!, s: s2, point: point, nodeName: hintNumberNodeName)
                    }
                }
            }
        }
    }
}