//
//  RomPlatformInput.swift
//  CHIP8WatchOS WatchKit Extension
//
//  Created by Ryan Grey on 19/02/2021.
//

import Foundation
import Chip8Emulator

struct WatchInputMappingService: PlatformInputMappingService {
    typealias PlatformInputCode = WatchInputCode

    func mapping(for romName: RomName) -> [WatchInputCode : SemanticInputCode] {
        switch romName {
        case .chip8:
            return [:]
        case .airplane:
            return [
                .screenTap : .primaryAction
            ]
        case .astroDodge:
            return [
                .screenTap : .primaryAction,
                .crownDown : .left,
                .crownUp : .right
            ]
        case .breakout:
            return [
                .crownDown : .left,
                .crownUp : .right
            ]
        case .filter :
            return [
                .crownDown : .left,
                .crownUp : .right
            ]
        case .landing :
            return [
                .screenTap : .primaryAction
            ]
        case .lunarLander :
            return [
                .screenTap : .primaryAction,
                .crownDown : .left,
                .crownUp : .right
            ]
        case .maze :
            return [:]
        case .missile :
            return [
                .screenTap : .primaryAction
            ]
        case .pong :
            return [
                .crownDown : .down,
                .crownUp : .up
            ]
        case .rocket :
            return [
                .screenTap : .primaryAction
            ]
        case .spaceInvaders :
            return [
                .screenTap : .primaryAction,
                .crownDown : .left,
                .crownUp : .right
            ]
        case .tetris :
            return [
                .screenLongPress : .secondaryAction,
                .screenTap : .primaryAction,
                .crownDown : .left,
                .crownUp : .right
            ]
        case .wipeOff :
            return [
                .crownDown : .left,
                .crownUp : .right
            ]
        }
    }

    func semanticInputCode(from romName: RomName, from platformInputCode: WatchInputCode) -> SemanticInputCode? {
        return mapping(for: romName)[platformInputCode]
    }
}
