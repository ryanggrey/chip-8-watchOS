//
//  PlatformSupportedRomService.swift
//  CHIP8WatchOS WatchKit Extension
//
//  Created by Ryan Grey on 20/02/2021.
//

import Foundation
import Chip8Emulator

struct PlatformSupportedRomService {
    private let inputMappingService: WatchInputMappingService

    init(inputMappingService: WatchInputMappingService) {
        self.inputMappingService = inputMappingService
    }
    
    var supportedRoms: [RomName] {
        let allRoms = RomName.allCases
        let supportedRoms = allRoms.filter { rom in
            let hasMapping = inputMappingService.platformMapping(for: rom) != nil
            return hasMapping
        }
        return supportedRoms
    }
}
