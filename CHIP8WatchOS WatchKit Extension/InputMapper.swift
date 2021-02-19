//
//  InputMapper.swift
//  CHIP8WatchOS WatchKit Extension
//
//  Created by Ryan Grey on 19/02/2021.
//

import Foundation
import Chip8Emulator

struct InputMapper {
    static func map(
        platformInput: WatchInputCode,
        romName: RomName
        ) -> Chip8KeyCode? {
        guard let platformInputMapping = PlatformInputMappingService.mapping(for: romName),
              let semanticInputMapping =  SemanticInputMappingService.mapping(for: romName),
              let semanticInputCode = platformInputMapping[platformInput],
              let chip8KeyCode = semanticInputMapping[semanticInputCode]
        else { return nil }

        return chip8KeyCode
    }
}
