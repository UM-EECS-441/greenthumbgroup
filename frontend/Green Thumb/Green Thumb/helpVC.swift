//
//  helpVC.swift
//  Green Thumb
//
//  Created by Joe Riggs on 11/28/20.
//

import youtube_ios_player_helper
import UIKit

class helpVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        youtubePlayerView.load(withVideoId: "n636NPn6zUM")
    }
    @IBOutlet weak var youtubePlayerView: YTPlayerView!
}
