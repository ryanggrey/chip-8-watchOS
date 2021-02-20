//
//  RomPlatformInput.swift
//  CHIP8WatchOS WatchKit Extension
//
//  Created by Ryan Grey on 19/02/2021.
//

import Foundation
import Chip8Emulator

typealias PlatformMapping = [WatchInputCode : SemanticInputCode]

struct WatchInputMappingService {
    private let mapping: [RomName : PlatformMapping] = [
        .chip8 : [:],
        .airplane : [
            .screenTap : .primaryAction
        ],
        .astroDodge: [
            .screenTap : .primaryAction,
            .crownDown : .left,
            .crownUp : .right
        ],
        .breakout: [
            .crownDown : .left,
            .crownUp : .right
        ],
        .filter : [
            .crownDown : .left,
            .crownUp : .right
        ],
        .landing : [
            .screenTap : .primaryAction
        ],
        .lunarLander : [
            .screenTap : .primaryAction,
            .crownDown : .left,
            .crownUp : .right
        ],
        .maze : [:],
        .missile : [
            .screenTap : .primaryAction
        ],
        .pong : [
            .crownDown : .down,
            .crownUp : .up
        ],
        .rocket : [
            .screenTap : .primaryAction
        ],
        .spaceInvaders : [
            .screenTap : .primaryAction,
            .crownDown : .left,
            .crownUp : .right
        ],
        .tetris : [
            .screenLongPress : .secondaryAction,
            .screenTap : .primaryAction,
            .crownDown : .left,
            .crownUp : .right
        ],
        .wipeOff : [
            .crownDown : .left,
            .crownUp : .right
        ]
    ]

    func platformMapping(for romName: RomName) -> PlatformMapping? {
        return mapping[romName]
    }
}

extension WatchInputMappingService: PlatformInputMappingService {
    typealias PlatformInputCode = WatchInputCode

    func semanticInputCode(from romName: RomName, from platformInputCode: WatchInputCode) -> SemanticInputCode? {
        return platformMapping(for: romName)?[platformInputCode]
    }
}
