//
//  MinesweeperHelpViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2017/05/14.
//  Copyright © 2017年 趙偉. All rights reserved.
//

import UIKit

class MinesweeperHelpViewController: GameHelpViewController {

    var gameDocument: MinesweeperDocument { return MinesweeperDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return MinesweeperDocument.sharedInstance }

}
