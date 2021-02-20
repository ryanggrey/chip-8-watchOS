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
    private var activeRom: RomName?

    private lazy var platformInputMappingService: WatchInputMappingService = {
        return WatchInputMappingService()
    }()

    private lazy var inputMapper: InputMapper<WatchInputMappingService> = {
        return InputMapper(platformInputMappingService: platformInputMappingService)
    }()

    private lazy var supportedRomService: PlatformSupportedRomService = {
        return PlatformSupportedRomService(inputMappingService: platformInputMappingService)
    }()

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
        let pickerIndex = 0
        romPicker.setSelectedItemIndex(pickerIndex)
        pickerDidSelect(pickerIndex)
    }

    private func setupRenderer() {
        chip8Image.setWidth(chip8ImageSize.width)
        chip8Image.setHeight(chip8ImageSize.height)
    }

    @IBAction func pickerDidSelect(_ index: Int) {
        activeRom = supportedRomService.supportedRoms[index]
        guard let romName = activeRom?.rawValue,
              let romData = NSDataAsset(name: romName)?.data else { return }

        let rom = [Byte](romData)
        let ram = RomLoader.loadRam(from: rom)
        runEmulator(with: ram)
    }

    private var pickerItems: [WKPickerItem] {
        return supportedRomService.supportedRoms.map { createPickerItem(with: $0.rawValue) }
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
        if chip8.shouldPlaySound {
            // TODO: sounds
            WKInterfaceDevice.current().play(.failure)
        }
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
    private func chip8KeyCode(from platformInput: WatchInputCode) -> Int? {
        guard let romName = activeRom,
              let chip8KeyCode = inputMapper.map(platformInput: platformInput, romName: romName)?.rawValue
        else { return nil }

        return chip8KeyCode
    }

    @IBAction func didTapChip8Screen(_ gesture: WKTapGestureRecognizer) {
        guard let chip8KeyCode = chip8KeyCode(from: .screenTap) else { return }

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
        guard let chip8KeyCode = chip8KeyCode(from: .screenTap) else { return }

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
        guard let chip8KeyCode = chip8KeyCode(from: .screenLongPress) else { return }

        // ensure romPicker is no longer focus and that crown controls game
        crownSequencer.focus()
        chip8.handleKeyDown(key: chip8KeyCode)
    }

    private func didEndLongPress() {
        guard let chip8KeyCode = chip8KeyCode(from: .screenLongPress) else { return }

        chip8.handleKeyUp(key: chip8KeyCode)
    }

    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        guard let chip8CodeForCrownUp = chip8KeyCode(from: .crownUp),
              let chip8CodeForCrownDown = chip8KeyCode(from: .crownDown)
        else { return }

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
        guard let chip8CodeForCrownUp = chip8KeyCode(from: .crownUp),
              let chip8CodeForCrownDown = chip8KeyCode(from: .crownDown)
        else { return }

        chip8.handleKeyUp(key: chip8CodeForCrownUp)
        chip8.handleKeyUp(key: chip8CodeForCrownDown)
    }
}
