//
//  Cross.swift
//  ChineseChess
//
//  Created by Gary Li on 2/17/18.
//  Copyright © 2018 Gary Li. All rights reserved.
//

import UIKit

let imageFiles = ["rking","rrook","rgun","rhorse","rpawn","rbishop","rscholar","bking","brook","bgun","bhorse","bpawn","bbishop","bscholar","none"]


enum Pieces: Int {
    case rking = 0
    case rrook = 1
    case rgun = 2
    case rhorse = 3
    case rpawn = 4
    case rbishop = 5
    case rscholar = 6
    case bking = 7
    case brook = 8
    case bgun = 9
    case bhorse = 10
    case bpawn = 11
    case bbishop = 12
    case bscholar = 13
    case none = 14
}

class Cross {

    //TODO: to add init()
    
    var row: Int = 0      //the current row in the board, top/left is 0,0
    var col: Int = 0      //the current column in the board
    var x: Int = 0        //the start X of the image on the position
    var y: Int = 0        //the start Y of the image on the position
    var width: Int = 0    //image width
    var height: Int = 0   //image height
    var imageName: String? = nil //image name if there is a piece, or nil if no piece = ""
    var viewTag: Int = 0
    var piece: Pieces = Pieces.none
}
