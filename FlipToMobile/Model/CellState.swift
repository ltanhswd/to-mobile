//
//  CellState.swift
//  TestSMB
//
//  Created by iOS on 11/19/20.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation

struct CellState {
    var cellProgress:Float!
    var sentByte:Int64! = 0
    var isEnablePauseButton:Bool!
    var isEnableStartButton:Bool!
    var isHideProgressBar:Bool!
    var isError:Bool!
}
