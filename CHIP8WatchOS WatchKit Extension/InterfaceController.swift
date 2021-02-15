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
    @IBOutlet weak var chip8Image: WKInterfaceImage!
    @IBOutlet weak var romPicker: WKInterfacePicker!
    private var chip8: Chip8!
    private var cpuTimer: Timer?
    private let cpuHz: TimeInterval = 1/600
    private var displayTimer: Timer?
    private let displayHz: TimeInterval = 1/30
    private var activeRomConfiguration: RomConfiguration?

    private let romConfigurations = [
        RomConfiguration(romName: RomName.airplane, mapping: KeyMapping.airplane),
        RomConfiguration(romName: RomName.astroDodge, mapping: KeyMapping.astroDodge),
        RomConfiguration(romName: RomName.breakout, mapping: KeyMapping.breakout),
        RomConfiguration(romName: RomName.filter, mapping: KeyMapping.filter),
        RomConfiguration(romName: RomName.landing, mapping: KeyMapping.landing),
        RomConfiguration(romName: RomName.lunarLander, mapping: KeyMapping.lunarLanding),
        RomConfiguration(romName: RomName.maze, mapping: KeyMapping.none),
        RomConfiguration(romName: RomName.missile, mapping: KeyMapping.missile),
        RomConfiguration(romName: RomName.pong, mapping: KeyMapping.pong),
        RomConfiguration(romName: RomName.rocket, mapping: KeyMapping.rocket),
        RomConfiguration(romName: RomName.spaceInvaders, mapping: KeyMapping.spaceInvaders),
        RomConfiguration(romName: RomName.tetris, mapping: KeyMapping.tetris),
        RomConfiguration(romName: RomName.wipeOff, mapping: KeyMapping.wipeOff)
    ]

    private var chip8ImageSize: CGSize {
        let width = contentFrame.size.width
        let height = contentFrame.size.width / 2
        return CGSize(width: width, height: height)
    }

    override func didAppear() {
        super.didAppear()
        crownSequencer.delegate = self
        crownSequencer.focus()
        setupRenderer()
        setupPicker()
    }

    private func setupPicker() {
        romPicker.setItems(self.pickerItems)
        romPicker.setSelectedItemIndex(self.pickerItems.count - 1)
    }

    private func setupRenderer() {
        chip8Image.setWidth(chip8ImageSize.width)
        chip8Image.setHeight(chip8ImageSize.height)
    }

    @IBAction func pickerDidSelect(_ index: Int) {
        activeRomConfiguration = self.romConfigurations[index]
        guard let romName = activeRomConfiguration?.romName,
              let romData = NSDataAsset(name: romName)?.data else { return }

        let rom = [Byte](romData)
        let ram = RomLoader.loadRam(from: rom)
        runEmulator(with: ram)
    }

    private var pickerItems: [WKPickerItem] {
        return romConfigurations.map { createPickerItem(with: $0.romName) }
    }

    private func createPickerItem(with title: String) -> WKPickerItem {
        let item = WKPickerItem()
        item.title = title
        return item
    }

    private func runEmulator(with rom: [Byte]) {
        setupChip8(with: rom)
        startCpu()
        startRendering()
    }

    private func startCpu() {
        cpuTimer?.invalidate()
        cpuTimer = nil

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
        displayTimer?.invalidate()
        displayTimer = nil

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
            containerSize: chip8ImageSize,
            isYReversed: false
        )
        render(path: path)
    }

    private func render(path: CGPath) {
        guard let context = createPixelContext(color: .white) else { return }
        context.addPath(path)
        context.fillPath()

        guard let cgImage = context.makeImage() else { return }
        let image = UIImage(cgImage: cgImage)
        chip8Image.setImage(image)
    }

    private func createPixelContext(color: UIColor) -> CGContext? {
        UIGraphicsBeginImageContext(chip8ImageSize)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        UIGraphicsEndImageContext()

        context.setShouldAntialias(false)
        context.setLineWidth(1.0)
        context.setLineJoin(.bevel)
        context.setLineCap(.square)
        context.setStrokeColor(color.cgColor)
        context.setFillColor(color.cgColor)

        return context
    }
}

// Handle User Gestures
extension InterfaceController: WKCrownDelegate {
    @IBAction func didTapChip8Screen(_ gesture: WKTapGestureRecognizer) {
        guard let keyMapping = activeRomConfiguration?.mapping,
              let chip8KeyCode = keyMapping[.screenTap]?.rawValue else { return }

        // ensure romPicker is no longer focus and that crown controls game
        crownSequencer.focus()

        chip8.handleKeyDown(key: chip8KeyCode)

        /*
         tap gestures are discrete/atomic and there appears to
         be no way be notified of imtermediary gesture state such
         as touchDown, touchUp etc. This means we need to simulate
         the touchUp event so that Chip8 doesn't end up thinking a
         key has been pressed and never released
         */
        Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(self.didEndTap),
            userInfo: nil,
            repeats: false
        )
    }

    @objc private func didEndTap() {
        guard let keyMapping = activeRomConfiguration?.mapping,
              let chip8KeyCode = keyMapping[.screenTap]?.rawValue else { return }

        chip8.handleKeyUp(key: chip8KeyCode)
    }

    @IBAction func didLongPressChip8Screen(_ gesture: WKLongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            didBeginLongPress()
            return
        case .ended:
            didEndLongPress()
            return
        case .failed:
            didEndLongPress()
            return
        default:
            return
        }
    }

    private func didBeginLongPress() {
        guard let keyMapping = activeRomConfiguration?.mapping,
              let chip8KeyCode = keyMapping[.screenLongPress]?.rawValue else { return }

        // ensure romPicker is no longer focus and that crown controls game
        crownSequencer.focus()
        chip8.handleKeyDown(key: chip8KeyCode)
    }

    private func didEndLongPress() {
        guard let keyMapping = activeRomConfiguration?.mapping,
              let chip8KeyCode = keyMapping[.screenLongPress]?.rawValue else { return }

        chip8.handleKeyUp(key: chip8KeyCode)
    }

    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        guard let keyMapping = activeRomConfiguration?.mapping,
              let chip8CodeForCrownUp = keyMapping[.crownUp]?.rawValue,
              let chip8CodeForCrownDown = keyMapping[.crownDown]?.rawValue else { return }

        /*
         rotationalDelta should give us - sign for down direction
         and + sign for up direction. However +0 appears to happen
         as the initial value for for _both_ up and down crown
         directions. This is why we're avoiding 0 in the below
         `if/elseif`.
         */

        if rotationalDelta < 0 {
            // ensure previous direction released
            chip8.handleKeyUp(key: chip8CodeForCrownUp)

            // activate new direction
            chip8.handleKeyDown(key: chip8CodeForCrownDown)
        } else if rotationalDelta > 0 {
            // ensure previous direction released
            chip8.handleKeyUp(key: chip8CodeForCrownDown)

            // activate new direction
            chip8.handleKeyDown(key: chip8CodeForCrownUp)
        }
    }

    func crownDidBecomeIdle(_ crownSequencer: WKCrownSequencer?) {
        guard let keyMapping = activeRomConfiguration?.mapping,
              let chip8CodeForCrownUp = keyMapping[.crownUp]?.rawValue,
              let chip8CodeForCrownDown = keyMapping[.crownDown]?.rawValue else { return }

        chip8.handleKeyUp(key: chip8CodeForCrownUp)
        chip8.handleKeyUp(key: chip8CodeForCrownDown)
    }
}
