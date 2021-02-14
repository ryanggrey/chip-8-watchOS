//
//  KeyMapping.swift
//  CHIP-8
//
//  Created by Ryan Grey on 14/02/2021.
//

import Foundation
import Chip8Emulator

typealias KeyMapping = [WatchInputCode : Chip8KeyCode]

/*
 Controls must map to crownUp, crownDown and screenTap only.
 If a game requires more than these 3 inputs then it is not
 playable on watchOS. This makes it ideal for games with one
 dimension of movement and an action.
 */

extension KeyMapping {
    static var invaders: KeyMapping {
        return [
            .screenTap : .five,
            .crownDown : .four,
            .crownUp : .six
        ]
    }

    static var breakout: KeyMapping {
        return [
            .crownDown : .four,
            .crownUp : .six
        ]
    }

    static var pong: KeyMapping {
        return [
            .crownDown : .four,
            .crownUp : .one
        ]
    }
}
