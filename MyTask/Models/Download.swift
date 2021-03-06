//
//  Download.swift
//  MyTask
//
//  Created by Hassnain Khaliq on 23/11/2021.
//

import Foundation

class Download {
  
  var isDownloading = false
  var progress: Float = 0
  var resumeData: Data?
  var task: URLSessionDownloadTask?
  var track: Track
  
  init(track: Track) {
    self.track = track
  }
}
