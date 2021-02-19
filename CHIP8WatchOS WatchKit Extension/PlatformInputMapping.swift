//
//  PlatformInputMapping.swift
//  CHIP8WatchOS WatchKit Extension
//
//  Created by Ryan Grey on 19/02/2021.
//

import Foundation

typealias PlatformInputMapping = [WatchInputCode : SemanticInputCode]

/*
 Controls must map to crownUp, crownDown and screenTap only.
 If a game requires more than these 3 inputs then it is not
 playable on watchOS. This makes it ideal for games with one
 dimension of movement and an action.
 */

extension PlatformInputMapping {
    static let airplane: PlatformInputMapping = [
        .screenTap : .primaryAction
    ]

    static let astroDodge: PlatformInputMapping = [
        .screenTap : .primaryAction,
        .crownDown : .left,
        .crownUp : .right
    ]

    static let breakout: PlatformInputMapping = [
        .crownDown : .left,
        .crownUp : .right
    ]

    static let filter: PlatformInputMapping = Self.breakout

    static let landing: PlatformInputMapping = [
        .screenTap : .primaryAction
    ]

    static let lunarLanding: PlatformInputMapping = [
        .screenTap : .primaryAction,
        .crownDown : .left,
        .crownUp : .right
    ]

    static let missile: PlatformInputMapping = [
        .screenTap : .primaryAction
    ]

    static let none: PlatformInputMapping = [:]

    static let pong: PlatformInputMapping = [
        .crownDown : .down,
        .crownUp : .up
    ]

    static let rocket: PlatformInputMapping = [
        .screenTap : .primaryAction
    ]

    static let spaceInvaders: PlatformInputMapping = [
        .screenTap : .primaryAction,
        .crownDown : .left,
        .crownUp : .right
    ]

    static let tetris: PlatformInputMapping = [
        .screenLongPress : .secondaryAction,
        .screenTap : .primaryAction,
        .crownDown : .left,
        .crownUp : .right
    ]

    static let wipeOff: PlatformInputMapping = breakout
}
