//
//  MPVolumeView+Volume.swift
//  Music
//
//  Created by Rasmus Krämer on 07.09.23.
//

import Foundation
import MediaPlayer

#if !os(macOS)
extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}
#endif
