//
//  RomPlatformInput.swift
//  CHIP8WatchOS WatchKit Extension
//
//  Created by Ryan Grey on 19/02/2021.
//

import Foundation
import Chip8Emulator

struct PlatformInputMappingService {
    static private let mapping: [RomName : PlatformInputMapping] = [
        .chip8 : .none,
        .airplane : .airplane,
        .astroDodge: .astroDodge,
        .breakout: .breakout,
        .filter : .filter,
        .landing : .landing,
        .lunarLander : .lunarLanding,
        .maze : .none,
        .missile : .missile,
        .pong : .pong,
        .rocket : .rocket,
        .spaceInvaders : .spaceInvaders,
        .tetris : .tetris,
        .wipeOff : .wipeOff
    ]

    static func mapping(for romName: RomName) -> PlatformInputMapping? {
        return mapping[romName]
    }
}
