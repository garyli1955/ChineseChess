//
//  ViewController.swift
//  ChineseChess
//
//  Created by Gary Li on 2/17/18.
//  Copyright © 2018 Gary Li. All rights reserved.
//

import UIKit
import AVFoundation
import CoreBluetooth

enum Player {
    case red
    case black
}

let maxRow = 10 //the number of rows on the board
let maxCol = 9  //the number of column on the board

class ViewController: UIViewController {
    
    let TAG = "ViewController: "
    
    //initial piece positions of a game (reverse order if red/black change side
    
    var pieces: [Pieces] =
    [Pieces.brook, Pieces.bhorse, Pieces.bbishop,Pieces.bscholar,Pieces.bking,Pieces.bscholar,Pieces.bbishop,Pieces.bhorse,Pieces.brook,
    Pieces.none,  Pieces.none,  Pieces.none,   Pieces.none,    Pieces.none, Pieces.none,    Pieces.none,   Pieces.none,  Pieces.none,
    Pieces.none,  Pieces.bgun,  Pieces.none,   Pieces.none,    Pieces.none, Pieces.none,    Pieces.none,   Pieces.bgun,  Pieces.none,
    Pieces.bpawn, Pieces.none,  Pieces.bpawn,  Pieces.none,    Pieces.bpawn,Pieces.none,    Pieces.bpawn,  Pieces.none,  Pieces.bpawn,
    Pieces.none,  Pieces.none,  Pieces.none,   Pieces.none,    Pieces.none, Pieces.none,    Pieces.none,   Pieces.none,  Pieces.none,
    Pieces.none,  Pieces.none,  Pieces.none,   Pieces.none,    Pieces.none, Pieces.none,    Pieces.none,   Pieces.none,  Pieces.none,
    Pieces.rpawn, Pieces.none,  Pieces.rpawn,  Pieces.none,    Pieces.rpawn,Pieces.none,    Pieces.rpawn,  Pieces.none,  Pieces.rpawn,
    Pieces.none,  Pieces.rgun,  Pieces.none,   Pieces.none,    Pieces.none, Pieces.none,    Pieces.none,   Pieces.rgun,  Pieces.none,
    Pieces.none,  Pieces.none,  Pieces.none,   Pieces.none,    Pieces.none, Pieces.none,    Pieces.none,   Pieces.none,  Pieces.none,
    Pieces.rrook, Pieces.rhorse,Pieces.rbishop,Pieces.rscholar,Pieces.rking,Pieces.rscholar,Pieces.rbishop,Pieces.rhorse,Pieces.rrook
    ]
    
    //TODO: use these two array to check whether a piece is a red one or a black one
    let RedPieces = [Pieces.rking,Pieces.rrook,Pieces.rgun,Pieces.rhorse,Pieces.rbishop,Pieces.rscholar,Pieces.rpawn]
    let BlackPieces = [Pieces.bking,Pieces.brook,Pieces.bgun,Pieces.bhorse,Pieces.bbishop,Pieces.bscholar,Pieces.bpawn]
   
    
    let xMargin = 5 //the starting pixel of the board image in X coordinator
    let yMargin = 120 //the starting pixel of the board image in Y coordinator
    
    let xUnit = 37
    let yUnit = 37
    let xGap = 3
    let yGap = 3
    
    //the crosses on the board, each cross may have a piece
    //var crosses = [Cross?](repeating: nil, count: maxRow*maxCol)
    var crosses: [Cross] = []
    var checkMove = CheckMove()
    
    let viewTagBoard = 100    //view tag for the board image
    let viewTagCursor = 101   //view tag for the cursor image
    let viewTagBase = 1       //view tag cannot be zero
    var playerPieceTapped: AVAudioPlayer!
    var playerWrongMove: AVAudioPlayer!
    
    var gameOver = true //set as false after startClicked()
    var lock = false
    var turn = Player.red
    var computerSide = Player.black
    var humanSide = Player.red
    var focus = false //if the first piece is selected, the focus will be set as true, otherwise set as false
    var timerCountRed = 20*60 //default set 20 min each
    var timerCountBlack = 20*60
    var timerGame = Timer()
    var initialCross = Cross()
    var lastCross = Cross()
    
    @IBOutlet weak var buttonReset: UIButton!
    @IBOutlet weak var buttonStart: UIButton!
    @IBOutlet weak var buttonReverse: UIButton!
    
    @IBOutlet weak var labelMsg: UILabel!
    
    @IBAction func resetClicked(_ sender: UIButton) {
        print("resetClicked()")
        playerPieceTapped.play() //play a sound as button clicked
        buttonReverse.isEnabled = true
        buttonStart.isEnabled = true
        newGame()
    }
    
    @IBAction func startClicked(_ sender: UIButton) {
        print("startClicked()")
        playerPieceTapped.play() //play a sound as button clicked
        gameOver = false
        buttonReverse.isEnabled = false
        buttonStart.isEnabled = false
        labelMsg.text = "Red Turn"
        //TODO: start the timer of red side (the side to take the first move)
        
    }
    
    @IBAction func reserveClicked(_ sender: UIButton) {
        print("reserverClicked()")
        playerPieceTapped.play() //play a sound as button clicked
        //red/black reserses side
        removeAllPieces()
        reserseSide()
        showAllPieces()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        print("screen width: \(screenWidth), screen height: \(screenHeight)")
        
        //prepare sound for a card tapped
        var path = Bundle.main.path(forResource: "flipcard", ofType: "wav")!
        var url = URL(fileURLWithPath: path)
        do {
            playerPieceTapped = try AVAudioPlayer(contentsOf: url)
            playerPieceTapped.prepareToPlay()
        } catch let error as NSError {
            print(error.description)
        }
        
        path = Bundle.main.path(forResource: "wrong_move", ofType: "WAV")!
        url = URL(fileURLWithPath: path)
        do {
            playerWrongMove = try AVAudioPlayer(contentsOf: url)
            playerWrongMove.prepareToPlay()
        } catch let error as NSError {
            print(error.description)
        }
        
        //create an array of crosses to store information for every cross on the board
        for row in 0..<maxRow {
            for col in 0..<maxCol {
                let cross = Cross()
                crosses.append(cross)
                crosses[row*maxCol+col].row = row
                crosses[row*maxCol+col].col = col
                crosses[row*maxCol+col].x = xMargin + col*(xUnit+xGap)
                crosses[row*maxCol+col].y = yMargin + row*(yUnit+yGap)
                crosses[row*maxCol+col].viewTag = row*maxCol+col+viewTagBase
            }
        }
        
        //assign the pieces to the initial positions for every cross
        showBoard()
        newGame()
    }

    
    
    //tap event handler (if any card has been tapped)
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        print("\t\n"+TAG+"imageTapped()")
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        let tag = tappedImage.tag //get UIImage tag with which to get the card instance
        print("tag:\(tag)")
        //view tags for pieces starts from viewTagBase, a none zero value
        if tag >= viewTagBase { //a piece image was tapped
            if gameOver == false { //process this event only when game is not over
                let cross = crosses[tag - viewTagBase]
                if focus == false { //non piece has been selected yet
                    //get the UIImage user tapped
                    print("initial piece: \(cross.piece),row:\(String(describing: cross.row)),col:\(String(describing: cross.col))")
                    if (turn == Player.red && RedPieces.contains((cross.piece))) ||
                        (turn == Player.black && BlackPieces.contains((cross.piece))) {
                        //the cross has a piece in an expected player
                        
                        focus = true
                        playerPieceTapped.play() //play a sound of a card tapped
                        removeCursor() //remove cursor of last move
                        showCursor(x: (cross.x), y: (cross.y))
                        initialCross = cross //remember the source cross
                    }
                    else {
                        print("no piece on the cross, or not your pieces")
                        playerWrongMove.play()
                    }
                }
                else {
                    //the destination cross (the second tab after focus was set) has been tabbed
                    focus = false
                    removeCursor()
                    //print("before checkMove(): \(initialCross.piece), \(String(describing: cross.piece))")
                    
                    
                    if checkMove.checkMove(crosses: crosses , targetPos: cross, lastPos: initialCross, player: turn, gameOver: &gameOver) {
                        //print("after checkMove(): \(initialCross.piece), \(String(describing: cross.piece))")
                        
                        //a legal move
                        
                        //remove the image on initialCross
                        removePiece(cross: cross) //remove the UIImage in destination cross
                        removePiece(cross: initialCross) //remove the UIImage in initial cross
                        //set destination cross based on initialCross
                        cross.imageName = initialCross.imageName //assign the UIImage in intial cross to destination cross
                        cross.piece = initialCross.piece
                        //set initialCross as none
                        initialCross.imageName = "none" //assign none piece to initial cross
                        initialCross.piece = Pieces.none
                        
                        lastCross = cross //remember last cross (it will be needed to remove cursor at next step
                        showPiece(cross: cross) //show the piece in new cross/location
                        showPiece(cross: initialCross) //show none in initial cross
                        showCursor(x:(cross.x),y:(cross.y))
                        if (gameOver == false) {
                            if turn == Player.red {
                                labelMsg.text = "Black Turn"
                                turn = Player.black
                            }
                            else {
                                labelMsg.text = "Red Turn"
                                turn = Player.red
                            }
                        }
                        playerPieceTapped.play() //play a sound of a card tapped
                    }
                    else {
                        //print("after checkMove(): \(initialCross.piece), \(String(describing: cross.piece))")
                        showCursor(x:(initialCross.x),y:(initialCross.y))
                        playerWrongMove.play()
                    }
            
                }
            }
            else {
                print("Please click start game")
                playerWrongMove.play()
            }
        }
        else {
            print("invalid action, since lockCards is on or game is over")
        }
    }

    func newGame() {
        print("newGame()")
        //delete pieces if there is any
        removeAllPieces()
        initAllPieces()
        showAllPieces()
        turn = Player.red
        computerSide = Player.black
        humanSide = Player.red
        focus = false
        labelMsg.text = "click Start to time the game"
    }
    
    func showBoard() {
        print("showBoard()")
        //display chess board
        let image = UIImage(named: "board256")!
        let imageViewBoard = UIImageView(image: image)
        imageViewBoard.contentMode = .scaleAspectFill //fill the card image size into specified demension
        imageViewBoard.frame.size = CGSize(width:maxCol*(xUnit+xGap), height:maxRow*(yUnit+yGap)) //set the size of image view
        imageViewBoard.frame.origin = CGPoint(x:xMargin, y:yMargin)
        imageViewBoard.tag = viewTagBoard
        self.view.addSubview(imageViewBoard)
    }
    
    func initAllPieces() {
        print(TAG+"initAllPieces()")
        for row in 0..<maxRow {
            for col in 0..<maxCol {
                crosses[row*maxCol+col].piece = pieces[row*maxCol+col]
                crosses[row*maxCol+col].imageName = imageFiles[pieces[row*maxCol+col].rawValue]
                print("[\(row),\(col)],\(crosses[row*maxCol+col].piece),tag:\(crosses[row*maxCol+col].viewTag)")
            }
        }
    }
    
    func showAllPieces() {
        print("showAllPices()")
        for row in 0..<maxRow {
            for col in 0..<maxCol {
                let cross = crosses[row*maxCol+col]
                cross.viewTag = row*maxCol+col+viewTagBase //remember the viewTag in Card instance
                let image = UIImage(named: (cross.imageName!))! //TODO: add catch {} in case the file does not exist
                let imageView: UIImageView = UIImageView(image: image) //create an image view to hold the image
                imageView.tag = row*maxCol+col+viewTagBase //set the view tag for future retrieval
           
                imageView.contentMode = .scaleAspectFill //fill the card image size into specified demension
                imageView.frame.size = CGSize(width:xUnit, height:yUnit) //set the size of image view
                imageView.frame.origin = CGPoint(x:(cross.x), y:(cross.y))
            
                //enable capture
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(tapGesture)
            
                self.view.addSubview(imageView)
            }
        }
    }
    
    func removeAllPieces() {
        print("deleteBoardPieces()")
        //clear board and pieces (assuming viewTag starts from viewTagBase (starts from non-zero value)
        for i in 0..<crosses.count {
            removePiece(cross: crosses[i])
        }
        if let viewWithTag = self.view.viewWithTag(viewTagCursor) as? UIImageView {
            viewWithTag.removeFromSuperview()
        }
    }
    
    func removePiece(cross: Cross) {
        let tag = cross.viewTag
        if let viewWithTag = self.view.viewWithTag(tag) as? UIImageView {
            print("removePiece():[\(cross.row),\(cross.col)],\(imageFiles[cross.piece.rawValue]),tag:\(cross.viewTag) removed")
            viewWithTag.removeFromSuperview()
        }
    }
    
    func showCursor(x: Int, y: Int) {
        print("showCursor()")
        let image = UIImage(named: "cursor")! //TODO: add catch {} in case the file does not exist
        let imageView: UIImageView = UIImageView(image: image) //create an image view to hold the image
        imageView.tag = viewTagCursor //set the view tag for future retrieval
        
        imageView.contentMode = .scaleAspectFill //fill the card image size into specified demension
        imageView.frame.size = CGSize(width:xUnit, height:yUnit) //set the size of image view
        imageView.frame.origin = CGPoint(x:x, y:y)
        
        self.view.addSubview(imageView)
    }
    
    func removeCursor() {
        print("removeCursor()")
        if let viewWithTag = self.view.viewWithTag(viewTagCursor) as? UIImageView {
            print("cursor removed")
            viewWithTag.removeFromSuperview()
        }
        else {
            print("no cursor to remove")
        }
    }
    
    func showPiece(cross: Cross) {
        print("showPiece(): [\(cross.row),\(cross.col)],\(imageFiles[cross.piece.rawValue]),tag:\(cross.viewTag)")
        let image = UIImage(named: cross.imageName!)! //TODO: add catch {} in case the file does not exist
        let imageView: UIImageView = UIImageView(image: image) //create an image view to hold the image
        imageView.tag = cross.viewTag //set the view tag for future retrieval
        
        imageView.contentMode = .scaleAspectFill //fill the card image size into specified demension
        imageView.frame.size = CGSize(width:xUnit, height:yUnit) //set the size of image view
        imageView.frame.origin = CGPoint(x:cross.x, y:cross.y)
        
        //enable capture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        
        self.view.addSubview(imageView)
    }
    
    func reserseSide() {
        print("reverseSide()")
        //remove all pieces from the board
        if humanSide == Player.red {
            humanSide = Player.black
            computerSide = Player.red
        }
        else {
            humanSide = Player.red
            computerSide = Player.black
        }
        //reverse pieces array
        for i in 0..<pieces.count/2 {
            let pieceTmp = pieces[i]
            pieces[i] = pieces[maxRow*maxCol-1-i]
            pieces[maxRow*maxCol-1-i] = pieceTmp
        }
        //set the pieces with new order in crosses array
        for row in 0..<maxRow {
            for col in 0..<maxCol {
                crosses[row*maxCol+col].imageName = imageFiles[row*maxCol+col]
                print("row:\(row),col:\(col):"+imageFiles[row*maxCol+col])
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

