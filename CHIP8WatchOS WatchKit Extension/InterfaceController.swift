//
//  InterfaceController.swift
//  CHIP8WatchOS WatchKit Extension
//
//  Created by Ryan Grey on 09/02/2021.
//

import WatchKit
import Foundation
import SpriteKit

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var interfaceScene: WKInterfaceSKScene!
    private let scene = SKScene()
    private let bitmapNode = SKShapeNode()
    private let cpuHz: TimeInterval = 1/600
    private var chip8: Chip8!
    private var timer: Timer?

    private func setupScene() {
        let width = self.contentFrame.size.width
        let height = width / 2

        scene.shouldRasterize = true
        scene.size.width = width
        scene.size.height = height
        scene.backgroundColor = .black
        scene.scaleMode = .aspectFit
        //interfaceScene.preferredFramesPerSecond = 10
        interfaceScene.presentScene(scene)

        bitmapNode.strokeColor = .white
        bitmapNode.fillColor = .white
        bitmapNode.lineWidth = 1
        bitmapNode.lineCap = .round
        bitmapNode.position = CGPoint.zero
        scene.addChild(bitmapNode)
    }

    private func runEmulator(with rom: [Byte]) {
        var chipState = ChipState()
        chipState.ram = rom

        self.chip8 = Chip8(
            state: chipState,
            cpuHz: cpuHz
        )
        timer = Timer.scheduledTimer(
            timeInterval: cpuHz,
            target: self,
            selector: #selector(self.timerFired),
            userInfo: nil,
            repeats: true
        )
    }

    @objc private func timerFired() {
        chip8.cycle()
        render(screen: chip8.screen)
        // TODO: sounds
    }

    private func createPath(from screen: Chip8Screen) -> CGPath {
        let path = CGMutablePath()

        let viewWidth = scene.size.width
        let viewHeight = scene.size.height
        let pixelWidth = round(viewWidth / CGFloat(screen.size.width))
        let pixelHeight = round(viewHeight / CGFloat(screen.size.height))
        let pixelSize = CGSize(width: pixelWidth, height: pixelHeight)

        let xRange = 0..<screen.size.width
        let yRange = 0..<screen.size.height
        for x in xRange {
            for y in yRange {
                let pixelAddress = y * screen.size.width + x
                guard screen.pixels[pixelAddress] == 1 else {
                    // skip if we're not meant to draw pixel
                    continue
                }

                let xCoord = CGFloat(x) * pixelSize.width
                let yCoord = viewHeight - (CGFloat(y) * pixelSize.height)
                let origin = CGPoint(x: xCoord, y: yCoord)
                let frame = CGRect(origin: origin, size: pixelSize)
                path.addRect(frame)
            }
        }
        return path
    }

    private func render(screen: Chip8Screen) {
        let path = createPath(from: screen)
        bitmapNode.path = path
    }

    override func awake(withContext context: Any?) {
        setupScene()
        let rom = [Byte](NSDataAsset(name: "Maze [David Winter, 199x]")!.data)
        let ram = RomLoader.loadRam(from: rom)
        runEmulator(with: ram)
    }
    
    override func willActivate() {
    }
    
    override func didDeactivate() {
    }

}
