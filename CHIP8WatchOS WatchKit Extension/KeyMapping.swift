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
    static let airplane: KeyMapping = [
        .screenTap : .eight
    ]

    static let astroDodge: KeyMapping = [
        .screenTap : .five,
        .crownDown : .four,
        .crownUp : .six
    ]

    static let breakout: KeyMapping = [
        .crownDown : .four,
        .crownUp : .six
    ]

    static let filter: KeyMapping = Self.breakout

    static let landing: KeyMapping = [
        .screenTap : .eight
    ]

    static let lunarLanding: KeyMapping = [
        .screenTap : .two,
        .crownDown : .four,
        .crownUp : .six
    ]

    static let missile: KeyMapping = [
        .screenTap : .eight
    ]

    static let none: KeyMapping = [:]

    static let pong: KeyMapping = [
        .crownDown : .four,
        .crownUp : .one
    ]

    static let rocket: KeyMapping = [
        .screenTap : .f
    ]

    static let spaceInvaders: KeyMapping = [
        .screenTap : .five,
        .crownDown : .four,
        .crownUp : .six
    ]

    static let tetris: KeyMapping = [
        .screenLongPress : .seven,
        .screenTap : .four,
        .crownDown : .five,
        .crownUp : .six
    ]
}
