import UIKit

import Saffron


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var sf2 = SoundFont()
        sf2.soundEngineName = "EMU8000"
        sf2.bankName = "Chipsound"
        sf2.soundROMName = "ROM"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

