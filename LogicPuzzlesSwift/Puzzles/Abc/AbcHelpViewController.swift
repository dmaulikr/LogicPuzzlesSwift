//
//  AbcHelpViewController.swift
//  LogicPuzzlesSwift
//
//  Created by 趙偉 on 2017/05/14.
//  Copyright © 2017年 趙偉. All rights reserved.
//

import UIKit

class AbcHelpViewController: GameHelpViewController {

    var gameDocument: AbcDocument { return AbcDocument.sharedInstance }
    override func getGameDocument() -> GameDocumentBase! { return AbcDocument.sharedInstance }

}
