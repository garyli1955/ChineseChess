//
//  CheckMove.swift
//  ChineseChess
//
//  Created by Gary Li on 2/19/18.
//  Copyright © 2018 Gary Li. All rights reserved.
//

import UIKit

class CheckMove: NSObject {
    let TAG = "CheckMove: "
    
    func getKingPosition(crosses: [Cross], player: Player, row: inout Int, col: inout Int) {
        
        var found = false
        if player == Player.red {
            for r in 7...9 {
                innerloop: for c in 3...5 {
                    if (crosses[r*maxCol+c].piece == Pieces.rking) {
                        found = true
                        col = c
                        break innerloop
                    }
                }
                if (found) {
                    row = r
                    break
                }
            }
        }
        else if player == Player.black {
            for r in 0...2 {
                innerloop: for c in 3...5 {
                    if (crosses[r*maxCol+c].piece == Pieces.bking) {
                        found = true
                        col = c
                        break innerloop
                    }
                }
                if (found) {
                    row = r
                    break
                }
            }
        }
        print(TAG+"getKingPosition(): \(player),[\(row),\(col)]")
    }
    
    //=================================================
    // function name:
    //     Block()
    // description:
    //     check GUN (Pao) movement
    // parameters:
    //     Pos = the target postion
    //     LastPos = the original position
    //       Piece = the piece
    //       Player = Red/Black
    // return:
    //     the number of pieces between the starting and ending crosses    //
    // called by:
    //        1).
    //        2).
    //========================================================
    func checkBlock(crosses: [Cross],row: Int,col: Int,lastRow: Int,lastCol: Int) ->Int {
        print(TAG+"checkBlock()")
        var n = 0
    
        if (row == lastRow) && (col != lastCol) {
            if (lastCol > col) {
                for i in ((col+1)..<lastCol).reversed() {
                    if crosses[row*maxCol+i].piece != Pieces.none {
                        n += 1
                        print(TAG+"block piece[\(row),\(i)]: \(crosses[row*maxCol+i].piece)")
                    }
                }
            }
            else {
                for i in (lastCol+1)..<col {
                    if (crosses[row*maxCol+i].piece != Pieces.none) {
                        n += 1
                        print(TAG+"block piece [\(row),\(i)]: \(crosses[row*maxCol+i].piece)")
                    }
                }
            }
        }
        else if (col == lastCol) && (row != lastRow) {
            if (lastRow > row) {
                // for (i = lastRow-1; i > row; i--) {
                for i in (row+1..<lastRow).reversed() {
                    if (crosses[i*maxCol+col].piece != Pieces.none) {
                        n += 1
                        print(TAG+"block piece [\(i),\(col)]: + crosses[i+col].piece");
                    }
                }
            }
            else {
                for i in lastRow+1..<row {
                    if crosses[i*maxCol+col].piece != Pieces.none {
                        n += 1
                        print(TAG+"block piece [\(i),\(col)]: + crosses[i*maxCol+col].piece)")
                    }
                }
            }
        }
        return(n)   //the number of pieces between the current position and last position
    }
    
    func checkKing(crosses: [Cross],row: Int,col: Int,lastRow: Int,lastCol: Int, player: Player) -> Bool {
        print(TAG+"checkKing()")
        var i = 0
        if ((abs(row - lastRow) > 1) || (abs(col - lastCol) > 1)) {
            return (false)
        }
        if ((abs(row - lastRow) < 1) && (abs(col - lastCol) < 1)) {
            return (false)
        }
        switch (player) {
            case Player.red:
                if ((row > 9) || (row < 7) || (col > 5) || (col < 3)) {
                    return (false)
                }
                if (col != lastCol) {
                    i = 0
                    while (crosses[i*maxCol+col].piece != Pieces.bking) && (i != row) {
                        i += 1
                    }
                    if (i == row) {
                        return (true)    //black king is not in the same column
                    }
                    while (i != row) {
                        i += 1
                        if (crosses[i*maxCol+col].piece != Pieces.none) {
                            return (true)
                        }
                    }
                    return (false);    //red king is facing black king
                }
    
            case Player.black:
                if ((row > 2) || (row < 0) || (col > 5) || (col < 3)) {
                    return (false)
                }
                if (col != lastCol) {
                    i = 9
                    while ((crosses[i*maxCol+col].piece != Pieces.rking) && (i != row)) {
                        i -= 1
                    }
                    if (i == row) {
                        return (true);    //red king is not in the same column
                    }
                    while (i != row) {
                        i -= 1
                        if (crosses[i*maxCol+col].piece != Pieces.none) {
                            return (true)
                        }
                    }
                    return (false);    //red king is facing black king
                }
        }
        return (true)
    }
    
    func checkBishop(crosses: [Cross],row: Int,col: Int,lastRow: Int,lastCol: Int, player: Player) -> Bool {
        print(TAG+"checkBishop()")
        
        if ((abs(row - lastRow) != 2) || (abs(col - lastCol) != 2)) {
            return (false)
        }
        switch (player) {
            case Player.red:
                if (row < 5) {
                    return (false)
                }
            case Player.black:
                if (row > 4) {
                    return (false)
                }
        }
        if ((row > lastRow) && (col > lastCol)) {
            if (crosses[(lastRow + 1)*maxCol+(lastCol + 1)].piece != Pieces.none) {
                return (false)
            }
        }
        if ((row > lastRow) && (col < lastCol)) {
            if (crosses[(lastRow + 1)*maxCol+(lastCol - 1)].piece != Pieces.none) {
                return (false)
            }
        }
        if ((row < lastRow) && (col < lastCol)) {
            if (crosses[(lastRow - 1)*maxCol+(lastCol - 1)].piece != Pieces.none) {
                return (false)
            }
        }
        if ((row < lastRow) && (col > lastCol)) {
            if (crosses[(lastRow - 1)*maxCol+(lastCol + 1)].piece != Pieces.none) {
                return (false)
            }
        }
        return (true)
    }
    
    func checkScholar(crosses: [Cross],row: Int,col: Int,lastRow: Int,lastCol: Int, player: Player) -> Bool {
        print(TAG+"checkScholar()")
        if ((abs(row - lastRow) != 1) || (abs(col - lastCol) != 1)) {
            return (false)
        }
        if ((col < 3) || (col > 5)) {
            return (false)
        }
        switch (player) {
            case Player.red:
                if (row < 7) {
                    return (false)
                }
    
            case Player.black:
                if (row > 2) {
                    return (false)
                }
        }
        return (true)
    }
    
    func checkRook(crosses: [Cross],row: Int,col: Int,lastRow: Int,lastCol: Int) ->Bool {
        print(TAG+"checkRook()")
        let n = checkBlock(crosses: crosses, row: row, col: col, lastRow: lastRow, lastCol: lastCol)
        if (n == 0) {
            return (true)
        }
        else {
            return (false);
        }
    }
    
    func checkHorse(crosses: [Cross],row: Int,col: Int,lastRow: Int,lastCol: Int) -> Bool {
        print(TAG+"checkHorse()");
        if ((abs(lastRow - row) == 2)&&(abs(lastCol - col) == 1)) {
            if (lastRow > row) {
                if (crosses[(lastRow - 1)*maxCol+lastCol].piece == Pieces.none) {
                    return (true)
                }
            }
            else {
                if (crosses[(lastRow + 1)*maxCol+lastCol].piece == Pieces.none) {
                    return (true)
                }
            }
        }
        else if ((abs(lastRow - row) == 1)&&(abs(lastCol - col) == 2)) {
            if (lastCol > col) {
                if (crosses[lastRow*maxCol+(lastCol-1)].piece == Pieces.none) {
                    return (true);
                }
            }
            else {
                if (crosses[lastRow*maxCol+(lastCol+1)].piece == Pieces.none) {
                    return (true)
                }
            }
        }
        return(false) //an illegal move, if not above cases
    }
    
    func checkGun(crosses: [Cross],row: Int,col: Int,lastRow: Int,lastCol: Int) ->Bool {
        print(TAG+"checkGun()")
        let n = checkBlock(crosses: crosses,row: row, col:col, lastRow: lastRow, lastCol: lastCol)
        switch (n) {
            case 0:
                if (crosses[row*maxCol+col].piece == Pieces.none) {
                    return (true)
                }
                else {
                    return (false)
                }
            case 1:
                if (crosses[row*maxCol+col].piece != Pieces.none) {
                    return (true)
                }
                else {
                    return (false)
                }
            default:
                return (false)
        }
        return(false) //an illegal move, if not above cases
    }
    
    func checkPawn(crosses: [Cross],row: Int,col: Int,lastRow: Int,lastCol: Int, player: Player) ->Bool {
        print(TAG+"checkPawn()")
        switch (player) {
            case Player.red:
                if ((lastRow - row) == 1) && (col == lastCol) {
                    return (true)    //move ahead one step
                }
                if ((lastRow < 5) && (abs(col - lastCol) == 1) && (lastRow == row)) {
                    return (true);    //move sideway one step if red pawn has acrossed river
                }
    
            case Player.black:
                if (((row - lastRow) == 1) && (col == lastCol)) {
                    return (true)   //move ahead one step
                }
                if ((lastRow > 4) && (abs(col - lastCol) == 1) && (lastRow == row)) {
                    return (true)   //move sideway one step if red pawn has acrossed river
                }
        }
        return(false) //an illegal move, if not above cases
    }
    
    func checkKingFaceToFace(crosses: [Cross], targetRow: Int, targetCol: Int, lastRow: Int, lastCol: Int, player: Player) ->Bool {
        var crosses = crosses //make a mutable local copy to assume the destination situation
        var blackRow = 0
        var blackCol = 0
        var result = false
        print(TAG+"checkKingFaceToFace()")
       
        //to identify bking row and col
        getKingPosition(crosses: crosses, player: Player.black, row: &blackRow, col: &blackCol)
        //blackRow, blackCol points to Pieces.bking

        var redRow = 0
        var redCol = 0
        getKingPosition(crosses: crosses, player: Player.red, row: &redRow, col: &redCol)
        //redRow, redCol point to Pieces.rKing
        if redCol != blackCol {
            print("kings are not face to face")
            result = false    //red king and black king is not in the same column
        }
        else {
            var i = blackRow + 1
            while crosses[i*maxCol+redCol].piece == Pieces.none {
                i += 1
            }
            if i != redRow {
                print("kings are not face to face")
                result = false //there is at least a piece between red king and black king
            }
            else {
                print("kings are face to face")
                result = true    //the red king and black king face to face
            }
        }
        
        return(result)
    }
    
    func checkRookAndGunAttack(crosses: [Cross], player: Player, row: Int, col: Int) -> Bool {
        print(TAG+"checkRookAndGunAttack()")
        var n = 0
        var opponentRook = Pieces.none
        var opponentGun = Pieces.none
        if player == Player.red {
            opponentRook = Pieces.brook
            opponentGun = Pieces.bgun
        }
        else {
            opponentRook = Pieces.rrook
            opponentGun = Pieces.rgun
        }
        //row, col point to Pieces.rking
        //check opponent's rook and gun attacking

        if row < maxRow-1 {
            n = 0
            //for (i = row+1, n = 0; i < maxRow; i++) {
            for i in (row+1)..<maxRow {
                print("check row \(i)")
                if (crosses[i*maxCol+col].piece == opponentRook) && (n == 0) {
                    print("being attaked by \(crosses[row*maxCol+i].piece) at [\(i),\(col)]")
                    return (true)
                }
                if ((crosses[i*maxCol+col].piece == opponentGun) && (n == 1)) {
                    print("being attaked by \(crosses[row*maxCol+i].piece) at [\(i),\(col)]")
                    return (true)
                }
                if (crosses[i*maxCol+col].piece != Pieces.none) {
                    print("found \(crosses[i*maxCol+col].piece) at [\(i),\(col)] ")
                    n += 1
                }
            }
        }
        if (row > 0) {
            n = 0
            //for (i = row - 1, n = 0; i >= 0; i--) {
            for i in (0..<row).reversed() {
                print("check row \(i)")
                if ((crosses[i*maxCol+col].piece == opponentRook) && (n == 0)) {
                    print("being attaked by \(crosses[i*maxCol+col].piece) at [\(i),\(col)]")
                    return (true)
                }
                if ((crosses[i*maxCol+col].piece == opponentGun) && (n == 1)) {
                    print("being attaked by \(crosses[i*maxCol+col].piece) at [\(i),\(col)]")
                    return (true)
                }
                if (crosses[i*maxCol+col].piece != Pieces.none) {
                    print("\(crosses[i*maxCol+col].piece) found at [\(i),\(col)]")
                    n += 1
                }
            }
        }
        if (col < maxCol-1) {
            n = 0
            //for (i = col + 1, n = 0; i <= 8; i++) {
            for i in (col+1)..<(maxCol-1) {
                print("check col \(i)")
                if (crosses[row*maxCol+i].piece == opponentRook) && (n == 0) {
                    print("being attaked by \(crosses[row*maxCol+i].piece) at [\(row),\(i)]")
                    return (true)
                }
                if (crosses[row*maxCol+i].piece == opponentGun) && (n == 1) {
                    print("being attaked by \(crosses[row*maxCol+i].piece) at [\(row),\(i)]")
                    return (true)
                }
                if crosses[row*maxCol+i].piece != Pieces.none {
                    print("\(crosses[row*maxCol+i].piece) found at [\(row),\(i)]")
                    n += 1
                }
            }
        }
        if (col > 0) {
            n = 0
            //for (i = col - 1, n = 0; i >= 0; i--) {
            for i in (0..<col).reversed() {
                print("check col \(i)")
                if (crosses[row*maxCol+i].piece == opponentRook) && (n == 0) {
                    print("being attaked by \(crosses[row*maxCol+i].piece) at [\(row),\(i)]")
                    return (true)
                }
                if (crosses[row*maxCol+i].piece == opponentGun) && (n == 1) {
                    print("being attaked by \(crosses[row*maxCol+i].piece) at [\(row),\(i)]")
                    return (true)
                }
                if crosses[row*maxCol+i].piece != Pieces.none {
                    print("\(crosses[row*maxCol+i].piece) found at [\(row),\(i)]")
                    n += 1
                }
            }
        }
        return(false) //when getting here, there is no attack by opponent's rook or gun
    }
    
    func checkPawnAttack(crosses: [Cross], player: Player, row: Int, col: Int) -> Bool {
        print(TAG+"checkPawnAttack()")
        var opponentPawn = Pieces.none
        if player == Player.red {
            opponentPawn = Pieces.bpawn
        }
        else {
            opponentPawn = Pieces.rpawn
        }
        if (col > 0) {
            if crosses[row*maxCol+col-1].piece == opponentPawn {
                return (true)
            }
        }
        if (col < maxCol-1) {
            if crosses[row*maxCol+col+1].piece == opponentPawn {
                return (true)
            }
        }

        if player == Player.red {
            //check black pawn attacking
            //TODO: if black/red reversed side, the algorithm will be symmetric
            if (row > 0) {
                if crosses[(row-1)*maxCol+col].piece == opponentPawn {
                    return (true)
                }
            }
        }
        else {
            //check red pawn attacking
            if crosses[(row+1)*maxCol+col].piece == opponentPawn {
                return (true)
            }
        }
        return(false)
    }
    
    func checkHorseAttack(crosses: [Cross], player: Player, row: Int, col: Int) -> Bool {
        print(TAG+"checkHorseAttack()")
        var opponentHorse = Pieces.none
        if player == Player.red {
            opponentHorse = Pieces.bhorse
        }
        else {
            opponentHorse = Pieces.rhorse
        }
        //check horse attacking
        if ((row > 0)&&(col > 1)) {
            if (crosses[(row - 1)*maxCol+col - 2].piece == opponentHorse) &&
                (crosses[(row - 1)*maxCol+col - 1].piece == Pieces.none) {
                return (true)
            }
        }
        if (row > 0) && (col < maxCol-2) {
            if (crosses[(row - 1)*maxCol+col + 2].piece == opponentHorse) &&
                (crosses[(row - 1)*maxCol+col + 1].piece == Pieces.none) {
                return (true);
            }
        }
        if (row > 1)&&(col > 0) {
            if (crosses[(row - 2)*maxCol+col - 1].piece == opponentHorse) &&
                (crosses[(row - 1)*maxCol+col - 1].piece == Pieces.none) {
                return (true)
            }
        }
        if (row > 1)&&(col < maxCol - 1) {
            if (crosses[(row - 2)*maxCol+col + 1].piece == opponentHorse) &&
                (crosses[(row - 1)*maxCol+col + 1].piece == Pieces.none) {
                return (true)
            }
        }
        if player == Player.red {
            switch (row) { //TBD: check row and col boundaries...
                case 7:
                    if (crosses[(row + 2)*maxCol+col - 1].piece == opponentHorse) &&
                        (crosses[(row + 1)*maxCol+col - 1].piece == Pieces.none) {
                        return (true)
                    }
                    if (crosses[(row + 2)*maxCol+col + 1].piece == opponentHorse) &&
                        (crosses[(row + 1)*maxCol+col + 1].piece == Pieces.none) {
                        return (true)
                    }
                case 8:
                    if (crosses[(row + 1)*maxCol+col - 2].piece == opponentHorse) &&
                        (crosses[(row + 1)*maxCol+col - 1].piece == Pieces.none) {
                        return (true)
                    }
                    if (crosses[(row + 1)*maxCol+col + 2].piece == opponentHorse) &&
                        (crosses[(row + 1)*maxCol+col + 1].piece == Pieces.none) {
                        return (true)
                    }
                default:
                    //print("row: \(row) not checked")
                   break
            }
        }
        else {
            //check bking
            switch (row) {
            case 1:
                if (crosses[(row-1)*maxCol+col - 2].piece == opponentHorse) &&
                    (crosses[(row-1)*maxCol+col - 1].piece == Pieces.none) {
                    return (true);
                }
                if (crosses[(row-1)*maxCol+col + 2].piece == opponentHorse) &&
                    (crosses[(row-1)*maxCol+col + 1].piece == Pieces.none) {
                    return (true);
                }
            case 2:
                if (crosses[(row-2)*maxCol+col - 1].piece == opponentHorse) &&
                    (crosses[(row-1)*maxCol+col - 1].piece == Pieces.none) {
                    return (true)
                }
                if (crosses[(row-2)*maxCol+col + 1].piece == opponentHorse) &&
                    (crosses[(row-1)*maxCol+col + 1].piece == Pieces.none) {
                    return (true)
                }
            
            default:
                print("row: \(row) not checked")
            }
        }
        return(false)
    }
    
    func underCheck(crosses: [Cross], player: Player) ->Bool {
        var row = 0
        var col = 0

        print(TAG+"underCheck()")

        // identify the location of red king
        getKingPosition(crosses: crosses, player: player, row:&row, col:&col)
            
        if checkRookAndGunAttack(crosses:crosses, player: player, row: row, col: col) {
            print("being attacked by opponent's rook or gun")
            return(true)
        }
        if checkPawnAttack(crosses:crosses, player: player, row: row, col: col) {
            print("being attacked by opponent's pawn")
            return(true)
        }
            
        if checkHorseAttack(crosses:crosses, player: player, row: row, col: col) {
            print("being attacked by opponent's horse")
            return(true)
        }
        return(false) //if not above cases, king is not under attack
    }
    
    //=================================================
    // function name:
    //     CheckMove()
    // description:
    //     check whether the intended move legal or not
    // parameters:
    //     Pos = the target postion
    //     LastPos = the original position
    //       Piece = the piece
    //       Player = Red/Black
    // return:
    //     true = legal move
    //     false = illegal move
    // called by:
    //        1).
    //        2).
    //========================================================
    func checkMove(crosses: [Cross],targetPos: Cross,lastPos: Cross,player: Player, gameOver: inout Bool) ->Bool  {
        //var crosses = crosses
        let lastPiece = lastPos.piece
        let targetPiece = targetPos.piece
        let targetRow = targetPos.row
        let targetCol = targetPos.col
        let lastRow = lastPos.row
        let lastCol = lastPos.col
        var result = false
    
    // conduct the general check first:
    // 1). black king cannot face to the red king (done)
    // 2). long check is not allowed
    // 3). the move should not result in a check
    // 4). should not continue after the king was eaten
        print("checkMove(): \(player),\(lastPiece) from [\(lastRow),\(lastCol)] to [\(targetRow),\(targetCol)] \(targetPiece)")
    
        if gameOver {
            // show a message ?
            print("game over")
            return (false)
        }
        
        //set original pieces and they will be used to recover if the move is illegal
        let originalDestPiece = crosses[targetRow*maxCol+targetCol].piece
        let originalSrcPiece = crosses[lastRow*maxCol+lastCol].piece
        
        //set the assumed move (this should not change the original crosses)
        crosses[targetRow*maxCol+targetCol].piece = crosses[lastRow*maxCol+lastCol].piece
        crosses[lastRow*maxCol+lastCol].piece = Pieces.none
        
        if (checkKingFaceToFace(crosses: crosses, targetRow: targetRow, targetCol: targetCol, lastRow: lastRow, lastCol: lastCol, player: player)) {
            print("King face to face")
        
            //recover the original situation (in case checkMove() has changed it)
            crosses[targetRow*maxCol+targetCol].piece = originalDestPiece
            crosses[lastRow*maxCol+lastCol].piece = originalSrcPiece
            
            return (false);
        }
        //TODO: why crosses were changed even by using a local copy in CheckKingFaceToFace()???
        //print("after checkKingFaceToFace(): \(crosses[lastRow*maxCol+lastCol].piece), \(crosses[targetRow*maxCol+targetCol].piece)")
        
        
        result = underCheck(crosses: crosses,player: player);  //check whether the king is being checked due to this move
    
        //recover the original situation
        crosses[targetRow*maxCol+targetCol].piece = originalDestPiece
        crosses[lastRow*maxCol+lastCol].piece = originalSrcPiece
        
        if (result) {
            print("the move will make own king under check")
            //recover the original situation (in case checkMove() has changed it)
            
            return (false);
        }
    
        
        //TODO: check after this move, whether the opponent king is being checked, and give a warning sound
        
        switch (player) {
            case Player.red:
                if targetPiece.rawValue < Pieces.bking.rawValue //red pieces
                {
                    print(TAG+"should eat own piece")
                    return (false)    //should not eat own pieces
                }
                if (lastPiece.rawValue > Pieces.rscholar.rawValue) {
                    print(TAG+"should not move black piece or a nempty spot")
                    return (false)    //should not move oppoent's pieces
                }
    
            case Player.black:
                if targetPiece.rawValue >= Pieces.bking.rawValue && targetPiece.rawValue <= Pieces.bscholar.rawValue //black pieces
                {
                    print(TAG+"should not eat own piece");
                    return (false)    //should not eat own pieces
                }
                if (lastPiece.rawValue < Pieces.bking.rawValue) {
                    print(TAG+"should not move red piece or an empty spot")
                    return (false);    //should not move oppoent's pieces
                }
        }
        switch (lastPiece) {
        case Pieces.rking:
            fallthrough
        case Pieces.bking:
            result = checkKing(crosses: crosses, row: targetRow, col: targetCol, lastRow: lastRow, lastCol: lastCol, player: player)
        case Pieces.rbishop:
            fallthrough
        case Pieces.bbishop:
            result = checkBishop(crosses: crosses, row: targetRow, col: targetCol, lastRow: lastRow, lastCol: lastCol, player: player);

        case Pieces.rscholar:
            fallthrough
        case Pieces.bscholar:
            result = checkScholar(crosses: crosses, row: targetRow, col: targetCol, lastRow: lastRow, lastCol: lastCol, player: player);
            
        case Pieces.rrook:
            fallthrough
        case Pieces.brook:
            result = checkRook(crosses: crosses, row: targetRow, col: targetCol, lastRow: lastRow, lastCol: lastCol)
            
        case Pieces.rhorse:
            fallthrough
        case Pieces.bhorse:
            result = checkHorse(crosses:crosses, row: targetRow, col: targetCol, lastRow: lastRow, lastCol: lastCol)
    
        case Pieces.rgun:
            fallthrough
        case Pieces.bgun:
            result = checkGun(crosses: crosses, row: targetRow, col: targetCol, lastRow: lastRow, lastCol: lastCol)
    
        case Pieces.rpawn:
            fallthrough
        case Pieces.bpawn:
            result = checkPawn(crosses: crosses, row: targetRow, col: targetCol, lastRow: lastRow, lastCol: lastCol, player: player)
    
        default:
            break
        }
        
        if result {
            if ((player == Player.red && targetPiece == Pieces.bking) ||
                (player == Player.black && targetPiece == Pieces.rking)) {
                gameOver = true
            }
        }
        return(result)
    }
}
