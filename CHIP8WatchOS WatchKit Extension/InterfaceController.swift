//
//  InterfaceController.swift
//  CHIP8WatchOS WatchKit Extension
//
//  Created by Ryan Grey on 09/02/2021.
//

import WatchKit
import Foundation
import SpriteKit
import Chip8Emulator

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var interfaceScene: WKInterfaceSKScene!
    private var chip8: Chip8!
    private let scene = SKScene()
    private let bitmapNode = SKShapeNode()
    private var cpuTimer: Timer?
    private let cpuHz: TimeInterval = 1/600
    private var displayTimer: Timer?
    private let displayHz: TimeInterval = 1/30

    override func awake(withContext context: Any?) {
        setupScene()
        let rom = [Byte](NSDataAsset(name: RomName.spaceInvaders)!.data)
        let ram = RomLoader.loadRam(from: rom)
        runEmulator(with: ram)
    }

    override func didAppear() {
        super.didAppear()
        crownSequencer.delegate = self
        crownSequencer.focus()
    }

    private func setupScene() {
        let width = self.contentFrame.size.width
        let height = width / 2

        scene.shouldRasterize = true
        scene.size.width = width
        scene.size.height = height
        scene.backgroundColor = .black
        scene.scaleMode = .aspectFit
        interfaceScene.presentScene(scene)

        bitmapNode.strokeColor = .white
        bitmapNode.fillColor = .white
        bitmapNode.lineWidth = 1
        bitmapNode.lineCap = .round
        bitmapNode.position = CGPoint.zero
        
        scene.addChild(bitmapNode)
    }

    private func runEmulator(with rom: [Byte]) {
        setupChip8(with: rom)
        startCpu()
        startRendering()
    }

    private func startCpu() {
        cpuTimer = Timer.scheduledTimer(
            timeInterval: cpuHz,
            target: self,
            selector: #selector(self.cpuTimerFired),
            userInfo: nil,
            repeats: true
        )
        RunLoop.current.add(cpuTimer!, forMode: .common)
    }

    @objc private func cpuTimerFired() {
        chip8.cycle()
        // TODO: sounds
    }

    private func startRendering() {
        displayTimer = Timer.scheduledTimer(
            timeInterval: displayHz,
            target: self,
            selector: #selector(self.displayTimerFired),
            userInfo: nil,
            repeats: true
        )
    }

    @objc private func displayTimerFired() {
        if chip8.needsRedraw {
            render(screen: chip8.screen)
            chip8.needsRedraw = false
        }
    }

    private func setupChip8(with rom: [Byte]) {
        var chipState = ChipState()
        chipState.ram = rom
        self.chip8 = Chip8(
            state: chipState,
            cpuHz: cpuHz
        )
    }

    private func render(screen: Chip8Screen) {
        let path = PathFactory.from(
            screen: screen,
            containerSize: scene.size
        )
        bitmapNode.path = path
    }
}

// Handle User Gestures
extension InterfaceController: WKCrownDelegate {
    @IBAction func didTap(_ sender: Any) {
        /*
         watchOS gestures are discrete/atomic and there appears to
         be no way be notified of imtermediary gesture state such
         as touchDown, touchUp etc. This means we need to simulate
         the touchUp event so that Chip8 doesn't end up thinking a
         key has been pressed and never released
         */

        chip8.handleKeyDown(key: Chip8KeyCode.five.rawValue)
        Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(self.didEndTap),
            userInfo: nil,
            repeats: false
        )
    }

    @objc private func didEndTap() {
        chip8.handleKeyUp(key: Chip8KeyCode.five.rawValue)
    }

    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        /*
         rotationalDelta should give us - sign for down direction
         and + sign for up direction. However +0 appears to happen
         as the initial value for for _both_ up and down crown
         directions. This is why we're avoiding 0 in the below
         `if/elseif`.
         */

        if rotationalDelta < 0 {
            // ensure previous direction released
            chip8.handleKeyUp(key: Chip8KeyCode.six.rawValue)

            // activate new direction
            chip8.handleKeyDown(key: Chip8KeyCode.four.rawValue)
        } else if rotationalDelta > 0 {
            // ensure previous direction released
            chip8.handleKeyUp(key: Chip8KeyCode.four.rawValue)

            // activate new direction
            chip8.handleKeyDown(key: Chip8KeyCode.six.rawValue)
        }
    }

    func crownDidBecomeIdle(_ crownSequencer: WKCrownSequencer?) {
        chip8.handleKeyUp(key: Chip8KeyCode.four.rawValue)
        chip8.handleKeyUp(key: Chip8KeyCode.six.rawValue)
    }
}
