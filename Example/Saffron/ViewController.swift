import UIKit

import Saffron


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let name = "RIFF"
        let fourCCName = name.toFourCC()
        let nameFromFourCC = String(fourCC: fourCCName)
        print("Name = '\(name)', converted back to string from FourCC = '\(nameFromFourCC)'")
        
        let version = SoundFontVersion(major: 2, minor: 1)
        let chunkData = ChunkData(maxSize: 4, initialValue: 0)
        
        
        let sf2 = SoundFont()
        sf2.soundEngineName = "EMU8000"
        sf2.bankName = "Chipsound"
        sf2.soundROMName = "ROM"
        
        print(sf2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

